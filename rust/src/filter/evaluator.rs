//! Filter expression evaluation (ticket R7).
//!
//! Extracted from the former monolithic `filter.rs`. Houses
//! [`evaluate_filter_expression`] and the per-thread regex compilation cache
//! (ticket R2) that backs `RegexFilter` / `WordFilter`.

use chrono::{DateTime, Utc};
use taskchampion::Task;

use crate::filter::{
    compile_regex, get_datetime_property, get_string_property, has_virtual_tag, FilterExpression,
};

/// Evaluate a [`FilterExpression`] against a single task.
pub(crate) fn evaluate_filter_expression(task: &Task, expr: &FilterExpression) -> bool {
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
            // Ticket R2: reuse the compiled regex via the thread-local cache
            // instead of recompiling `\b{value}\b` for every task.
            let pattern = format!(r"\b{}\b", regex::escape(&search_val));
            compile_regex(&pattern).is_some_and(|re| re.is_match(&text))
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
            compile_regex(&pattern).is_some_and(|re| !re.is_match(&text))
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
            // Ticket R2: look up (and prime) the per-thread regex cache.
            compile_regex(&regex_pattern).is_some_and(|re| re.is_match(&v))
        }),
        FilterExpression::NoneFilter { property } => {
            get_string_property(task, &property.name).is_none_or(|v| v.is_empty())
        }
        FilterExpression::AnyFilter { property } => {
            get_string_property(task, &property.name).is_some_and(|v| !v.is_empty())
        }
        FilterExpression::DateBeforeFilter { property, date } => {
            compare_filter_date(task, &property.name, date, |task_dt, f_dt| task_dt < f_dt)
        }
        FilterExpression::DateAfterFilter { property, date } => {
            compare_filter_date(task, &property.name, date, |task_dt, f_dt| task_dt > f_dt)
        }
        FilterExpression::DateByFilter { property, date } => {
            compare_filter_date(task, &property.name, date, |task_dt, f_dt| task_dt <= f_dt)
        }
        FilterExpression::DateFromFilter { property, from } => {
            compare_filter_date(task, &property.name, from, |task_dt, f_dt| task_dt >= f_dt)
        }
        FilterExpression::DateToFilter { property, to } => {
            compare_filter_date(task, &property.name, to, |task_dt, f_dt| task_dt <= f_dt)
        }
        FilterExpression::LessThanFilter { property, value } => {
            urgency_compare(task, &property.name, |u| u < *value)
        }
        FilterExpression::LessThanOrEqualFilter { property, value } => {
            urgency_compare(task, &property.name, |u| u <= *value)
        }
        FilterExpression::GreaterThanFilter { property, value } => {
            urgency_compare(task, &property.name, |u| u > *value)
        }
        FilterExpression::GreaterThanOrEqualFilter { property, value } => {
            urgency_compare(task, &property.name, |u| u >= *value)
        }
    }
}

/// Helper: compare a task datetime property against a filter date using `cmp`.
fn compare_filter_date(
    task: &Task,
    property_name: &str,
    date_str: &str,
    cmp: impl Fn(DateTime<Utc>, DateTime<Utc>) -> bool,
) -> bool {
    let Some(task_dt) = get_datetime_property(task, property_name) else {
        return false;
    };
    let Ok(parsed) = DateTime::parse_from_rfc3339(date_str) else {
        return false;
    };
    cmp(task_dt, parsed.with_timezone(&Utc))
}

/// Helper: apply a numeric comparison to the task's `urgency` property.
fn urgency_compare(task: &Task, property_name: &str, cmp: impl Fn(f64) -> bool) -> bool {
    if property_name != "urgency" {
        return false;
    }
    let Some(urgency_str) = task.get_value("urgency") else {
        return false;
    };
    let Ok(urgency) = urgency_str.parse::<f64>() else {
        return false;
    };
    cmp(urgency)
}
