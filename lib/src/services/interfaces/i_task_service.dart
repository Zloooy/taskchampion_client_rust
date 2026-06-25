import '../../models/models.dart';

/// Abstract interface for task management operations.
abstract interface class ITaskService {
  /// Get all tasks from the database.
  Future<List<Task>> getAllTasks({TaskSort? sort});

  /// Get tasks matching a custom filter expression.
  Future<List<Task>> filterTasks(TaskFilter filter, {TaskSort? sort});

  /// Get a single task by UUID.
  Future<Task?> getTaskByUuid(String uuid);

  /// Create a new task.
  Future<Task> createTask({
    required String description,
    TaskPriority priority = TaskPriority.none,
    String? project,
    List<String>? tags,
    DateTime? due,
    DateTime? wait,
  });

  /// Update an existing task.
  Future<Task> updateTask({
    required String uuid,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? project,
    List<String>? tags,
    DateTime? due,
  });

  /// Delete a task by UUID.
  Future<void> deleteTask(String uuid);

  /// Get task statistics.
  Future<TaskStats> getStats();

  /// Export tasks to a file.
  Future<int> exportTasks(String filePath);

  /// Import tasks from a file.
  Future<int> importTasks(String filePath);
}
