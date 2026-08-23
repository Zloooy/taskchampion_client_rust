use chrono::{DateTime, Utc};
use std::collections::HashMap;
use std::str::FromStr;
use taskchampion::{utc_timestamp, Operations, Replica, Status, Tag};
use uuid::Uuid;

use crate::error::{TcError, TcResult};

/// Parse a datetime string into a `DateTime<Utc>`.
///
/// Returns:
/// * `Ok(None)` when `dt_str` is empty (meaning "no value").
/// * `Ok(Some(dt))` when `dt_str` parses cleanly as RFC-3339.
/// * `Err(TcError::BadDatetime)` when `dt_str` is non-empty but malformed.
///
/// Previously this function returned a bare `Option`, silently dropping
/// malformed inputs. Ticket R8 asked for malformed dates to propagate so the
/// caller can decide whether to abort (writes) or ignore (reads).
pub fn parse_datetime(dt_str: &str) -> TcResult<Option<DateTime<Utc>>> {
    if dt_str.is_empty() {
        return Ok(None);
    }
    match DateTime::parse_from_rfc3339(dt_str) {
        Ok(dt) => Ok(Some(dt.with_timezone(&Utc))),
        Err(err) => Err(TcError::bad_datetime(dt_str, err.to_string())),
    }
}

/// Lenient datetime parse used on the *read* path.
///
/// Stored task data may contain legacy or externally-produced values that we
/// do not want to crash on while serialising a task out to the Dart side.
/// Returns `None` for empty *or* unparseable input.
fn parse_datetime_lenient(dt_str: &str) -> Option<DateTime<Utc>> {
    parse_datetime(dt_str).ok().flatten()
}

/// Apply task fields from a HashMap onto a freshly-created task.
///
/// This is the create path (ticket R9): nothing is cleared first, only the
/// fields present in `task_data` are written. Prefer the typed
/// [`apply_dto_on_create`] for new code.
fn apply_on_create(
    task: &mut taskchampion::Task,
    task_data: &HashMap<String, String>,
    ops: &mut Operations,
) -> Result<(), anyhow::Error> {
    apply_task_data(task, task_data, ops, /* clear_existing */ false)
}

/// Replace an existing task's mutable fields from a HashMap.
///
/// This is the update path (ticket R9): existing tags, dependencies and
/// annotations are cleared before applying the new values. Prefer the typed
/// [`replace_dto_on_update`] for new code.
fn replace_on_update(
    task: &mut taskchampion::Task,
    task_data: &HashMap<String, String>,
    ops: &mut Operations,
) -> Result<(), anyhow::Error> {
    apply_task_data(task, task_data, ops, /* clear_existing */ true)
}

/// Shared core for [`apply_on_create`] / [`replace_on_update`].
///
/// `clear_existing` controls whether the multi-valued fields (tags,
/// dependencies, annotations) are cleared before applying the new values.
/// Kept private because new call sites should pick one of the two named
/// entry points above.
fn apply_task_data(
    task: &mut taskchampion::Task,
    task_data: &HashMap<String, String>,
    ops: &mut Operations,
    clear_existing: bool,
) -> Result<(), anyhow::Error> {
    if let Some(desc) = task_data.get("description") {
        task.set_description(desc.clone(), ops)?;
    }

    if let Some(status) = task_data.get("status") {
        let task_status = match status.as_str() {
            "completed" => Status::Completed,
            "deleted" => Status::Deleted,
            _ => Status::Pending,
        };
        task.set_status(task_status, ops)?;
    }

    if let Some(priority) = task_data.get("priority") {
        task.set_priority(priority.clone(), ops)?;
    }

    if let Some(due) = task_data.get("due") {
        if let Some(dt) = parse_datetime(due)? {
            task.set_due(Some(dt), ops)?;
        }
    }

    if let Some(wait) = task_data.get("wait") {
        if let Some(dt) = parse_datetime(wait)? {
            task.set_wait(Some(dt), ops)?;
        }
    }

    // Handle tags
    if let Some(tags_str) = task_data.get("tags") {
        if clear_existing {
            // Only remove USER tags; synthetic tags cannot be modified.
            let existing_tags: Vec<Tag> = task.get_tags().filter(|t| t.is_user()).collect();
            for tag in existing_tags {
                task.remove_tag(&tag, ops)?;
            }
        }
        for tag in tags_str.split_whitespace() {
            let tag = Tag::from_str(tag)?;
            task.add_tag(&tag, ops)?;
        }
    }

    // Handle dependencies
    if let Some(depends_str) = task_data.get("depends") {
        if clear_existing {
            let existing_deps: Vec<Uuid> = task.get_dependencies().collect();
            for dep in existing_deps {
                task.remove_dependency(dep, ops)?;
            }
        }
        for dep_uuid_str in depends_str.split_whitespace() {
            if let Ok(dep_uuid) = Uuid::parse_str(dep_uuid_str) {
                task.add_dependency(dep_uuid, ops)?;
            }
        }
    }

    // Handle annotations
    if clear_existing {
        let existing_annotations: Vec<i64> = task
            .get_annotations()
            .map(|a| a.entry.timestamp())
            .collect();
        for ts in existing_annotations {
            task.remove_annotation(utc_timestamp(ts), ops)?;
        }
    }
    for (key, value) in task_data.iter() {
        if let Some(ts_str) = key.strip_prefix("annotation_") {
            if let Ok(ts) = ts_str.parse::<i64>() {
                let annotation = taskchampion::Annotation {
                    entry: utc_timestamp(ts),
                    description: value.clone(),
                };
                task.add_annotation(annotation, ops)?;
            }
        }
    }

    // Handle UDAs.
    //
    // Ticket R5 / I-13: previously the membership test used
    // `key.starts_with(prefix)` for *every* built-in property, which
    // silently dropped legitimate UDAs whose name happened to share a prefix
    // with a built-in (e.g. `entry_note`, `description_long`,
    // `modified_by`). Only `annotation_` is genuinely a prefix; every other
    // entry below is an exact field name.
    //
    // `scheduled` and `until` are real UDAs too but get a datetime
    // normalisation pass, so they are deliberately NOT in this reserved list.
    let reserved_exact = [
        "description",
        "status",
        "priority",
        "due",
        "wait",
        "entry",
        "modified",
        "end",
        "tags",
        "depends",
        "uuid",
    ];

    for (key, value) in task_data.iter() {
        let is_builtin = reserved_exact.contains(&key.as_str()) || key.starts_with("annotation_");
        if is_builtin {
            continue;
        }
        if key == "scheduled" || key == "until" {
            if let Some(dt) = parse_datetime(value)? {
                task.set_user_defined_attribute(key.clone(), dt.to_rfc3339(), ops)?;
            }
        } else {
            task.set_user_defined_attribute(key.clone(), value.clone(), ops)?;
        }
    }

    Ok(())
}

/// Convert a HashMap task data to taskchampion Task
pub async fn create_task_from_map<S: taskchampion::storage::Storage>(
    replica: &mut Replica<S>,
    task_data: HashMap<String, String>,
) -> Result<Uuid, anyhow::Error> {
    let mut ops = Operations::new();

    let uuid = Uuid::new_v4();
    let mut task = replica.create_task(uuid, &mut ops).await?;

    apply_on_create(&mut task, &task_data, &mut ops)?;

    replica.commit_operations(ops).await?;

    Ok(uuid)
}

/// Update an existing task with new data
pub async fn update_task_in_replica<S: taskchampion::storage::Storage>(
    replica: &mut Replica<S>,
    uuid: Uuid,
    task_data: HashMap<String, String>,
) -> Result<(), anyhow::Error> {
    let mut ops = Operations::new();
    let mut task = replica
        .get_task(uuid)
        .await?
        .ok_or_else(|| anyhow::anyhow!("Task not found"))?;

    replace_on_update(&mut task, &task_data, &mut ops)?;

    replica.commit_operations(ops).await?;

    Ok(())
}

/// Convert taskchampion Task to HashMap for JSON serialization
pub fn task_to_map(task: &taskchampion::Task) -> HashMap<String, String> {
    let mut map = HashMap::new();

    map.insert("uuid".to_string(), task.get_uuid().to_string());
    map.insert(
        "description".to_string(),
        task.get_description().to_string(),
    );
    let status_str = match task.get_status() {
        taskchampion::Status::Pending => "pending",
        taskchampion::Status::Completed => "completed",
        taskchampion::Status::Deleted => "deleted",
        taskchampion::Status::Recurring => "recurring",
        taskchampion::Status::Unknown(_) => "unknown",
    };
    map.insert("status".to_string(), status_str.to_string());

    if let Some(entry) = task.get_entry() {
        map.insert("entry".to_string(), entry.to_rfc3339());
    } else {
        map.insert("entry".to_string(), chrono::Utc::now().to_rfc3339());
    }

    if let Some(modified) = task.get_modified() {
        map.insert("modified".to_string(), modified.to_rfc3339());
    }

    if let Some(end_str) = task.get_value("end") {
        // Read path: be lenient about legacy/malformed stored values so that
        // exporting a task never fails on a single bad row.
        if let Some(end) = parse_datetime_lenient(end_str) {
            map.insert("end".to_string(), end.to_rfc3339());
        }
    }

    let priority = task.get_priority();
    if !priority.is_empty() {
        map.insert("priority".to_string(), priority.to_string());
    }

    if let Some(due) = task.get_due() {
        map.insert("due".to_string(), due.to_rfc3339());
    }

    if let Some(wait) = task.get_wait() {
        map.insert("wait".to_string(), wait.to_rfc3339());
    }

    // Ticket R6: filter synthetic tags out via `Tag::is_user()` rather than
    // the old `has_virtual_tag` check. `Task::get_tags()` yields BOTH user
    // and synthetic tags (PENDING, UNBLOCKED, …), so we must exclude the
    // synthetic ones when serialising the user-facing tag list. Using
    // `is_user()` is exact and cannot drop a legitimate user tag whose name
    // happens to collide with a synthetic tag (the old `has_virtual_tag`
    // approach dropped any user tag named e.g. "project").
    let tags: Vec<String> = task
        .get_tags()
        .filter(|t| t.is_user())
        .map(|t| t.to_string())
        .collect();
    map.insert("tags".to_string(), tags.join(" "));

    let deps: Vec<String> = task.get_dependencies().map(|u| u.to_string()).collect();
    map.insert("depends".to_string(), deps.join(" "));

    for annotation in task.get_annotations() {
        let key = format!("annotation_{}", annotation.entry.timestamp());
        map.insert(key, annotation.description);
    }

    for (key, value) in task.get_user_defined_attributes() {
        map.insert(key.to_string(), value.to_string());
    }

    map
}

// ============================================================================
// Typed DTO conversion (ticket R5)
// ============================================================================

use crate::models::{AnnotationDto, TaskDto};

/// Convert a taskchampion [`Task`] into a typed [`TaskDto`].
///
/// Unlike [`task_to_map`], this preserves tags as a real `Vec<String>` (so
/// spaces in tags survive) and separates annotations/UDAs into their own
/// fields, eliminating the UDA-prefix-drop bug.
pub fn task_to_dto(task: &taskchampion::Task) -> TaskDto {
    let priority = task.get_priority();
    // `get_tags()` yields both user and synthetic tags; keep only user tags
    // (ticket R6). Synthetic tags like PENDING/UNBLOCKED are derived from
    // task state and must not be exposed as user-modifiable tags.
    let tags: Vec<String> = task
        .get_tags()
        .filter(|t| t.is_user())
        .map(|t| t.to_string())
        .collect();
    let depends: Vec<String> = task.get_dependencies().map(|u| u.to_string()).collect();
    let annotations: Vec<AnnotationDto> = task
        .get_annotations()
        .map(|a| AnnotationDto {
            entry: chrono::DateTime::from_timestamp(a.entry.timestamp(), 0)
                .map(|dt| dt.to_rfc3339())
                .unwrap_or_default(),
            description: a.description,
        })
        .collect();

    // Promoted UDA fields (`scheduled` / `until` / `recur`) are lifted out of
    // the raw UDA map into their dedicated DTO fields so a round-trip keeps
    // them in the canonical place. They are NOT duplicated back into `udas`
    // (documented in [`TaskDto`]).
    let mut udas: HashMap<String, String> = HashMap::new();
    let mut scheduled: Option<String> = None;
    let mut until: Option<String> = None;
    let mut recur: Option<String> = None;
    for (k, v) in task.get_user_defined_attributes() {
        match k {
            "scheduled" => scheduled = Some(v.to_string()),
            "until" => until = Some(v.to_string()),
            "recur" => recur = Some(v.to_string()),
            _ => {
                udas.insert(k.to_string(), v.to_string());
            }
        }
    }

    TaskDto {
        uuid: task.get_uuid().to_string(),
        description: task.get_description().to_string(),
        status: task.get_status().into(),
        priority: if priority.is_empty() {
            None
        } else {
            Some(priority.to_string())
        },
        due: task.get_due().map(|dt| dt.to_rfc3339()),
        wait: task.get_wait().map(|dt| dt.to_rfc3339()),
        entry: task.get_entry().map(|dt| dt.to_rfc3339()),
        modified: task.get_modified().map(|dt| dt.to_rfc3339()),
        // `end` may be stored as an explicit value or via the timestamp
        // setters (unix seconds); parse leniently so legacy rows never crash
        // the read path.
        end: task.get_value("end").and_then(parse_end_value),
        scheduled,
        until,
        recur,
        tags,
        depends,
        // Reads always surface the concrete list; "preserve" (None) is a
        // write-path concept only.
        annotations: Some(annotations),
        udas,
    }
}

/// Parse a stored `end` property value into an RFC-3339 string.
///
/// TaskChampion stores timestamps as unix-second strings (see
/// `Task::set_timestamp`), but explicit `end` values written via
/// [`taskchampion::Task::set_value`] may be RFC-3339. Accept both; return
/// `None` for empty or unparseable input (read path stays lenient).
fn parse_end_value(raw: &str) -> Option<String> {
    if let Ok(secs) = raw.parse::<i64>() {
        return chrono::DateTime::from_timestamp(secs, 0).map(|dt| dt.to_rfc3339());
    }
    parse_datetime_lenient(raw).map(|dt| dt.to_rfc3339())
}

/// Apply a typed [`TaskDto`] onto a freshly-created task.
///
/// This is the typed analogue of `apply_task_data(.., clear_existing=false)`,
/// used on the create path. Tags are applied directly from the `Vec<String>`
/// (no whitespace split), and UDAs are written verbatim from the dedicated
/// map — fixing both the space-in-tag bug and the UDA-prefix-drop bug.
pub fn apply_dto_on_create(
    task: &mut taskchampion::Task,
    dto: &TaskDto,
    ops: &mut Operations,
) -> Result<(), anyhow::Error> {
    // NOTE: `dto.uuid` is ignored on create — the replica allocates the task's
    // uuid (see [`create_task_from_dto`]). Callers should leave it empty.
    task.set_description(dto.description.clone(), ops)?;
    task.set_status(dto.status.into(), ops)?;
    if let Some(ref priority) = dto.priority {
        task.set_priority(priority.clone(), ops)?;
    }
    apply_optional_datetime(task, "due", dto.due.as_deref(), ops, |t, dt, o| {
        t.set_due(Some(dt), o)
    })?;
    apply_optional_datetime(task, "wait", dto.wait.as_deref(), ops, |t, dt, o| {
        t.set_wait(Some(dt), o)
    })?;
    apply_optional_datetime(task, "entry", dto.entry.as_deref(), ops, |t, dt, o| {
        t.set_entry(Some(dt), o)
    })?;
    apply_modified(task, dto.modified.as_deref(), ops)?;
    apply_end(task, dto.end.as_deref(), ops)?;
    apply_promoted_fields(task, dto, ops)?;
    apply_tags(task, &dto.tags, /* clear_existing */ false, ops)?;
    apply_dependencies(task, &dto.depends, /* clear_existing */ false, ops)?;
    // A brand-new task has nothing to preserve, so `None` is a harmless no-op
    // here; `Some(list)` applies the given annotations.
    apply_annotations(task, dto.annotations.as_deref(), ops)?;
    apply_udas(task, &dto.udas, ops)?;
    Ok(())
}

/// Replace an existing task's mutable fields with those from a typed [`TaskDto`].
///
/// This is the typed analogue of `apply_task_data(.., clear_existing=true)`,
/// used on the update path: existing tags and dependencies are always cleared
/// and replaced. Annotations follow the tri-state semantics of
/// [`TaskDto::annotations`]: they are only cleared/replaced when
/// `dto.annotations` is `Some(...)`; `None` leaves them untouched.
pub fn replace_dto_on_update(
    task: &mut taskchampion::Task,
    dto: &TaskDto,
    ops: &mut Operations,
) -> Result<(), anyhow::Error> {
    // NOTE: `dto.uuid` is READ-ONLY on update and deliberately ignored — the
    // target task is addressed by the separately-passed uuid in
    // [`update_task_with_dto`]. A caller can never reassign a task's identity
    // through the DTO.
    task.set_description(dto.description.clone(), ops)?;
    task.set_status(dto.status.into(), ops)?;
    if let Some(ref priority) = dto.priority {
        task.set_priority(priority.clone(), ops)?;
    } else {
        // Clear priority by setting it to empty.
        task.set_priority(String::new(), ops)?;
    }
    apply_optional_datetime(task, "due", dto.due.as_deref(), ops, |t, dt, o| {
        t.set_due(Some(dt), o)
    })?;
    if dto.due.is_none() {
        task.set_due(None, ops)?;
    }
    apply_optional_datetime(task, "wait", dto.wait.as_deref(), ops, |t, dt, o| {
        t.set_wait(Some(dt), o)
    })?;
    if dto.wait.is_none() {
        task.set_wait(None, ops)?;
    }
    apply_optional_datetime(task, "entry", dto.entry.as_deref(), ops, |t, dt, o| {
        t.set_entry(Some(dt), o)
    })?;
    // Absent => leave alone: the library auto-refreshes `modified` on commit.
    apply_modified(task, dto.modified.as_deref(), ops)?;
    apply_end(task, dto.end.as_deref(), ops)?;
    apply_promoted_fields(task, dto, ops)?;
    apply_tags(task, &dto.tags, /* clear_existing */ true, ops)?;
    apply_dependencies(task, &dto.depends, /* clear_existing */ true, ops)?;
    // Tri-state: None preserves existing annotations, Some(empty) clears them,
    // Some(list) replaces them.
    apply_annotations(task, dto.annotations.as_deref(), ops)?;
    apply_udas(task, &dto.udas, ops)?;
    Ok(())
}

fn apply_optional_datetime(
    _task: &mut taskchampion::Task,
    _field: &str,
    value: Option<&str>,
    _ops: &mut Operations,
    setter: impl Fn(
        &mut taskchampion::Task,
        chrono::DateTime<chrono::Utc>,
        &mut Operations,
    ) -> Result<(), taskchampion::Error>,
) -> Result<(), anyhow::Error> {
    if let Some(raw) = value {
        if let Some(dt) = parse_datetime(raw)? {
            setter(_task, dt, _ops)?;
        }
    }
    Ok(())
}

/// Apply an explicit `modified` timestamp, or leave it untouched.
///
/// Absent values are intentionally a no-op: TaskChampion refreshes `modified`
/// automatically on commit, so clearing it would just be overwritten.
fn apply_modified(
    task: &mut taskchampion::Task,
    value: Option<&str>,
    ops: &mut Operations,
) -> Result<(), anyhow::Error> {
    if let Some(raw) = value {
        if let Some(dt) = parse_datetime(raw)? {
            task.set_modified(dt, ops)?;
        }
    }
    Ok(())
}

/// Apply an explicit `end` timestamp via the generic property setter.
///
/// There is no dedicated `set_end`: normally `end` is derived from status
/// changes (`Task::set_status` sets/clears it on complete/delete/pending).
/// Writing through [`taskchampion::Task::set_value`] lets callers pin an
/// explicit end timestamp that round-trips verbatim. Note that flipping
/// status afterwards will overwrite/clear this value per TaskChampion's own
/// bookkeeping — that conflict is resolved in favour of the library.
fn apply_end(
    task: &mut taskchampion::Task,
    value: Option<&str>,
    ops: &mut Operations,
) -> Result<(), anyhow::Error> {
    match value {
        Some(raw) => {
            // Validate up front so malformed input surfaces as
            // TcError::BadDatetime before anything is written. A non-empty
            // string that parses cleanly always yields a timestamp here.
            if let Some(dt) = parse_datetime(raw)? {
                task.set_value("end", Some(dt.to_rfc3339()), ops)?;
            }
        }
        None => {
            // Explicitly clear any stored end (e.g. re-opening a completed task).
            task.set_value("end", None::<String>, ops)?;
        }
    }
    Ok(())
}

/// Apply the three promoted UDA fields (`scheduled` / `until` / `recur`).
///
/// All three remain UDAs in storage — TaskChampion has no dedicated setters
/// for them (Taskwarrior convention). Datetime fields are validated via
/// [`parse_datetime`] but stored verbatim so sub-second precision survives
/// the round trip; `recur` is a free-form rule/duration string.
///
/// The promoted fields own their UDA names exclusively: any same-named key in
/// `dto.udas` is ignored on write (documented on [`TaskDto::udas`]).
fn apply_promoted_fields(
    task: &mut taskchampion::Task,
    dto: &TaskDto,
    ops: &mut Operations,
) -> Result<(), anyhow::Error> {
    for (key, dedicated) in [
        ("scheduled", dto.scheduled.as_deref()),
        ("until", dto.until.as_deref()),
    ] {
        match dedicated {
            Some(raw) => {
                parse_datetime(raw)?;
                task.set_user_defined_attribute(key.to_string(), raw.to_string(), ops)?;
            }
            None => {
                task.remove_user_defined_attribute(key, ops)?;
            }
        }
    }

    // `recur` is not a datetime; empty strings count as "absent".
    match dto.recur.as_deref().filter(|s| !s.is_empty()) {
        Some(raw) => {
            task.set_user_defined_attribute("recur".to_string(), raw.to_string(), ops)?;
        }
        None => {
            task.remove_user_defined_attribute("recur", ops)?;
        }
    }
    Ok(())
}

fn apply_tags(
    task: &mut taskchampion::Task,
    tags: &[String],
    clear_existing: bool,
    ops: &mut Operations,
) -> Result<(), anyhow::Error> {
    if clear_existing {
        // Only remove USER tags; synthetic tags (PENDING, UNBLOCKED, …) are
        // derived from task state and cannot be modified — attempting to
        // remove them errors with "Synthetic tags cannot be modified".
        let existing: Vec<Tag> = task.get_tags().filter(|t| t.is_user()).collect();
        for tag in existing {
            task.remove_tag(&tag, ops)?;
        }
    }
    for tag in tags {
        let parsed = Tag::from_str(tag)?;
        task.add_tag(&parsed, ops)?;
    }
    Ok(())
}

fn apply_dependencies(
    task: &mut taskchampion::Task,
    depends: &[String],
    clear_existing: bool,
    ops: &mut Operations,
) -> Result<(), anyhow::Error> {
    if clear_existing {
        let existing: Vec<Uuid> = task.get_dependencies().collect();
        for dep in existing {
            task.remove_dependency(dep, ops)?;
        }
    }
    for dep_str in depends {
        if let Ok(dep_uuid) = Uuid::parse_str(dep_str) {
            task.add_dependency(dep_uuid, ops)?;
        }
    }
    Ok(())
}

/// Apply the tri-state annotations field of a [`TaskDto`].
///
/// * `None` — leave the task's existing annotations untouched (the plain
///   "update something else" case must not wipe them).
/// * `Some(list)` — replace the task's annotations with exactly `list`;
///   an empty list clears all annotations.
fn apply_annotations(
    task: &mut taskchampion::Task,
    annotations: Option<&[AnnotationDto]>,
    ops: &mut Operations,
) -> Result<(), anyhow::Error> {
    match annotations {
        None => Ok(()),
        Some(list) => {
            let existing: Vec<i64> = task
                .get_annotations()
                .map(|a| a.entry.timestamp())
                .collect();
            for ts in existing {
                task.remove_annotation(utc_timestamp(ts), ops)?;
            }
            for ann in list {
                if let Some(dt) = parse_datetime(&ann.entry)? {
                    let annotation = taskchampion::Annotation {
                        entry: utc_timestamp(dt.timestamp()),
                        description: ann.description.clone(),
                    };
                    task.add_annotation(annotation, ops)?;
                }
            }
            Ok(())
        }
    }
}

/// Names handled by dedicated DTO fields or other built-in setters.
///
/// The generic UDA loops must skip these so a promoted field is written
/// exactly once (from its dedicated field) and never double-written as a
/// plain UDA.
/// Names handled by dedicated DTO fields or other built-in setters.
///
/// The generic UDA loop must skip these so each field is written exactly once
/// (from its dedicated handling) and never double-written as a plain UDA.
/// `scheduled` / `until` / `recur` are consulted by
/// [`apply_promoted_fields`] *before* this loop runs, which is why they are
/// safe to skip here.
const HANDLED_BUILTIN_KEYS: &[&str] = &[
    "uuid",
    "description",
    "status",
    "priority",
    "due",
    "wait",
    "entry",
    "modified",
    "end",
    "tags",
    "depends",
    "scheduled",
    "until",
    "recur",
];

fn apply_udas(
    task: &mut taskchampion::Task,
    udas: &HashMap<String, String>,
    ops: &mut Operations,
) -> Result<(), anyhow::Error> {
    for (key, value) in udas {
        if HANDLED_BUILTIN_KEYS.contains(&key.as_str()) || key.starts_with("annotation_") {
            continue;
        }
        task.set_user_defined_attribute(key.clone(), value.clone(), ops)?;
    }
    Ok(())
}

/// Create a task in the replica from a typed DTO. Returns the new UUID.
pub async fn create_task_from_dto<S: taskchampion::storage::Storage>(
    replica: &mut Replica<S>,
    dto: TaskDto,
) -> Result<Uuid, anyhow::Error> {
    let mut ops = Operations::new();
    let uuid = Uuid::new_v4();
    let mut task = replica.create_task(uuid, &mut ops).await?;
    apply_dto_on_create(&mut task, &dto, &mut ops)?;
    replica.commit_operations(ops).await?;
    Ok(uuid)
}

/// Replace an existing task's mutable fields from a typed DTO.
pub async fn update_task_with_dto<S: taskchampion::storage::Storage>(
    replica: &mut Replica<S>,
    uuid: Uuid,
    dto: TaskDto,
) -> Result<(), anyhow::Error> {
    let mut ops = Operations::new();
    let mut task = replica
        .get_task(uuid)
        .await?
        .ok_or_else(|| anyhow::anyhow!("Task not found"))?;
    replace_dto_on_update(&mut task, &dto, &mut ops)?;
    replica.commit_operations(ops).await?;
    Ok(())
}

// ============================================================================
// TESTS
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use crate::create_storage_async;
    use chrono::Datelike;
    use taskchampion::Operations;
    use taskchampion::Replica;
    use tempfile::TempDir;

    async fn create_test_task<S: taskchampion::storage::Storage>(
        replica: &mut Replica<S>,
        description: &str,
        status: Status,
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

    async fn build_replica(dir: &TempDir) -> taskchampion::Replica<taskchampion::SqliteStorage> {
        let storage = create_storage_async(dir.path().to_str().unwrap().to_string())
            .await
            .unwrap();
        taskchampion::Replica::new(storage)
    }

    #[test]
    fn test_parse_datetime_valid() {
        let dt = parse_datetime("2024-01-15T12:00:00Z").unwrap();
        assert!(dt.is_some());
        assert_eq!(dt.unwrap().year(), 2024);
    }

    #[test]
    fn test_parse_datetime_empty() {
        // Empty input is the "no value" sentinel, not an error.
        assert_eq!(parse_datetime("").unwrap(), None);
    }

    #[test]
    fn test_parse_datetime_invalid_returns_structured_error() {
        // Ticket R8: malformed dates now surface as TcError::BadDatetime
        // instead of being silently dropped.
        let err = parse_datetime("not-a-date").unwrap_err();
        assert!(matches!(err, TcError::BadDatetime { .. }));
    }

    #[test]
    fn test_parse_datetime_lenient_drops_invalid() {
        assert!(parse_datetime_lenient("").is_none());
        assert!(parse_datetime_lenient("not-a-date").is_none());
        assert!(parse_datetime_lenient("2024-01-15T12:00:00Z").is_some());
    }

    #[test]
    fn test_create_task_basic() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;
            let mut task_data: HashMap<String, String> = HashMap::new();
            task_data.insert("description".to_string(), "Test task".to_string());
            task_data.insert("status".to_string(), "pending".to_string());
            let uuid = create_task_from_map(&mut replica, task_data).await.unwrap();
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(task.get_description(), "Test task");
        });
    }

    #[test]
    fn test_update_task() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;
            let mut create_ops = Operations::new();
            let uuid = Uuid::new_v4();
            let mut task = replica.create_task(uuid, &mut create_ops).await.unwrap();
            task.set_description("Original".to_string(), &mut create_ops)
                .unwrap();
            replica.commit_operations(create_ops).await.unwrap();

            let mut update_data: HashMap<String, String> = HashMap::new();
            update_data.insert("description".to_string(), "Updated".to_string());
            update_task_in_replica(&mut replica, uuid, update_data)
                .await
                .unwrap();

            let updated_task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(updated_task.get_description(), "Updated");
        });
    }

    #[test]
    fn test_task_to_map() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;
            let uuid = create_test_task(&mut replica, "Test task", Status::Pending, "H").await;
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let map = task_to_map(&task);
            assert_eq!(map.get("description"), Some(&"Test task".to_string()));
            assert_eq!(map.get("status"), Some(&"pending".to_string()));
            assert_eq!(map.get("priority"), Some(&"H".to_string()));
        });
    }

    // ========================================================================
    // Ticket R5: typed DTO round-trip + bug-fix regressions.
    // ========================================================================

    use crate::models::{AnnotationDto, TaskDto, TaskStatusDto};

    fn sample_dto() -> TaskDto {
        TaskDto {
            uuid: String::new(),
            description: "DTO task".to_string(),
            status: TaskStatusDto::Pending,
            priority: Some("H".to_string()),
            due: Some("2024-01-15T10:00:00Z".to_string()),
            wait: None,
            entry: None,
            modified: None,
            end: None,
            scheduled: None,
            until: None,
            recur: None,
            // Note: TaskChampion itself rejects tags containing whitespace
            // (`Tag::from_str("with space")` errors), so the historical
            // `tags.join(" ")` / `split_whitespace()` round-trip happened to
            // work for *valid* tags. The DTO's `Vec<String>` is still a
            // structural improvement: it removes the join/split fragility and
            // keeps the cardinality of the tag set unambiguous.
            tags: vec!["home".to_string(), "important_tag".to_string()],
            depends: vec![],
            annotations: Some(vec![AnnotationDto {
                entry: "2024-01-01T00:00:00Z".to_string(),
                description: "note".to_string(),
            }]),
            // Ticket R5 / I-13 regression: a UDA whose name shares a prefix
            // with a built-in property must survive.
            udas: {
                let mut m = HashMap::new();
                m.insert("entry_note".to_string(), "kept!".to_string());
                m.insert("project".to_string(), "ProjectA".to_string());
                m
            },
        }
    }

    #[test]
    fn test_dto_round_trip_preserves_tags_and_udas() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;

            let dto = sample_dto();
            let uuid = create_task_from_dto(&mut replica, dto).await.unwrap();
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let out = task_to_dto(&task);
            // Both tags survive as distinct elements (the legacy map path
            // joined them into one string and would have needed a split to
            // recover them).
            assert_eq!(out.tags.len(), 2);
            assert!(out.tags.contains(&"home".to_string()));
            assert!(out.tags.contains(&"important_tag".to_string()));
            // UDA whose name shares a prefix with a built-in survives
            // (previously dropped by the starts_with check).
            assert_eq!(out.udas.get("entry_note"), Some(&"kept!".to_string()));
            assert_eq!(out.udas.get("project"), Some(&"ProjectA".to_string()));
            // Priority and due survive.
            assert_eq!(out.priority.as_deref(), Some("H"));
            assert!(out.due.as_deref().unwrap().starts_with("2024-01-15"));
            // Annotation round-trips (reads always surface `Some(list)`).
            let annotations = out.annotations.as_deref().unwrap_or_default();
            assert_eq!(annotations.len(), 1);
            assert_eq!(annotations[0].description, "note");
        });
    }

    #[test]
    fn test_dto_update_replaces_tags_and_priority() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;

            // Create with the sample DTO.
            let dto = sample_dto();
            let uuid = create_task_from_dto(&mut replica, dto).await.unwrap();

            // Update with a new tag set and no priority.
            let mut update = sample_dto();
            update.tags = vec!["work".to_string()];
            update.priority = None;
            update_task_with_dto(&mut replica, uuid, update)
                .await
                .unwrap();

            let task = replica.get_task(uuid).await.unwrap().unwrap();
            let out = task_to_dto(&task);
            // Old tags were cleared; only "work" remains.
            assert_eq!(out.tags, vec!["work".to_string()]);
            // Priority cleared.
            assert_eq!(out.priority, None);
        });
    }

    // ========================================================================
    // Annotations are tri-state at the FFI boundary: an absent list (None)
    // preserves what is stored; Some(list) replaces; Some(empty) clears.
    // ========================================================================

    #[test]
    fn test_dto_update_without_annotations_preserves_existing() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;

            // Create a task with one annotation.
            let dto = sample_dto();
            let uuid = create_task_from_dto(&mut replica, dto).await.unwrap();

            // Update other fields but leave annotations ABSENT (None).
            let mut update = sample_dto();
            update.annotations = None;
            update.description = "Annotated description".to_string();
            update.due = Some("2031-01-01T00:00:00Z".to_string());
            update.tags = vec!["new_tag".to_string()];
            update.priority = Some("L".to_string());
            update_task_with_dto(&mut replica, uuid, update)
                .await
                .unwrap();

            let task = replica.get_task(uuid).await.unwrap().unwrap();
            let out = task_to_dto(&task);
            // The original annotation SURVIVED the update ...
            let annotations = out.annotations.as_deref().unwrap_or_default();
            assert_eq!(annotations.len(), 1);
            assert_eq!(annotations[0].description, "note");
            // ... while every other field was replaced as usual.
            assert_eq!(out.description, "Annotated description");
            assert_rfc3339_eq(&out.due, "2031-01-01T00:00:00");
            assert_eq!(out.tags, vec!["new_tag".to_string()]);
            assert_eq!(out.priority.as_deref(), Some("L"));
        });
    }

    #[test]
    fn test_dto_update_with_empty_annotation_list_clears_existing() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;

            let dto = sample_dto();
            let uuid = create_task_from_dto(&mut replica, dto).await.unwrap();

            // Explicitly clear all annotations.
            let mut update = sample_dto();
            update.annotations = Some(vec![]);
            update.description = "Cleared description".to_string();
            update_task_with_dto(&mut replica, uuid, update)
                .await
                .unwrap();

            let task = replica.get_task(uuid).await.unwrap().unwrap();
            let out = task_to_dto(&task);
            assert!(matches!(
                out.annotations.as_deref(),
                Some(annotations) if annotations.is_empty()
            ));
            assert_eq!(out.description, "Cleared description");
        });
    }

    #[test]
    fn test_dto_update_with_new_annotation_list_replaces_existing() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;

            let dto = sample_dto();
            let uuid = create_task_from_dto(&mut replica, dto).await.unwrap();

            // Replace the stored annotation set with a different one.
            let mut update = sample_dto();
            update.annotations = Some(vec![AnnotationDto {
                entry: "2025-06-01T12:00:00Z".to_string(),
                description: "replacement note".to_string(),
            }]);
            update_task_with_dto(&mut replica, uuid, update)
                .await
                .unwrap();

            let task = replica.get_task(uuid).await.unwrap().unwrap();
            let out = task_to_dto(&task);
            let annotations = out.annotations.as_deref().unwrap_or_default();
            assert_eq!(annotations.len(), 1);
            assert_eq!(annotations[0].description, "replacement note");
            // Timestamps are stored at whole-second precision; compare the
            // instant rather than the exact RFC-3339 spelling.
            let entry_dt = DateTime::parse_from_rfc3339(&annotations[0].entry)
                .unwrap()
                .with_timezone(&Utc);
            assert_eq!(
                entry_dt,
                DateTime::parse_from_rfc3339("2025-06-01T12:00:00Z")
                    .unwrap()
                    .with_timezone(&Utc)
            );
        });
    }

    // ========================================================================
    // Extended create/update coverage: entry / modified / end / scheduled /
    // until / recur, and uuid immutability on update.
    // ========================================================================

    /// Compare an RFC-3339 string to the second (stored values are whole
    /// seconds or verbatim strings).
    fn assert_rfc3339_eq(actual: &Option<String>, expected: &str) {
        let actual = actual.as_deref().unwrap_or("");
        assert!(
            actual.starts_with(expected),
            "expected value starting with {expected:?}, got {actual:?}"
        );
    }

    #[test]
    fn test_dto_create_sets_recur_scheduled_until_entry_and_reads_them_back() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;

            let mut dto = sample_dto();
            dto.recur = Some("weekly".to_string());
            dto.scheduled = Some("2024-02-01T08:00:00Z".to_string());
            dto.until = Some("2024-12-31T23:59:59Z".to_string());
            dto.entry = Some("2024-01-02T03:04:05Z".to_string());
            let uuid = create_task_from_dto(&mut replica, dto).await.unwrap();
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let out = task_to_dto(&task);
            assert_eq!(out.recur.as_deref(), Some("weekly"));
            assert_rfc3339_eq(&out.scheduled, "2024-02-01T08:00:00");
            assert_rfc3339_eq(&out.until, "2024-12-31T23:59:59");
            assert_rfc3339_eq(&out.entry, "2024-01-02T03:04:05");
            // Promoted fields must not leak into the raw UDA map.
            assert!(!out.udas.contains_key("recur"));
            assert!(!out.udas.contains_key("scheduled"));
            assert!(!out.udas.contains_key("until"));
        });
    }

    #[test]
    fn test_dto_create_with_explicit_end_reads_back() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;

            let mut dto = sample_dto();
            dto.end = Some("2024-06-15T12:00:00Z".to_string());
            let uuid = create_task_from_dto(&mut replica, dto).await.unwrap();
            let task = replica.get_task(uuid).await.unwrap().unwrap();

            let out = task_to_dto(&task);
            // The explicit status write happens BEFORE apply_end in
            // apply_dto_on_create, so the pending-status bookkeeping does not
            // clobber it.
            assert_rfc3339_eq(&out.end, "2024-06-15T12:00:00");
        });
    }

    #[test]
    fn test_dto_update_changes_fields_but_never_uuid() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;

            let dto = sample_dto();
            let uuid = create_task_from_dto(&mut replica, dto).await.unwrap();

            // Attempt a full replacement whose uuid differs from the real one.
            let mut update = sample_dto();
            update.uuid = "deadbeef-dead-beef-dead-beefdeadbeef".to_string();
            update.description = "Replaced description".to_string();
            update.due = Some("2030-05-05T05:05:05Z".to_string());
            update.tags = vec!["brand_new_tag".to_string()];
            update.priority = Some("L".to_string());
            update_task_with_dto(&mut replica, uuid, update)
                .await
                .unwrap();

            // The task is still addressable under its ORIGINAL uuid ...
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(task.get_uuid(), uuid);
            // ... and the smuggled uuid was never created as a second task.
            let smuggled = Uuid::parse_str("deadbeef-dead-beef-dead-beefdeadbeef").unwrap();
            assert!(replica.get_task(smuggled).await.unwrap().is_none());

            let out = task_to_dto(&task);
            assert_eq!(out.uuid, uuid.to_string());
            assert_eq!(out.description, "Replaced description");
            assert_rfc3339_eq(&out.due, "2030-05-05T05:05:05");
            assert_eq!(out.tags, vec!["brand_new_tag".to_string()]);
            assert_eq!(out.priority.as_deref(), Some("L"));
        });
    }

    #[test]
    fn test_dto_update_removes_promoted_fields_when_absent() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;

            let mut dto = sample_dto();
            dto.recur = Some("daily".to_string());
            dto.scheduled = Some("2024-02-01T08:00:00Z".to_string());
            dto.until = Some("2024-12-31T23:59:59Z".to_string());
            let uuid = create_task_from_dto(&mut replica, dto).await.unwrap();

            // Update without the promoted fields -> they must be cleared.
            let update = sample_dto();
            update_task_with_dto(&mut replica, uuid, update)
                .await
                .unwrap();

            let task = replica.get_task(uuid).await.unwrap().unwrap();
            let out = task_to_dto(&task);
            assert_eq!(out.recur, None);
            assert_eq!(out.scheduled, None);
            assert_eq!(out.until, None);
        });
    }

    #[test]
    fn test_dto_create_malformed_datetime_is_an_error() {
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;

            let mut dto = sample_dto();
            dto.scheduled = Some("not-a-date".to_string());
            assert!(create_task_from_dto(&mut replica, dto).await.is_err());
        });
    }

    #[test]
    fn test_dto_uda_name_collision_with_promoted_field_is_unambiguous() {
        // A UDA whose name collides with a promoted field has exactly one
        // owner: the promoted field. On write the dedicated field wins and
        // the same-named entry in `udas` is ignored (documented on
        // [`TaskDto::udas`]); on read the value surfaces ONLY in the
        // dedicated field, never duplicated into `udas`.
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;

            // Dedicated field set + conflicting udas entry: dedicated wins.
            let mut dto = sample_dto();
            dto.recur = Some("weekly".to_string());
            dto.udas.insert("recur".to_string(), "monthly".to_string());
            let uuid = create_task_from_dto(&mut replica, dto).await.unwrap();
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            let out = task_to_dto(&task);
            assert_eq!(out.recur.as_deref(), Some("weekly"));
            assert!(!out.udas.contains_key("recur"));

            // Same collision via update: the stored value is overwritten,
            // never double-written.
            let mut update = sample_dto();
            update.recur = Some("yearly".to_string());
            update
                .udas
                .insert("recur".to_string(), "monthly".to_string());
            update_task_with_dto(&mut replica, uuid, update)
                .await
                .unwrap();
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            let out = task_to_dto(&task);
            assert_eq!(out.recur.as_deref(), Some("yearly"));
            assert!(!out.udas.contains_key("recur"));
        });
    }

    #[test]
    fn test_legacy_apply_no_longer_drops_prefix_collision_udas() {
        // Regression for I-13: the legacy HashMap path must also keep a UDA
        // named e.g. "entry_note" rather than dropping it as a built-in.
        let td = TempDir::new().unwrap();
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();
        runtime.block_on(async move {
            let mut replica = build_replica(&td).await;
            let mut data: HashMap<String, String> = HashMap::new();
            data.insert("description".to_string(), "T".to_string());
            data.insert("entry_note".to_string(), "survived".to_string());
            let uuid = create_task_from_map(&mut replica, data).await.unwrap();
            let task = replica.get_task(uuid).await.unwrap().unwrap();
            assert_eq!(
                task.get_user_defined_attribute("entry_note").unwrap(),
                "survived"
            );
        });
    }
}
