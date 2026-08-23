import 'dart:collection';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../rust_bridge/models.dart' as frb;
import 'annotation.dart';
import 'task.dart';
import 'task_priority.dart';
import 'task_status.dart';

part 'task_params.freezed.dart';

/// Parameters describing a task to create or update in TaskChampion.
///
/// This is the single input object for every user-settable attribute on the
/// create path ([`TaskParams.toTaskDto`] maps it onto the generated FFI
/// [frb.TaskDto]). It deliberately does **not** carry a `uuid`: identities are
/// allocated by the backend on create and addressed through the task's own
/// `uuid` on update.
///
/// Multi-valued fields (`tags`, `depends`) and all scalar fields represent the
/// **full desired state**: on update they are replaced wholesale (matching the
/// Rust replace semantics), not merged with the stored values.
///
/// Conventions used when mapping to the wire format:
/// * Dates are serialized as RFC-3339 UTC strings (`DateTime.toUtc().toIso8601String()`).
/// * Priority uses the canonical Taskwarrior codes `"H"` / `"M"` / `"L"`;
///   [TaskPriority.none] maps to `null`.
/// * `scheduled` / `until` / `recur` are routed to their dedicated
///   [frb.TaskDto] fields and must **not** also appear in [udas] — the
///   dedicated fields own those UDA names and an absent dedicated field clears
///   the stored value.
@freezed
sealed class TaskParams with _$TaskParams {
  const factory TaskParams({
    /// Task description (required).
    @Assert('description.trim().isNotEmpty') required String description,

    /// Initial task status (default: pending).
    @Default(TaskStatus.pending) TaskStatus status,

    /// Task priority (default: none).
    @Default(TaskPriority.none) TaskPriority priority,

    /// Project name; stored as the conventional `project` UDA.
    String? project,

    /// User tags. Replaced wholesale on update.
    @Default([]) List<String> tags,

    /// UUIDs of tasks this task depends on. Replaced wholesale on update.
    @Default([]) List<String> depends,

    /// Due date.
    DateTime? due,

    /// Wait-until date (task is hidden until this date).
    DateTime? wait,

    /// Scheduled-start date; stored as the conventional `scheduled` UDA.
    DateTime? scheduled,

    /// Until/expiry date; stored as the conventional `until` UDA.
    DateTime? until,

    /// Creation timestamp. Backend-managed when omitted; pass an explicit
    /// value only when re-importing a task with a known entry date.
    DateTime? entry,

    /// Completion/deletion timestamp. Normally derived from status changes;
    /// an explicit value pins it.
    DateTime? end,

    /// Recurrence rule/duration string (e.g. `"weekly"`); stored as the
    /// conventional `recur` UDA.
    String? recur,

    /// Annotations for the task, oldest-first.
    ///
    /// Always sent as a concrete list on the wire: a populated list replaces
    /// the stored annotations wholesale; an empty list explicitly clears all
    /// stored annotations. [fromTask] copies the loaded task's annotations in,
    /// so a plain load → edit → save round-trips them unchanged.
    @Default([]) List<Annotation> annotations,

    /// Arbitrary user-defined attributes.
    ///
    /// Keys `scheduled`, `until` and `recur` are ignored on write (the
    /// dedicated fields own them); use those fields instead.
    @Default({}) Map<String, String> udas,
  }) = _TaskParams;

  // Private constructor so the generated `_TaskParams` extends this class and
  // inherits the concrete methods below.
  const TaskParams._();

  /// Build parameters from an existing [Task].
  ///
  /// The idiomatic "update" workflow is: load a task, tweak what changed via
  /// [Task.copyWith], then save with these params. The task's `uuid` is NOT
  /// carried here — it is used separately as the addressing key on update.
  ///
  /// Note: `parent` and `urgency` live inside [Task.udas] on read and are
  /// preserved verbatim in the resulting [udas] map. The task's annotations
  /// are copied into [annotations] so a save round-trips them unchanged.
  factory TaskParams.fromTask(Task task) => TaskParams(
        description: task.description,
        status: task.status,
        priority: task.priority,
        project: task.project,
        tags: [...task.tags],
        depends: [...task.depends],
        annotations: [...task.annotations],
        due: task.due,
        wait: task.wait,
        scheduled: task.scheduled,
        until: task.until,
        entry: task.entry,
        end: task.end,
        // `recur` has no first-class [Task] field; it round-trips through udas.
        recur: task.udas['recur'],
        udas: _preservedUdas(task),
      );

  /// Map these parameters to the generated FFI [frb.TaskDto].
  ///
  /// [uuid] is included verbatim (empty on create — the backend allocates the
  /// real uuid there; harmless on update where the backend ignores it).
  ///
  /// Annotations are always sent as a concrete list (the wire field itself is
  /// nullable, but `null` would mean "leave stored annotations untouched",
  /// which is never what this method wants): [annotations] replaces the
  /// task's annotations wholesale, and an empty list clears them.
  frb.TaskDto toTaskDto({String uuid = ''}) {
    final wireUdas = <String, String>{...udas};
    // The promoted fields own their UDA names; drop any same-named keys so we
    // never double-write (the backend would ignore them anyway).
    wireUdas.remove('scheduled');
    wireUdas.remove('until');
    wireUdas.remove('recur');

    // `project` has no dedicated DTO field; it round-trips through the
    // conventional `project` UDA (mirroring the read path, which lifts that
    // UDA back into Task.project).
    if (project != null && project!.isNotEmpty) {
      wireUdas['project'] = project!;
    } else {
      wireUdas.remove('project');
    }

    return frb.TaskDto(
      uuid: uuid,
      description: description,
      status: _statusToDto(status),
      priority: _priorityToCode(priority),
      due: _rfc3339(due),
      wait: _rfc3339(wait),
      entry: _rfc3339(entry),
      modified: null,
      end: _rfc3339(end),
      scheduled: _rfc3339(scheduled),
      until: _rfc3339(until),
      recur: (recur == null || recur!.isEmpty) ? null : recur,
      tags: List<String>.unmodifiable(tags),
      depends: List<String>.unmodifiable(depends),
      // Always a concrete list: a populated list replaces the stored
      // annotations wholesale; an empty one explicitly clears them all.
      annotations: annotations
          .map(
            (a) => frb.AnnotationDto(
              entry: a.entry.toUtc().toIso8601String(),
              description: a.description,
            ),
          )
          .toList(),
      udas: wireUdas,
    );
  }
}

// ============================================================================
// Private helpers
// ============================================================================

/// RFC-3339 UTC serialization accepted by the Rust-side datetime parser.
String? _rfc3339(DateTime? value) => value?.toUtc().toIso8601String();

/// Canonical Taskwarrior priority code, or `null` for no priority.
String? _priorityToCode(TaskPriority priority) => switch (priority) {
      TaskPriority.high => 'H',
      TaskPriority.medium => 'M',
      TaskPriority.low => 'L',
      TaskPriority.none => null,
    };

frb.TaskStatusDto _statusToDto(TaskStatus status) => switch (status) {
      TaskStatus.pending => frb.TaskStatusDto.pending,
      TaskStatus.completed => frb.TaskStatusDto.completed,
      TaskStatus.deleted => frb.TaskStatusDto.deleted,
    };

/// UDAs to preserve when round-tripping a [Task] back into parameters.
///
/// Standard fields that the backend manages through dedicated setters
/// (`project`, `parent`, `scheduled`, `until`, `urgency`) are excluded: they
/// either have dedicated [TaskParams] fields, are handled implicitly by
/// status transitions, or are client-computed values that should not be
/// re-pinned. `recur` is lifted into its dedicated field by the caller.
Map<String, String> _preservedUdas(Task task) {
  const managedKeys = {
    'project',
    'parent',
    'scheduled',
    'until',
    'urgency',
    'recur',
  };
  final preserved = <String, String>{
    for (final entry in task.udas.entries)
      if (!managedKeys.contains(entry.key)) entry.key: entry.value,
  };
  return UnmodifiableMapView(preserved);
}
