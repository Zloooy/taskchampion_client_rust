use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ============================================================================
// Sync result
// ============================================================================

/// Sync result structure for returning sync statistics.
///
/// (Renamed candidate `SyncResult` is tracked under ticket R9; the public
/// name is preserved here for FFI backward compatibility.)
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

/// Preferred name for the sync result (ticket R9).
///
/// This is an alias for [`SyncResultData`] rather than a rename so that the
/// already-generated `frb_generated.rs` keeps compiling. A full rename
/// (deleting `SyncResultData`) requires a coordinated FRB + Dart codegen pass
/// and is deferred to avoid breaking the FFI surface.
pub type SyncResult = SyncResultData;

// ============================================================================
// Typed task DTOs (ticket R5)
// ============================================================================

/// Mirrors [`taskchampion::Status`] for FFI consumers.
///
/// Stored as the lowercase Taskwarrior string in the wire form so the Dart
/// side matches the rest of the crate's vocabulary.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum TaskStatusDto {
    Pending,
    Completed,
    Deleted,
    Recurring,
    /// TaskChampion's escape hatch for unknown status strings.
    Unknown,
}

impl TaskStatusDto {
    /// Build a DTO from a raw status string read out of a TaskMap.
    pub fn from_taskmap(value: &str) -> Self {
        match value {
            "pending" => TaskStatusDto::Pending,
            "completed" => TaskStatusDto::Completed,
            "deleted" => TaskStatusDto::Deleted,
            "recurring" => TaskStatusDto::Recurring,
            _ => TaskStatusDto::Unknown,
        }
    }

    /// Convert back into the Taskwarrior wire string.
    pub fn as_taskmap(&self) -> &'static str {
        match self {
            TaskStatusDto::Pending => "pending",
            TaskStatusDto::Completed => "completed",
            TaskStatusDto::Deleted => "deleted",
            TaskStatusDto::Recurring => "recurring",
            TaskStatusDto::Unknown => "unknown",
        }
    }
}

impl From<taskchampion::Status> for TaskStatusDto {
    fn from(status: taskchampion::Status) -> Self {
        match status {
            taskchampion::Status::Pending => TaskStatusDto::Pending,
            taskchampion::Status::Completed => TaskStatusDto::Completed,
            taskchampion::Status::Deleted => TaskStatusDto::Deleted,
            taskchampion::Status::Recurring => TaskStatusDto::Recurring,
            // Status::Unknown carries an opaque payload we deliberately drop
            // at the FFI boundary.
            taskchampion::Status::Unknown(_) => TaskStatusDto::Unknown,
        }
    }
}

impl From<TaskStatusDto> for taskchampion::Status {
    fn from(status: TaskStatusDto) -> Self {
        match status {
            TaskStatusDto::Pending => taskchampion::Status::Pending,
            TaskStatusDto::Completed => taskchampion::Status::Completed,
            TaskStatusDto::Deleted => taskchampion::Status::Deleted,
            TaskStatusDto::Recurring => taskchampion::Status::Recurring,
            // Status::Unknown carries an opaque reason string; the DTO is
            // lossy here so we record a descriptive placeholder.
            TaskStatusDto::Unknown => taskchampion::Status::Unknown("unknown".to_string()),
        }
    }
}

/// A single annotation entry.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct AnnotationDto {
    /// RFC-3339 timestamp of when the annotation was added.
    pub entry: String,
    /// The free-form annotation text.
    pub description: String,
}

/// A fully typed task, intended to replace the lossy `HashMap<String,String>`
/// representation at the FFI boundary.
///
/// Notable fixes vs. the legacy map encoding:
/// * `tags` is a real `Vec<String>` — the old code joined/split on
///   whitespace, which corrupted tags containing spaces (ticket R5).
/// * `udas` is a separate map, so a UDA whose name happens to share a prefix
///   with a built-in property (e.g. `"entry_note"`) is no longer silently
///   dropped (ticket R5 / I-13).
/// * `annotations` is a structured list rather than `annotation_<timestamp>`
///   keys interleaved with everything else.
///
/// Datetimes are carried as RFC-3339 strings to stay wire-compatible with
/// the existing Dart consumers without forcing a chrono-aware FRB regen.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct TaskDto {
    pub uuid: String,
    pub description: String,
    pub status: TaskStatusDto,
    /// Canonical priority code (`"H"`/`"M"`/`"L"`) or `None` for no priority.
    /// See [`crate::properties::CANONICAL_PRIORITIES`].
    pub priority: Option<String>,
    /// RFC-3339 due date, if set.
    pub due: Option<String>,
    /// RFC-3339 wait-until date, if set.
    pub wait: Option<String>,
    /// RFC-3339 creation timestamp, if set.
    pub entry: Option<String>,
    /// RFC-3339 last-modified timestamp, if set.
    pub modified: Option<String>,
    /// RFC-3339 completion/deletion timestamp, if set.
    pub end: Option<String>,
    /// User tags. Each tag is a separate element; spaces are preserved.
    pub tags: Vec<String>,
    /// Dependency UUIDs (string form).
    pub depends: Vec<String>,
    /// Annotations, oldest-first.
    pub annotations: Vec<AnnotationDto>,
    /// User-defined attributes, keyed by their Taskwarrior name.
    pub udas: HashMap<String, String>,
}

impl TaskDto {
    /// Convenience accessor for whether the task has a given tag.
    pub fn has_tag(&self, tag: &str) -> bool {
        self.tags.iter().any(|t| t == tag)
    }
}

// ============================================================================
// Tests
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn status_dto_round_trips_through_taskmap() {
        for raw in ["pending", "completed", "deleted", "recurring"] {
            let dto = TaskStatusDto::from_taskmap(raw);
            assert_eq!(dto.as_taskmap(), raw);
        }
    }

    #[test]
    fn status_dto_unknown_maps_to_unknown() {
        assert_eq!(
            TaskStatusDto::from_taskmap("nonsense"),
            TaskStatusDto::Unknown
        );
        assert_eq!(TaskStatusDto::Unknown.as_taskmap(), "unknown");
    }

    #[test]
    fn status_dto_round_trips_through_taskchampion_status() {
        let tc_status: taskchampion::Status = TaskStatusDto::Pending.into();
        assert_eq!(tc_status, taskchampion::Status::Pending);
        let dto: TaskStatusDto = taskchampion::Status::Completed.into();
        assert_eq!(dto, TaskStatusDto::Completed);
    }

    #[test]
    fn task_dto_has_tag_checks_membership() {
        let dto = TaskDto {
            uuid: "u".into(),
            description: "d".into(),
            status: TaskStatusDto::Pending,
            priority: None,
            due: None,
            wait: None,
            entry: None,
            modified: None,
            end: None,
            tags: vec!["home".into(), "with space".into()],
            depends: vec![],
            annotations: vec![],
            udas: HashMap::new(),
        };
        assert!(dto.has_tag("home"));
        assert!(dto.has_tag("with space"));
        assert!(!dto.has_tag("work"));
    }

    #[test]
    fn task_dto_serializes_to_json() {
        let dto = TaskDto {
            uuid: "u".into(),
            description: "d".into(),
            status: TaskStatusDto::Pending,
            priority: Some("H".into()),
            due: Some("2024-01-15T10:00:00Z".into()),
            wait: None,
            entry: None,
            modified: None,
            end: None,
            tags: vec!["a".into(), "b".into()],
            depends: vec![],
            annotations: vec![AnnotationDto {
                entry: "2024-01-01T00:00:00Z".into(),
                description: "note".into(),
            }],
            udas: HashMap::new(),
        };
        let json = serde_json::to_string(&dto).unwrap();
        // Tags survive as a real array, not a space-joined string.
        assert!(json.contains(r#""tags":["a","b"]"#));
        assert!(json.contains(r#""priority":"H""#));
        // Round-trip.
        let back: TaskDto = serde_json::from_str(&json).unwrap();
        assert_eq!(dto, back);
    }
}
