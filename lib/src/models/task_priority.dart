/// Task priority enumeration
///
/// Represents the priority level of a task in TaskChampion.
enum TaskPriority {
  /// High priority (most urgent)
  high,

  /// Medium priority
  medium,

  /// Low priority
  low,

  /// No priority set (default)
  none;

}

/// Extension methods for TaskPriority
extension TaskPriorityExtensions on TaskPriority {

  /// Check if priority is set (not none)
  bool get isSet => this != TaskPriority.none;
}
