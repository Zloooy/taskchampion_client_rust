use chrono::{DateTime, Utc};
use std::collections::HashMap;
use std::str::FromStr;
use taskchampion::{utc_timestamp, Operations, Replica, Status, Tag};
use uuid::Uuid;

/// Parse a datetime string into a DateTime<Utc>
/// Returns None if the string is empty or invalid
pub fn parse_datetime(dt_str: &str) -> Option<DateTime<Utc>> {
    if dt_str.is_empty() {
        return None;
    }
    DateTime::parse_from_rfc3339(dt_str)
        .map(|dt| dt.with_timezone(&Utc))
        .ok()
}

/// Apply task fields from a HashMap
fn apply_task_data(
    task: &mut taskchampion::Task,
    task_data: &HashMap<String, String>,
    ops: &mut Operations,
    clear_existing: bool,
) -> Result<(), anyhow::Error> {
    if let Some(desc) = task_data.get("description") {
        task.set_description(desc.clone(), ops)?;
    }

    if let Some(status) = task_data.get("status") {
        let task_status = match status.as_str() {
            "completed" => Status::Completed,
            "deleted" => Status::Deleted,
            _ => Status::Pending,
        };
        task.set_status(task_status, ops)?;
    }

    if let Some(priority) = task_data.get("priority") {
        task.set_priority(priority.clone(), ops)?;
    }

    if let Some(due) = task_data.get("due") {
        if let Some(dt) = parse_datetime(due) {
            task.set_due(Some(dt), ops)?;
        }
    }

    if let Some(wait) = task_data.get("wait") {
        if let Some(dt) = parse_datetime(wait) {
            task.set_wait(Some(dt), ops)?;
        }
    }

    // Handle tags
    if let Some(tags_str) = task_data.get("tags") {
        if clear_existing {
            let existing_tags: Vec<Tag> = task.get_tags().collect();
            for tag in existing_tags {
                task.remove_tag(&tag, ops)?;
            }
        }
        for tag in tags_str.split_whitespace() {
            let tag = Tag::from_str(tag)?;
            task.add_tag(&tag, ops)?;
        }
    }

    // Handle dependencies
    if let Some(depends_str) = task_data.get("depends") {
        if clear_existing {
            let existing_deps: Vec<Uuid> = task.get_dependencies().collect();
            for dep in existing_deps {
                task.remove_dependency(dep, ops)?;
            }
        }
        for dep_uuid_str in depends_str.split_whitespace() {
            if let Ok(dep_uuid) = Uuid::parse_str(dep_uuid_str) {
                task.add_dependency(dep_uuid, ops)?;
            }
        }
    }

    // Handle annotations
    if clear_existing {
        let existing_annotations: Vec<i64> = task
            .get_annotations()
            .map(|a| a.entry.timestamp())
            .collect();
        for ts in existing_annotations {
            task.remove_annotation(utc_timestamp(ts), ops)?;
        }
    }
    for (key, value) in task_data.iter() {
        if let Some(ts_str) = key.strip_prefix("annotation_") {
            if let Ok(ts) = ts_str.parse::<i64>() {
                let annotation = taskchampion::Annotation {
                    entry: utc_timestamp(ts),
                    description: value.clone(),
                };
                task.add_annotation(annotation, ops)?;
            }
        }
    }

    // Handle UDAs
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
            if key == "scheduled" || key == "until" {
                if let Some(dt) = parse_datetime(value) {
                    task.set_user_defined_attribute(key.clone(), dt.to_rfc3339(), ops)?;
                }
            } else {
                task.set_user_defined_attribute(key.clone(), value.clone(), ops)?;
            }
        }
    }

    Ok(())
}

/// Convert a HashMap task data to taskchampion Task
pub async fn create_task_from_map<S: taskchampion::storage::Storage>(
    replica: &mut Replica<S>,
    task_data: HashMap<String, String>,
) -> Result<Uuid, anyhow::Error> {
    let mut ops = Operations::new();

    let uuid = Uuid::new_v4();
    let mut task = replica.create_task(uuid, &mut ops).await?;

    apply_task_data(&mut task, &task_data, &mut ops, false)?;

    replica.commit_operations(ops).await?;

    Ok(uuid)
}

/// Update an existing task with new data
pub async fn update_task_in_replica<S: taskchampion::storage::Storage>(
    replica: &mut Replica<S>,
    uuid: Uuid,
    task_data: HashMap<String, String>,
) -> Result<(), anyhow::Error> {
    let mut ops = Operations::new();
    let mut task = replica
        .get_task(uuid)
        .await?
        .ok_or_else(|| anyhow::anyhow!("Task not found"))?;

    apply_task_data(&mut task, &task_data, &mut ops, true)?;

    replica.commit_operations(ops).await?;

    Ok(())
}

/// Convert taskchampion Task to HashMap for JSON serialization
pub fn task_to_map(task: &taskchampion::Task) -> HashMap<String, String> {
    let mut map = HashMap::new();

    map.insert("uuid".to_string(), task.get_uuid().to_string());
    map.insert(
        "description".to_string(),
        task.get_description().to_string(),
    );
    let status_str = match task.get_status() {
        taskchampion::Status::Pending => "pending",
        taskchampion::Status::Completed => "completed",
        taskchampion::Status::Deleted => "deleted",
        taskchampion::Status::Recurring => "recurring",
        taskchampion::Status::Unknown(_) => "unknown",
    };
    map.insert("status".to_string(), status_str.to_string());

    if let Some(entry) = task.get_entry() {
        map.insert("entry".to_string(), entry.to_rfc3339());
    } else {
        map.insert("entry".to_string(), chrono::Utc::now().to_rfc3339());
    }

    if let Some(modified) = task.get_modified() {
        map.insert("modified".to_string(), modified.to_rfc3339());
    }

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

    let tags: Vec<String> = task
        .get_tags()
        .filter_map(|t| {
            let tag_str = t.to_string();
            if crate::filter::has_virtual_tag(task, &tag_str) {
                None
            } else {
                Some(tag_str)
            }
        })
        .collect();
    map.insert("tags".to_string(), tags.join(" "));

    let deps: Vec<String> = task.get_dependencies().map(|u| u.to_string()).collect();
    map.insert("depends".to_string(), deps.join(" "));

    for annotation in task.get_annotations() {
        let key = format!("annotation_{}", annotation.entry.timestamp());
        map.insert(key, annotation.description);
    }

    for (key, value) in task.get_user_defined_attributes() {
        map.insert(key.to_string(), value.to_string());
    }

    map
}

// ============================================================================
// TESTS
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use crate::create_storage_async;
    use chrono::Datelike;
    use taskchampion::Operations;
    use taskchampion::Replica;
    use tempfile::TempDir;

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

    async fn build_replica(dir: &TempDir) -> taskchampion::Replica<taskchampion::SqliteStorage> {
        let storage = create_storage_async(dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        taskchampion::Replica::new(storage)
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

    #[test]
    fn test_create_task_basic() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;
            let mut task_data: HashMap<String, String> = HashMap::new();
            task_data.insert("description".to_string(), "Test task".to_string());
            task_data.insert("status".to_string(), "pending".to_string());
            let uuid = create_task_from_map(&mut replica, task_data).await.unwrap();
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(task.get_description(), "Test task");
        });
    }

    #[test]
    fn test_update_task() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;
            let mut create_ops = Operations::new();
            let uuid = Uuid::new_v4();
            let mut task = replica.create_task(uuid, &mut create_ops).await.unwrap();
            task.set_description("Original".to_string(), &mut create_ops)
                .unwrap();
            replica.commit_operations(create_ops).await.unwrap();

            let mut update_data: HashMap<String, String> = HashMap::new();
            update_data.insert("description".to_string(), "Updated".to_string());
            update_task_in_replica(&mut replica, uuid, update_data)
                .await
                .unwrap();

            let updated_task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(updated_task.get_description(), "Updated");
        });
    }

    #[test]
    fn test_task_to_map() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "H").await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let map = task_to_map(&task);
            assert_eq!(map.get("description"), Some(&"Test task".to_string()));
            assert_eq!(map.get("status"), Some(&"pending".to_string()));
            assert_eq!(map.get("priority"), Some(&"H".to_string()));
        });
    }
}
