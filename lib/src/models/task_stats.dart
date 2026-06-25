/// Task statistics data class
class TaskStats {
  /// Total number of tasks
  final int total;

  /// Number of pending tasks
  final int pending;

  /// Number of completed tasks
  final int completed;

  /// Number of deleted tasks
  final int deleted;

  const TaskStats({
    required this.total,
    required this.pending,
    required this.completed,
    required this.deleted,
  });

  /// Create TaskStats from a map
  factory TaskStats.fromMap(Map<String, int> map) {
    return TaskStats(
      total: map['total_tasks'] ?? 0,
      pending: map['pending'] ?? 0,
      completed: map['completed'] ?? 0,
      deleted: map['deleted'] ?? 0,
    );
  }
}
