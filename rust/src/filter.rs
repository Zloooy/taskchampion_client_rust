use chrono::{DateTime, Utc};
use taskchampion::storage::Storage;
use taskchampion::{Replica, Task};

// ============================================================================
// Regex compilation cache (ticket R2)
// ============================================================================
//
// `RegexFilter` and `WordFilter` previously called `Regex::new` inside the
// per-task closure inside `evaluate_filter_expression`. For large task
// databases this recompiles the same pattern thousands of times.
//
// We memoise compiled regexes per-pattern-string in a thread-local cache so
// that subsequent evaluations within the same thread (which is the common
// case during a single filter pass on the FRB-owned tokio worker) reuse the
// already-compiled `Regex`. Compilation failures are cached as `None` to keep
// the observable behaviour identical to the previous `is_ok_and(|re| ...)`
// fall-through (an invalid pattern simply never matches).
//
// `Regex` is `Send` but not `Sync`-cheaply-enough for our purposes; the
// thread-local avoids locking entirely on the hot path.

use regex::Regex;
use std::cell::RefCell;
use std::collections::HashMap;

thread_local! {
    /// Per-thread cache of compiled regexes, keyed by the exact pattern string
    /// (including any inline `(?i)` flag we prepend for case-insensitive matches).
    static REGEX_CACHE: RefCell<HashMap<String, Option<Regex>>> =
        RefCell::new(HashMap::new());
}

/// Compile (or fetch the cached compilation of) a regex pattern.
///
/// Returns `None` when the pattern is not a valid regex, mirroring the
/// previous `Regex::new(..).ok()` behaviour.
fn compile_regex(pattern: &str) -> Option<Regex> {
    REGEX_CACHE.with(|cache| {
        let borrowed = cache.borrow();
        if let Some(existing) = borrowed.get(pattern) {
            return existing.clone();
        }
        drop(borrowed);
        let compiled = Regex::new(pattern).ok();
        cache
            .borrow_mut()
            .insert(pattern.to_string(), compiled.clone());
        compiled
    })
}

// ============================================================================
// Sub-modules (ticket R7 split)
// ============================================================================

mod evaluator;
mod sort;

pub(crate) use evaluator::evaluate_filter_expression;
pub use sort::compare_tasks;

/// Property reference used both for filtering and for sorting.
///
/// Ticket R9 consolidated the previously-duplicated `PropertyRef` and
/// `SortProperty` structs (both were `{ name: String }`) into this single
/// type. `SortProperty` is kept as a deprecated alias so external/serde
/// references keep compiling.
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
pub struct PropertyRef {
    pub name: String,
}

/// Legacy alias for [`PropertyRef`] used in sort specifications.
///
/// Prefer `PropertyRef` in new code; this alias exists for backward
/// compatibility with serialised sort specs and existing call sites.
pub type SortProperty = PropertyRef;

/// Sort direction enum
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum SortDirection {
    Ascending,
    Descending,
}

/// Sort specification
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
pub struct TaskSort {
    pub property: SortProperty,
    pub direction: SortDirection,
}

/// Main filter expression type (taskwarrior-compatible)
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
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
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
pub struct TaskFilter {
    pub filter: FilterExpression,
}

/// Get a string property value from a task
pub(crate) fn get_string_property(task: &Task, property_name: &str) -> Option<String> {
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
pub(crate) fn get_datetime_property(task: &Task, property_name: &str) -> Option<DateTime<Utc>> {
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

/// Check if a task has a virtual tag.
///
/// Thin delegation to the central [`crate::virtual_tags`] registry (ticket R6).
/// Kept here as a `pub(crate)` shim so existing call sites inside the crate
/// keep compiling without touching every reference.
pub(crate) fn has_virtual_tag(task: &Task, tag: &str) -> bool {
    crate::virtual_tags::has_virtual_tag(task, tag)
}

/// Parse an optional JSON-encoded [`TaskFilter`] into an optional [`FilterExpression`].
///
/// Returns `Ok(None)` when `filter_json` is `None`. Returns an error if the JSON
/// string cannot be deserialized into a `TaskFilter`. This centralizes the
/// `filter_opt` parsing previously duplicated across the API and property queries.
pub(crate) fn parse_filter_option(
    filter_json: Option<String>,
) -> anyhow::Result<Option<FilterExpression>> {
    match filter_json {
        Some(json) => {
            let task_filter: TaskFilter = serde_json::from_str(&json)?;
            Ok(Some(task_filter.filter))
        }
        None => Ok(None),
    }
}

/// Returns `true` when `expr` constrains the task set to `status == pending`
/// and nothing else useful for the fast path, i.e. when `pending_tasks()` is
/// a safe superset of the candidates the filter would ever accept.
///
/// Recognised shapes (ticket R3):
/// * `EqualsFilter { property: "status", value: "pending" }`
/// * `AndGroup { ..., EqualsFilter { property: "status", value: "pending" }, ... }`
///
/// Because `pending_tasks()` returns every pending task, any AND-combination
/// that *includes* a `status == pending` constraint is still a subset of the
/// pending set, so the fast path applies. OR-groups and NOT-wrapped status
/// filters do *not* qualify, because they could admit non-pending tasks.
fn implies_pending_only(expr: &FilterExpression) -> bool {
    fn is_status_pending(property: &PropertyRef, value: &serde_json::Value) -> bool {
        property.name == "status" && value.as_str() == Some("pending")
    }

    match expr {
        FilterExpression::EqualsFilter { property, value } => is_status_pending(property, value),
        FilterExpression::AndGroup { filters } => filters.iter().any(implies_pending_only),
        _ => false,
    }
}

/// Collect the base set of tasks to evaluate, applying the pending-status fast path.
///
/// When the filter constrains the result to `status == pending` (either as a
/// top-level `EqualsFilter` or inside an `AndGroup` — the most common real
/// query shape), TaskChampion's built-in [`Replica::pending_tasks`] is used
/// for better performance. Otherwise all tasks are loaded. The resulting
/// tasks still need to be passed through [`evaluate_filter_expression`] when a
/// filter is present.
pub(crate) async fn collect_base_tasks<S: Storage>(
    replica: &mut Replica<S>,
    filter_opt: Option<&FilterExpression>,
) -> anyhow::Result<Vec<Task>> {
    if filter_opt.is_some_and(implies_pending_only) {
        return Ok(replica.pending_tasks().await?.into_iter().collect());
    }
    Ok(replica.all_tasks().await?.into_values().collect())
}

// ============================================================================
// FILTER TESTS
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use crate::create_storage_async;
    use std::str::FromStr;
    use taskchampion::Operations;
    use taskchampion::Replica;
    use tempfile::TempDir;
    use uuid::Uuid;

    async fn create_test_task<S: taskchampion::storage::Storage>(
        replica: &mut Replica<S>,
        description: &str,
        status: taskchampion::Status,
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
            task.add_tag(&taskchampion::Tag::from_str(tag).unwrap(), &mut ops)
                .unwrap();
        }
        replica.commit_operations(ops).await.unwrap();
        uuid
    }

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
        // Set an explicit status so the task is returned by
        // `Replica::pending_tasks()` (which filters on the TaskMap `status`
        // key) — matching the assumption made by the pending fast-path tests.
        task.set_status(taskchampion::Status::Pending, &mut ops)
            .unwrap();
        task.set_user_defined_attribute("project".to_string(), project.to_string(), &mut ops)
            .unwrap();
        replica.commit_operations(ops).await.unwrap();
        uuid
    }

    async fn build_replica(dir: &TempDir) -> Replica<taskchampion::SqliteStorage> {
        let storage = create_storage_async(dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        Replica::new(storage)
    }

    #[test]
    fn test_get_string_property_description() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(
                get_string_property(&task, "description"),
                Some("Test task".to_string())
            );
        });
    }

    #[test]
    fn test_get_string_property_status() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid = create_test_task(
                &mut replica,
                "Test task",
                taskchampion::Status::Completed,
                "",
            )
            .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(
                get_string_property(&task, "status"),
                Some("completed".to_string())
            );
        });
    }

    #[test]
    fn test_get_string_property_priority() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid = create_test_task(
                &mut replica,
                "Test task",
                taskchampion::Status::Pending,
                "H",
            )
            .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(
                get_string_property(&task, "priority"),
                Some("H".to_string())
            );
        });
    }

    #[test]
    fn test_get_string_property_priority_none() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(get_string_property(&task, "priority"), None);
        });
    }

    #[test]
    fn test_get_string_property_project() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid = create_test_task_with_project(&mut replica, "Test task", "MyProject").await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(
                get_string_property(&task, "project"),
                Some("MyProject".to_string())
            );
        });
    }

    #[test]
    fn test_get_datetime_property_due() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let due_date = Utc::now() + chrono::Duration::days(1);
            let uuid = create_test_task_with_due(&mut replica, "Test task", due_date).await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            let result = get_datetime_property(&task, "due").unwrap();
            assert!((result - due_date).num_seconds() < 1);
        });
    }

    #[test]
    fn test_has_virtual_tag_pending() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert!(has_virtual_tag(&task, "PENDING"));
            assert!(!has_virtual_tag(&task, "COMPLETED"));
            assert!(!has_virtual_tag(&task, "DELETED"));
        });
    }

    #[test]
    fn test_has_virtual_tag_completed() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid = create_test_task(
                &mut replica,
                "Test task",
                taskchampion::Status::Completed,
                "",
            )
            .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert!(!has_virtual_tag(&task, "PENDING"));
            assert!(has_virtual_tag(&task, "COMPLETED"));
            assert!(!has_virtual_tag(&task, "DELETED"));
        });
    }

    #[test]
    fn test_has_virtual_tag_tagged() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task_with_tags(&mut replica, "Test task", vec!["home", "important"])
                    .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert!(has_virtual_tag(&task, "TAGGED"));
        });
    }

    #[test]
    fn test_has_virtual_tag_priority() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid = create_test_task(
                &mut replica,
                "Test task",
                taskchampion::Status::Pending,
                "H",
            )
            .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert!(has_virtual_tag(&task, "PRIORITY"));
        });
    }

    #[test]
    fn test_has_virtual_tag_project() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid = create_test_task_with_project(&mut replica, "Test task", "MyProject").await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert!(has_virtual_tag(&task, "PROJECT"));
        });
    }

    #[test]
    fn test_has_virtual_tag_annotated() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid = Uuid::new_v4();
            let mut ops = Operations::new();
            let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
            task.set_description("Test task".to_string(), &mut ops)
                .unwrap();
            let annotation = taskchampion::Annotation {
                entry: taskchampion::utc_timestamp(Utc::now().timestamp()),
                description: "Test annotation".to_string(),
            };
            task.add_annotation(annotation, &mut ops).unwrap();
            replica.commit_operations(ops).await.unwrap();
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert!(has_virtual_tag(&task, "ANNOTATED"));
        });
    }

    #[test]
    fn test_evaluate_equals_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
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
        });
    }

    #[test]
    fn test_evaluate_not_equals_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let filter = FilterExpression::NotEqualsFilter {
                property: PropertyRef {
                    name: "description".to_string(),
                },
                value: serde_json::Value::String("Wrong task".to_string()),
            };
            assert!(evaluate_filter_expression(&task, &filter));
        });
    }

    #[test]
    fn test_evaluate_in_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let filter = FilterExpression::InFilter {
                property: PropertyRef {
                    name: "description".to_string(),
                },
                values: vec![
                    serde_json::Value::String("Task 1".to_string()),
                    serde_json::Value::String("Test task".to_string()),
                ],
            };
            assert!(evaluate_filter_expression(&task, &filter));
        });
    }

    #[test]
    fn test_evaluate_contains_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid = create_test_task(
                &mut replica,
                "Buy milk from store",
                taskchampion::Status::Pending,
                "",
            )
            .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let filter = FilterExpression::ContainsFilter {
                property: PropertyRef {
                    name: "description".to_string(),
                },
                value: "milk".to_string(),
                case_sensitive: false,
            };
            assert!(evaluate_filter_expression(&task, &filter));
        });
    }

    #[test]
    fn test_evaluate_starts_with_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Buy milk", taskchampion::Status::Pending, "").await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let filter = FilterExpression::StartsWithFilter {
                property: PropertyRef {
                    name: "description".to_string(),
                },
                value: "Buy".to_string(),
                case_sensitive: true,
            };
            assert!(evaluate_filter_expression(&task, &filter));
        });
    }

    #[test]
    fn test_evaluate_ends_with_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Buy milk", taskchampion::Status::Pending, "").await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let filter = FilterExpression::EndsWithFilter {
                property: PropertyRef {
                    name: "description".to_string(),
                },
                value: "milk".to_string(),
                case_sensitive: true,
            };
            assert!(evaluate_filter_expression(&task, &filter));
        });
    }

    #[test]
    fn test_evaluate_word_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid = create_test_task(
                &mut replica,
                "Buy milk from store",
                taskchampion::Status::Pending,
                "",
            )
            .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let filter = FilterExpression::WordFilter {
                property: PropertyRef {
                    name: "description".to_string(),
                },
                value: "milk".to_string(),
                case_sensitive: false,
            };
            assert!(evaluate_filter_expression(&task, &filter));
        });
    }

    #[test]
    fn test_evaluate_regex_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Buy milk", taskchampion::Status::Pending, "").await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let filter = FilterExpression::RegexFilter {
                property: PropertyRef {
                    name: "description".to_string(),
                },
                pattern: "^Buy\\s+\\w+$".to_string(),
                case_sensitive: true,
            };
            assert!(evaluate_filter_expression(&task, &filter));
        });
    }

    #[test]
    fn test_evaluate_none_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let filter = FilterExpression::NoneFilter {
                property: PropertyRef {
                    name: "project".to_string(),
                },
            };
            assert!(evaluate_filter_expression(&task, &filter));
        });
    }

    #[test]
    fn test_evaluate_any_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid = create_test_task_with_project(&mut replica, "Test task", "MyProject").await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let filter = FilterExpression::AnyFilter {
                property: PropertyRef {
                    name: "project".to_string(),
                },
            };
            assert!(evaluate_filter_expression(&task, &filter));
        });
    }

    #[test]
    fn test_evaluate_date_before_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
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
        });
    }

    #[test]
    fn test_evaluate_date_after_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
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
        });
    }

    #[test]
    fn test_evaluate_less_than_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
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
        });
    }

    #[test]
    fn test_evaluate_greater_than_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
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
        });
    }

    #[test]
    fn test_evaluate_tag_filter_include() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task_with_tags(&mut replica, "Test task", vec!["home", "important"])
                    .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let filter = FilterExpression::Tag {
                tag: "home".to_string(),
                exclude: false,
            };
            assert!(evaluate_filter_expression(&task, &filter));
        });
    }

    #[test]
    fn test_evaluate_tag_filter_exclude() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task_with_tags(&mut replica, "Test task", vec!["home", "important"])
                    .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let filter = FilterExpression::Tag {
                tag: "work".to_string(),
                exclude: true,
            };
            assert!(evaluate_filter_expression(&task, &filter));
        });
    }

    #[test]
    fn test_evaluate_virtual_tag_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let filter = FilterExpression::VirtualTag {
                tag: "PENDING".to_string(),
                exclude: false,
            };
            assert!(evaluate_filter_expression(&task, &filter));
        });
    }

    #[test]
    fn test_evaluate_and_group() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
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
        });
    }

    #[test]
    fn test_evaluate_or_group() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
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
        });
    }

    #[test]
    fn test_evaluate_xor_group() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
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
        });
    }

    #[test]
    fn test_evaluate_not_filter() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
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
        });
    }

    #[test]
    fn test_deserialize_equals_filter() {
        let json = r#"{
            "type": "EqualsFilter",
            "property": {"name": "status"},
            "value": "pending"
        }"#;
        let result: Result<FilterExpression, _> = serde_json::from_str(json);
        assert!(result.is_ok());
    }

    #[test]
    fn test_deserialize_tag_filter() {
        let json = r#"{
            "type": "Tag",
            "tag": "home",
            "exclude": false
        }"#;
        let result: Result<FilterExpression, _> = serde_json::from_str(json);
        assert!(result.is_ok());
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
        assert!(result.is_ok());
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
        assert!(result.is_ok());
    }

    #[test]
    fn test_get_string_property_unknown() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(get_string_property(&task, "unknown_property"), None);
        });
    }

    #[test]
    fn test_get_datetime_property_unknown() {
        let td = TempDir::new().unwrap();
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid =
                create_test_task(&mut replica, "Test task", taskchampion::Status::Pending, "")
                    .await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(get_datetime_property(&task, "unknown_property"), None);
        });
    }

    #[test]
    fn test_parse_filter_option_none() {
        let result = parse_filter_option(None).unwrap();
        assert!(result.is_none());
    }

    #[test]
    fn test_parse_filter_option_some() {
        let json = r#"{"filter": {"type": "Tag", "tag": "home", "exclude": false}}"#.to_string();
        let result = parse_filter_option(Some(json)).unwrap();
        match result {
            Some(FilterExpression::Tag { tag, exclude }) => {
                assert_eq!(tag, "home");
                assert!(!exclude);
            }
            other => panic!("expected Tag filter, got {other:?}"),
        }
    }

    #[test]
    fn test_parse_filter_option_invalid_json() {
        let result = parse_filter_option(Some("not json".to_string()));
        assert!(result.is_err());
    }

    #[tokio::test]
    async fn test_collect_base_tasks_returns_all_without_filter() {
        let td = TempDir::new().unwrap();
        let mut replica = build_replica(&td).await;
        create_test_task(&mut replica, "T1", taskchampion::Status::Pending, "").await;
        create_test_task(&mut replica, "T2", taskchampion::Status::Completed, "").await;
        let tasks = collect_base_tasks(&mut replica, None).await.unwrap();
        assert_eq!(tasks.len(), 2);
    }

    #[tokio::test]
    async fn test_collect_base_tasks_pending_fast_path() {
        let td = TempDir::new().unwrap();
        let mut replica = build_replica(&td).await;
        create_test_task(&mut replica, "T1", taskchampion::Status::Pending, "").await;
        create_test_task(&mut replica, "T2", taskchampion::Status::Pending, "").await;
        create_test_task(&mut replica, "T3", taskchampion::Status::Completed, "").await;
        let filter = FilterExpression::EqualsFilter {
            property: PropertyRef {
                name: "status".to_string(),
            },
            value: serde_json::Value::String("pending".to_string()),
        };
        let tasks = collect_base_tasks(&mut replica, Some(&filter))
            .await
            .unwrap();
        assert_eq!(tasks.len(), 2);
        for task in &tasks {
            assert_eq!(task.get_status(), taskchampion::Status::Pending);
        }
    }

    #[test]
    fn test_implies_pending_only_top_level_equals() {
        // Ticket R3: the original fast-path shape must still be recognised.
        let filter = FilterExpression::EqualsFilter {
            property: PropertyRef {
                name: "status".to_string(),
            },
            value: serde_json::Value::String("pending".to_string()),
        };
        assert!(implies_pending_only(&filter));
    }

    #[test]
    fn test_implies_pending_only_and_group_with_status() {
        // The most common real query shape: AND of status==pending with
        // arbitrary other constraints. The fast path must still fire.
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
                    case_sensitive: false,
                },
            ],
        };
        assert!(implies_pending_only(&filter));
    }

    #[test]
    fn test_implies_pending_only_rejects_or_group() {
        // An OR with status==pending can admit non-pending tasks; fast path
        // must NOT apply.
        let filter = FilterExpression::OrGroup {
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
        assert!(!implies_pending_only(&filter));
    }

    #[test]
    fn test_implies_pending_only_rejects_non_pending_value() {
        let filter = FilterExpression::EqualsFilter {
            property: PropertyRef {
                name: "status".to_string(),
            },
            value: serde_json::Value::String("completed".to_string()),
        };
        assert!(!implies_pending_only(&filter));
    }

    #[tokio::test]
    async fn test_collect_base_tasks_and_group_fast_path() {
        // Ticket R3: an AndGroup that *contains* a status==pending term must
        // use pending_tasks() so that the base set excludes completed/deleted.
        let td = TempDir::new().unwrap();
        let mut replica = build_replica(&td).await;
        create_test_task(&mut replica, "T1", taskchampion::Status::Pending, "").await;
        create_test_task(&mut replica, "T2", taskchampion::Status::Pending, "").await;
        create_test_task(&mut replica, "T3", taskchampion::Status::Completed, "").await;

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
                    value: "T".to_string(),
                    case_sensitive: true,
                },
            ],
        };
        let tasks = collect_base_tasks(&mut replica, Some(&filter))
            .await
            .unwrap();
        // Fast path: only the two pending tasks are returned as candidates.
        assert_eq!(tasks.len(), 2);
        for task in &tasks {
            assert_eq!(task.get_status(), taskchampion::Status::Pending);
        }
    }
}
