use anyhow::Result;
use std::path::PathBuf;
use taskchampion::storage::AccessMode;
use taskchampion::SqliteStorage;

pub async fn create_storage_async(taskdb_dir_path: String) -> Result<SqliteStorage> {
    let taskdb_dir = PathBuf::from(taskdb_dir_path);
    let storage = SqliteStorage::new(taskdb_dir, AccessMode::ReadWrite, true).await?;
    Ok(storage)
}
