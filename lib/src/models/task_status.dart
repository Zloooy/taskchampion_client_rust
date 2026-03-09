/// Task status enumeration
///
/// Represents the current state of a task in TaskChampion.
enum TaskStatus {
  /// Task is active and needs to be done
  pending,

  /// Task has been completed
  completed,

  /// Task has been deleted
  deleted;

  /// Convert from string representation
  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskStatus.pending,
    );
  }

  /// Convert to string representation
  @override
  String toString() => name;
}

/// Extension methods for TaskStatus
extension TaskStatusExtensions on TaskStatus {
  /// Check if the task is in an active state
  bool get isActive => this == TaskStatus.pending;

  /// Check if the task is in a resolved state
  bool get isResolved =>
      this == TaskStatus.completed || this == TaskStatus.deleted;
}
