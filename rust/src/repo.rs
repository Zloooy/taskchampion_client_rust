//! `TaskRepo` — a reusable session over an opened TaskChampion SQLite store.
//!
//! Every FFI entry point used to repeat the same four-step ceremony:
//!
//! ```text
//! let storage = create_storage_async(path).await?;
//! let mut replica = Replica::new(storage);
//! // …one operation…
//! // (implicit) drop replica, drop storage
//! ```
//!
//! That re-opens the SQLite database on every call. Worse, `SqliteStorage`
//! runs the actual `rusqlite::Connection` on a dedicated actor thread, so each
//! call also spawns a fresh OS thread. Ticket R4 introduces [`TaskRepo`]: a
//! session object that owns a long-lived [`Replica`] over a single
//! `SqliteStorage` and lends out short-lived `&mut Replica` borrows via
//! [`TaskRepo::with_replica`].
//!
//! Because `Replica` is `Send` but **not** `Sync` (it carries interior
//! mutability for its working-set cache, and `Storage::txn` needs `&mut
//! self`), the borrow is serialised through a `tokio::sync::Mutex`. That
//! matches SQLite's own serialisation model and lets the working-set cache
//! stay warm.
//!
//! An optional process-wide cache ([`RepoCache`]) maps a database path to a
//! shared `Arc<TaskRepo>` so the Dart side can pass the same path repeatedly
//! without re-opening the database or respawning the actor thread.

use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::{Arc, Mutex, OnceLock};

use taskchampion::storage::AccessMode;
use taskchampion::{Replica, SqliteStorage, Task};
use tokio::sync::Mutex as AsyncMutex;

use crate::error::{TcError, TcResult};

/// A reusable session over a TaskChampion SQLite database.
///
/// Owns a single [`Replica`] over a [`SqliteStorage`] and lends out
/// `&mut Replica` borrows via [`with_replica`](Self::with_replica). The
/// replica is guarded by a `tokio::sync::Mutex` so concurrent callers queue
/// rather than race (matching SQLite's serialised write model).
pub struct TaskRepo {
    replica: AsyncMutex<Replica<SqliteStorage>>,
}

impl TaskRepo {
    /// Open a read/write TaskChampion database at `taskdb_dir`.
    ///
    /// Mirrors the flags historically used by
    /// [`crate::storage::create_storage_async`] (`AccessMode::ReadWrite` with
    /// `create_if_missing = true`).
    pub async fn open(taskdb_dir: impl Into<PathBuf>) -> TcResult<Self> {
        let storage = SqliteStorage::new(taskdb_dir.into(), AccessMode::ReadWrite, true)
            .await
            .map_err(TcError::from)?;
        Ok(Self {
            replica: AsyncMutex::new(Replica::new(storage)),
        })
    }

    /// Run `f` against the repo's [`Replica`], returning whatever `f`'s
    /// future resolves to.
    ///
    /// The mutex guard is held for the duration of `f`, so concurrent
    /// `with_replica` calls on the same repo serialise. This replaces the
    /// per-FFI-call open-storage-then-drop ceremony of the old code.
    ///
    /// `f` receives a borrowed `&mut Replica` and returns a pinned, boxed
    /// future borrowing that `&mut Replica`. This HRTB shape is the idiomatic
    /// workaround until native async closures stabilise; callers wrap their
    /// body with `Box::pin(async move { ... })`.
    ///
    /// # Example
    /// ```ignore
    /// let repo = TaskRepo::open(path).await?;
    /// let count = repo.with_replica(|replica| Box::pin(async move {
    ///     replica.all_tasks().await.map(|t| t.len())
    /// })).await;
    /// ```
    pub async fn with_replica<F, R>(&self, f: F) -> R
    where
        F: for<'a> FnOnce(
            &'a mut Replica<SqliteStorage>,
        ) -> std::pin::Pin<Box<dyn std::future::Future<Output = R> + 'a>>,
    {
        let mut replica = self.replica.lock().await;
        f(&mut replica).await
    }
}

impl std::fmt::Debug for TaskRepo {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("TaskRepo").finish_non_exhaustive()
    }
}

// ============================================================================
// Process-wide path → handle cache
// ============================================================================

/// Process-wide cache of opened [`TaskRepo`] handles, keyed by the canonical
/// database directory path.
///
/// Use [`RepoCache::get_or_open`] to obtain a shared handle; subsequent calls
/// with the same path reuse the already-opened storage and actor thread. This
/// is the moral equivalent of a connection pool for SQLite.
///
/// The map is guarded by a plain `std::sync::Mutex`: the lock is only held
/// briefly to read/insert an `Arc` (never across an `.await`), and the actual
/// database work happens outside the lock.
pub struct RepoCache {
    map: Mutex<HashMap<PathBuf, Arc<TaskRepo>>>,
}

static GLOBAL_REPO_CACHE: OnceLock<RepoCache> = OnceLock::new();

/// Returns the process-wide [`RepoCache`].
pub fn global_repo_cache() -> &'static RepoCache {
    GLOBAL_REPO_CACHE.get_or_init(|| RepoCache {
        map: Mutex::new(HashMap::new()),
    })
}

impl RepoCache {
    /// Create an empty, independent cache.
    ///
    /// Most callers should use [`global_repo_cache`]; this constructor exists
    /// for tests and embedders that want an isolated cache (the global cache
    /// is shared across all tests, so tests using it must not run in parallel).
    pub fn new() -> Self {
        Self {
            map: Mutex::new(HashMap::new()),
        }
    }

    /// Returns a shared handle for `taskdb_dir`, opening it on first use.
    ///
    /// The expensive async `open` happens outside the map lock, so a cache
    /// hit never blocks on I/O. Two concurrent callers for a brand-new path
    /// may both open it; the loser's handle is silently dropped. This is
    /// acceptable and rare.
    pub async fn get_or_open(&self, taskdb_dir: impl Into<PathBuf>) -> TcResult<Arc<TaskRepo>> {
        let path: PathBuf = taskdb_dir.into();

        // Fast path: lock just long enough to clone an existing Arc.
        if let Some(handle) = self.map.lock().ok().and_then(|m| m.get(&path).cloned()) {
            return Ok(handle);
        }

        // Slow path: open (potentially racy) then insert if still absent.
        let repo = Arc::new(TaskRepo::open(path.clone()).await?);
        if let Ok(mut map) = self.map.lock() {
            map.entry(path).or_insert(Arc::clone(&repo));
        }
        Ok(repo)
    }

    /// Returns the number of currently-cached handles (diagnostic / test use).
    pub fn len(&self) -> usize {
        self.map.lock().map(|m| m.len()).unwrap_or(0)
    }

    /// Returns `true` when no handles are cached.
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }

    /// Drop all cached handles. Mainly useful for tests.
    pub fn clear(&self) {
        if let Ok(mut map) = self.map.lock() {
            map.clear();
        }
    }
}

impl Default for RepoCache {
    fn default() -> Self {
        Self::new()
    }
}

impl std::fmt::Debug for RepoCache {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let len = self.len();
        f.debug_struct("RepoCache").field("len", &len).finish()
    }
}

/// Convenience: load all tasks via a cached [`TaskRepo`] handle.
///
/// Demonstrates the intended usage of the cache and is reused by the unit
/// tests below.
pub async fn all_tasks_via_cache(taskdb_dir: impl Into<PathBuf>) -> TcResult<Vec<Task>> {
    let repo = global_repo_cache().get_or_open(taskdb_dir).await?;
    repo.with_replica(|replica| Box::pin(async move { replica.all_tasks().await }))
        .await
        .map_err(TcError::from)
        .map(|tasks| tasks.into_values().collect())
}

// ============================================================================
// Tests
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use taskchampion::{Operations, Status};
    use uuid::Uuid;

    async fn seed_one_task(repo: &TaskRepo, description: &str) -> Uuid {
        let description = description.to_string();
        repo.with_replica(|replica| {
            Box::pin(async move {
                let uuid = Uuid::new_v4();
                let mut ops = Operations::new();
                let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
                task.set_description(description, &mut ops).unwrap();
                task.set_status(Status::Pending, &mut ops).unwrap();
                replica.commit_operations(ops).await.unwrap();
                uuid
            })
        })
        .await
    }

    #[tokio::test]
    async fn repo_opens_and_runs_with_replica() {
        let td = tempfile::TempDir::new().unwrap();
        let repo = TaskRepo::open(td.path()).await.unwrap();
        let uuid = seed_one_task(&repo, "hello").await;

        let tasks: Vec<Task> = repo
            .with_replica(|replica| Box::pin(async move { replica.all_tasks().await }))
            .await
            .unwrap()
            .into_values()
            .collect();
        assert_eq!(tasks.len(), 1);
        assert_eq!(tasks[0].get_uuid(), uuid);
        assert_eq!(tasks[0].get_description(), "hello");
    }

    #[tokio::test]
    async fn repo_can_be_shared_across_calls() {
        let td = tempfile::TempDir::new().unwrap();
        let repo = Arc::new(TaskRepo::open(td.path()).await.unwrap());

        // Two independent `with_replica` calls against the same handle.
        seed_one_task(&repo, "first").await;
        seed_one_task(&repo, "second").await;

        let count = repo
            .with_replica(|replica| {
                Box::pin(async move { replica.all_tasks().await.unwrap().len() })
            })
            .await;
        assert_eq!(count, 2);
    }

    #[tokio::test]
    async fn repo_cache_reuses_handle_for_same_path() {
        let cache = RepoCache::new();
        let td = tempfile::TempDir::new().unwrap();
        let path = td.path().to_path_buf();

        let h1 = cache.get_or_open(path.clone()).await.unwrap();
        let h2 = cache.get_or_open(path.clone()).await.unwrap();
        assert!(Arc::ptr_eq(&h1, &h2), "expected the same Arc handle");
        assert_eq!(cache.len(), 1);
    }

    #[tokio::test]
    async fn repo_cache_distinguishes_different_paths() {
        let cache = RepoCache::new();
        let td1 = tempfile::TempDir::new().unwrap();
        let td2 = tempfile::TempDir::new().unwrap();

        let h1 = cache.get_or_open(td1.path()).await.unwrap();
        let h2 = cache.get_or_open(td2.path()).await.unwrap();
        assert!(!Arc::ptr_eq(&h1, &h2));
        assert_eq!(cache.len(), 2);
    }

    #[tokio::test]
    async fn all_tasks_via_cache_returns_seeded_tasks() {
        // Use the global cache here since `all_tasks_via_cache` does; isolate
        // it by clearing first and last.
        global_repo_cache().clear();
        let td = tempfile::TempDir::new().unwrap();
        let repo = TaskRepo::open(td.path()).await.unwrap();
        seed_one_task(&repo, "cached").await;
        drop(repo);

        let tasks = all_tasks_via_cache(td.path()).await.unwrap();
        assert_eq!(tasks.len(), 1);
        global_repo_cache().clear();
    }
}
