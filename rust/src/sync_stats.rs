//! Sync statistics: compute added/updated/deleted task counts and the number
//! of versions processed by a [`taskchampion::Replica::sync`] call.
//!
//! The `taskchampion` crate's sync API (`Replica::sync`) returns no change
//! information, so this module derives the statistics itself:
//!
//! * **Task counters** — the replica state is snapshotted before and after the
//!   sync (via [`Replica::all_task_data`]) and the snapshots are diffed. This
//!   covers changes applied to the local database from *both* directions:
//!   remote versions pulled down from the server as well as locally pending
//!   operations that were pushed (and possibly transformed) during the sync.
//!
//! * **Version counter** — the sync protocol is wrapped in
//!   [`CountingServer`], a thin [`Server`](taskchampion::server::Server)
//!   decorator that counts every version segment exchanged with the server
//!   (versions published by this client plus versions fetched from the
//!   server).
//!
//! # Semantics of the counters (contract for the Dart side)
//!
//! * `tasks_added`     — tasks present after the sync but absent before it.
//! * `tasks_updated`   — tasks present in both states whose property map
//!   (excluding the volatile `modified` timestamp) changed.
//! * `tasks_deleted`   — tasks present before the sync but purged from the
//!   local database by the sync. Note that marking a task's status as
//!   `"deleted"` is an *update*, not a deletion; only physical removals
//!   (e.g. purges propagated over the wire) count.
//! * `versions_synced` — number of history-segment versions exchanged with
//!   the server during the sync (published + fetched), i.e. "versions
//!   processed".

use std::cell::Cell;
use std::collections::HashMap;
use std::time::Instant;

use taskchampion::{server::Server, Error as TcError, Replica, TaskData};
use uuid::Uuid;

/// Statistics about the changes a single sync applied to the local replica.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct SyncStats {
    /// Tasks created in the local database by the sync.
    pub tasks_added: u64,
    /// Existing tasks whose data changed as a result of the sync.
    pub tasks_updated: u64,
    /// Tasks physically removed from the local database by the sync.
    pub tasks_deleted: u64,
    /// Number of version segments exchanged with the server during the sync.
    pub versions_synced: u64,
}

impl SyncStats {
    /// Fill in the task counters by diffing the pre/post-sync snapshots.
    pub fn compute_task_diff(
        &mut self,
        before: &HashMap<Uuid, TaskData>,
        after: &HashMap<Uuid, TaskData>,
    ) {
        for (uuid, after_data) in after {
            match before.get(uuid) {
                None => self.tasks_added += 1,
                Some(before_data) => {
                    if !tasks_equal_ignoring_modified(before_data, after_data) {
                        self.tasks_updated += 1;
                    }
                }
            }
        }
        for uuid in before.keys() {
            if !after.contains_key(uuid) {
                self.tasks_deleted += 1;
            }
        }
    }
}

/// Collect every property of a [`TaskData`] except the volatile `modified`
/// timestamp, which is touched on nearly every write and would otherwise make
/// every synced task look changed.
fn props_ignoring_modified(data: &TaskData) -> HashMap<String, String> {
    data.iter()
        .filter(|(k, _)| k.as_str() != "modified")
        .map(|(k, v)| (k.clone(), v.clone()))
        .collect()
}

/// Compare two tasks' properties, ignoring the `modified` key.
fn tasks_equal_ignoring_modified(a: &TaskData, b: &TaskData) -> bool {
    props_ignoring_modified(a) == props_ignoring_modified(b)
}

/// A [`Server`](taskchampion::server::Server) decorator that counts the
/// version segments flowing through it.
///
/// Every accepted `add_version` corresponds to one version *published* by
/// this client and every successful `get_child_version` to one version
/// *fetched* from the server. Together they are the versions "processed" by
/// the sync.
///
/// The counter lives in a [`Cell`] so that [`sync_with_stats`] can read it
/// back after the sync without downcasting a `Box<dyn Server>` (which does
/// not implement `Any`).
pub struct CountingServer {
    inner: Box<dyn Server>,
    versions: Cell<u64>,
}

impl CountingServer {
    pub fn new(inner: Box<dyn Server>) -> Self {
        Self {
            inner,
            versions: Cell::new(0),
        }
    }

    /// Number of version segments exchanged so far.
    pub fn versions(&self) -> u64 {
        self.versions.get()
    }
}

#[async_trait::async_trait(?Send)]
impl Server for CountingServer {
    async fn add_version(
        &mut self,
        parent_version_id: taskchampion::server::VersionId,
        history_segment: taskchampion::server::HistorySegment,
    ) -> Result<
        (
            taskchampion::server::AddVersionResult,
            taskchampion::server::SnapshotUrgency,
        ),
        TcError,
    > {
        let result = self
            .inner
            .add_version(parent_version_id, history_segment)
            .await?;
        // Only count the version once the server has accepted it.
        if matches!(result.0, taskchampion::server::AddVersionResult::Ok(_)) {
            self.versions.set(self.versions.get() + 1);
        }
        Ok(result)
    }

    async fn get_child_version(
        &mut self,
        parent_version_id: taskchampion::server::VersionId,
    ) -> Result<taskchampion::server::GetVersionResult, TcError> {
        let result = self.inner.get_child_version(parent_version_id).await?;
        if matches!(
            result,
            taskchampion::server::GetVersionResult::Version { .. }
        ) {
            self.versions.set(self.versions.get() + 1);
        }
        Ok(result)
    }

    async fn add_snapshot(
        &mut self,
        version_id: taskchampion::server::VersionId,
        snapshot: taskchampion::server::Snapshot,
    ) -> Result<(), TcError> {
        self.inner.add_snapshot(version_id, snapshot).await
    }

    async fn get_snapshot(
        &mut self,
    ) -> Result<
        Option<(
            taskchampion::server::VersionId,
            taskchampion::server::Snapshot,
        )>,
        TcError,
    > {
        self.inner.get_snapshot().await
    }
}

/// Snapshot of every task's raw property data.
type TaskSnapshot = HashMap<Uuid, TaskData>;

async fn snapshot_of<S: taskchampion::storage::Storage>(
    replica: &mut Replica<S>,
) -> Result<TaskSnapshot, TcError> {
    replica.all_task_data().await
}

/// Run `replica.sync(server, avoid_snapshots)` while recording statistics.
///
/// Returns the stats together with the moment the sync started (so callers can
/// compute a wall-clock duration). On failure the error is propagated; the
/// partial stats gathered up to that point are discarded because the local
/// state may be mid-transaction at that point.
pub async fn sync_with_stats<S: taskchampion::storage::Storage + Send>(
    replica: &mut Replica<S>,
    server: Box<dyn Server>,
    avoid_snapshots: bool,
) -> Result<(SyncStats, Instant), TcError> {
    let started = Instant::now();
    let before = snapshot_of(replica).await?;

    // Box the wrapper and keep a raw pointer to its payload so we can read
    // the counter back after `replica.sync` (which only accepts
    // `&mut Box<dyn Server>` and does not allow downcasting).
    let counting: Box<CountingServer> = Box::new(CountingServer::new(server));
    let counting_ptr: *const CountingServer = &*counting;
    let mut server_box: Box<dyn Server> = counting;

    replica.sync(&mut server_box, avoid_snapshots).await?;
    let after = snapshot_of(replica).await?;

    // The `Cell<u64>` payload is still alive inside `server_box`; reading it
    // through the raw pointer is sound because sync hands us no aliasing
    // access to that memory.
    let versions = unsafe { (*counting_ptr).versions() };

    let mut stats = SyncStats::default();
    stats.compute_task_diff(&before, &after);
    stats.versions_synced = versions;

    Ok((stats, started))
}

// ============================================================================
// Tests
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use taskchampion::{Operations, Status};
    use tempfile::TempDir;

    /// Build a history segment containing a single JSON-encoded
    /// create+describe operation pair for `uuid`.
    ///
    /// NOTE: the production sync protocol in `taskchampion` 3.x does NOT
    /// compress history segments (they are plain UTF-8 JSON documents of shape
    /// `{"operations": [...]}`); this helper exists only to document the
    /// decoding assumptions exercised by
    /// [`history_segment_decoding_is_plain_json`].
    fn make_create_segment(uuid: Uuid) -> Vec<u8> {
        serde_json::to_vec(&serde_json::json!({
            "operations": [
                {"Create": {"uuid": uuid.to_string()}},
                {"Update": {
                    "uuid": uuid.to_string(),
                    "property": "description",
                    "value": "remote task",
                    "timestamp": "2026-01-01T00:00:00Z"
                }}
            ]
        }))
        .unwrap()
    }

    /// A fake in-process server holding a queue of versions to serve, plus a
    /// catch-all `add_version` acceptor.
    struct FakeServer {
        queue: Vec<(Uuid, Vec<u8>)>,
    }

    impl FakeServer {
        fn new(versions: Vec<(Uuid, Vec<u8>)>) -> Self {
            Self { queue: versions }
        }
    }

    #[async_trait::async_trait(?Send)]
    impl Server for FakeServer {
        async fn add_version(
            &mut self,
            _parent_version_id: Uuid,
            _history_segment: Vec<u8>,
        ) -> Result<
            (
                taskchampion::server::AddVersionResult,
                taskchampion::server::SnapshotUrgency,
            ),
            TcError,
        > {
            Ok((
                taskchampion::server::AddVersionResult::Ok(Uuid::new_v4()),
                taskchampion::server::SnapshotUrgency::None,
            ))
        }

        async fn get_child_version(
            &mut self,
            parent_version_id: Uuid,
        ) -> Result<taskchampion::server::GetVersionResult, TcError> {
            match self.queue.first().cloned() {
                Some((version_id, segment)) => {
                    self.queue.remove(0);
                    Ok(taskchampion::server::GetVersionResult::Version {
                        version_id,
                        parent_version_id,
                        history_segment: segment,
                    })
                }
                None => Ok(taskchampion::server::GetVersionResult::NoSuchVersion),
            }
        }

        async fn add_snapshot(
            &mut self,
            _version_id: Uuid,
            _snapshot: Vec<u8>,
        ) -> Result<(), TcError> {
            Ok(())
        }

        async fn get_snapshot(&mut self) -> Result<Option<(Uuid, Vec<u8>)>, TcError> {
            Ok(None)
        }
    }

    /// Drive `sync_with_stats` against a real SQLite replica + a fake server
    /// that pushes one brand-new remote task. Asserts the returned stats.
    async fn run_fetch_scenario(extra_local_ops: bool) -> (SyncStats, Uuid) {
        let td = TempDir::new().unwrap();
        let db_dir = td.path().join("db");
        let storage = taskchampion::SqliteStorage::new(
            db_dir,
            taskchampion::storage::AccessMode::ReadWrite,
            true,
        )
        .await
        .unwrap();
        let mut replica = Replica::new(storage);

        // Optionally seed a local pending change first (upload direction).
        if extra_local_ops {
            let mut ops = Operations::new();
            let local_uuid = Uuid::new_v4();
            let mut task = replica.create_task(local_uuid, &mut ops).await.unwrap();
            task.set_description("local task".to_string(), &mut ops)
                .unwrap();
            task.set_status(Status::Pending, &mut ops).unwrap();
            replica.commit_operations(ops).await.unwrap();
        }

        let remote_uuid = Uuid::new_v4();
        let segment = make_create_segment(remote_uuid);
        let server = Box::new(FakeServer::new(vec![(Uuid::new_v4(), segment)]));
        let (stats, _start) = sync_with_stats(&mut replica, server, false)
            .await
            .expect("sync should succeed");

        // Sanity: the remote task really made it into the local database.
        let fetched = replica
            .get_task(remote_uuid)
            .await
            .unwrap()
            .expect("remote task must exist locally after sync");
        assert_eq!(fetched.get_description(), "remote task");

        (stats, remote_uuid)
    }

    #[tokio::test]
    async fn fetch_new_remote_task_reports_added_and_versions() {
        let (stats, _) = run_fetch_scenario(false).await;
        assert_eq!(
            stats.tasks_added, 1,
            "the fetched task must be counted as added"
        );
        assert_eq!(stats.tasks_updated, 0);
        assert_eq!(stats.tasks_deleted, 0);
        // At least the fetched version passes through the server wrapper.
        assert!(
            stats.versions_synced >= 1,
            "expected at least one version processed, got {}",
            stats.versions_synced
        );
    }

    #[tokio::test]
    async fn local_change_plus_remote_fetch_reported_in_both_directions() {
        let (stats, _) = run_fetch_scenario(true).await;
        // The local task existed before the sync and the remote segment does
        // not touch it, so only the remote task is an addition.
        assert_eq!(stats.tasks_added, 1);
        assert!(stats.versions_synced >= 1);
    }

    /// Build a [`TaskData`] fixture from raw property pairs.
    fn make_task(uuid: Uuid, props: &[(&str, &str)]) -> TaskData {
        let mut ops = Operations::new();
        let mut data = TaskData::create(uuid, &mut ops);
        for (key, value) in props {
            data.update(*key, Some((*value).to_string()), &mut ops);
        }
        data
    }

    #[test]
    fn task_diff_counts_add_update_delete() {
        let mut stats = SyncStats::default();
        let old_task = Uuid::new_v4();
        let new_task = Uuid::new_v4();
        let gone_task = Uuid::new_v4();

        let mut before = HashMap::new();
        before.insert(
            old_task,
            make_task(
                old_task,
                &[("description", "old description"), ("status", "pending")],
            ),
        );
        before.insert(gone_task, make_task(gone_task, &[("description", "bye")]));

        let mut after = before.clone();
        // Modify the surviving task in a meaningful way.
        after.insert(
            old_task,
            make_task(
                old_task,
                &[("description", "new description"), ("status", "pending")],
            ),
        );
        // Add a brand-new task.
        after.insert(
            new_task,
            make_task(new_task, &[("description", "brand new")]),
        );
        // Purge one task.
        after.remove(&gone_task);

        stats.compute_task_diff(&before, &after);
        assert_eq!(stats.tasks_added, 1);
        assert_eq!(stats.tasks_updated, 1);
        assert_eq!(stats.tasks_deleted, 1);
    }

    #[test]
    fn modified_timestamp_alone_does_not_count_as_update() {
        let mut stats = SyncStats::default();
        let task = Uuid::new_v4();

        let mut before = HashMap::new();
        before.insert(
            task,
            make_task(task, &[("description", "same"), ("modified", "1700000000")]),
        );

        let mut after = before.clone();
        after.insert(
            task,
            make_task(task, &[("description", "same"), ("modified", "1700000999")]),
        );

        stats.compute_task_diff(&before, &after);
        assert_eq!(stats.tasks_updated, 0, "only 'modified' changed");
        assert_eq!(stats.tasks_added, 0);
        assert_eq!(stats.tasks_deleted, 0);
    }

    /// Document the wire format assumption used when decoding remote history
    /// segments: plain JSON of shape `{"operations": [...]}`.
    #[test]
    fn history_segment_decoding_is_plain_json() {
        let uuid = Uuid::new_v4();
        let seg = make_create_segment(uuid);
        let parsed: serde_json::Value =
            serde_json::from_slice(&seg).expect("segment must be valid JSON");
        let ops = parsed
            .get("operations")
            .and_then(|o| o.as_array())
            .expect("segment must carry an operations array");
        assert_eq!(ops.len(), 2);
        assert!(ops[0].get("Create").is_some());
        assert!(ops[1].get("Update").is_some());
    }
}
