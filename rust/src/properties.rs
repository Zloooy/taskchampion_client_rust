use std::collections::HashSet;
use taskchampion::Replica;

use crate::{
    create_storage_async, evaluate_filter_expression, get_datetime_property, get_string_property,
    has_virtual_tag, FilterExpression, SortDirection, TaskFilter, TaskSort,
};

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

// -------------------------------------------------------------------------
// Unit tests - placed directly in the module as requested.
// -------------------------------------------------------------------------
#[cfg(test)]
mod tests {
    use super::*;
    use taskchampion::Operations;
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
}
