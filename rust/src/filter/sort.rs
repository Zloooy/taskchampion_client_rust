//! Sort comparison for tasks (ticket R7).
//!
//! Extracted from the former monolithic `filter.rs`. Houses [`compare_tasks`]
//! (single-sort comparison, still used by the property-value path) and [`compare_tasks_multi`] (SQL `ORDER BY` semantics over a
//! [`TaskSortList`]), plus the small string / datetime / double comparison
//! helpers they compose.

use taskchampion::Task;

use crate::filter::{
    get_datetime_property, get_string_property, SortDirection, TaskSort, TaskSortList,
};

/// Compare two tasks for sorting according to `sort`.
pub fn compare_tasks(task1: &Task, task2: &Task, sort: &TaskSort) -> std::cmp::Ordering {
    compare_task_pair(task1, task2, sort)
}

/// Compare two tasks according to an ordered list of sorts
/// (SQL `ORDER BY` semantics).
///
/// Iterates `sort_list.sorts` in order and returns the first non-`Equal`
/// ordering. If every key compares equal (or the list is empty), returns
/// [`std::cmp::Ordering::Equal`].
pub fn compare_tasks_multi(
    task1: &Task,
    task2: &Task,
    sort_list: &TaskSortList,
) -> std::cmp::Ordering {
    for sort in &sort_list.sorts {
        let ordering = compare_task_pair(task1, task2, sort);
        if ordering != std::cmp::Ordering::Equal {
            return ordering;
        }
    }
    std::cmp::Ordering::Equal
}

/// Per-key comparison shared by [`compare_tasks`] and [`compare_tasks_multi`].
fn compare_task_pair(task1: &Task, task2: &Task, sort: &TaskSort) -> std::cmp::Ordering {
    let property_name = &sort.property.name;
    let ascending = sort.direction == SortDirection::Ascending;

    let str_cmp = |prop: &str| -> Option<std::cmp::Ordering> {
        optional_cmp(
            get_string_property(task1, prop),
            get_string_property(task2, prop),
        )
    };

    let dt_cmp = |prop: &str| -> Option<std::cmp::Ordering> {
        optional_cmp(
            get_datetime_property(task1, prop),
            get_datetime_property(task2, prop),
        )
    };

    let double_cmp = |prop: &str| -> Option<std::cmp::Ordering> {
        let v1 = task1.get_value(prop).and_then(|s| s.parse::<f64>().ok());
        let v2 = task2.get_value(prop).and_then(|s| s.parse::<f64>().ok());
        // f64 is only PartialOrd, so it needs its own comparison (no Ord).
        match (v1, v2) {
            (Some(a), Some(b)) => Some(a.partial_cmp(&b).unwrap_or(std::cmp::Ordering::Equal)),
            (Some(_), None) => Some(std::cmp::Ordering::Greater),
            (None, Some(_)) => Some(std::cmp::Ordering::Less),
            (None, None) => None,
        }
    };

    let result = match property_name.as_str() {
        "description" | "status" | "priority" | "project" => str_cmp(property_name),
        "due" | "wait" | "entry" | "modified" | "end" | "scheduled" | "until" => {
            dt_cmp(property_name)
        }
        "urgency" => double_cmp(property_name),
        _ => str_cmp(property_name)
            .or_else(|| dt_cmp(property_name))
            .or_else(|| double_cmp(property_name)),
    };

    match (result, ascending) {
        (Some(ord), true) => ord,
        (Some(ord), false) => ord.reverse(),
        (None, _) => std::cmp::Ordering::Equal,
    }
}

/// Compare two `Option<T: Ord>` values, treating `Some` as greater than
/// `None` (so that tasks missing a property sort after tasks that have it).
fn optional_cmp<T: Ord>(a: Option<T>, b: Option<T>) -> Option<std::cmp::Ordering> {
    match (a, b) {
        (Some(a), Some(b)) => Some(a.cmp(&b)),
        (Some(_), None) => Some(std::cmp::Ordering::Greater),
        (None, Some(_)) => Some(std::cmp::Ordering::Less),
        (None, None) => None,
    }
}

// ============================================================================
// SORT TESTS
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use crate::create_storage_async;
    use crate::SortProperty;
    use chrono::{DateTime, Utc};
    use taskchampion::storage::Storage;
    use taskchampion::{Operations, Replica, Status};
    use tempfile::TempDir;
    use uuid::Uuid;

    /// Create a task with a description, status, and an optional user-defined
    /// attribute (e.g. `project`).
    async fn create_task<S: Storage>(
        replica: &mut Replica<S>,
        description: &str,
        status: Status,
        project: Option<&str>,
    ) -> Uuid {
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description(description.to_string(), &mut ops)
            .unwrap();
        task.set_status(status, &mut ops).unwrap();
        if let Some(project) = project {
            task.set_user_defined_attribute("project".to_string(), project.to_string(), &mut ops)
                .unwrap();
        }
        replica.commit_operations(ops).await.unwrap();
        uuid
    }

    /// Create a task with a due date.
    async fn create_task_with_due<S: Storage>(
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

    async fn build_replica(dir: &TempDir) -> Replica<taskchampion::SqliteStorage> {
        let storage = create_storage_async(dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        Replica::new(storage)
    }

    fn sort(name: &str, direction: SortDirection) -> TaskSort {
        TaskSort {
            property: SortProperty {
                name: name.to_string(),
            },
            direction,
        }
    }

    #[test]
    fn test_compare_tasks_multi_primary_key_decides() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let a = create_task(&mut replica, "A", Status::Pending, Some("work")).await;
            let b = create_task(&mut replica, "B", Status::Pending, Some("home")).await;
            let task_a = replica.get_task(a).await.unwrap().unwrap();
            let task_b = replica.get_task(b).await.unwrap().unwrap();

            // Primary key (description asc) decides; the second key is never
            // consulted because the first key already differs.
            let list = TaskSortList {
                sorts: vec![
                    sort("description", SortDirection::Ascending),
                    sort("project", SortDirection::Descending),
                ],
            };
            assert_eq!(
                compare_tasks_multi(&task_a, &task_b, &list),
                std::cmp::Ordering::Less
            );
            assert_eq!(
                compare_tasks_multi(&task_b, &task_a, &list),
                std::cmp::Ordering::Greater
            );
        });
    }

    #[test]
    fn test_compare_tasks_multi_tie_break_on_second_key() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            // Same description, different projects.
            let a = create_task(&mut replica, "Same", Status::Pending, Some("alpha")).await;
            let b = create_task(&mut replica, "Same", Status::Pending, Some("beta")).await;
            let task_a = replica.get_task(a).await.unwrap().unwrap();
            let task_b = replica.get_task(b).await.unwrap().unwrap();

            let list = TaskSortList {
                sorts: vec![
                    sort("description", SortDirection::Ascending),
                    sort("project", SortDirection::Ascending),
                ],
            };
            assert_eq!(
                compare_tasks_multi(&task_a, &task_b, &list),
                std::cmp::Ordering::Less
            );
            assert_eq!(
                compare_tasks_multi(&task_b, &task_a, &list),
                std::cmp::Ordering::Greater
            );
        });
    }

    #[test]
    fn test_compare_tasks_multi_per_key_direction() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            // Same project; due dates differ.
            let early = Utc::now() + chrono::Duration::days(1);
            let late = Utc::now() + chrono::Duration::days(10);
            let a = create_task_with_due(&mut replica, "A", early).await;
            let b = create_task_with_due(&mut replica, "B", late).await;
            let task_a = replica.get_task(a).await.unwrap().unwrap();
            let task_b = replica.get_task(b).await.unwrap().unwrap();

            // First key (project) is equal; second key (due) is descending,
            // so the later due date sorts first.
            let list = TaskSortList {
                sorts: vec![
                    sort("project", SortDirection::Ascending),
                    sort("due", SortDirection::Descending),
                ],
            };
            assert_eq!(
                compare_tasks_multi(&task_a, &task_b, &list),
                std::cmp::Ordering::Greater
            );
            assert_eq!(
                compare_tasks_multi(&task_b, &task_a, &list),
                std::cmp::Ordering::Less
            );
        });
    }

    #[test]
    fn test_compare_tasks_multi_all_keys_equal_returns_equal() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let a = create_task(&mut replica, "Same", Status::Pending, Some("proj")).await;
            let b = create_task(&mut replica, "Same", Status::Pending, Some("proj")).await;
            let task_a = replica.get_task(a).await.unwrap().unwrap();
            let task_b = replica.get_task(b).await.unwrap().unwrap();

            let list = TaskSortList {
                sorts: vec![
                    sort("description", SortDirection::Ascending),
                    sort("project", SortDirection::Descending),
                ],
            };
            assert_eq!(
                compare_tasks_multi(&task_a, &task_b, &list),
                std::cmp::Ordering::Equal
            );
        });
    }

    #[test]
    fn test_compare_tasks_multi_empty_list_returns_equal() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let a = create_task(&mut replica, "A", Status::Pending, None).await;
            let b = create_task(&mut replica, "B", Status::Pending, None).await;
            let task_a = replica.get_task(a).await.unwrap().unwrap();
            let task_b = replica.get_task(b).await.unwrap().unwrap();

            let list = TaskSortList { sorts: vec![] };
            assert_eq!(
                compare_tasks_multi(&task_a, &task_b, &list),
                std::cmp::Ordering::Equal
            );
        });
    }
}
