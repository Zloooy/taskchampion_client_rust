use serde::{Deserialize, Serialize};

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
