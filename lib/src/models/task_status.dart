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

  /// Convert to string representation
  @override
  String toString() => name;
}
