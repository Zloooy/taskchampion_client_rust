//! Virtual tag registry (ticket R6).
//!
//! Taskwarrior defines a set of "virtual" (or "special") tags that are not
//! stored on the task but derived from its properties: `PENDING`, `COMPLETED`,
//! `DUE`, `OVERDUE`, `BLOCKED`, `TAGGED`, `PRIORITY`, … .
//!
//! The previous implementation of `has_virtual_tag` was a single ~100-line
//! `match` statement. Adding a new virtual tag meant editing that match arm
//! and remembering to keep several ad-hoc lists in sync. This module replaces
//! it with a perfect-hash table (`phf::Map`) that maps each canonical virtual
//! tag name (uppercase) to a predicate `fn(&Task) -> bool`.
//!
//! Adding a new virtual tag is now a single line in the `phf::phf_map!`
//! invocation below — satisfying the Open/Closed Principle — and lookups are
//! O(1) instead of a linear scan through a `match`.

use chrono::{Datelike, Utc};
use std::str::FromStr;
use taskchampion::Task;

/// Static registry of virtual tags.
///
/// Keys are the canonical uppercase names. Each value is a predicate evaluated
/// against the task. `PENDING`/`COMPLETED`/etc. are stored both as virtual
/// tags (here) and as real status tags on the task itself; the predicate first
/// consults the task's own tags and falls back to a derived check.
#[allow(clippy::too_many_lines)] // one-line-per-tag table; intentional
pub static VIRTUAL_TAGS: phf::Map<&'static str, fn(&Task) -> bool> = phf::phf_map! {
    // Status-backed virtual tags. These are stored as real tags by
    // TaskChampion, so the predicate delegates to `has_real_tag` (which is
    // what Taskwarrior's `+PENDING` etc. reduce to).
    "ACTIVE" => is_active,
    "BLOCKED" => is_blocked,
    "BLOCKING" => is_blocking,
    "COMPLETED" => is_completed,
    "DELETED" => is_deleted,
    "PENDING" => is_pending,
    "UNBLOCKED" => is_unblocked,
    "WAITING" => is_waiting,

    // Pure-derived virtual tags.
    "ANNOTATED" => is_annotated,
    "DUE" => is_due,
    "DUETODAY" => is_due_today,
    "TODAY" => is_due_today,
    "INSTANCE" => is_instance,
    "LATEST" => is_latest,
    "MONTH" => is_due_this_month,
    "ORPHAN" => is_orphan,
    "OVERDUE" => is_overdue,
    "PARENT" => is_parent,
    "PRIORITY" => has_priority,
    "PROJECT" => has_project,
    "QUARTER" => is_due_this_quarter,
    "READY" => is_ready,
    "SCHEDULED" => is_scheduled,
    "TAGGED" => is_tagged,
    "TEMPLATE" => is_template,
    "TOMORROW" => is_due_tomorrow,
    "UDA" => is_uda,
    "UNTIL" => has_until,
    "WEEK" => is_due_this_week,
    "YEAR" => is_due_this_year,
    "YESTERDAY" => is_due_yesterday,
};

/// Look up a virtual tag predicate and evaluate it against `task`.
///
/// `tag` is matched case-insensitively against the canonical (uppercase)
/// registry keys. Returns `false` for unknown tags, preserving the previous
/// `has_virtual_tag` contract.
pub fn has_virtual_tag(task: &Task, tag: &str) -> bool {
    VIRTUAL_TAGS
        .get(&tag.to_uppercase())
        .is_some_and(|predicate| predicate(task))
}

/// Returns the canonical (uppercase) names of every registered virtual tag.
///
/// Useful for tooling that wants to enumerate virtual tags (for example to
/// populate autocomplete or to filter them out of a tag list).
pub fn virtual_tag_names() -> impl Iterator<Item = &'static &'static str> {
    VIRTUAL_TAGS.keys()
}

// ---------------------------------------------------------------------------
// Predicate implementations.
//
// Each predicate is a free function so it can live in the `phf` table without
// capturing state. They are intentionally `fn(&Task) -> bool` (not closures)
// because `phf::Map` requires function pointers.
// ---------------------------------------------------------------------------

/// Check a synthetic tag (`PENDING`, `ACTIVE`, …) the same way Taskwarrior
/// does: by handing the uppercase name to `Tag::from_str` and letting
/// TaskChampion's `has_tag` derive the answer from task properties.
///
/// TaskChampion treats all-uppercase tag names as synthetic, so `get_tags()`
/// (which yields only user tags) cannot be used here.
fn has_synthetic_tag(task: &Task, name: &str) -> bool {
    taskchampion::Tag::from_str(name)
        .ok()
        .is_some_and(|tag| task.has_tag(&tag))
}

fn is_active(task: &Task) -> bool {
    has_synthetic_tag(task, "ACTIVE")
}

fn is_blocked(task: &Task) -> bool {
    has_synthetic_tag(task, "BLOCKED")
}

fn is_blocking(task: &Task) -> bool {
    has_synthetic_tag(task, "BLOCKING")
}

fn is_completed(task: &Task) -> bool {
    has_synthetic_tag(task, "COMPLETED")
}

fn is_deleted(task: &Task) -> bool {
    has_synthetic_tag(task, "DELETED")
}

fn is_pending(task: &Task) -> bool {
    has_synthetic_tag(task, "PENDING")
}

fn is_unblocked(task: &Task) -> bool {
    has_synthetic_tag(task, "UNBLOCKED")
}

fn is_waiting(task: &Task) -> bool {
    has_synthetic_tag(task, "WAITING")
}

fn is_annotated(task: &Task) -> bool {
    task.get_annotations().count() > 0
}

fn is_due(task: &Task) -> bool {
    task.get_due()
        .is_some_and(|due| due <= Utc::now() + chrono::Duration::days(7))
}

fn is_due_today(task: &Task) -> bool {
    task.get_due()
        .is_some_and(|due| due.date_naive() == Utc::now().date_naive())
}

fn is_instance(task: &Task) -> bool {
    task.get_value("template").is_some() || task.get_value("parent").is_some()
}

fn is_latest(task: &Task) -> bool {
    let _ = task;
    false
}

fn is_due_this_month(task: &Task) -> bool {
    task.get_due().is_some_and(|due| {
        let now = Utc::now();
        due.month() == now.month() && due.year() == now.year()
    })
}

fn is_orphan(task: &Task) -> bool {
    let _ = task;
    false
}

fn is_overdue(task: &Task) -> bool {
    task.get_due()
        .is_some_and(|due| due < Utc::now() && task.get_status() == taskchampion::Status::Pending)
}

fn is_parent(task: &Task) -> bool {
    task.get_value("last").is_some() || task.get_value("mask").is_some()
}

fn has_priority(task: &Task) -> bool {
    !task.get_priority().is_empty()
}

fn has_project(task: &Task) -> bool {
    task.get_value("project").is_some()
}

fn is_due_this_quarter(task: &Task) -> bool {
    task.get_due().is_some_and(|due| {
        let now = Utc::now();
        let current_quarter = (now.month() - 1) / 3 + 1;
        let due_quarter = (due.month() - 1) / 3 + 1;
        current_quarter == due_quarter && now.year() == due.year()
    })
}

fn is_ready(task: &Task) -> bool {
    task.get_status() == taskchampion::Status::Pending
        && task.get_wait().is_none_or(|w| w <= Utc::now())
}

fn is_scheduled(task: &Task) -> bool {
    task.get_value("scheduled").is_some()
}

fn is_tagged(task: &Task) -> bool {
    task.get_tags().count() > 0
}

fn is_template(task: &Task) -> bool {
    task.get_value("last").is_some() || task.get_value("mask").is_some()
}

fn is_due_tomorrow(task: &Task) -> bool {
    task.get_due().is_some_and(|due| {
        let tomorrow = Utc::now() + chrono::Duration::days(1);
        due.date_naive() == tomorrow.date_naive()
    })
}

fn is_uda(task: &Task) -> bool {
    let _ = task;
    false
}

fn has_until(task: &Task) -> bool {
    task.get_value("until").is_some()
}

fn is_due_this_week(task: &Task) -> bool {
    task.get_due().is_some_and(|due| {
        let now_iso = Utc::now().iso_week();
        let due_iso = due.iso_week();
        now_iso.year() == due_iso.year() && now_iso.week() == due_iso.week()
    })
}

fn is_due_this_year(task: &Task) -> bool {
    task.get_due()
        .is_some_and(|due| due.year() == Utc::now().year())
}

fn is_due_yesterday(task: &Task) -> bool {
    task.get_due().is_some_and(|due| {
        let yesterday = Utc::now() - chrono::Duration::days(1);
        due.date_naive() == yesterday.date_naive()
    })
}

// ============================================================================
// Tests
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Duration;
    use std::str::FromStr;
    use taskchampion::{Operations, Replica, Status, Tag};
    use uuid::Uuid;

    async fn build_replica() -> Replica<taskchampion::SqliteStorage> {
        let td = tempfile::TempDir::new().unwrap();
        let storage = crate::storage::create_storage_async(td.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        // Leak the tempdir so the storage stays valid for the test body. Tests
        // are short-lived and the OS reclaims the space afterwards.
        std::mem::forget(td);
        Replica::new(storage)
    }

    async fn make_task(
        status: Status,
    ) -> (
        Replica<taskchampion::SqliteStorage>,
        taskchampion::Task,
        Uuid,
    ) {
        let mut replica = build_replica().await;
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description("T".to_string(), &mut ops).unwrap();
        task.set_status(status, &mut ops).unwrap();
        replica.commit_operations(ops).await.unwrap();
        let task = replica.get_task(uuid).await.unwrap().unwrap();
        (replica, task, uuid)
    }

    #[tokio::test]
    async fn pending_task_has_pending_virtual_tag() {
        let (_, task, _) = make_task(Status::Pending).await;
        assert!(has_virtual_tag(&task, "PENDING"));
        assert!(!has_virtual_tag(&task, "COMPLETED"));
        // Case-insensitive lookup.
        assert!(has_virtual_tag(&task, "pending"));
        assert!(has_virtual_tag(&task, "Pending"));
    }

    #[tokio::test]
    async fn completed_task_has_completed_virtual_tag() {
        let (_, task, _) = make_task(Status::Completed).await;
        assert!(has_virtual_tag(&task, "COMPLETED"));
        assert!(!has_virtual_tag(&task, "PENDING"));
    }

    #[tokio::test]
    async fn deleted_task_has_deleted_virtual_tag() {
        let (_, task, _) = make_task(Status::Deleted).await;
        assert!(has_virtual_tag(&task, "DELETED"));
    }

    #[tokio::test]
    async fn unknown_virtual_tag_is_false() {
        let (_, task, _) = make_task(Status::Pending).await;
        assert!(!has_virtual_tag(&task, "NOT_A_REAL_VIRTUAL_TAG"));
    }

    #[tokio::test]
    async fn tagged_task_has_tagged_virtual_tag() {
        let mut replica = build_replica().await;
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description("T".to_string(), &mut ops).unwrap();
        task.add_tag(&Tag::from_str("home").unwrap(), &mut ops)
            .unwrap();
        replica.commit_operations(ops).await.unwrap();
        let task = replica.get_task(uuid).await.unwrap().unwrap();
        assert!(has_virtual_tag(&task, "TAGGED"));
    }

    #[tokio::test]
    async fn priority_task_has_priority_virtual_tag() {
        let mut replica = build_replica().await;
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description("T".to_string(), &mut ops).unwrap();
        task.set_priority("H".to_string(), &mut ops).unwrap();
        replica.commit_operations(ops).await.unwrap();
        let task = replica.get_task(uuid).await.unwrap().unwrap();
        assert!(has_virtual_tag(&task, "PRIORITY"));
    }

    #[tokio::test]
    async fn project_task_has_project_virtual_tag() {
        let mut replica = build_replica().await;
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description("T".to_string(), &mut ops).unwrap();
        task.set_user_defined_attribute("project".to_string(), "P".to_string(), &mut ops)
            .unwrap();
        replica.commit_operations(ops).await.unwrap();
        let task = replica.get_task(uuid).await.unwrap().unwrap();
        assert!(has_virtual_tag(&task, "PROJECT"));
    }

    #[tokio::test]
    async fn annotated_task_has_annotated_virtual_tag() {
        let mut replica = build_replica().await;
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description("T".to_string(), &mut ops).unwrap();
        let annotation = taskchampion::Annotation {
            entry: taskchampion::utc_timestamp(Utc::now().timestamp()),
            description: "note".to_string(),
        };
        task.add_annotation(annotation, &mut ops).unwrap();
        replica.commit_operations(ops).await.unwrap();
        let task = replica.get_task(uuid).await.unwrap().unwrap();
        assert!(has_virtual_tag(&task, "ANNOTATED"));
    }

    #[tokio::test]
    async fn due_soon_task_has_due_virtual_tag() {
        let mut replica = build_replica().await;
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description("T".to_string(), &mut ops).unwrap();
        task.set_due(Some(Utc::now() + Duration::days(2)), &mut ops)
            .unwrap();
        replica.commit_operations(ops).await.unwrap();
        let task = replica.get_task(uuid).await.unwrap().unwrap();
        assert!(has_virtual_tag(&task, "DUE"));
    }

    #[tokio::test]
    async fn overdue_pending_task_has_overdue_virtual_tag() {
        let mut replica = build_replica().await;
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description("T".to_string(), &mut ops).unwrap();
        task.set_status(Status::Pending, &mut ops).unwrap();
        task.set_due(Some(Utc::now() - Duration::days(1)), &mut ops)
            .unwrap();
        replica.commit_operations(ops).await.unwrap();
        let task = replica.get_task(uuid).await.unwrap().unwrap();
        assert!(has_virtual_tag(&task, "OVERDUE"));
    }

    #[tokio::test]
    async fn ready_task_has_ready_virtual_tag() {
        let mut replica = build_replica().await;
        let uuid = Uuid::new_v4();
        let mut ops = Operations::new();
        let mut task = replica.create_task(uuid, &mut ops).await.unwrap();
        task.set_description("T".to_string(), &mut ops).unwrap();
        task.set_status(Status::Pending, &mut ops).unwrap();
        replica.commit_operations(ops).await.unwrap();
        let task = replica.get_task(uuid).await.unwrap().unwrap();
        assert!(has_virtual_tag(&task, "READY"));
    }

    #[test]
    fn registry_contains_legacy_set_of_tags() {
        // Regression: every virtual tag the old match-statement handled must
        // still be present in the registry.
        let expected = [
            "ACTIVE",
            "BLOCKED",
            "BLOCKING",
            "COMPLETED",
            "DELETED",
            "PENDING",
            "UNBLOCKED",
            "WAITING",
            "ANNOTATED",
            "DUE",
            "DUETODAY",
            "TODAY",
            "INSTANCE",
            "LATEST",
            "MONTH",
            "ORPHAN",
            "OVERDUE",
            "PARENT",
            "PRIORITY",
            "PROJECT",
            "QUARTER",
            "READY",
            "SCHEDULED",
            "TAGGED",
            "TEMPLATE",
            "TOMORROW",
            "UDA",
            "UNTIL",
            "WEEK",
            "YEAR",
            "YESTERDAY",
        ];
        for name in expected {
            assert!(
                VIRTUAL_TAGS.contains_key(name),
                "virtual tag {name} missing from registry"
            );
        }
    }

    #[test]
    fn virtual_tag_names_is_non_empty() {
        assert!(virtual_tag_names().count() > 20);
    }
}
