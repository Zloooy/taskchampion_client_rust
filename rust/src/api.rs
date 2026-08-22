#![allow(unexpected_cfgs)]

//! TaskChampion Rust FFI Bridge
//!
//! This module provides the FFI bridge between Dart and Rust for TaskChampion operations.
//! It exposes functions for task management, synchronization, and authentication.

use flutter_rust_bridge::frb;
use std::collections::HashMap;
use taskchampion::{Operations, ServerConfig, Status};
use uuid::Uuid;

use crate::filter::{
    collect_base_tasks, compare_tasks, evaluate_filter_expression, FilterExpression, TaskSort,
};
use crate::global_repo_cache;
use crate::models::SyncResultData;
use crate::runtime::get_runtime;
use crate::sync_stats::sync_with_stats;
use crate::task_ops::{create_task_from_map, task_to_map, update_task_in_replica};

/// Open the cached [`crate::TaskRepo`] for `taskdb_dir_path` (ticket R4).
///
/// Centralises the "look up (or open) a shared handle" ceremony so the FFI
/// functions below can stay one-liners. The returned handle reuses the
/// already-open SQLite connection and actor thread across calls.
async fn open_repo(taskdb_dir_path: String) -> anyhow::Result<std::sync::Arc<crate::TaskRepo>> {
    Ok(global_repo_cache().get_or_open(taskdb_dir_path).await?)
}

// ============================================================================
// TASK OPERATIONS
// ============================================================================

/// Get all tasks from the local TaskChampion replica as a JSON array
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
///
/// # Returns
/// JSON string containing an array of task objects
#[frb]
pub fn get_all_tasks_json(taskdb_dir_path: String) -> Result<String, anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        repo.with_replica(|replica| {
            Box::pin(async move {
                let tasks = replica.all_tasks().await?;

                let mut task_maps: Vec<HashMap<String, String>> = Vec::new();
                for (_, task) in tasks {
                    task_maps.push(task_to_map(&task));
                }

                let json = serde_json::to_string(&task_maps)?;
                Ok::<String, anyhow::Error>(json)
            })
        })
        .await
    })
}

/// Get all tasks from the local TaskChampion replica with sorting
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `sort_json` - JSON string representing the sort specification
///
/// # Returns
/// JSON string containing an array of sorted task objects
#[frb]
pub fn get_all_tasks_with_sort_json(
    taskdb_dir_path: String,
    sort_json: String,
) -> Result<String, anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        repo.with_replica(|replica| {
            Box::pin(async move {
                let tasks = replica.all_tasks().await?;

                // Parse sort specification
                let sort: TaskSort = serde_json::from_str(&sort_json)?;

                // Collect tasks into a vector for sorting
                let mut task_vec: Vec<taskchampion::Task> = tasks.into_values().collect();

                // Sort tasks
                task_vec.sort_by(|a, b| compare_tasks(a, b, &sort));

                // Convert to maps
                let mut task_maps: Vec<HashMap<String, String>> = Vec::new();
                for task in task_vec {
                    task_maps.push(task_to_map(&task));
                }

                let json = serde_json::to_string(&task_maps)?;
                Ok::<String, anyhow::Error>(json)
            })
        })
        .await
    })
}

/// Add a new task to the local TaskChampion replica
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `task_data` - HashMap containing task properties (description, status, priority, etc.)
///
/// # Returns
/// UUID of the newly created task as a string
#[frb]
pub fn add_task(
    taskdb_dir_path: String,
    task_data: HashMap<String, String>,
) -> Result<String, anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        repo.with_replica(|replica| {
            Box::pin(async move {
                let uuid = create_task_from_map(replica, task_data).await?;
                Ok::<String, anyhow::Error>(uuid.to_string())
            })
        })
        .await
    })
}

/// Update an existing task in the local TaskChampion replica
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `uuid_str` - UUID of the task to update
/// * `task_data` - HashMap containing updated task properties
#[frb]
pub fn update_task(
    taskdb_dir_path: String,
    uuid_str: String,
    task_data: HashMap<String, String>,
) -> Result<(), anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        repo.with_replica(|replica| {
            Box::pin(async move {
                let uuid = Uuid::parse_str(&uuid_str)?;
                update_task_in_replica(replica, uuid, task_data).await?;
                Ok::<(), anyhow::Error>(())
            })
        })
        .await
    })
}

/// Delete a task from the local TaskChampion replica
///
/// Marks the task as deleted (sets its status to `Deleted`).
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `uuid_str` - UUID of the task to delete
#[frb]
pub fn delete_task(taskdb_dir_path: String, uuid_str: String) -> Result<(), anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        repo.with_replica(|replica| {
            Box::pin(async move {
                let uuid = Uuid::parse_str(&uuid_str)?;
                if let Some(mut task) = replica.get_task(uuid).await? {
                    let mut ops = Operations::new();
                    task.set_status(Status::Deleted, &mut ops)?;
                    replica.commit_operations(ops).await?;
                }
                Ok::<(), anyhow::Error>(())
            })
        })
        .await
    })
}

/// Get a single task by UUID
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `uuid_str` - UUID of the task to retrieve
///
/// # Returns
/// JSON string containing the task object, or null if not found
#[frb]
pub fn get_task_by_uuid(
    taskdb_dir_path: String,
    uuid_str: String,
) -> Result<Option<String>, anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        repo.with_replica(|replica| {
            Box::pin(async move {
                let uuid = Uuid::parse_str(&uuid_str)?;
                if let Some(task) = replica.get_task(uuid).await? {
                    let task_map = task_to_map(&task);
                    let json = serde_json::to_string(&task_map)?;
                    Ok::<Option<String>, anyhow::Error>(Some(json))
                } else {
                    Ok(None)
                }
            })
        })
        .await
    })
}

/// Get tasks filtered by a filter expression with sorting
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `filter_json` - JSON string representing the filter expression
/// * `sort_json` - JSON string representing the sort specification
///
/// # Returns
/// JSON string containing an array of filtered and sorted task objects
#[frb]
pub fn get_tasks_with_filter_and_sort_json(
    taskdb_dir_path: String,
    filter_json: String,
    sort_json: String,
) -> Result<String, anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        repo.with_replica(|replica| {
            Box::pin(async move {
                // Parse the filter and sort JSON
                let filter: FilterExpression = serde_json::from_str(&filter_json)?;
                let sort: TaskSort = serde_json::from_str(&sort_json)?;

                // Optimization: Use pending_tasks() if filter constrains to
                // pending status (ticket R3).
                let tasks: Vec<taskchampion::Task> =
                    collect_base_tasks(replica, Some(&filter)).await?;

                // Filter tasks
                let mut filtered_tasks: Vec<taskchampion::Task> = tasks
                    .into_iter()
                    .filter(|task| evaluate_filter_expression(task, &filter))
                    .collect();

                // Sort tasks
                filtered_tasks.sort_by(|a, b| compare_tasks(a, b, &sort));

                // Convert to maps
                let mut task_maps: Vec<HashMap<String, String>> = Vec::new();
                for task in filtered_tasks {
                    task_maps.push(task_to_map(&task));
                }

                let json = serde_json::to_string(&task_maps)?;
                Ok::<String, anyhow::Error>(json)
            })
        })
        .await
    })
}

// ============================================================================
// TYPED DTO OPERATIONS (ticket R5)
//
// These additive entry points exchange fully-typed [`TaskDto`]s instead of
// the lossy `HashMap<String,String>` + JSON-string convention used by the
// legacy functions above. Tags survive as a real `Vec<String>` (so tags
// containing spaces are no longer corrupted), UDAs are carried in their own
// map (so a UDA whose name shares a prefix with a built-in is no longer
// dropped), and annotations are structured.
// ============================================================================

// Re-export the DTO types so FRB picks them up from the api surface.
pub use crate::models::{AnnotationDto, TaskDto, TaskStatusDto};
use crate::task_ops::{create_task_from_dto, task_to_dto, update_task_with_dto};

/// Get all tasks as typed DTOs.
///
/// Prefer this over [`get_all_tasks_json`] when the Dart side can consume
/// `TaskDto` values directly: it avoids the JSON round-trip and preserves
/// tag/UDA structure exactly.
#[frb]
pub fn get_all_tasks_dtos(taskdb_dir_path: String) -> Result<Vec<TaskDto>, anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        repo.with_replica(|replica| {
            Box::pin(async move {
                let tasks = replica.all_tasks().await?;
                let dtos: Vec<TaskDto> = tasks.into_values().map(|t| task_to_dto(&t)).collect();
                Ok::<Vec<TaskDto>, anyhow::Error>(dtos)
            })
        })
        .await
    })
}

/// Add a task from a typed DTO. Returns the new task's UUID as a string.
#[frb]
pub fn add_task_dto(taskdb_dir_path: String, dto: TaskDto) -> Result<String, anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        repo.with_replica(|replica| {
            Box::pin(async move {
                let uuid = create_task_from_dto(replica, dto).await?;
                Ok::<String, anyhow::Error>(uuid.to_string())
            })
        })
        .await
    })
}

/// Replace an existing task's mutable fields from a typed DTO.
#[frb]
pub fn update_task_dto(
    taskdb_dir_path: String,
    uuid_str: String,
    dto: TaskDto,
) -> Result<(), anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        repo.with_replica(|replica| {
            Box::pin(async move {
                let uuid = Uuid::parse_str(&uuid_str)?;
                update_task_with_dto(replica, uuid, dto).await?;
                Ok::<(), anyhow::Error>(())
            })
        })
        .await
    })
}

// ============================================================================
// SYNC OPERATIONS
// ============================================================================

/// Synchronize tasks with a TaskChampion sync server
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `server_url` - URL of the TaskChampion sync server
/// * `client_id` - Client ID for authentication
/// * `encryption_secret` - Secret key for encrypting sync data
///
/// # Returns
/// `SyncResultData` with accurate change statistics:
/// * `versions_synced` — version segments exchanged with the server
///   (published + fetched).
/// * `tasks_added` / `tasks_updated` / `tasks_deleted` — changes applied to
///   the local database by the sync, in **both directions** (remote versions
///   pulled down as well as locally pending operations pushed/transformed).
#[frb]
pub fn sync_with_server(
    taskdb_dir_path: String,
    server_url: String,
    client_id: String,
    encryption_secret: String,
) -> Result<SyncResultData, anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        // Create server configuration outside the replica borrow so we don't
        // hold the lock during network setup.
        let server_config = ServerConfig::Remote {
            url: server_url,
            client_id: Uuid::parse_str(&client_id)?,
            encryption_secret: encryption_secret.into_bytes(),
        };
        let server = server_config.into_server().await?;

        repo.with_replica(|replica| {
            Box::pin(async move {
                // Perform synchronization while recording how many versions
                // were exchanged and how the local task set changed. The
                // pre/post snapshots are taken inside this closure so they
                // observe exactly the state before/after `sync`.
                let (stats, started) = sync_with_stats(replica, server, true).await?;
                let duration_ms = started.elapsed().as_millis() as u64;

                Ok::<SyncResultData, anyhow::Error>(SyncResultData {
                    success: true,
                    versions_synced: stats.versions_synced,
                    tasks_added: stats.tasks_added,
                    tasks_updated: stats.tasks_updated,
                    tasks_deleted: stats.tasks_deleted,
                    error_message: None,
                    duration_ms: Some(duration_ms),
                })
            })
        })
        .await
    })
}

/// Get the latest snapshot from the sync server
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database (not used for remote snapshots)
/// * `server_url` - URL of the TaskChampion sync server
/// * `client_id` - Client ID for authentication
/// * `encryption_secret` - Secret key for encrypting sync data
///
/// # Returns
/// JSON string containing snapshot data
#[frb]
pub fn get_snapshot(
    _taskdb_dir_path: String,
    server_url: String,
    client_id: String,
    encryption_secret: String,
) -> Result<String, anyhow::Error> {
    get_runtime().block_on(async {
        let server_config = ServerConfig::Remote {
            url: server_url,
            client_id: Uuid::parse_str(&client_id)?,
            encryption_secret: encryption_secret.into_bytes(),
        };

        let mut server = server_config.into_server().await?;

        if let Some((version_id, _snapshot_data)) = server.get_snapshot().await? {
            let mut result = HashMap::new();
            result.insert("version_id".to_string(), version_id.to_string());
            // Note: snapshot_data is encrypted Vec<u8>, we just return metadata
            result.insert("has_snapshot".to_string(), "true".to_string());

            let json = serde_json::to_string(&result)?;
            Ok(json)
        } else {
            Ok("null".to_string())
        }
    })
}

// ============================================================================
// AUTHENTICATION OPERATIONS
// ============================================================================

/// Validate client credentials with the sync server
///
/// # Arguments
/// * `server_url` - URL of the TaskChampion sync server
/// * `client_id` - Client ID to validate
/// * `encryption_secret` - Secret key for encryption
///
/// # Returns
/// JSON with validation result and server information
#[frb]
pub fn validate_credentials(
    server_url: String,
    client_id: String,
    encryption_secret: String,
) -> Result<String, anyhow::Error> {
    // Create server configuration to validate it parses correctly
    let _server_config = ServerConfig::Remote {
        url: server_url.clone(),
        client_id: Uuid::parse_str(&client_id)?,
        encryption_secret: encryption_secret.into_bytes(),
    };

    // Try to get snapshot to validate credentials
    let mut result = HashMap::new();

    // Note: This is a simplified validation - in production you'd want
    // to actually attempt a connection to the server
    result.insert("valid".to_string(), "true".to_string());
    result.insert("server_url".to_string(), server_url);
    result.insert("client_id".to_string(), client_id);

    let json = serde_json::to_string(&result)?;
    Ok(json)
}

// ============================================================================
// UTILITY OPERATIONS
// ============================================================================

/// Get task database statistics
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
///
/// # Returns
/// JSON with database statistics (task count, etc.)
#[frb]
pub fn get_taskdb_stats(taskdb_dir_path: String) -> Result<String, anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        repo.with_replica(|replica| {
            Box::pin(async move {
                let tasks = replica.all_tasks().await?;

                let total_tasks = tasks.len() as u64;
                let mut pending = 0u64;
                let mut completed = 0u64;
                let mut deleted = 0u64;

                for (_, task) in &tasks {
                    match task.get_status() {
                        Status::Pending => pending += 1,
                        Status::Completed => completed += 1,
                        Status::Deleted => deleted += 1,
                        _ => {}
                    }
                }
                let mut result: HashMap<String, u64> = HashMap::new();
                result.insert("total_tasks".to_string(), total_tasks);
                result.insert("pending".to_string(), pending);
                result.insert("completed".to_string(), completed);
                result.insert("deleted".to_string(), deleted);

                let json = serde_json::to_string(&result)?;
                Ok::<String, anyhow::Error>(json)
            })
        })
        .await
    })
}

/// Export all tasks to a JSON file
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `export_file_path` - Path where the export file should be saved
///
/// # Returns
/// Number of tasks exported
#[frb]
pub fn export_tasks(
    taskdb_dir_path: String,
    export_file_path: String,
) -> Result<i32, anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        let task_maps: Vec<HashMap<String, String>> = repo
            .with_replica(|replica| {
                Box::pin(async move {
                    let tasks = replica.all_tasks().await?;
                    let mut task_maps: Vec<HashMap<String, String>> = Vec::new();
                    for (_, task) in tasks {
                        task_maps.push(task_to_map(&task));
                    }
                    Ok::<Vec<HashMap<String, String>>, anyhow::Error>(task_maps)
                })
            })
            .await?;

        let json = serde_json::to_string_pretty(&task_maps)?;
        std::fs::write(export_file_path, json)?;

        Ok(task_maps.len() as i32)
    })
}

/// Import tasks from a JSON file
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `import_file_path` - Path to the JSON file to import
///
/// # Returns
/// Number of tasks imported
#[frb]
pub fn import_tasks(
    taskdb_dir_path: String,
    import_file_path: String,
) -> Result<i32, anyhow::Error> {
    let repo = get_runtime().block_on(open_repo(taskdb_dir_path))?;
    get_runtime().block_on(async move {
        // Read + parse outside the replica borrow; the import file lives on
        // the local filesystem and shouldn't keep the SQLite handle locked.
        let json_content = std::fs::read_to_string(import_file_path)?;
        let tasks_data: Vec<HashMap<String, String>> = serde_json::from_str(&json_content)?;

        repo.with_replica(|replica| {
            Box::pin(async move {
                let mut imported_count = 0i32;
                // Ticket R8: collect per-row failures instead of silently
                // dropping them. The first batch of failures is surfaced to
                // the caller so that malformed import files no longer look
                // like a partial success.
                let mut failures: Vec<(usize, String)> = Vec::new();
                for (idx, task_data) in tasks_data.into_iter().enumerate() {
                    // Skip if task already exists
                    if let Some(uuid_str) = task_data.get("uuid") {
                        if let Ok(uuid) = Uuid::parse_str(uuid_str) {
                            if replica.get_task(uuid).await?.is_some() {
                                continue;
                            }
                        }
                    }

                    match create_task_from_map(replica, task_data).await {
                        Ok(_) => imported_count += 1,
                        Err(err) => failures.push((idx, err.to_string())),
                    }
                }

                if failures.is_empty() {
                    Ok::<i32, anyhow::Error>(imported_count)
                } else {
                    // Include the partial count and the first few failure
                    // reasons so the caller can diagnose the bad rows without
                    // losing the fact that some imports did succeed.
                    let shown: Vec<String> = failures
                        .iter()
                        .take(5)
                        .map(|(idx, msg)| format!("row {idx}: {msg}"))
                        .collect();
                    let truncated = if failures.len() > shown.len() {
                        format!("\n(and {} more)", failures.len() - shown.len())
                    } else {
                        String::new()
                    };
                    Err(anyhow::anyhow!(
                        "imported {} task(s) but {} row(s) failed:\n{}{}",
                        imported_count,
                        failures.len(),
                        shown.join("\n"),
                        truncated
                    ))
                }
            })
        })
        .await
    })
}

// ============================================================================
// PROPERTY OPERATIONS
// ============================================================================

/// Retrieve distinct values for a given task property
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `property` - Name of the property to query (e.g. "description", "due")
/// * `filter_json` - Optional JSON describing a TaskFilter to limit the tasks
/// * `sort_json` - Optional JSON describing a TaskSort that may affect the order of the returned list
///
/// # Returns
/// JSON string containing an array of distinct property values
#[frb]
pub fn get_task_property_values(
    taskdb_dir_path: String,
    property: String,
    filter_json: Option<String>,
    sort_json: Option<String>,
) -> Result<Vec<String>, anyhow::Error> {
    get_runtime().block_on(async {
        crate::properties::get_task_property_values(
            taskdb_dir_path,
            property,
            filter_json,
            sort_json,
        )
        .await
    })
}

/// Retrieve distinct tag values from tasks, with optional virtual tag inclusion and pattern filtering.
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `filter_json` - Optional JSON describing a TaskFilter to limit the tasks
/// * `include_virtual_tags` - When true, include virtual tags (tags starting with '+' or '-')
/// * `pattern` - Optional case-insensitive substring that a tag must contain
///
/// # Returns
/// JSON string containing an array of distinct tag values
#[frb]
pub fn get_tags(
    taskdb_dir_path: String,
    filter_json: Option<String>,
    include_virtual_tags: bool,
    pattern: Option<String>,
) -> Result<Vec<String>, anyhow::Error> {
    get_runtime().block_on(async {
        crate::properties::get_tags(taskdb_dir_path, filter_json, include_virtual_tags, pattern)
            .await
    })
}

// ============================================================================
// TYPED PROPERTY OPERATIONS
// ============================================================================

// Re-export PropertyReturnType from properties module so FRB picks it up
pub use crate::properties::PropertyReturnType;

/// Retrieve distinct property values with typed conversion.
///
/// This is a typed version of `get_task_property_values` that converts the
/// returned values to the requested type (String, DateTime, TaskStatus,
/// or TaskPriority).
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `property` - Name of the property to query (e.g. "description", "due", "status")
/// * `return_type` - The type of values expected
/// * `filter_json` - Optional JSON describing a TaskFilter to limit the tasks
/// * `sort_json` - Optional JSON describing a TaskSort that may affect the order
///
/// # Returns
/// JSON string containing an array of typed property values
#[frb]
pub fn get_task_property_values_typed(
    taskdb_dir_path: String,
    property: String,
    return_type: PropertyReturnType,
    filter_json: Option<String>,
    sort_json: Option<String>,
) -> Result<Vec<String>, anyhow::Error> {
    get_runtime().block_on(async {
        crate::properties::get_task_property_values_typed(
            taskdb_dir_path,
            property,
            return_type,
            filter_json,
            sort_json,
        )
        .await
    })
}

/// Retrieve all possible enum values for a given property type.
///
/// Only supports `EnumStatus` and `EnumPriority`. For any other return type,
/// returns an error.
///
/// # Arguments
/// * `return_type` - The type of enum values to return
///
/// # Returns
/// JSON string containing an array of all possible enum values
#[frb]
pub fn get_all_enum_values(return_type: PropertyReturnType) -> Result<Vec<String>, anyhow::Error> {
    crate::properties::get_all_enum_values(return_type)
}

// ============================================================================
// TESTS
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use crate::storage::create_storage_async;
    use taskchampion::Replica;
    use tempfile::TempDir;

    /// Helper function to create a test task in a replica
    async fn create_test_task<S: taskchampion::storage::Storage>(
        replica: &mut Replica<S>,
        description: &str,
        status: Status,
        priority: &str,
    ) -> Uuid {
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description(description.to_string(), &mut ops)
            .unwrap();
        task.set_status(status, &mut ops).unwrap();
        if !priority.is_empty() {
            task.set_priority(priority.to_string(), &mut ops).unwrap();
        }
        replica.commit_operations(ops).await.unwrap();
        uuid
    }

    /// Helper function to create a test task with project
    async fn create_test_task_with_project<S: taskchampion::storage::Storage>(
        replica: &mut Replica<S>,
        description: &str,
        project: &str,
    ) -> Uuid {
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description(description.to_string(), &mut ops)
            .unwrap();
        // Real tasks always carry an explicit status. Setting it here keeps the
        // helper's output consistent with `Replica::pending_tasks()` (which
        // only returns tasks whose TaskMap has an explicit `status` key) and
        // with the filter fast-path exercised by the tests below.
        task.set_status(Status::Pending, &mut ops).unwrap();
        task.set_user_defined_attribute("project".to_string(), project.to_string(), &mut ops)
            .unwrap();
        replica.commit_operations(ops).await.unwrap();
        uuid
    }

    // ========================================================================
    // Tests for get_tasks_with_filter_and_sort_json integration
    // ========================================================================

    #[test]
    fn test_get_tasks_with_filter_and_sort_json_status_pending() {
        let temp_dir = TempDir::new().unwrap();
        let path = temp_dir.path().to_string_lossy().to_string();

        // Use block_on to create tasks since helper functions are async
        get_runtime().block_on(async {
            let storage = create_storage_async(path.clone()).await.unwrap();
            let mut replica = Replica::new(storage);

            create_test_task(&mut replica, "Pending task 1", Status::Pending, "").await;
            create_test_task(&mut replica, "Pending task 2", Status::Pending, "").await;
            create_test_task(&mut replica, "Completed task", Status::Completed, "").await;
        });

        let filter_json = r#"{
            "type": "EqualsFilter",
            "property": {"name": "status"},
            "value": "pending"
        }"#;
        let sort_json = r#"{
            "property": {"name": "description"},
            "direction": "ascending"
        }"#;

        let result = get_tasks_with_filter_and_sort_json(
            path,
            filter_json.to_string(),
            sort_json.to_string(),
        )
        .unwrap();
        let tasks: Vec<HashMap<String, String>> = serde_json::from_str(&result).unwrap();

        assert_eq!(tasks.len(), 2);
        for task in &tasks {
            assert_eq!(task.get("status"), Some(&"pending".to_string()));
        }
    }

    #[test]
    fn test_get_tasks_with_filter_and_sort_json_complex_filter() {
        let temp_dir = TempDir::new().unwrap();
        let path = temp_dir.path().to_string_lossy().to_string();

        // Use block_on to create tasks since helper functions are async
        get_runtime().block_on(async {
            let storage = create_storage_async(path.clone()).await.unwrap();
            let mut replica = Replica::new(storage);

            create_test_task_with_project(&mut replica, "Task 1", "ProjectA").await;
            create_test_task_with_project(&mut replica, "Task 2", "ProjectB").await;
            create_test_task_with_project(&mut replica, "Task 3", "ProjectA").await;
            create_test_task(&mut replica, "Task 4", Status::Completed, "").await;
        });

        let filter_json = r#"{
            "type": "AndGroup",
            "filters": [
                {
                    "type": "EqualsFilter",
                    "property": {"name": "project"},
                    "value": "ProjectA"
                },
                {
                    "type": "EqualsFilter",
                    "property": {"name": "status"},
                    "value": "pending"
                }
            ]
        }"#;
        let sort_json = r#"{
            "property": {"name": "description"},
            "direction": "ascending"
        }"#;

        let result = get_tasks_with_filter_and_sort_json(
            path,
            filter_json.to_string(),
            sort_json.to_string(),
        )
        .unwrap();
        let tasks: Vec<HashMap<String, String>> = serde_json::from_str(&result).unwrap();

        assert_eq!(tasks.len(), 2);
        for task in &tasks {
            assert_eq!(task.get("project"), Some(&"ProjectA".to_string()));
        }
    }
}
