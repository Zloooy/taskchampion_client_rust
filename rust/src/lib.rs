#![allow(unexpected_cfgs)]

//! TaskChampion Rust FFI Bridge
//!
//! This module provides the FFI bridge between Dart and Rust for TaskChampion operations.
//! It exposes functions for task management, synchronization, and authentication.

pub mod api;
pub mod filter;
pub mod models;
pub mod properties;
pub mod runtime;
pub mod storage;
mod task_ops;

pub use filter::{
    evaluate_filter_expression, get_datetime_property, get_string_property, has_virtual_tag,
    FilterExpression, PropertyRef, SortDirection, TaskFilter, TaskSort,
};
pub use properties::{
    get_all_enum_values, get_tags, get_task_property_values, get_task_property_values_typed,
    PropertyReturnType,
};
pub use runtime::get_runtime;
pub use storage::create_storage_async;

mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
