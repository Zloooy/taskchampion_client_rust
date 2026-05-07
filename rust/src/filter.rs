use chrono::{DateTime, Datelike, Utc};
use std::str::FromStr;
use taskchampion::Task;

/// Property reference for filtering
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
pub struct PropertyRef {
    pub name: String,
}

/// Sort direction enum
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum SortDirection {
    Ascending,
    Descending,
}

/// Property reference for sorting
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
pub struct SortProperty {
    pub name: String,
}

/// Sort specification
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
pub struct TaskSort {
    pub property: SortProperty,
    pub direction: SortDirection,
}

/// String comparison filters
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
#[serde(tag = "type")]
pub enum StringPropertyFilter {
    Equals {
        property: PropertyRef,
        value: String,
    },
    NotEquals {
        property: PropertyRef,
        value: String,
    },
    In {
        property: PropertyRef,
        values: Vec<String>,
    },
    NotIn {
        property: PropertyRef,
        values: Vec<String>,
    },
    Contains {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    NotContains {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    StartsWith {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    EndsWith {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    Word {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    NoWord {
        property: PropertyRef,
        value: String,
        case_sensitive: bool,
    },
    Regex {
        property: PropertyRef,
        pattern: String,
        case_sensitive: bool,
    },
    None {
        property: PropertyRef,
    },
    Any {
        property: PropertyRef,
    },
}

/// DateTime comparison filters
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
#[serde(tag = "type")]
pub enum DateTimePropertyFilter {
    Equals {
        property: PropertyRef,
        value: String,
    },
    NotEquals {
        property: PropertyRef,
        value: String,
    },
    In {
        property: PropertyRef,
        values: Vec<String>,
    },
    NotIn {
        property: PropertyRef,
        values: Vec<String>,
    },
    Before {
        property: PropertyRef,
        date: String,
    },
    After {
        property: PropertyRef,
        date: String,
    },
    By {
        property: PropertyRef,
        date: String,
    },
    DateFrom {
        property: PropertyRef,
        from: String,
    },
    DateTo {
        property: PropertyRef,
        to: String,
    },
    None {
        property: PropertyRef,
    },
    Any {
        property: PropertyRef,
    },
}

/// Numeric comparison filters
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
#[serde(tag = "type")]
pub enum NumericPropertyFilter {
    Equals { property: PropertyRef, value: f64 },
    NotEquals { property: PropertyRef, value: f64 },
    LessThan { property: PropertyRef, value: f64 },
    LessThanOrEqual { property: PropertyRef, value: f64 },
    GreaterThan { property: PropertyRef, value: f64 },
    GreaterThanOrEqual { property: PropertyRef, value: f64 },
    None { property: PropertyRef },
    Any { property: PropertyRef },
}

/// Combined property filter enum
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
#[serde(untagged)]
pub enum PropertyFilter {
    String(StringPropertyFilter),
    DateTime(DateTimePropertyFilter),
    Numeric(NumericPropertyFilter),
}

/// Filter group types
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
#[serde(tag = "type")]
pub enum FilterGroup {
    AndFilterGroup { filters: Vec<FilterExpression> },
    OrFilterGroup { filters: Vec<FilterExpression> },
    XorFilterGroup { filters: Vec<FilterExpression> },
}

/// Tag filter for +tag / -tag syntax
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
#[serde(tag = "type")]
pub struct TagFilter {
    pub tag: String,
    pub exclude: bool,
}

/// Virtual tag filter for +ACTIVE, -DELETED, etc.
#[derive(Debug, Clone, serde::Deserialize, serde::Serialize)]
#[serde(tag = "type")]
pub struct VirtualTagFilter {
    pub tag: String,
    pub exclude: bool,
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
pub fn get_string_property(task: &Task, property_name: &str) -> Option<String> {
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
pub fn get_datetime_property(task: &Task, property_name: &str) -> Option<DateTime<Utc>> {
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

/// Check if a task has a virtual tag
pub fn has_virtual_tag(task: &Task, tag: &str) -> bool {
    match tag.to_uppercase().as_str() {
        "ACTIVE" | "BLOCKED" | "BLOCKING" | "COMPLETED" | "DELETED" | "PENDING" | "UNBLOCKED"
        | "WAITING" => {
            if let Ok(tag_obj) = taskchampion::Tag::from_str(tag) {
                return task.has_tag(&tag_obj);
            }
            false
        }
        "ANNOTATED" => task.get_annotations().count() > 0,
        "DUE" => {
            if let Some(due) = task.get_due() {
                let now = Utc::now();
                let seven_days = chrono::Duration::days(7);
                due <= now + seven_days
            } else {
                false
            }
        }
        "DUETODAY" | "TODAY" => {
            if let Some(due) = task.get_due() {
                let now = Utc::now();
                due.date_naive() == now.date_naive()
            } else {
                false
            }
        }
        "INSTANCE" => task.get_value("template").is_some() || task.get_value("parent").is_some(),
        "LATEST" => false,
        "MONTH" => {
            if let Some(due) = task.get_due() {
                let now = Utc::now();
                due.month() == now.month() && due.year() == now.year()
            } else {
                false
            }
        }
        "ORPHAN" => false,
        "OVERDUE" => {
            if let Some(due) = task.get_due() {
                due < Utc::now() && task.get_status() == taskchampion::Status::Pending
            } else {
                false
            }
        }
        "PARENT" => task.get_value("last").is_some() || task.get_value("mask").is_some(),
        "PRIORITY" => !task.get_priority().is_empty(),
        "PROJECT" => task.get_value("project").is_some(),
        "QUARTER" => {
            if let Some(due) = task.get_due() {
                let now = Utc::now();
                let current_quarter = (now.month() - 1) / 3 + 1;
                let due_quarter = (due.month() - 1) / 3 + 1;
                current_quarter == due_quarter && now.year() == due.year()
            } else {
                false
            }
        }
        "READY" => {
            task.get_status() == taskchampion::Status::Pending
                && task.get_wait().is_none_or(|w| w <= Utc::now())
        }
        "SCHEDULED" => task.get_value("scheduled").is_some(),
        "TAGGED" => task.get_tags().count() > 0,
        "TEMPLATE" => task.get_value("last").is_some() || task.get_value("mask").is_some(),
        "TOMORROW" => {
            if let Some(due) = task.get_due() {
                let tomorrow = Utc::now() + chrono::Duration::days(1);
                due.date_naive() == tomorrow.date_naive()
            } else {
                false
            }
        }
        "UDA" => false,
        "UNTIL" => task.get_value("until").is_some(),
        "WEEK" => {
            if let Some(due) = task.get_due() {
                let now_iso = Utc::now().iso_week();
                let due_iso = due.iso_week();
                now_iso.year() == due_iso.year() && now_iso.week() == due_iso.week()
            } else {
                false
            }
        }
        "YEAR" => {
            if let Some(due) = task.get_due() {
                due.year() == Utc::now().year()
            } else {
                false
            }
        }
        "YESTERDAY" => {
            if let Some(due) = task.get_due() {
                let yesterday = Utc::now() - chrono::Duration::days(1);
                due.date_naive() == yesterday.date_naive()
            } else {
                false
            }
        }
        _ => false,
    }
}

/// Compare two tasks for sorting
pub fn compare_tasks(task1: &Task, task2: &Task, sort: &TaskSort) -> std::cmp::Ordering {
    let property_name = &sort.property.name;
    let ascending = sort.direction == SortDirection::Ascending;

    let str_cmp = |prop: &str| -> Option<std::cmp::Ordering> {
        let v1 = get_string_property(task1, prop);
        let v2 = get_string_property(task2, prop);
        match (v1, v2) {
            (Some(a), Some(b)) => Some(a.cmp(&b)),
            (Some(_), None) => Some(std::cmp::Ordering::Greater),
            (None, Some(_)) => Some(std::cmp::Ordering::Less),
            (None, None) => None,
        }
    };

    let dt_cmp = |prop: &str| -> Option<std::cmp::Ordering> {
        let v1 = get_datetime_property(task1, prop);
        let v2 = get_datetime_property(task2, prop);
        match (v1, v2) {
            (Some(a), Some(b)) => Some(a.cmp(&b)),
            (Some(_), None) => Some(std::cmp::Ordering::Greater),
            (None, Some(_)) => Some(std::cmp::Ordering::Less),
            (None, None) => None,
        }
    };

    let double_cmp = |prop: &str| -> Option<std::cmp::Ordering> {
        let v1 = task1.get_value(prop).and_then(|s| s.parse::<f64>().ok());
        let v2 = task2.get_value(prop).and_then(|s| s.parse::<f64>().ok());
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

/// Evaluate a filter expression against a task
pub fn evaluate_filter_expression(task: &Task, expr: &FilterExpression) -> bool {
    match expr {
        FilterExpression::AndGroup { filters } => {
            filters.iter().all(|f| evaluate_filter_expression(task, f))
        }
        FilterExpression::OrGroup { filters } => {
            filters.iter().any(|f| evaluate_filter_expression(task, f))
        }
        FilterExpression::XorGroup { filters } => {
            filters
                .iter()
                .filter(|f| evaluate_filter_expression(task, f))
                .count()
                == 1
        }
        FilterExpression::Not { inner } => !evaluate_filter_expression(task, inner),
        FilterExpression::Tag { tag, exclude } => {
            let has_tag = task.get_tags().any(|t| t.as_ref() == tag.as_str());
            if *exclude {
                !has_tag
            } else {
                has_tag
            }
        }
        FilterExpression::VirtualTag { tag, exclude } => {
            let has_virtual = has_virtual_tag(task, tag);
            if *exclude {
                !has_virtual
            } else {
                has_virtual
            }
        }
        FilterExpression::EqualsFilter { property, value } => {
            get_string_property(task, &property.name).is_some_and(|v| {
                if let Some(s) = value.as_str() {
                    v == s
                } else {
                    false
                }
            })
        }
        FilterExpression::NotEqualsFilter { property, value } => {
            get_string_property(task, &property.name).is_none_or(|v| {
                if let Some(s) = value.as_str() {
                    v != s
                } else {
                    true
                }
            })
        }
        FilterExpression::InFilter { property, values } => {
            get_string_property(task, &property.name)
                .is_some_and(|v| values.iter().any(|val| val.as_str() == Some(&v)))
        }
        FilterExpression::NotInFilter { property, values } => {
            get_string_property(task, &property.name)
                .is_none_or(|v| values.iter().all(|val| val.as_str() != Some(&v)))
        }
        FilterExpression::ContainsFilter {
            property,
            value,
            case_sensitive,
        } => get_string_property(task, &property.name).is_some_and(|v| {
            if *case_sensitive {
                v.contains(value)
            } else {
                v.to_lowercase().contains(&value.to_lowercase())
            }
        }),
        FilterExpression::NotContainsFilter {
            property,
            value,
            case_sensitive,
        } => get_string_property(task, &property.name).is_none_or(|v| {
            if *case_sensitive {
                !v.contains(value)
            } else {
                !v.to_lowercase().contains(&value.to_lowercase())
            }
        }),
        FilterExpression::StartsWithFilter {
            property,
            value,
            case_sensitive,
        } => get_string_property(task, &property.name).is_some_and(|v| {
            if *case_sensitive {
                v.starts_with(value)
            } else {
                v.to_lowercase().starts_with(&value.to_lowercase())
            }
        }),
        FilterExpression::EndsWithFilter {
            property,
            value,
            case_sensitive,
        } => get_string_property(task, &property.name).is_some_and(|v| {
            if *case_sensitive {
                v.ends_with(value)
            } else {
                v.to_lowercase().ends_with(&value.to_lowercase())
            }
        }),
        FilterExpression::WordFilter {
            property,
            value,
            case_sensitive,
        } => get_string_property(task, &property.name).is_some_and(|v| {
            let search_val = if *case_sensitive {
                value.clone()
            } else {
                value.to_lowercase()
            };
            let text = if *case_sensitive { v } else { v.to_lowercase() };
            let pattern = format!(r"\b{}\b", regex::escape(&search_val));
            regex::Regex::new(&pattern).is_ok_and(|re| re.is_match(&text))
        }),
        FilterExpression::NoWordFilter {
            property,
            value,
            case_sensitive,
        } => get_string_property(task, &property.name).is_none_or(|v| {
            let search_val = if *case_sensitive {
                value.clone()
            } else {
                value.to_lowercase()
            };
            let text = if *case_sensitive { v } else { v.to_lowercase() };
            let pattern = format!(r"\b{}\b", regex::escape(&search_val));
            regex::Regex::new(&pattern).is_ok_and(|re| !re.is_match(&text))
        }),
        FilterExpression::RegexFilter {
            property,
            pattern,
            case_sensitive,
        } => get_string_property(task, &property.name).is_some_and(|v| {
            let regex_pattern = if *case_sensitive {
                pattern.clone()
            } else {
                format!("(?i){pattern}")
            };
            regex::Regex::new(&regex_pattern).is_ok_and(|re| re.is_match(&v))
        }),
        FilterExpression::NoneFilter { property } => {
            get_string_property(task, &property.name).is_none_or(|v| v.is_empty())
        }
        FilterExpression::AnyFilter { property } => {
            get_string_property(task, &property.name).is_some_and(|v| !v.is_empty())
        }
        FilterExpression::DateBeforeFilter { property, date } => {
            get_datetime_property(task, &property.name).is_some_and(|task_dt| {
                let filter_dt = DateTime::parse_from_rfc3339(date)
                    .map(|dt| dt.with_timezone(&Utc))
                    .ok();
                filter_dt.is_some_and(|f_dt| task_dt < f_dt)
            })
        }
        FilterExpression::DateAfterFilter { property, date } => {
            get_datetime_property(task, &property.name).is_some_and(|task_dt| {
                let filter_dt = DateTime::parse_from_rfc3339(date)
                    .map(|dt| dt.with_timezone(&Utc))
                    .ok();
                filter_dt.is_some_and(|f_dt| task_dt > f_dt)
            })
        }
        FilterExpression::DateByFilter { property, date } => {
            get_datetime_property(task, &property.name).is_some_and(|task_dt| {
                let filter_dt = DateTime::parse_from_rfc3339(date)
                    .map(|dt| dt.with_timezone(&Utc))
                    .ok();
                filter_dt.is_some_and(|f_dt| task_dt <= f_dt)
            })
        }
        FilterExpression::DateFromFilter { property, from } => {
            get_datetime_property(task, &property.name).is_some_and(|task_dt| {
                let filter_dt = DateTime::parse_from_rfc3339(from)
                    .map(|dt| dt.with_timezone(&Utc))
                    .ok();
                filter_dt.is_some_and(|f_dt| task_dt >= f_dt)
            })
        }
        FilterExpression::DateToFilter { property, to } => {
            get_datetime_property(task, &property.name).is_some_and(|task_dt| {
                let filter_dt = DateTime::parse_from_rfc3339(to)
                    .map(|dt| dt.with_timezone(&Utc))
                    .ok();
                filter_dt.is_some_and(|f_dt| task_dt <= f_dt)
            })
        }
        FilterExpression::LessThanFilter { property, value } => {
            if property.name == "urgency" {
                if let Some(urgency_str) = task.get_value("urgency") {
                    if let Ok(urgency) = urgency_str.parse::<f64>() {
                        return urgency < *value;
                    }
                }
            }
            false
        }
        FilterExpression::LessThanOrEqualFilter { property, value } => {
            if property.name == "urgency" {
                if let Some(urgency_str) = task.get_value("urgency") {
                    if let Ok(urgency) = urgency_str.parse::<f64>() {
                        return urgency <= *value;
                    }
                }
            }
            false
        }
        FilterExpression::GreaterThanFilter { property, value } => {
            if property.name == "urgency" {
                if let Some(urgency_str) = task.get_value("urgency") {
                    if let Ok(urgency) = urgency_str.parse::<f64>() {
                        return urgency > *value;
                    }
                }
            }
            false
        }
        FilterExpression::GreaterThanOrEqualFilter { property, value } => {
            if property.name == "urgency" {
                if let Some(urgency_str) = task.get_value("urgency") {
                    if let Ok(urgency) = urgency_str.parse::<f64>() {
                        return urgency >= *value;
                    }
                }
            }
            false
        }
    }
}

// ============================================================================
// FILTER TESTS
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use crate::create_storage_async;
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
}
