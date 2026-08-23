import 'package:freezed_annotation/freezed_annotation.dart';
import 'annotation.dart';
import 'task_parser.dart';
import 'task_status.dart';
import 'task_priority.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// Represents a TaskChampion task
///
/// This is the primary data model for tasks in the TaskChampion system.
/// Tasks can be created, modified, and synchronized across devices.
@freezed
abstract class Task with _$Task {
  const factory Task({
    /// Unique identifier for the task (UUID v4)
    required String uuid,

    /// Task description
    required String description,

    /// Current task status
    /// All unknown values fallback to pending
    @JsonKey(unknownEnumValue: TaskStatus.pending)
    @Default(TaskStatus.pending)
    TaskStatus status,

    /// Task priority (high, medium, low, or none)
    /// All unknown values fallback to none
    @JsonKey(unknownEnumValue: TaskPriority.none)
    @Default(TaskPriority.none)
    TaskPriority priority,

    /// Project name (optional) - stored as UDA in TaskChampion
    String? project,

    /// List of tags associated with the task
    @Default([]) List<String> tags,

    /// Due date (optional)
    DateTime? due,

    /// Wait until date (task is hidden until this date)
    DateTime? wait,

    /// Scheduled date (optional) - stored as UDA in TaskChampion
    DateTime? scheduled,

    /// Until date (task is deleted after this date) - stored as UDA in TaskChampion
    DateTime? until,

    /// Task creation timestamp
    required DateTime entry,

    /// Last modification timestamp
    DateTime? modified,

    /// End/completion timestamp
    DateTime? end,

    /// User Defined Attributes (UDAs)
    /// This includes all custom attributes that are not part of the standard TaskChampion data model
    /// Standard fields like 'project', 'scheduled', 'until', 'parent', 'urgency' are also stored as UDAs
    @Default({}) Map<String, String> udas,

    /// Urgency score (stored as UDA in TaskChampion, calculated by clients)
    double? urgency,

    /// Parent task UUID (for subtasks) - stored as UDA in TaskChampion
    String? parent,

    /// List of dependent task UUIDs
    @Default([]) List<String> depends,

    /// Annotations attached to the task, oldest-first.
    @Default([]) List<Annotation> annotations,
  }) = _Task;

  /// Create a Task from a JSON map
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  /// Create a Task from raw JSON returned by Rust FFI
  ///
  /// This handles the flat structure where UDAs are returned as top-level keys
  /// alongside standard task properties.
  factory Task.fromRawJson(Map<String, dynamic> json) =>
      TaskParser().parse(json);
}

/// Extension methods for Task
extension TaskExtensions on Task {
  /// Check if the task is pending
  bool get isPending => status == TaskStatus.pending;

  /// Check if the task is completed
  bool get isCompleted => status == TaskStatus.completed;

  /// Check if the task is deleted
  bool get isDeleted => status == TaskStatus.deleted;

  /// Check if the task is waiting
  bool get isWaiting => wait != null && wait!.isAfter(DateTime.now());

  /// Check if the task is due soon (within 24 hours)
  bool get isDueSoon =>
      due != null &&
      due!.isBefore(DateTime.now().add(const Duration(hours: 24)));

  /// Check if the task is overdue
  bool get isOverdue =>
      due != null && due!.isBefore(DateTime.now()) && isPending;

  /// Check if the task has a high priority
  bool get isHighPriority => priority == TaskPriority.high;

  /// Check if the task has tags
  bool get hasTags => tags.isNotEmpty;

  /// Check if the task has a project
  bool get hasProject => project != null && project!.isNotEmpty;

  /// Check if the task has dependencies
  bool get hasDependencies => depends.isNotEmpty;

  /// Get the tag list as a comma-separated string
  String get tagsAsString => tags.join(',');

  /// Check if the task has a specific tag
  bool hasTag(String tag) => tags.contains(tag);

  /// Check if the task belongs to a specific project
  bool isInProject(String projectName) => project == projectName;
}
