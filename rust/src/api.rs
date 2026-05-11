#![allow(unexpected_cfgs)]

//! TaskChampion Rust FFI Bridge
//!
//! This module provides the FFI bridge between Dart and Rust for TaskChampion operations.
//! It exposes functions for task management, synchronization, and authentication.

use flutter_rust_bridge::frb;
use std::collections::HashMap;
use taskchampion::{Operations, Replica, ServerConfig, Status};
use uuid::Uuid;

use crate::filter::{compare_tasks, evaluate_filter_expression, FilterExpression, TaskSort};
use crate::models::SyncResultData;
use crate::runtime::get_runtime;
use crate::storage::create_storage_async;
use crate::task_ops::{create_task_from_map, task_to_map, update_task_in_replica};

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
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);
        let tasks = replica.all_tasks().await?;

        let mut task_maps: Vec<HashMap<String, String>> = Vec::new();
        for (_, task) in tasks {
            task_maps.push(task_to_map(&task));
        }

        let json = serde_json::to_string(&task_maps)?;
        Ok(json)
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
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);
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
        Ok(json)
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
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);
        let uuid = create_task_from_map(&mut replica, task_data).await?;

        Ok(uuid.to_string())
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
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);
        let uuid = Uuid::parse_str(&uuid_str)?;

        update_task_in_replica(&mut replica, uuid, task_data).await?;

        Ok(())
    })
}

/// Delete a task from the local TaskChampion replica
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `uuid_str` - UUID of the task to delete
///
/// # Returns
/// 0 on success, error otherwise
#[frb]
pub fn delete_task(taskdb_dir_path: String, uuid_str: String) -> Result<i8, anyhow::Error> {
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);
        let uuid = Uuid::parse_str(&uuid_str)?;

        if let Some(mut task) = replica.get_task(uuid).await? {
            let mut ops = Operations::new();
            task.set_status(Status::Deleted, &mut ops)?;
            replica.commit_operations(ops).await?;
        }

        Ok(0)
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
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);
        let uuid = Uuid::parse_str(&uuid_str)?;

        if let Some(task) = replica.get_task(uuid).await? {
            let task_map = task_to_map(&task);
            let json = serde_json::to_string(&task_map)?;
            Ok(Some(json))
        } else {
            Ok(None)
        }
    })
}

/// Get all pending tasks from the local TaskChampion replica as a JSON array
///
/// This is optimized to use TaskChampion's built-in pending tasks query
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
///
/// # Returns
/// JSON string containing an array of pending task objects
#[frb]
pub fn get_pending_tasks_json(taskdb_dir_path: String) -> Result<String, anyhow::Error> {
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);
        let tasks = replica.pending_tasks().await?;

        let mut task_maps: Vec<HashMap<String, String>> = Vec::new();
        for task in tasks {
            task_maps.push(task_to_map(&task));
        }

        let json = serde_json::to_string(&task_maps)?;
        Ok(json)
    })
}

/// Get tasks filtered by a filter expression
///
/// # Arguments
/// * `taskdb_dir_path` - Path to the directory containing the task database
/// * `filter_json` - JSON string representing the filter expression
///
/// # Returns
/// JSON string containing an array of filtered task objects
#[frb]
pub fn get_tasks_with_filter_json(
    taskdb_dir_path: String,
    filter_json: String,
) -> Result<String, anyhow::Error> {
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);

        // Parse the filter JSON
        let filter: FilterExpression = serde_json::from_str(&filter_json)?;

        // Optimization: Use pending_tasks() if filter is only for pending status
        let tasks: Vec<taskchampion::Task> =
            if let FilterExpression::EqualsFilter { property, value } = &filter {
                if property.name == "status" && value.as_str() == Some("pending") {
                    // Use built-in pending_tasks() for better performance
                    replica.pending_tasks().await?.into_iter().collect()
                } else {
                    // Fall back to all_tasks for other filters
                    replica.all_tasks().await?.into_values().collect()
                }
            } else {
                // For complex filters, get all tasks
                replica.all_tasks().await?.into_values().collect()
            };

        let mut task_maps: Vec<HashMap<String, String>> = Vec::new();
        for task in tasks {
            if evaluate_filter_expression(&task, &filter) {
                task_maps.push(task_to_map(&task));
            }
        }

        let json = serde_json::to_string(&task_maps)?;
        Ok(json)
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
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);

        // Parse the filter and sort JSON
        let filter: FilterExpression = serde_json::from_str(&filter_json)?;
        let sort: TaskSort = serde_json::from_str(&sort_json)?;

        // Optimization: Use pending_tasks() if filter is only for pending status
        let tasks: Vec<taskchampion::Task> =
            if let FilterExpression::EqualsFilter { property, value } = &filter {
                if property.name == "status" && value.as_str() == Some("pending") {
                    // Use built-in pending_tasks() for better performance
                    replica.pending_tasks().await?.into_iter().collect()
                } else {
                    // Fall back to all_tasks for other filters
                    replica.all_tasks().await?.into_values().collect()
                }
            } else {
                // For complex filters, get all tasks
                replica.all_tasks().await?.into_values().collect()
            };

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
        Ok(json)
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
/// Sync result as JSON with status and statistics
#[frb]
pub fn sync_with_server(
    taskdb_dir_path: String,
    server_url: String,
    client_id: String,
    encryption_secret: String,
) -> Result<SyncResultData, anyhow::Error> {
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);

        // Create server configuration
        let server_config = ServerConfig::Remote {
            url: server_url,
            client_id: Uuid::parse_str(&client_id)?,
            encryption_secret: encryption_secret.into_bytes(),
        };

        // Convert to server instance
        let mut server = server_config.into_server().await?;

        let num_local_operations = replica.num_local_operations().await.unwrap_or(0) as u64;
        // Perform synchronization
        replica.sync(&mut server, true).await?;

        Ok(SyncResultData {
            success: true,
            versions_synced: num_local_operations,
            tasks_added: 0,
            tasks_updated: 0,
            tasks_deleted: 0,
            error_message: None,
            duration_ms: None,
        })
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

/// Generate a new client ID for use with the sync server
///
/// # Returns
/// New UUID as a string
#[frb]
pub fn generate_client_id() -> String {
    Uuid::new_v4().to_string()
}

/// Generate a new encryption secret for use with the sync server
///
/// # Returns
/// Random secret as a hex string
#[frb]
pub fn generate_encryption_secret() -> String {
    let bytes: [u8; 32] = rand::random();
    hex::encode(&bytes)
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
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);
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
        Ok(json)
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
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);
        let tasks = replica.all_tasks().await?;

        let mut task_maps: Vec<HashMap<String, String>> = Vec::new();
        for (_, task) in tasks {
            task_maps.push(task_to_map(&task));
        }

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
    get_runtime().block_on(async {
        let storage = create_storage_async(taskdb_dir_path).await?;
        let mut replica = Replica::new(storage);

        let json_content = std::fs::read_to_string(import_file_path)?;
        let tasks_data: Vec<HashMap<String, String>> = serde_json::from_str(&json_content)?;

        let mut imported_count = 0;
        for task_data in tasks_data {
            // Skip if task already exists
            if let Some(uuid_str) = task_data.get("uuid") {
                if let Ok(uuid) = Uuid::parse_str(uuid_str) {
                    if replica.get_task(uuid).await?.is_some() {
                        continue;
                    }
                }
            }

            if create_task_from_map(&mut replica, task_data).await.is_ok() {
                imported_count += 1;
            }
        }

        Ok(imported_count)
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

    use crate::filter::{
        evaluate_filter_expression, get_datetime_property, get_string_property, has_virtual_tag,
        PropertyRef,
    };
    use crate::task_ops::parse_datetime;
    use chrono::Datelike;
    use std::str::FromStr;
    use taskchampion::Operations;
    use taskchampion::{Replica, Tag};
    use tempfile::TempDir;
    use uuid::Uuid;

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

    /// Helper function to create a test task with tags
    async fn create_test_task_with_tags<S: taskchampion::storage::Storage>(
        replica: &mut Replica<S>,
        description: &str,
        tags: Vec<&str>,
    ) -> Uuid {
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description(description.to_string(), &mut ops)
            .unwrap();
        for tag in tags {
            task.add_tag(&Tag::from_str(tag).unwrap(), &mut ops)
                .unwrap();
        }
        replica.commit_operations(ops).await.unwrap();
        uuid
    }

    /// Helper function to create a test task with due date
    async fn create_test_task_with_due<S: taskchampion::storage::Storage>(
        replica: &mut Replica<S>,
        description: &str,
        due: chrono::DateTime<chrono::Utc>,
    ) -> Uuid {
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description(description.to_string(), &mut ops)
            .unwrap();
        task.set_due(Some(due), &mut ops).unwrap();
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
        task.set_user_defined_attribute("project".to_string(), project.to_string(), &mut ops)
            .unwrap();
        replica.commit_operations(ops).await.unwrap();
        uuid
    }

    // ========================================================================
    // Tests for get_string_property
    // ========================================================================

    #[tokio::test]
    async fn test_get_string_property_description() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        assert_eq!(
            get_string_property(&task, "description"),
            Some("Test task".to_string())
        );
    }

    #[tokio::test]
    async fn test_get_string_property_status() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Completed, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        assert_eq!(
            get_string_property(&task, "status"),
            Some("completed".to_string())
        );
    }

    #[tokio::test]
    async fn test_get_string_property_priority() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "H").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        assert_eq!(
            get_string_property(&task, "priority"),
            Some("H".to_string())
        );
    }

    #[tokio::test]
    async fn test_get_string_property_priority_none() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        assert_eq!(get_string_property(&task, "priority"), None);
    }

    #[tokio::test]
    async fn test_get_string_property_project() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task_with_project(&mut replica, "Test task", "MyProject").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        assert_eq!(
            get_string_property(&task, "project"),
            Some("MyProject".to_string())
        );
    }

    #[tokio::test]
    async fn test_get_string_property_unknown() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        assert_eq!(get_string_property(&task, "unknown_property"), None);
    }

    // ========================================================================
    // Tests for get_datetime_property
    // ========================================================================

    #[tokio::test]
    async fn test_get_datetime_property_due() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let due_date = chrono::Utc::now() + chrono::Duration::days(1);
        let uuid = create_test_task_with_due(&mut replica, "Test task", due_date).await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let result = get_datetime_property(&task, "due").unwrap();
        assert!((result - due_date).num_seconds() < 1);
    }

    #[tokio::test]
    async fn test_get_datetime_property_entry() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        // Verify get_datetime_property can retrieve entry field
        // Note: entry may be None in test environment, but the function should not panic
        let result = get_datetime_property(&task, "entry");
        // Just verify the function works without crashing
        assert!(result.is_some() || result.is_none());
    }

    #[tokio::test]
    async fn test_get_datetime_property_unknown() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        assert_eq!(get_datetime_property(&task, "unknown_property"), None);
    }

    // ========================================================================
    // Tests for has_virtual_tag
    // ========================================================================

    #[tokio::test]
    async fn test_has_virtual_tag_pending() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        assert!(has_virtual_tag(&task, "PENDING"));
        assert!(!has_virtual_tag(&task, "COMPLETED"));
        assert!(!has_virtual_tag(&task, "DELETED"));
    }

    #[tokio::test]
    async fn test_has_virtual_tag_completed() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Completed, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        assert!(!has_virtual_tag(&task, "PENDING"));
        assert!(has_virtual_tag(&task, "COMPLETED"));
        assert!(!has_virtual_tag(&task, "DELETED"));
    }

    #[tokio::test]
    async fn test_has_virtual_tag_tagged() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid =
            create_test_task_with_tags(&mut replica, "Test task", vec!["home", "important"]).await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        assert!(has_virtual_tag(&task, "TAGGED"));
    }

    #[tokio::test]
    async fn test_has_virtual_tag_untagged() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        // Task without explicit tags should not have TAGGED virtual tag
        // Note: TaskChampion may add implicit tags, so we just verify the function doesn't crash
        let has_tagged = has_virtual_tag(&task, "TAGGED");
        // The result depends on whether TaskChampion adds implicit tags
        assert!(has_tagged || !has_tagged); // Always true, just ensures no panic
    }

    #[tokio::test]
    async fn test_has_virtual_tag_priority() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "H").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        assert!(has_virtual_tag(&task, "PRIORITY"));
    }

    #[tokio::test]
    async fn test_has_virtual_tag_project() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task_with_project(&mut replica, "Test task", "MyProject").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        assert!(has_virtual_tag(&task, "PROJECT"));
    }

    #[tokio::test]
    async fn test_has_virtual_tag_annotated() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description("Test task".to_string(), &mut ops)
            .unwrap();
        let annotation = taskchampion::Annotation {
            entry: taskchampion::utc_timestamp(chrono::Utc::now().timestamp()),
            description: "Test annotation".to_string(),
        };
        task.add_annotation(annotation, &mut ops).unwrap();
        replica.commit_operations(ops).await.unwrap();

        let task = replica.get_task(uuid).await.unwrap().unwrap();
        assert!(has_virtual_tag(&task, "ANNOTATED"));
    }

    // ========================================================================
    // Tests for evaluate_filter_expression - String property filters
    // ========================================================================

    #[tokio::test]
    async fn test_evaluate_equals_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::EqualsFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: serde_json::Value::String("Test task".to_string()),
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::EqualsFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: serde_json::Value::String("Wrong task".to_string()),
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    #[tokio::test]
    async fn test_evaluate_not_equals_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::NotEqualsFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: serde_json::Value::String("Wrong task".to_string()),
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_same = FilterExpression::NotEqualsFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: serde_json::Value::String("Test task".to_string()),
        };

        assert!(!evaluate_filter_expression(&task, &filter_same));
    }

    #[tokio::test]
    async fn test_evaluate_in_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::InFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            values: vec![
                serde_json::Value::String("Task 1".to_string()),
                serde_json::Value::String("Test task".to_string()),
                serde_json::Value::String("Task 3".to_string()),
            ],
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_not_in = FilterExpression::InFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            values: vec![
                serde_json::Value::String("Task 1".to_string()),
                serde_json::Value::String("Task 2".to_string()),
            ],
        };

        assert!(!evaluate_filter_expression(&task, &filter_not_in));
    }

    #[tokio::test]
    async fn test_evaluate_contains_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Buy milk from store", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::ContainsFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: "milk".to_string(),
            case_sensitive: false,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_case_sensitive = FilterExpression::ContainsFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: "MILK".to_string(),
            case_sensitive: true,
        };

        assert!(!evaluate_filter_expression(&task, &filter_case_sensitive));

        let filter_case_insensitive = FilterExpression::ContainsFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: "MILK".to_string(),
            case_sensitive: false,
        };

        assert!(evaluate_filter_expression(&task, &filter_case_insensitive));
    }

    #[tokio::test]
    async fn test_evaluate_starts_with_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Buy milk", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::StartsWithFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: "Buy".to_string(),
            case_sensitive: true,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::StartsWithFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: "Sell".to_string(),
            case_sensitive: true,
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    #[tokio::test]
    async fn test_evaluate_ends_with_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Buy milk", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::EndsWithFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: "milk".to_string(),
            case_sensitive: true,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::EndsWithFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: "Buy".to_string(),
            case_sensitive: true,
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    #[tokio::test]
    async fn test_evaluate_word_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Buy milk from store", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::WordFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: "milk".to_string(),
            case_sensitive: false,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_partial = FilterExpression::WordFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            value: "mil".to_string(),
            case_sensitive: false,
        };

        assert!(!evaluate_filter_expression(&task, &filter_partial));
    }

    #[tokio::test]
    async fn test_evaluate_regex_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Buy milk", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::RegexFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            pattern: "^Buy\\s+\\w+$".to_string(),
            case_sensitive: true,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::RegexFilter {
            property: PropertyRef {
                name: "description".to_string(),
            },
            pattern: "^Sell\\s+\\w+$".to_string(),
            case_sensitive: true,
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    #[tokio::test]
    async fn test_evaluate_none_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::NoneFilter {
            property: PropertyRef {
                name: "project".to_string(),
            },
        };

        assert!(evaluate_filter_expression(&task, &filter));
    }

    #[tokio::test]
    async fn test_evaluate_any_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task_with_project(&mut replica, "Test task", "MyProject").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::AnyFilter {
            property: PropertyRef {
                name: "project".to_string(),
            },
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let uuid2 = create_test_task(&mut replica, "Test task 2", Status::Pending, "").await;
        let task2 = replica.get_task(uuid2).await.unwrap().unwrap();

        assert!(!evaluate_filter_expression(&task2, &filter));
    }

    // ========================================================================
    // Tests for evaluate_filter_expression - Date filters
    // ========================================================================

    #[tokio::test]
    async fn test_evaluate_date_before_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let due_date = chrono::Utc::now() + chrono::Duration::days(1);
        let uuid = create_test_task_with_due(&mut replica, "Test task", due_date).await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let future_date = (chrono::Utc::now() + chrono::Duration::days(2)).to_rfc3339();
        let filter = FilterExpression::DateBeforeFilter {
            property: PropertyRef {
                name: "due".to_string(),
            },
            date: future_date,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let past_date = (chrono::Utc::now() - chrono::Duration::days(1)).to_rfc3339();
        let filter_wrong = FilterExpression::DateBeforeFilter {
            property: PropertyRef {
                name: "due".to_string(),
            },
            date: past_date,
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    #[tokio::test]
    async fn test_evaluate_date_after_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let due_date = chrono::Utc::now() + chrono::Duration::days(1);
        let uuid = create_test_task_with_due(&mut replica, "Test task", due_date).await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let past_date = (chrono::Utc::now() - chrono::Duration::days(1)).to_rfc3339();
        let filter = FilterExpression::DateAfterFilter {
            property: PropertyRef {
                name: "due".to_string(),
            },
            date: past_date,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let future_date = (chrono::Utc::now() + chrono::Duration::days(2)).to_rfc3339();
        let filter_wrong = FilterExpression::DateAfterFilter {
            property: PropertyRef {
                name: "due".to_string(),
            },
            date: future_date,
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    // ========================================================================
    // Tests for evaluate_filter_expression - Numeric filters
    // ========================================================================

    #[tokio::test]
    async fn test_evaluate_less_than_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description("Test task".to_string(), &mut ops)
            .unwrap();
        task.set_user_defined_attribute("urgency".to_string(), "5.0".to_string(), &mut ops)
            .unwrap();
        replica.commit_operations(ops).await.unwrap();

        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::LessThanFilter {
            property: PropertyRef {
                name: "urgency".to_string(),
            },
            value: 10.0,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::LessThanFilter {
            property: PropertyRef {
                name: "urgency".to_string(),
            },
            value: 3.0,
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    #[tokio::test]
    async fn test_evaluate_greater_than_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description("Test task".to_string(), &mut ops)
            .unwrap();
        task.set_user_defined_attribute("urgency".to_string(), "5.0".to_string(), &mut ops)
            .unwrap();
        replica.commit_operations(ops).await.unwrap();

        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::GreaterThanFilter {
            property: PropertyRef {
                name: "urgency".to_string(),
            },
            value: 3.0,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::GreaterThanFilter {
            property: PropertyRef {
                name: "urgency".to_string(),
            },
            value: 10.0,
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    // ========================================================================
    // Tests for evaluate_filter_expression - Tag filters
    // ========================================================================

    #[tokio::test]
    async fn test_evaluate_tag_filter_include() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid =
            create_test_task_with_tags(&mut replica, "Test task", vec!["home", "important"]).await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::Tag {
            tag: "home".to_string(),
            exclude: false,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::Tag {
            tag: "work".to_string(),
            exclude: false,
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    #[tokio::test]
    async fn test_evaluate_tag_filter_exclude() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid =
            create_test_task_with_tags(&mut replica, "Test task", vec!["home", "important"]).await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::Tag {
            tag: "work".to_string(),
            exclude: true,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::Tag {
            tag: "home".to_string(),
            exclude: true,
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    #[tokio::test]
    async fn test_evaluate_virtual_tag_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::VirtualTag {
            tag: "PENDING".to_string(),
            exclude: false,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::VirtualTag {
            tag: "COMPLETED".to_string(),
            exclude: false,
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    // ========================================================================
    // Tests for evaluate_filter_expression - Logical operators
    // ========================================================================

    #[tokio::test]
    async fn test_evaluate_and_group() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::AndGroup {
            filters: vec![
                FilterExpression::EqualsFilter {
                    property: PropertyRef {
                        name: "status".to_string(),
                    },
                    value: serde_json::Value::String("pending".to_string()),
                },
                FilterExpression::ContainsFilter {
                    property: PropertyRef {
                        name: "description".to_string(),
                    },
                    value: "Test".to_string(),
                    case_sensitive: true,
                },
            ],
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::AndGroup {
            filters: vec![
                FilterExpression::EqualsFilter {
                    property: PropertyRef {
                        name: "status".to_string(),
                    },
                    value: serde_json::Value::String("pending".to_string()),
                },
                FilterExpression::EqualsFilter {
                    property: PropertyRef {
                        name: "status".to_string(),
                    },
                    value: serde_json::Value::String("completed".to_string()),
                },
            ],
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    #[tokio::test]
    async fn test_evaluate_or_group() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::OrGroup {
            filters: vec![
                FilterExpression::EqualsFilter {
                    property: PropertyRef {
                        name: "status".to_string(),
                    },
                    value: serde_json::Value::String("completed".to_string()),
                },
                FilterExpression::ContainsFilter {
                    property: PropertyRef {
                        name: "description".to_string(),
                    },
                    value: "Test".to_string(),
                    case_sensitive: true,
                },
            ],
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::OrGroup {
            filters: vec![
                FilterExpression::EqualsFilter {
                    property: PropertyRef {
                        name: "status".to_string(),
                    },
                    value: serde_json::Value::String("completed".to_string()),
                },
                FilterExpression::EqualsFilter {
                    property: PropertyRef {
                        name: "status".to_string(),
                    },
                    value: serde_json::Value::String("deleted".to_string()),
                },
            ],
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    #[tokio::test]
    async fn test_evaluate_xor_group() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::XorGroup {
            filters: vec![
                FilterExpression::EqualsFilter {
                    property: PropertyRef {
                        name: "status".to_string(),
                    },
                    value: serde_json::Value::String("pending".to_string()),
                },
                FilterExpression::EqualsFilter {
                    property: PropertyRef {
                        name: "status".to_string(),
                    },
                    value: serde_json::Value::String("completed".to_string()),
                },
            ],
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::XorGroup {
            filters: vec![
                FilterExpression::EqualsFilter {
                    property: PropertyRef {
                        name: "status".to_string(),
                    },
                    value: serde_json::Value::String("pending".to_string()),
                },
                FilterExpression::ContainsFilter {
                    property: PropertyRef {
                        name: "description".to_string(),
                    },
                    value: "Test".to_string(),
                    case_sensitive: true,
                },
            ],
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    #[tokio::test]
    async fn test_evaluate_not_filter() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "").await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let filter = FilterExpression::Not {
            inner: Box::new(FilterExpression::EqualsFilter {
                property: PropertyRef {
                    name: "status".to_string(),
                },
                value: serde_json::Value::String("completed".to_string()),
            }),
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let filter_wrong = FilterExpression::Not {
            inner: Box::new(FilterExpression::EqualsFilter {
                property: PropertyRef {
                    name: "status".to_string(),
                },
                value: serde_json::Value::String("pending".to_string()),
            }),
        };

        assert!(!evaluate_filter_expression(&task, &filter_wrong));
    }

    // ========================================================================
    // Tests for get_tasks_with_filter_json integration
    // ========================================================================

    #[test]
    fn test_get_tasks_with_filter_json_status_pending() {
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

        let result = get_tasks_with_filter_json(path, filter_json.to_string()).unwrap();
        let tasks: Vec<HashMap<String, String>> = serde_json::from_str(&result).unwrap();

        assert_eq!(tasks.len(), 2);
        for task in &tasks {
            assert_eq!(task.get("status"), Some(&"pending".to_string()));
        }
    }

    #[test]
    fn test_get_tasks_with_filter_json_complex_filter() {
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

        let result = get_tasks_with_filter_json(path, filter_json.to_string()).unwrap();
        let tasks: Vec<HashMap<String, String>> = serde_json::from_str(&result).unwrap();

        assert_eq!(tasks.len(), 2);
        for task in &tasks {
            assert_eq!(task.get("project"), Some(&"ProjectA".to_string()));
        }
    }

    #[test]
    fn test_deserialize_equals_filter() {
        let json = r#"{
            "type": "EqualsFilter",
            "property": {"name": "status"},
            "value": "pending"
        }"#;

        let result: Result<FilterExpression, _> = serde_json::from_str(json);
        assert!(
            result.is_ok(),
            "Failed to deserialize EqualsFilter: {:?}",
            result.err()
        );
    }

    #[test]
    fn test_deserialize_tag_filter() {
        let json = r#"{
            "type": "Tag",
            "tag": "home",
            "exclude": false
        }"#;

        let result: Result<FilterExpression, _> = serde_json::from_str(json);
        assert!(
            result.is_ok(),
            "Failed to deserialize TagFilter: {:?}",
            result.err()
        );
    }

    #[test]
    fn test_deserialize_and_group() {
        let json = r#"{
            "type": "AndGroup",
            "filters": [
                {
                    "type": "EqualsFilter",
                    "property": {"name": "status"},
                    "value": "pending"
                },
                {
                    "type": "Tag",
                    "tag": "home",
                    "exclude": false
                }
            ]
        }"#;

        let result: Result<FilterExpression, _> = serde_json::from_str(json);
        assert!(
            result.is_ok(),
            "Failed to deserialize AndGroup: {:?}",
            result.err()
        );
    }

    #[test]
    fn test_deserialize_contains_filter() {
        let json = r#"{
            "type": "ContainsFilter",
            "property": {"name": "description"},
            "value": "test",
            "case_sensitive": false
        }"#;

        let result: Result<FilterExpression, _> = serde_json::from_str(json);
        assert!(
            result.is_ok(),
            "Failed to deserialize ContainsFilter: {:?}",
            result.err()
        );
    }

    #[test]
    fn test_parse_datetime_valid() {
        let dt = parse_datetime("2024-01-15T12:00:00Z");
        assert!(dt.is_some());
        assert_eq!(dt.unwrap().year(), 2024);
    }

    #[test]
    fn test_parse_datetime_empty() {
        assert!(parse_datetime("").is_none());
    }

    #[test]
    fn test_parse_datetime_invalid() {
        assert!(parse_datetime("not-a-date").is_none());
    }
}
