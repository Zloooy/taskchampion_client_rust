//! Structured error types for the TaskChampion FFI bridge.
//!
//! Historically every fallible function returned `Result<T, anyhow::Error>`,
//! which made it impossible for callers (including the Dart side via FRB) to
//! distinguish between e.g. a missing task and a malformed UUID. This module
//! introduces [`TcError`], a typed error enumeration so that failure modes
//! are first-class and introspectable at the FFI boundary.
//!
//! See ticket R8.

use thiserror::Error;

/// A specialized [`Result`] for TaskChampion bridge operations.
pub type TcResult<T> = Result<T, TcError>;

/// All structured errors that can be produced by the bridge.
///
/// The variants intentionally mirror the failure modes previously squashed
/// into `anyhow::Error`, plus a few that were silently dropped (malformed
/// datetimes, per-row import failures).
#[derive(Debug, Error)]
pub enum TcError {
    /// A task with the given UUID could not be found in the replica.
    #[error("task not found: {0}")]
    TaskNotFound(uuid::Uuid),

    /// A UUID string could not be parsed.
    #[error("invalid uuid: {value}")]
    BadUuid {
        /// The offending input.
        value: String,
    },

    /// A datetime string could not be parsed as RFC-3339.
    #[error("invalid datetime {value:?}: {reason}")]
    BadDatetime {
        /// The offending input.
        value: String,
        /// A human-readable explanation of why parsing failed.
        reason: String,
    },

    /// An error originating in the TaskChampion storage layer.
    #[error("storage error: {0}")]
    Storage(#[from] taskchampion::Error),

    /// An I/O error from the host filesystem.
    #[error("io error: {0}")]
    Io(#[from] std::io::Error),

    /// A (de)serialisation error.
    #[error("serde error: {0}")]
    Serde(#[from] serde_json::Error),

    /// A generic, free-form error for cases that do not map cleanly onto the
    /// structured variants above. New code should prefer adding a dedicated
    /// variant rather than reaching for this one.
    #[error("{0}")]
    Other(String),
}

impl TcError {
    /// Convenience constructor for [`TcError::BadUuid`] from any string-like input.
    pub fn bad_uuid(value: impl Into<String>) -> Self {
        TcError::BadUuid {
            value: value.into(),
        }
    }

    /// Convenience constructor for [`TcError::BadDatetime`].
    pub fn bad_datetime(value: impl Into<String>, reason: impl Into<String>) -> Self {
        TcError::BadDatetime {
            value: value.into(),
            reason: reason.into(),
        }
    }

    /// Convenience constructor for [`TcError::Other`].
    pub fn other(msg: impl Into<String>) -> Self {
        TcError::Other(msg.into())
    }
}

impl From<anyhow::Error> for TcError {
    /// Fold a downstream `anyhow::Error` into [`TcError::Other`].
    ///
    /// This keeps the `?` operator usable at call sites that still deal with
    /// `anyhow` (notably taskchampion's own API surface in some places) while
    /// we migrate towards fully structured errors.
    fn from(err: anyhow::Error) -> Self {
        TcError::Other(err.to_string())
    }
}

// ============================================================================
// Tests
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn task_not_found_displays_uuid() {
        let uuid = uuid::Uuid::new_v4();
        let err = TcError::TaskNotFound(uuid);
        let msg = err.to_string();
        assert!(msg.starts_with("task not found: "));
        assert!(msg.contains(&uuid.to_string()));
    }

    #[test]
    fn bad_uuid_carries_value() {
        let err = TcError::bad_uuid("not-a-uuid");
        match err {
            TcError::BadUuid { value } => assert_eq!(value, "not-a-uuid"),
            other => panic!("expected BadUuid, got {other:?}"),
        }
    }

    #[test]
    fn bad_datetime_carries_value_and_reason() {
        let err = TcError::bad_datetime("2024-13-99", "month out of range");
        match err {
            TcError::BadDatetime { value, reason } => {
                assert_eq!(value, "2024-13-99");
                assert_eq!(reason, "month out of range");
            }
            other => panic!("expected BadDatetime, got {other:?}"),
        }
    }

    #[test]
    fn serde_error_converts_via_from() {
        let serde_err: serde_json::Error =
            serde_json::from_str::<String>("not valid json").unwrap_err();
        let tc_err: TcError = serde_err.into();
        assert!(matches!(tc_err, TcError::Serde(_)));
    }

    #[test]
    fn io_error_converts_via_from() {
        let io_err = std::io::Error::new(std::io::ErrorKind::NotFound, "missing");
        let tc_err: TcError = io_err.into();
        assert!(matches!(tc_err, TcError::Io(_)));
    }

    #[test]
    fn anyhow_error_folds_into_other() {
        let anyhow_err = anyhow::anyhow!("something broke");
        let tc_err: TcError = anyhow_err.into();
        match tc_err {
            TcError::Other(msg) => assert_eq!(msg, "something broke"),
            other => panic!("expected Other, got {other:?}"),
        }
    }

    #[test]
    fn tc_result_aliases_work() {
        let ok: TcResult<i32> = Ok(42);
        assert!(ok.is_ok());
        assert_eq!(ok.as_ref().unwrap(), &42);

        let err: TcResult<i32> = Err(TcError::other("nope"));
        assert!(err.is_err());
    }
}
