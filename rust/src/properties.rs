use serde::{Deserialize, Serialize};
use std::collections::HashSet;
use taskchampion::Replica;

use crate::{
    create_storage_async, evaluate_filter_expression, get_datetime_property, get_string_property,
    has_virtual_tag, FilterExpression, SortDirection, TaskFilter, TaskSort,
};

/// The type of values expected from a property query.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum PropertyReturnType {
    /// Return raw string values.
    String,
    /// Return RFC-3339 datetime strings that can be parsed as DateTime.
    DateTime,
    /// Return task status enum values.
    EnumStatus,
    /// Return task priority enum values.
    EnumPriority,
}

/// Retrieve distinct values for a given task property.
///
/// * `taskdb_dir_path` - path to the TaskChampion SQLite directory.
/// * `property` - name of the property to query (e.g. "description", "due").
/// * `filter_json` - optional JSON describing a `TaskFilter` to limit the tasks.
/// * `sort_json` - optional JSON describing a `TaskSort` that may affect the order of the returned list.
#[flutter_rust_bridge::frb]
pub async fn get_task_property_values(
    taskdb_dir_path: String,
    property: String,
    filter_json: Option<String>,
    sort_json: Option<String>,
) -> Result<Vec<String>, anyhow::Error> {
    let storage = create_storage_async(taskdb_dir_path).await?;
    let mut replica = Replica::new(storage);

    let filter_opt: Option<FilterExpression> = if let Some(fjson) = filter_json {
        let tf: TaskFilter = serde_json::from_str(&fjson)?;
        Some(tf.filter)
    } else {
        None
    };

    let base_tasks: Vec<taskchampion::Task> = if let Some(ref filter) = filter_opt {
        if let FilterExpression::EqualsFilter { property, value } = filter {
            if property.name == "status" && value.as_str() == Some("pending") {
                replica.pending_tasks().await?.into_iter().collect()
            } else {
                replica.all_tasks().await?.into_values().collect()
            }
        } else {
            replica.all_tasks().await?.into_values().collect()
        }
    } else {
        replica.all_tasks().await?.into_values().collect()
    };

    let tasks: Vec<taskchampion::Task> = if let Some(ref filter) = filter_opt {
        base_tasks
            .into_iter()
            .filter(|t| evaluate_filter_expression(t, filter))
            .collect()
    } else {
        base_tasks
    };

    let mut distinct: HashSet<String> = HashSet::new();

    for task in tasks {
        if let Some(val) = get_string_property(&task, &property) {
            distinct.insert(val);
            continue;
        }
        if let Some(dt) = get_datetime_property(&task, &property) {
            distinct.insert(dt.to_rfc3339());
            continue;
        }
        if let Some(raw) = task.get_value(&property) {
            distinct.insert(raw.to_string());
        }
    }

    let mut values: Vec<String> = distinct.into_iter().collect();
    if let Some(sort_str) = sort_json {
        if let Ok(sort) = serde_json::from_str::<TaskSort>(&sort_str) {
            if sort.property.name == property {
                if sort.direction == SortDirection::Ascending {
                    values.sort();
                } else {
                    values.sort_by(|a, b| b.cmp(a));
                }
            }
        }
    } else {
        values.sort();
    }

    Ok(values)
}

/// Retrieve distinct tag values from tasks, with optional virtual tag inclusion and pattern filtering.
///
/// * `taskdb_dir_path` - path to the TaskChampion SQLite directory.
/// * `filter_json` - optional JSON describing a `TaskFilter` to limit the tasks.
/// * `include_virtual_tags` - when true, include virtual tags (tags starting with '+' or '-').
/// * `pattern` - optional case-insensitive substring that a tag must contain.
#[flutter_rust_bridge::frb]
pub async fn get_tags(
    taskdb_dir_path: String,
    filter_json: Option<String>,
    include_virtual_tags: bool,
    pattern: Option<String>,
) -> Result<Vec<String>, anyhow::Error> {
    let storage = create_storage_async(taskdb_dir_path).await?;
    let mut replica = Replica::new(storage);

    let filter_opt: Option<FilterExpression> = if let Some(fjson) = filter_json {
        let tf: TaskFilter = serde_json::from_str(&fjson)?;
        Some(tf.filter)
    } else {
        None
    };

    let base_tasks: Vec<taskchampion::Task> = if let Some(ref filter) = filter_opt {
        if let FilterExpression::EqualsFilter { property, value } = filter {
            if property.name == "status" && value.as_str() == Some("pending") {
                replica.pending_tasks().await?.into_iter().collect()
            } else {
                replica.all_tasks().await?.into_values().collect()
            }
        } else {
            replica.all_tasks().await?.into_values().collect()
        }
    } else {
        replica.all_tasks().await?.into_values().collect()
    };

    let tasks: Vec<taskchampion::Task> = if let Some(ref filter) = filter_opt {
        base_tasks
            .into_iter()
            .filter(|t| evaluate_filter_expression(t, filter))
            .collect()
    } else {
        base_tasks
    };

    let mut distinct: HashSet<String> = HashSet::new();
    let pattern_lc = pattern.as_ref().map(|p| p.to_lowercase());

    for task in tasks {
        for tag in task.get_tags() {
            let tag_str = tag.to_string();
            if !include_virtual_tags && has_virtual_tag(&task, &tag_str) {
                continue;
            }
            if let Some(ref pat) = pattern_lc {
                if !tag_str.to_lowercase().contains(pat) {
                    continue;
                }
            }
            distinct.insert(tag_str);
        }
    }

    let mut values: Vec<String> = distinct.into_iter().collect();
    values.sort();
    Ok(values)
}

/// Retrieve distinct property values with typed conversion.
///
/// This is a typed version of [`get_task_property_values`] that converts the
/// returned values to the requested type (`String`, `DateTime`, `TaskStatus`,
/// or `TaskPriority`).
///
/// * `taskdb_dir_path` - path to the TaskChampion SQLite directory.
/// * `property` - name of the property to query (e.g. "description", "due", "status").
/// * `return_type` - the type of values expected.
/// * `filter_json` - optional JSON describing a `TaskFilter` to limit the tasks.
/// * `sort_json` - optional JSON describing a `TaskSort` that may affect the order.
#[allow(clippy::collapsible_match)]
pub async fn get_task_property_values_typed(
    taskdb_dir_path: String,
    property: String,
    return_type: PropertyReturnType,
    filter_json: Option<String>,
    sort_json: Option<String>,
) -> Result<Vec<String>, anyhow::Error> {
    let storage = create_storage_async(taskdb_dir_path).await?;
    let mut replica = Replica::new(storage);

    let filter_opt: Option<FilterExpression> = if let Some(fjson) = filter_json {
        let tf: TaskFilter = serde_json::from_str(&fjson)?;
        Some(tf.filter)
    } else {
        None
    };

    let base_tasks: Vec<taskchampion::Task> = if let Some(ref filter) = filter_opt {
        if let FilterExpression::EqualsFilter { property, value } = filter {
            if property.name == "status" && value.as_str() == Some("pending") {
                replica.pending_tasks().await?.into_iter().collect()
            } else {
                replica.all_tasks().await?.into_values().collect()
            }
        } else {
            replica.all_tasks().await?.into_values().collect()
        }
    } else {
        replica.all_tasks().await?.into_values().collect()
    };

    let tasks: Vec<taskchampion::Task> = if let Some(ref filter) = filter_opt {
        base_tasks
            .into_iter()
            .filter(|t| evaluate_filter_expression(t, filter))
            .collect()
    } else {
        base_tasks
    };

    let mut raw_values: HashSet<String> = HashSet::new();

    for task in tasks {
        match return_type {
            PropertyReturnType::String => {
                if let Some(val) = get_string_property(&task, &property) {
                    raw_values.insert(val);
                }
            }
            PropertyReturnType::DateTime => {
                if let Some(dt) = get_datetime_property(&task, &property) {
                    raw_values.insert(dt.to_rfc3339());
                }
            }
            PropertyReturnType::EnumStatus => {
                if let Some(raw) = task.get_value(&property) {
                    let val_str = raw.to_string();
                    // Validate it's a valid status value
                    match val_str.as_str() {
                        "pending" | "completed" | "deleted" => {
                            raw_values.insert(val_str);
                        }
                        _ => {} // skip invalid values silently
                    }
                }
            }
            PropertyReturnType::EnumPriority => {
                if let Some(raw) = task.get_value(&property) {
                    let val_str = raw.to_string();
                    // Validate it's a valid priority value
                    match val_str.as_str() {
                        "high" | "medium" | "low" | "none" => {
                            raw_values.insert(val_str);
                        }
                        _ => {} // skip invalid values silently
                    }
                }
            }
        }
    }

    let mut values: Vec<String> = raw_values.into_iter().collect();
    if let Some(sort_str) = sort_json {
        if let Ok(sort) = serde_json::from_str::<TaskSort>(&sort_str) {
            if sort.property.name == property {
                if sort.direction == SortDirection::Ascending {
                    values.sort();
                } else {
                    values.sort_by(|a, b| b.cmp(a));
                }
            }
        }
    } else {
        values.sort();
    }

    Ok(values)
}

/// Retrieve all possible enum values for a given property type.
///
/// Only supports `EnumStatus` and `EnumPriority`. For any other return type,
/// returns an error.
///
/// * `return_type` - the type of enum values to return.
pub fn get_all_enum_values(return_type: PropertyReturnType) -> Result<Vec<String>, anyhow::Error> {
    match return_type {
        PropertyReturnType::EnumStatus => Ok(vec![
            "completed".to_string(),
            "deleted".to_string(),
            "pending".to_string(),
        ]),
        PropertyReturnType::EnumPriority => Ok(vec![
            "high".to_string(),
            "low".to_string(),
            "medium".to_string(),
            "none".to_string(),
        ]),
        PropertyReturnType::String | PropertyReturnType::DateTime => Err(anyhow::anyhow!(
            "getAllPropertyValues only supports enum types (EnumStatus, EnumPriority)"
        )),
    }
}

// -------------------------------------------------------------------------
// Unit tests - placed directly in the module as requested.
// -------------------------------------------------------------------------
#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Utc;
    use taskchampion::Operations;
    use taskchampion::Status;
    use tempfile::TempDir;
    use uuid::Uuid;

    #[tokio::test]
    async fn distinct_string_values() {
        let td = TempDir::new().unwrap();
        let path = td.path().to_str().unwrap().to_string();

        // Create test data
        {
            let storage = create_storage_async(path.clone()).await.unwrap();
            let mut replica = Replica::new(storage);
            for desc in &["alpha", "beta", "alpha"] {
                let mut ops = Operations::new();
                let uuid = Uuid::new_v4();
                let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
                task.set_description((*desc).to_string(), &mut ops).unwrap();
                replica.commit_operations(ops).await.unwrap();
            }
            drop(replica);
        }

        let result = get_task_property_values(path, "description".to_string(), None, None)
            .await
            .unwrap();
        assert_eq!(result, vec!["alpha".to_string(), "beta".to_string()]);
    }

    #[tokio::test]
    async fn typed_string_values() {
        let td = TempDir::new().unwrap();
        let path = td.path().to_str().unwrap().to_string();

        {
            let storage = create_storage_async(path.clone()).await.unwrap();
            let mut replica = Replica::new(storage);
            for desc in &["project-a", "project-b", "project-a"] {
                let mut ops = Operations::new();
                let uuid = Uuid::new_v4();
                let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
                task.set_user_defined_attribute(
                    "project".to_string(),
                    (*desc).to_string(),
                    &mut ops,
                )
                .unwrap();
                replica.commit_operations(ops).await.unwrap();
            }
            drop(replica);
        }

        let result = get_task_property_values_typed(
            path,
            "project".to_string(),
            PropertyReturnType::String,
            None,
            None,
        )
        .await
        .unwrap();
        assert_eq!(
            result,
            vec!["project-a".to_string(), "project-b".to_string()]
        );
    }

    #[tokio::test]
    async fn typed_datetime_values() {
        let td = TempDir::new().unwrap();
        let path = td.path().to_str().unwrap().to_string();

        {
            let storage = create_storage_async(path.clone()).await.unwrap();
            let mut replica = Replica::new(storage);
            for date_str in &["2024-01-15T10:00:00Z", "2024-02-20T15:30:00Z"] {
                let mut ops = Operations::new();
                let uuid = Uuid::new_v4();
                let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
                let dt = chrono::DateTime::parse_from_rfc3339(date_str)
                    .unwrap()
                    .with_timezone(&Utc);
                task.set_due(Some(dt), &mut ops).unwrap();
                replica.commit_operations(ops).await.unwrap();
            }
            drop(replica);
        }

        let result = get_task_property_values_typed(
            path,
            "due".to_string(),
            PropertyReturnType::DateTime,
            None,
            None,
        )
        .await
        .unwrap();
        assert_eq!(result.len(), 2);
    }

    #[tokio::test]
    async fn typed_enum_status_values() {
        let td = TempDir::new().unwrap();
        let path = td.path().to_str().unwrap().to_string();

        {
            let storage = create_storage_async(path.clone()).await.unwrap();
            let mut replica = Replica::new(storage);
            let statuses = [Status::Pending, Status::Completed, Status::Pending];
            for status in &statuses {
                let mut ops = Operations::new();
                let uuid = Uuid::new_v4();
                let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
                task.set_status(status.clone(), &mut ops).unwrap();
                replica.commit_operations(ops).await.unwrap();
            }
            drop(replica);
        }

        let result = get_task_property_values_typed(
            path,
            "status".to_string(),
            PropertyReturnType::EnumStatus,
            None,
            None,
        )
        .await
        .unwrap();
        assert_eq!(result, vec!["completed".to_string(), "pending".to_string()]);
    }

    #[tokio::test]
    async fn typed_enum_priority_values() {
        let td = TempDir::new().unwrap();
        let path = td.path().to_str().unwrap().to_string();

        {
            let storage = create_storage_async(path.clone()).await.unwrap();
            let mut replica = Replica::new(storage);
            for priority in &["high", "medium", "high"] {
                let mut ops = Operations::new();
                let uuid = Uuid::new_v4();
                let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
                task.set_priority(priority.to_string(), &mut ops).unwrap();
                replica.commit_operations(ops).await.unwrap();
            }
            drop(replica);
        }

        let result = get_task_property_values_typed(
            path,
            "priority".to_string(),
            PropertyReturnType::EnumPriority,
            None,
            None,
        )
        .await
        .unwrap();
        assert_eq!(result, vec!["high".to_string(), "medium".to_string()]);
    }

    #[tokio::test]
    async fn get_all_enum_values_status() {
        let result = get_all_enum_values(PropertyReturnType::EnumStatus).unwrap();
        assert_eq!(
            result,
            vec![
                "completed".to_string(),
                "deleted".to_string(),
                "pending".to_string()
            ]
        );
    }

    #[tokio::test]
    async fn get_all_enum_values_priority() {
        let result = get_all_enum_values(PropertyReturnType::EnumPriority).unwrap();
        assert_eq!(
            result,
            vec![
                "high".to_string(),
                "low".to_string(),
                "medium".to_string(),
                "none".to_string()
            ]
        );
    }

    #[tokio::test]
    async fn get_all_enum_values_rejects_non_enum() {
        let result = get_all_enum_values(PropertyReturnType::String);
        assert!(result.is_err());

        let result = get_all_enum_values(PropertyReturnType::DateTime);
        assert!(result.is_err());
    }
}
