import 'package:freezed_annotation/freezed_annotation.dart';
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
    @Default(TaskStatus.pending) TaskStatus status,

    /// Task priority (high, medium, low, or none)
    /// All unknown values fallback to none
    @JsonKey(unknownEnumValue: TaskPriority.none)
    @Default(TaskPriority.none) TaskPriority priority,

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
  }) = _Task;

  /// Create a Task from a JSON map
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  /// Create a Task from raw JSON returned by Rust FFI
  /// 
  /// This handles the flat structure where UDAs are returned as top-level keys
  /// alongside standard task properties.
  factory Task.fromRawJson(Map<String, dynamic> json) {
    // Known task properties that should be extracted
    const knownKeys = [
      'uuid', 'description', 'status', 'priority', 'project',
      'tags', 'due', 'wait', 'scheduled', 'until', 'entry',
      'modified', 'end', 'urgency', 'parent', 'depends', 'annotations'
    ];
    
    // Extract known properties
    final knownProps = <String, dynamic>{};
    // Extract UDAs (everything else)
    final udas = <String, String>{};
    
    // Properties that should be in udas map but also exposed as task properties
    const udaPropertyKeys = ['project', 'scheduled', 'until', 'parent', 'urgency'];
    
    for (final entry in json.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (key.startsWith('annotation_')) {
        // Skip annotations - they're handled separately (stored in Rust only)
        continue;
      } else if (udaPropertyKeys.contains(key) && value != null) {
        // These are stored as UDAs in TaskChampion but exposed as properties
        // Keep them for special handling below
        knownProps[key] = value;
      } else if (knownKeys.contains(key)) {
        knownProps[key] = value;
      } else {
        // Everything else is a UDA
        if (value is String) {
          udas[key] = value;
        }
      }
    }
    
    // Convert scheduled and until to DateTime if present
    // Note: Task.fromJson expects these as ISO8601 strings for parsing
    if (knownProps['scheduled'] is DateTime) {
      knownProps['scheduled'] = (knownProps['scheduled'] as DateTime).toIso8601String();
    } else if (knownProps['scheduled'] is String) {
      try {
        // Validate it's a valid datetime string
        DateTime.parse(knownProps['scheduled'] as String);
      } catch (_) {
        knownProps.remove('scheduled');
      }
    }
    
    if (knownProps['until'] is DateTime) {
      knownProps['until'] = (knownProps['until'] as DateTime).toIso8601String();
    } else if (knownProps['until'] is String) {
      try {
        DateTime.parse(knownProps['until'] as String);
      } catch (_) {
        knownProps.remove('until');
      }
    }
    
    // Convert urgency to double if present
    if (knownProps['urgency'] is String) {
      try {
        knownProps['urgency'] = double.parse(knownProps['urgency'] as String);
      } catch (_) {
        knownProps.remove('urgency');
      }
    }
    
    // Convert tags and depends to List<String> if they're strings
    if (knownProps['tags'] is String) {
      final tagsStr = knownProps['tags'] as String;
      knownProps['tags'] = tagsStr.split(' ').where((t) => t.isNotEmpty).toList();
    }

    if (knownProps['depends'] is String) {
      final dependsStr = knownProps['depends'] as String;
      knownProps['depends'] = dependsStr.split(' ').where((d) => d.isNotEmpty).toList();
    }

    // Handle missing priority - default to 'none'
    if (!knownProps.containsKey('priority') || knownProps['priority'] == null) {
      knownProps['priority'] = 'none';
    }

    // Add special UDA properties to udas map so they're preserved
    // These are exposed as task properties but stored as UDAs in TaskChampion
    if (knownProps['project'] != null && knownProps['project'] is String) {
      udas['project'] = knownProps['project'] as String;
    }
    if (knownProps['scheduled'] != null) {
      udas['scheduled'] = knownProps['scheduled'] is DateTime
          ? (knownProps['scheduled'] as DateTime).toIso8601String()
          : knownProps['scheduled'] as String;
    }
    if (knownProps['until'] != null) {
      udas['until'] = knownProps['until'] is DateTime
          ? (knownProps['until'] as DateTime).toIso8601String()
          : knownProps['until'] as String;
    }
    if (knownProps['parent'] != null && knownProps['parent'] is String) {
      udas['parent'] = knownProps['parent'] as String;
    }
    if (knownProps['urgency'] != null) {
      udas['urgency'] = knownProps['urgency'].toString();
    }

    // Create task with UDAs merged into the udas field
    final task = Task.fromJson(knownProps);

    // If there are additional UDAs, merge them
    if (udas.isNotEmpty) {
      return task.copyWith(
        udas: {...task.udas, ...udas},
      );
    }

    return task;
  }
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
