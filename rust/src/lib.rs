#![allow(unexpected_cfgs)]

//! TaskChampion Rust FFI Bridge.
//!
//! Provides the FFI bridge between Dart and Rust for TaskChampion operations,
//! exposing functions for task management, synchronization, and
//! authentication.
//!
//! # Module layout
//!
//! * [`api`] — the `#[frb]` FFI surface (JSON + typed DTO entry points).
//! * [`filter`] — filter expression types, evaluator, and sort comparator.
//!   Split into the [`filter::evaluator`] and [`filter::sort`] sub-modules
//!   (ticket R7).
//! * [`models`] — typed DTOs ([`models::TaskDto`], …) and sync result.
//! * [`properties`] — distinct-value queries over task properties.
//! * [`repo`] — the reusable [`repo::TaskRepo`] session + path cache.
//! * [`virtual_tags`] — the `phf`-backed virtual tag registry (ticket R6).
//! * [`error`] — structured [`error::TcError`] (ticket R8).
//! * [`task_ops`] — internal Task ↔ DTO / HashMap conversions.

pub mod api;
pub mod error;
pub mod filter;
pub mod models;
pub mod properties;
pub mod repo;
pub mod runtime;
pub mod storage;
pub mod sync_stats;
mod task_ops;
pub mod virtual_tags;

pub use error::{TcError, TcResult};
pub use filter::{
    compare_tasks, FilterExpression, PropertyRef, SortDirection, SortProperty, TaskFilter, TaskSort,
};
pub use models::SyncResultData;
pub use properties::{get_all_enum_values, get_task_property_values_typed, PropertyReturnType};
pub use repo::{global_repo_cache, RepoCache, TaskRepo};
pub use runtime::get_runtime;
pub use storage::create_storage_async;

mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
