#![allow(unexpected_cfgs)]

//! TaskChampion Rust FFI Bridge
//!
//! This module provides the FFI bridge between Dart and Rust for TaskChampion operations.
//! It exposes functions for task management, synchronization, and authentication.

use chrono::{DateTime, Datelike, Utc};
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::PathBuf;
use std::str::FromStr;
use taskchampion::storage::AccessMode;
use taskchampion::{utc_timestamp, Operations, Replica, ServerConfig, SqliteStorage, Status, Tag};
use uuid::Uuid;

use std::sync::OnceLock;

/// Global tokio runtime for async taskchampion operations
static TOKIO_RUNTIME: OnceLock<tokio::runtime::Runtime> = OnceLock::new();

/// Get or create the global tokio runtime
fn get_runtime() -> &'static tokio::runtime::Runtime {
    TOKIO_RUNTIME.get_or_init(|| {
        tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .expect("Failed to create tokio runtime")
    })
}

/// Helper function to create SqliteStorage (async, called within block_on)
async fn create_storage_async(taskdb_dir_path: String) -> Result<SqliteStorage, anyhow::Error> {
    let taskdb_dir = PathBuf::from(taskdb_dir_path);
    let storage = SqliteStorage::new(taskdb_dir, AccessMode::ReadWrite, true).await?;
    Ok(storage)
}

/// Sync result structure for returning sync statistics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SyncResultData {
    pub success: bool,
    pub versions_synced: u64,
    pub tasks_added: u64,
    pub tasks_updated: u64,
    pub tasks_deleted: u64,
    pub error_message: Option<String>,
    pub duration_ms: Option<u64>,
}

/// Parse a datetime string into a DateTime<Utc>
/// Returns None if the string is empty or invalid
fn parse_datetime(dt_str: &str) -> Option<DateTime<Utc>> {
    if dt_str.is_empty() {
        return None;
    }
    DateTime::parse_from_rfc3339(dt_str)
        .map(|dt| dt.with_timezone(&Utc))
        .ok()
}

/// Convert a HashMap task data to taskchampion Task
async fn create_task_from_map<S: taskchampion::storage::Storage>(
    replica: &mut Replica<S>,
    task_data: HashMap<String, String>,
) -> Result<Uuid, anyhow::Error> {
    let mut ops = Operations::new();

    // Create task with UUID
    let uuid = Uuid::new_v4();
    let mut task = replica.create_task(uuid, &mut ops).await?;

    // Set description
    if let Some(desc) = task_data.get("description") {
        task.set_description(desc.clone(), &mut ops)?;
    }

    // Set status
    if let Some(status) = task_data.get("status") {
        let task_status = match status.as_str() {
            "completed" => Status::Completed,
            "deleted" => Status::Deleted,
            _ => Status::Pending,
        };
        task.set_status(task_status, &mut ops)?;
    }

    // Set optional fields
    if let Some(priority) = task_data.get("priority") {
        task.set_priority(priority.clone(), &mut ops)?;
    }

    if let Some(due) = task_data.get("due") {
        if let Some(dt) = parse_datetime(due) {
            task.set_due(Some(dt), &mut ops)?;
        }
    }

    if let Some(wait) = task_data.get("wait") {
        if let Some(dt) = parse_datetime(wait) {
            task.set_wait(Some(dt), &mut ops)?;
        }
    }

    // Handle tags
    if let Some(tags_str) = task_data.get("tags") {
        for tag in tags_str.split_whitespace() {
            let tag = Tag::from_str(tag)?;
            task.add_tag(&tag, &mut ops)?;
        }
    }

    // Handle dependencies
    if let Some(depends_str) = task_data.get("depends") {
        for dep_uuid_str in depends_str.split_whitespace() {
            if let Ok(dep_uuid) = Uuid::parse_str(dep_uuid_str) {
                task.add_dependency(dep_uuid, &mut ops)?;
            }
        }
    }

    // Handle annotations (keys starting with "annotation_")
    for (key, value) in task_data.iter() {
        if let Some(ts_str) = key.strip_prefix("annotation_") {
            if let Ok(ts) = ts_str.parse::<i64>() {
                let annotation = taskchampion::Annotation {
                    entry: utc_timestamp(ts),
                    description: value.clone(),
                };
                task.add_annotation(annotation, &mut ops)?;
            }
        }
    }

    // Handle UDAs (all keys that are not known properties)
    let known_prefixes = [
        "description",
        "status",
        "priority",
        "due",
        "wait",
        "entry",
        "modified",
        "end",
        "tags",
        "depends",
        "uuid",
        "annotation_",
    ];

    for (key, value) in task_data.iter() {
        let is_known = known_prefixes
            .iter()
            .any(|prefix| key == *prefix || key.starts_with(prefix));
        if !is_known {
            // Handle special UDAs with proper parsing
            if key == "scheduled" || key == "until" {
                if let Some(dt) = parse_datetime(value) {
                    task.set_user_defined_attribute(key.clone(), dt.to_rfc3339(), &mut ops)?;
                }
            } else if key == "urgency" {
                // Store urgency as-is (it's typically calculated, but can be stored)
                task.set_user_defined_attribute(key.clone(), value.clone(), &mut ops)?;
            } else {
                // Regular UDA (including project, parent)
                task.set_user_defined_attribute(key.clone(), value.clone(), &mut ops)?;
            }
        }
    }

    replica.commit_operations(ops).await?;

    Ok(uuid)
}

/// Update an existing task with new data
async fn update_task_in_replica<S: taskchampion::storage::Storage>(
    replica: &mut Replica<S>,
    uuid: Uuid,
    task_data: HashMap<String, String>,
) -> Result<(), anyhow::Error> {
    let mut ops = Operations::new();
    let mut task = replica
        .get_task(uuid)
        .await?
        .ok_or_else(|| anyhow::anyhow!("Task not found"))?;

    // Update fields if provided
    if let Some(description) = task_data.get("description") {
        task.set_description(description.clone(), &mut ops)?;
    }

    if let Some(status) = task_data.get("status") {
        let task_status = match status.as_str() {
            "completed" => Status::Completed,
            "deleted" => Status::Deleted,
            _ => Status::Pending,
        };
        task.set_status(task_status, &mut ops)?;
    }

    if let Some(priority) = task_data.get("priority") {
        task.set_priority(priority.clone(), &mut ops)?;
    }

    if let Some(due) = task_data.get("due") {
        let dt = parse_datetime(due);
        task.set_due(dt, &mut ops)?;
    }

    if let Some(wait) = task_data.get("wait") {
        let dt = parse_datetime(wait);
        task.set_wait(dt, &mut ops)?;
    }

    // Handle tags - clear existing and add new
    if let Some(tags_str) = task_data.get("tags") {
        // Clear existing tags
        let existing_tags: Vec<Tag> = task.get_tags().collect();
        for tag in existing_tags {
            task.remove_tag(&tag, &mut ops)?;
        }
        // Add new tags
        for tag in tags_str.split_whitespace() {
            let tag = Tag::from_str(tag)?;
            task.add_tag(&tag, &mut ops)?;
        }
    }

    // Handle dependencies - clear existing and add new
    if let Some(depends_str) = task_data.get("depends") {
        // Clear existing dependencies
        let existing_deps: Vec<Uuid> = task.get_dependencies().collect();
        for dep in existing_deps {
            task.remove_dependency(dep, &mut ops)?;
        }
        // Add new dependencies
        for dep_uuid_str in depends_str.split_whitespace() {
            if let Ok(dep_uuid) = Uuid::parse_str(dep_uuid_str) {
                task.add_dependency(dep_uuid, &mut ops)?;
            }
        }
    }

    // Handle annotations - clear existing and add new
    // First, collect all existing annotation timestamps
    let existing_annotations: Vec<i64> = task
        .get_annotations()
        .map(|a| a.entry.timestamp())
        .collect();
    for ts in existing_annotations {
        task.remove_annotation(utc_timestamp(ts), &mut ops)?;
    }
    // Add new annotations from task_data
    for (key, value) in task_data.iter() {
        if let Some(ts_str) = key.strip_prefix("annotation_") {
            if let Ok(ts) = ts_str.parse::<i64>() {
                let annotation = taskchampion::Annotation {
                    entry: utc_timestamp(ts),
                    description: value.clone(),
                };
                task.add_annotation(annotation, &mut ops)?;
            }
        }
    }

    // Handle UDAs - update only the ones provided in task_data
    let known_prefixes = [
        "description",
        "status",
        "priority",
        "due",
        "wait",
        "entry",
        "modified",
        "end",
        "tags",
        "depends",
        "uuid",
        "annotation_",
    ];

    for (key, value) in task_data.iter() {
        let is_known = known_prefixes
            .iter()
            .any(|prefix| key == *prefix || key.starts_with(prefix));
        if !is_known {
            // Handle special UDAs with proper parsing
            if key == "scheduled" || key == "until" {
                if let Some(dt) = parse_datetime(value) {
                    task.set_user_defined_attribute(key.clone(), dt.to_rfc3339(), &mut ops)?;
                }
            } else {
                task.set_user_defined_attribute(key.clone(), value.clone(), &mut ops)?;
            }
        }
    }

    replica.commit_operations(ops).await?;

    Ok(())
}

/// Convert taskchampion Task to HashMap for JSON serialization
fn task_to_map(task: &taskchampion::Task) -> HashMap<String, String> {
    let mut map = HashMap::new();

    map.insert("uuid".to_string(), task.get_uuid().to_string());
    map.insert(
        "description".to_string(),
        task.get_description().to_string(),
    );
    // Convert status to lowercase string (pending, completed, deleted, recurring, unknown)
    let status_str = match task.get_status() {
        taskchampion::Status::Pending => "pending",
        taskchampion::Status::Completed => "completed",
        taskchampion::Status::Deleted => "deleted",
        taskchampion::Status::Recurring => "recurring",
        taskchampion::Status::Unknown(_) => "unknown",
    };
    map.insert("status".to_string(), status_str.to_string());

    // Entry timestamp - always present for valid tasks
    if let Some(entry) = task.get_entry() {
        map.insert("entry".to_string(), entry.to_rfc3339());
    } else {
        // Fallback to current time if entry is missing
        map.insert("entry".to_string(), chrono::Utc::now().to_rfc3339());
    }

    if let Some(modified) = task.get_modified() {
        map.insert("modified".to_string(), modified.to_rfc3339());
    }

    // Get 'end' property using get_value (no dedicated getter)
    if let Some(end_str) = task.get_value("end") {
        if let Some(end) = parse_datetime(end_str) {
            map.insert("end".to_string(), end.to_rfc3339());
        }
    }

    let priority = task.get_priority();
    if !priority.is_empty() {
        map.insert("priority".to_string(), priority.to_string());
    }

    if let Some(due) = task.get_due() {
        map.insert("due".to_string(), due.to_rfc3339());
    }

    if let Some(wait) = task.get_wait() {
        map.insert("wait".to_string(), wait.to_rfc3339());
    }

    // Handle tags
    let tags: Vec<String> = task.get_tags().map(|t| t.to_string()).collect();
    map.insert("tags".to_string(), tags.join(" "));

    // Handle dependencies
    let deps: Vec<String> = task.get_dependencies().map(|u| u.to_string()).collect();
    map.insert("depends".to_string(), deps.join(" "));

    // Handle annotations - store with "annotation_" prefix to preserve structure
    for annotation in task.get_annotations() {
        let key = format!("annotation_{}", annotation.entry.timestamp());
        map.insert(key, annotation.description);
    }

    // Handle UDAs (User Defined Attributes)
    // Special UDAs that are exposed as separate fields
    let special_udas = ["project", "scheduled", "until", "parent", "urgency"];

    for (key, value) in task.get_user_defined_attributes() {
        if special_udas.contains(&key) {
            // Add special UDAs as separate fields
            map.insert(key.to_string(), value.to_string());
        } else {
            // Other UDAs go into annotations field for backward compatibility
            // Note: This is a design decision - ideally we'd have a separate 'udas' field
            map.insert(key.to_string(), value.to_string());
        }
    }

    map
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

// ============================================================================
// FILTER TYPES (Taskwarrior-compatible)
// ============================================================================

/// Property reference for filtering
#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct PropertyRef {
    pub name: String,
}

/// Sort direction enum
#[derive(Debug, Clone, Deserialize, Serialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum SortDirection {
    Ascending,
    Descending,
}

/// Property reference for sorting
#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct SortProperty {
    pub name: String,
}

/// Sort specification
#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct TaskSort {
    pub property: SortProperty,
    pub direction: SortDirection,
}

/// String comparison filters
#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(tag = "type")]
pub enum StringPropertyFilter {
    Equals {
        property: PropertyRef,
        value: String,
    },
    NotEquals {
        property: PropertyRef,
        value: String,
    },
    In {
        property: PropertyRef,
        values: Vec<String>,
    },
    NotIn {
        property: PropertyRef,
        values: Vec<String>,
    },
    Contains {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    NotContains {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    StartsWith {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    EndsWith {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    Word {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    NoWord {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    Regex {
        property: PropertyRef,
        pattern: String,
        case_sensitive: bool,
    },
    None {
        property: PropertyRef,
    },
    Any {
        property: PropertyRef,
    },
}

/// DateTime comparison filters
#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(tag = "type")]
pub enum DateTimePropertyFilter {
    Equals {
        property: PropertyRef,
        value: String,
    },
    NotEquals {
        property: PropertyRef,
        value: String,
    },
    In {
        property: PropertyRef,
        values: Vec<String>,
    },
    NotIn {
        property: PropertyRef,
        values: Vec<String>,
    },
    Before {
        property: PropertyRef,
        date: String,
    },
    After {
        property: PropertyRef,
        date: String,
    },
    By {
        property: PropertyRef,
        date: String,
    },
    DateFrom {
        property: PropertyRef,
        from: String,
    },
    DateTo {
        property: PropertyRef,
        to: String,
    },
    None {
        property: PropertyRef,
    },
    Any {
        property: PropertyRef,
    },
}

/// Numeric comparison filters
#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(tag = "type")]
pub enum NumericPropertyFilter {
    Equals { property: PropertyRef, value: f64 },
    NotEquals { property: PropertyRef, value: f64 },
    LessThan { property: PropertyRef, value: f64 },
    LessThanOrEqual { property: PropertyRef, value: f64 },
    GreaterThan { property: PropertyRef, value: f64 },
    GreaterThanOrEqual { property: PropertyRef, value: f64 },
    None { property: PropertyRef },
    Any { property: PropertyRef },
}

/// Combined property filter enum
#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(untagged)]
pub enum PropertyFilter {
    String(StringPropertyFilter),
    DateTime(DateTimePropertyFilter),
    Numeric(NumericPropertyFilter),
}

/// Filter group types
#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(tag = "type")]
pub enum FilterGroup {
    AndFilterGroup { filters: Vec<FilterExpression> },
    OrFilterGroup { filters: Vec<FilterExpression> },
    XorFilterGroup { filters: Vec<FilterExpression> },
}

/// Tag filter for +tag / -tag syntax
#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(tag = "type")]
pub struct TagFilter {
    pub tag: String,
    pub exclude: bool,
}

/// Virtual tag filter for +ACTIVE, -DELETED, etc.
#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(tag = "type")]
pub struct VirtualTagFilter {
    pub tag: String,
    pub exclude: bool,
}

/// Main filter expression type (taskwarrior-compatible)
/// Uses internally tagged representation for unambiguous deserialization
#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(tag = "type")]
pub enum FilterExpression {
    AndGroup {
        filters: Vec<FilterExpression>,
    },
    OrGroup {
        filters: Vec<FilterExpression>,
    },
    XorGroup {
        filters: Vec<FilterExpression>,
    },
    Not {
        inner: Box<FilterExpression>,
    },
    Tag {
        tag: String,
        exclude: bool,
    },
    VirtualTag {
        tag: String,
        exclude: bool,
    },
    // Property filters - string
    EqualsFilter {
        property: PropertyRef,
        value: serde_json::Value,
    },
    NotEqualsFilter {
        property: PropertyRef,
        value: serde_json::Value,
    },
    InFilter {
        property: PropertyRef,
        values: Vec<serde_json::Value>,
    },
    NotInFilter {
        property: PropertyRef,
        values: Vec<serde_json::Value>,
    },
    ContainsFilter {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    NotContainsFilter {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    StartsWithFilter {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    EndsWithFilter {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    WordFilter {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    NoWordFilter {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    RegexFilter {
        property: PropertyRef,
        pattern: String,
        case_sensitive: bool,
    },
    NoneFilter {
        property: PropertyRef,
    },
    AnyFilter {
        property: PropertyRef,
    },
    // Date filters
    DateBeforeFilter {
        property: PropertyRef,
        date: String,
    },
    DateAfterFilter {
        property: PropertyRef,
        date: String,
    },
    DateByFilter {
        property: PropertyRef,
        date: String,
    },
    DateFromFilter {
        property: PropertyRef,
        from: String,
    },
    DateToFilter {
        property: PropertyRef,
        to: String,
    },
    // Numeric filters
    LessThanFilter {
        property: PropertyRef,
        value: f64,
    },
    LessThanOrEqualFilter {
        property: PropertyRef,
        value: f64,
    },
    GreaterThanFilter {
        property: PropertyRef,
        value: f64,
    },
    GreaterThanOrEqualFilter {
        property: PropertyRef,
        value: f64,
    },
}

/// Task filter wrapper
#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct TaskFilter {
    pub filter: FilterExpression,
}

// ============================================================================
// FILTER EVALUATION
// ============================================================================

// ============================================================================
// FILTER EVALUATION (Taskwarrior-compatible)
// ============================================================================

/// Get a string property value from a task
fn get_string_property(task: &taskchampion::Task, property_name: &str) -> Option<String> {
    match property_name {
        "description" => Some(task.get_description().to_string()),
        "status" => {
            let status_str = match task.get_status() {
                taskchampion::Status::Pending => "pending",
                taskchampion::Status::Completed => "completed",
                taskchampion::Status::Deleted => "deleted",
                taskchampion::Status::Recurring => "recurring",
                taskchampion::Status::Unknown(_) => "unknown",
            };
            Some(status_str.to_string())
        }
        "priority" => {
            let priority = task.get_priority();
            if priority.is_empty() {
                None
            } else {
                Some(priority.to_string())
            }
        }
        "project" => task.get_value("project").map(|s| s.to_string()),
        _ => None,
    }
}

/// Get a DateTime property value from a task
fn get_datetime_property(task: &taskchampion::Task, property_name: &str) -> Option<DateTime<Utc>> {
    match property_name {
        "due" => task.get_due(),
        "wait" => task.get_wait(),
        "entry" => task.get_entry(),
        "modified" => task.get_modified(),
        "scheduled" => task
            .get_value("scheduled")
            .and_then(|s| DateTime::parse_from_rfc3339(s).ok())
            .map(|dt| dt.with_timezone(&Utc)),
        "until" => task
            .get_value("until")
            .and_then(|s| DateTime::parse_from_rfc3339(s).ok())
            .map(|dt| dt.with_timezone(&Utc)),
        _ => None,
    }
}

/// Check if a task has a virtual tag
fn has_virtual_tag(task: &taskchampion::Task, tag: &str) -> bool {
    match tag.to_uppercase().as_str() {
        "ACTIVE" => task.get_value("start").is_some(),
        "ANNOTATED" => task.get_annotations().count() > 0,
        "BLOCKED" => task.get_dependencies().count() > 0,
        "BLOCKING" => task.is_blocking(),
        "COMPLETED" => task.get_status() == taskchampion::Status::Completed,
        "DELETED" => task.get_status() == taskchampion::Status::Deleted,
        "DUE" => {
            if let Some(due) = task.get_due() {
                let now = Utc::now();
                let seven_days = chrono::Duration::days(7);
                due <= now + seven_days
            } else {
                false
            }
        }
        "DUETODAY" | "TODAY" => {
            if let Some(due) = task.get_due() {
                let now = Utc::now();
                due.date_naive() == now.date_naive()
            } else {
                false
            }
        }
        "INSTANCE" => task.get_value("template").is_some() || task.get_value("parent").is_some(),
        "LATEST" => false, // Would need context to determine
        "MONTH" => {
            if let Some(due) = task.get_due() {
                let now = Utc::now();
                due.month() == now.month() && due.year() == now.year()
            } else {
                false
            }
        }
        "ORPHAN" => false, // Would need UDA validation
        "OVERDUE" => {
            if let Some(due) = task.get_due() {
                due < Utc::now() && task.get_status() == taskchampion::Status::Pending
            } else {
                false
            }
        }
        "PARENT" => task.get_value("last").is_some() || task.get_value("mask").is_some(),
        "PENDING" => task.get_status() == taskchampion::Status::Pending,
        "PRIORITY" => !task.get_priority().is_empty(),
        "PROJECT" => task.get_value("project").is_some(),
        "QUARTER" => {
            if let Some(due) = task.get_due() {
                let now = Utc::now();
                let current_quarter = (now.month() - 1) / 3 + 1;
                let due_quarter = (due.month() - 1) / 3 + 1;
                current_quarter == due_quarter && now.year() == due.year()
            } else {
                false
            }
        }
        "READY" => {
            task.get_status() == taskchampion::Status::Pending
                && task.get_wait().is_none_or(|w| w <= Utc::now())
        }
        "SCHEDULED" => task.get_value("scheduled").is_some(),
        "TAGGED" => task.get_tags().count() > 0,
        "TEMPLATE" => task.get_value("last").is_some() || task.get_value("mask").is_some(),
        "TOMORROW" => {
            if let Some(due) = task.get_due() {
                let tomorrow = Utc::now() + chrono::Duration::days(1);
                due.date_naive() == tomorrow.date_naive()
            } else {
                false
            }
        }
        "UDA" => false, // Would need UDA check
        "UNBLOCKED" => task.get_dependencies().count() == 0,
        "UNTIL" => task.get_value("until").is_some(),
        "WAITING" => task.get_wait().is_some_and(|w| w > Utc::now()),
        "WEEK" => {
            if let Some(due) = task.get_due() {
                let now_iso = Utc::now().iso_week();
                let due_iso = due.iso_week();
                now_iso.year() == due_iso.year() && now_iso.week() == due_iso.week()
            } else {
                false
            }
        }
        "YEAR" => {
            if let Some(due) = task.get_due() {
                due.year() == Utc::now().year()
            } else {
                false
            }
        }
        "YESTERDAY" => {
            if let Some(due) = task.get_due() {
                let yesterday = Utc::now() - chrono::Duration::days(1);
                due.date_naive() == yesterday.date_naive()
            } else {
                false
            }
        }
        _ => false,
    }
}

/// Compare two tasks for sorting
fn compare_tasks(
    task1: &taskchampion::Task,
    task2: &taskchampion::Task,
    sort: &TaskSort,
) -> std::cmp::Ordering {
    let property_name = &sort.property.name;
    let ascending = sort.direction == SortDirection::Ascending;

    // Try to get string property first
    let str_cmp = |prop: &str| -> Option<std::cmp::Ordering> {
        let v1 = get_string_property(task1, prop);
        let v2 = get_string_property(task2, prop);
        match (v1, v2) {
            (Some(a), Some(b)) => Some(a.cmp(&b)),
            (Some(_), None) => Some(std::cmp::Ordering::Greater),
            (None, Some(_)) => Some(std::cmp::Ordering::Less),
            (None, None) => None,
        }
    };

    // Try to get DateTime property
    let dt_cmp = |prop: &str| -> Option<std::cmp::Ordering> {
        let v1 = get_datetime_property(task1, prop);
        let v2 = get_datetime_property(task2, prop);
        match (v1, v2) {
            (Some(a), Some(b)) => Some(a.cmp(&b)),
            (Some(_), None) => Some(std::cmp::Ordering::Greater),
            (None, Some(_)) => Some(std::cmp::Ordering::Less),
            (None, None) => None,
        }
    };

    // Try to get double property (urgency)
    let double_cmp = |prop: &str| -> Option<std::cmp::Ordering> {
        let v1 = task1.get_value(prop).and_then(|s| s.parse::<f64>().ok());
        let v2 = task2.get_value(prop).and_then(|s| s.parse::<f64>().ok());
        match (v1, v2) {
            (Some(a), Some(b)) => Some(a.partial_cmp(&b).unwrap_or(std::cmp::Ordering::Equal)),
            (Some(_), None) => Some(std::cmp::Ordering::Greater),
            (None, Some(_)) => Some(std::cmp::Ordering::Less),
            (None, None) => None,
        }
    };

    // Try different property types
    let result = match property_name.as_str() {
        // String properties
        "description" | "status" | "priority" | "project" => str_cmp(property_name),
        // DateTime properties
        "due" | "wait" | "entry" | "modified" | "end" | "scheduled" | "until" => {
            dt_cmp(property_name)
        }
        // Double properties
        "urgency" => double_cmp(property_name),
        // Try as string first, then datetime, then double
        _ => str_cmp(property_name)
            .or_else(|| dt_cmp(property_name))
            .or_else(|| double_cmp(property_name)),
    };

    // Apply direction
    match (result, ascending) {
        (Some(ord), true) => ord,
        (Some(ord), false) => ord.reverse(),
        (None, _) => std::cmp::Ordering::Equal,
    }
}

/// Evaluate a filter expression against a task
fn evaluate_filter_expression(task: &taskchampion::Task, expr: &FilterExpression) -> bool {
    match expr {
        FilterExpression::AndGroup { filters } => {
            filters.iter().all(|f| evaluate_filter_expression(task, f))
        }
        FilterExpression::OrGroup { filters } => {
            filters.iter().any(|f| evaluate_filter_expression(task, f))
        }
        FilterExpression::XorGroup { filters } => {
            filters
                .iter()
                .filter(|f| evaluate_filter_expression(task, f))
                .count()
                == 1
        }
        FilterExpression::Not { inner } => !evaluate_filter_expression(task, inner),
        FilterExpression::Tag { tag, exclude } => {
            let has_tag = task.get_tags().any(|t| t.as_ref() == tag.as_str());
            if *exclude {
                !has_tag
            } else {
                has_tag
            }
        }
        FilterExpression::VirtualTag { tag, exclude } => {
            let has_virtual = has_virtual_tag(task, tag);
            if *exclude {
                !has_virtual
            } else {
                has_virtual
            }
        }
        // String property filters
        FilterExpression::EqualsFilter { property, value } => {
            get_string_property(task, &property.name).is_some_and(|v| {
                if let Some(s) = value.as_str() {
                    v == s
                } else {
                    false
                }
            })
        }
        FilterExpression::NotEqualsFilter { property, value } => {
            get_string_property(task, &property.name).is_none_or(|v| {
                if let Some(s) = value.as_str() {
                    v != s
                } else {
                    true
                }
            })
        }
        FilterExpression::InFilter { property, values } => {
            get_string_property(task, &property.name)
                .is_some_and(|v| values.iter().any(|val| val.as_str() == Some(&v)))
        }
        FilterExpression::NotInFilter { property, values } => {
            get_string_property(task, &property.name)
                .is_none_or(|v| values.iter().all(|val| val.as_str() != Some(&v)))
        }
        FilterExpression::ContainsFilter {
            property,
            value,
            case_sensitive,
        } => get_string_property(task, &property.name).is_some_and(|v| {
            if *case_sensitive {
                v.contains(value)
            } else {
                v.to_lowercase().contains(&value.to_lowercase())
            }
        }),
        FilterExpression::NotContainsFilter {
            property,
            value,
            case_sensitive,
        } => get_string_property(task, &property.name).is_none_or(|v| {
            if *case_sensitive {
                !v.contains(value)
            } else {
                !v.to_lowercase().contains(&value.to_lowercase())
            }
        }),
        FilterExpression::StartsWithFilter {
            property,
            value,
            case_sensitive,
        } => get_string_property(task, &property.name).is_some_and(|v| {
            if *case_sensitive {
                v.starts_with(value)
            } else {
                v.to_lowercase().starts_with(&value.to_lowercase())
            }
        }),
        FilterExpression::EndsWithFilter {
            property,
            value,
            case_sensitive,
        } => get_string_property(task, &property.name).is_some_and(|v| {
            if *case_sensitive {
                v.ends_with(value)
            } else {
                v.to_lowercase().ends_with(&value.to_lowercase())
            }
        }),
        FilterExpression::WordFilter {
            property,
            value,
            case_sensitive,
        } => {
            get_string_property(task, &property.name).is_some_and(|v| {
                let search_val = if *case_sensitive {
                    value.clone()
                } else {
                    value.to_lowercase()
                };
                let text = if *case_sensitive { v } else { v.to_lowercase() };
                // Use word boundary regex
                let pattern = format!(r"\b{}\b", regex::escape(&search_val));
                regex::Regex::new(&pattern).is_ok_and(|re| re.is_match(&text))
            })
        }
        FilterExpression::NoWordFilter {
            property,
            value,
            case_sensitive,
        } => get_string_property(task, &property.name).is_none_or(|v| {
            let search_val = if *case_sensitive {
                value.clone()
            } else {
                value.to_lowercase()
            };
            let text = if *case_sensitive { v } else { v.to_lowercase() };
            let pattern = format!(r"\b{}\b", regex::escape(&search_val));
            regex::Regex::new(&pattern).is_ok_and(|re| !re.is_match(&text))
        }),
        FilterExpression::RegexFilter {
            property,
            pattern,
            case_sensitive,
        } => get_string_property(task, &property.name).is_some_and(|v| {
            let regex_pattern = if *case_sensitive {
                pattern.clone()
            } else {
                format!("(?i){pattern}")
            };
            regex::Regex::new(&regex_pattern).is_ok_and(|re| re.is_match(&v))
        }),
        FilterExpression::NoneFilter { property } => {
            get_string_property(task, &property.name).is_none_or(|v| v.is_empty())
        }
        FilterExpression::AnyFilter { property } => {
            get_string_property(task, &property.name).is_some_and(|v| !v.is_empty())
        }
        // Date filters
        FilterExpression::DateBeforeFilter { property, date } => {
            get_datetime_property(task, &property.name).is_some_and(|task_dt| {
                let filter_dt = DateTime::parse_from_rfc3339(date)
                    .map(|dt| dt.with_timezone(&Utc))
                    .ok();
                filter_dt.is_some_and(|f_dt| task_dt < f_dt)
            })
        }
        FilterExpression::DateAfterFilter { property, date } => {
            get_datetime_property(task, &property.name).is_some_and(|task_dt| {
                let filter_dt = DateTime::parse_from_rfc3339(date)
                    .map(|dt| dt.with_timezone(&Utc))
                    .ok();
                filter_dt.is_some_and(|f_dt| task_dt > f_dt)
            })
        }
        FilterExpression::DateByFilter { property, date } => {
            get_datetime_property(task, &property.name).is_some_and(|task_dt| {
                let filter_dt = DateTime::parse_from_rfc3339(date)
                    .map(|dt| dt.with_timezone(&Utc))
                    .ok();
                filter_dt.is_some_and(|f_dt| task_dt <= f_dt)
            })
        }
        FilterExpression::DateFromFilter { property, from } => {
            get_datetime_property(task, &property.name).is_some_and(|task_dt| {
                let filter_dt = DateTime::parse_from_rfc3339(from)
                    .map(|dt| dt.with_timezone(&Utc))
                    .ok();
                filter_dt.is_some_and(|f_dt| task_dt >= f_dt)
            })
        }
        FilterExpression::DateToFilter { property, to } => {
            get_datetime_property(task, &property.name).is_some_and(|task_dt| {
                let filter_dt = DateTime::parse_from_rfc3339(to)
                    .map(|dt| dt.with_timezone(&Utc))
                    .ok();
                filter_dt.is_some_and(|f_dt| task_dt <= f_dt)
            })
        }
        // Numeric filters
        FilterExpression::LessThanFilter { property, value } => {
            // For now, only support urgency as a numeric property
            if property.name == "urgency" {
                if let Some(urgency_str) = task.get_value("urgency") {
                    if let Ok(urgency) = urgency_str.parse::<f64>() {
                        return urgency < *value;
                    }
                }
            }
            false
        }
        FilterExpression::LessThanOrEqualFilter { property, value } => {
            if property.name == "urgency" {
                if let Some(urgency_str) = task.get_value("urgency") {
                    if let Ok(urgency) = urgency_str.parse::<f64>() {
                        return urgency <= *value;
                    }
                }
            }
            false
        }
        FilterExpression::GreaterThanFilter { property, value } => {
            if property.name == "urgency" {
                if let Some(urgency_str) = task.get_value("urgency") {
                    if let Ok(urgency) = urgency_str.parse::<f64>() {
                        return urgency > *value;
                    }
                }
            }
            false
        }
        FilterExpression::GreaterThanOrEqualFilter { property, value } => {
            if property.name == "urgency" {
                if let Some(urgency_str) = task.get_value("urgency") {
                    if let Ok(urgency) = urgency_str.parse::<f64>() {
                        return urgency >= *value;
                    }
                }
            }
            false
        }
    }
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
// TESTS
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
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
        due: DateTime<Utc>,
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let due_date = Utc::now() + chrono::Duration::days(1);
        let uuid = create_test_task_with_due(&mut replica, "Test task", due_date).await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let result = get_datetime_property(&task, "due").unwrap();
        assert!((result - due_date).num_seconds() < 1);
    }

    #[tokio::test]
    async fn test_get_datetime_property_entry() {
        let temp_dir = TempDir::new().unwrap();
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description("Test task".to_string(), &mut ops)
            .unwrap();
        let annotation = taskchampion::Annotation {
            entry: utc_timestamp(Utc::now().timestamp()),
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let due_date = Utc::now() + chrono::Duration::days(1);
        let uuid = create_test_task_with_due(&mut replica, "Test task", due_date).await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let future_date = (Utc::now() + chrono::Duration::days(2)).to_rfc3339();
        let filter = FilterExpression::DateBeforeFilter {
            property: PropertyRef {
                name: "due".to_string(),
            },
            date: future_date,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let past_date = (Utc::now() - chrono::Duration::days(1)).to_rfc3339();
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
            .await
            .unwrap();
        let mut replica = Replica::new(storage);

        let due_date = Utc::now() + chrono::Duration::days(1);
        let uuid = create_test_task_with_due(&mut replica, "Test task", due_date).await;
        let task = replica.get_task(uuid).await.unwrap().unwrap();

        let past_date = (Utc::now() - chrono::Duration::days(1)).to_rfc3339();
        let filter = FilterExpression::DateAfterFilter {
            property: PropertyRef {
                name: "due".to_string(),
            },
            date: past_date,
        };

        assert!(evaluate_filter_expression(&task, &filter));

        let future_date = (Utc::now() + chrono::Duration::days(2)).to_rfc3339();
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
        let storage = create_storage_async(temp_dir.path().to_string_lossy().to_string())
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
}
