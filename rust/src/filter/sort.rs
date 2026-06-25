//! Sort comparison for tasks (ticket R7).
//!
//! Extracted from the former monolithic `filter.rs`. Houses [`compare_tasks`]
//! and the small string / datetime / double comparison helpers it composes.

use taskchampion::Task;

use crate::filter::{get_datetime_property, get_string_property, SortDirection, TaskSort};

/// Compare two tasks for sorting according to `sort`.
pub fn compare_tasks(task1: &Task, task2: &Task, sort: &TaskSort) -> std::cmp::Ordering {
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
