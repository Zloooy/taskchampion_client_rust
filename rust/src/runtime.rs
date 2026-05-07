use std::sync::OnceLock;

use tokio::runtime::Runtime;

/// Global tokio runtime for async taskchampion operations
static TOKIO_RUNTIME: OnceLock<Runtime> = OnceLock::new();

/// Get or create the global tokio runtime
pub fn get_runtime() -> &'static Runtime {
    TOKIO_RUNTIME.get_or_init(|| {
        tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .expect("Failed to create tokio runtime")
    })
}
