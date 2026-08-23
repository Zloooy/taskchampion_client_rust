import '../../models/models.dart';

/// Abstract interface for task management operations.
abstract interface class ITaskService {
  /// Get all tasks from the database.
  Future<List<Task>> getAllTasks({TaskSort? sort});

  /// Get tasks matching a custom filter expression.
  Future<List<Task>> filterTasks(TaskFilter filter, {TaskSort? sort});

  /// Get a single task by UUID.
  Future<Task?> getTaskByUuid(String uuid);

  /// Create a new task from [params].
  ///
  /// Returns the created task (re-fetched from storage so the backend-
  /// generated UUID and timestamps are included).
  Future<Task> createTask(TaskParams params);

  /// Update an existing task with the full desired state of [task].
  ///
  /// The task is addressed by [Task.uuid], which acts as a **read-only
  /// identity**: it selects which task to update and cannot be changed —
  /// every other field on [task] represents the *new complete state* and is
  /// written wholesale. Multi-valued fields ([Task.tags], [Task.depends])
  /// are REPLACED entirely (not merged), matching the Rust replace semantics;
  /// omitting a value clears it.
  ///
  /// Typical usage: load a task, apply changes via [Task.copyWith], pass the
  /// result here.
  ///
  /// Returns the updated task (re-fetched from storage).
  Future<Task> updateTask(Task task);

  /// Delete a task by UUID.
  Future<void> deleteTask(String uuid);

  /// Get task statistics.
  Future<TaskStats> getStats();

  /// Export tasks to a file.
  Future<int> exportTasks(String filePath);

  /// Import tasks from a file.
  Future<int> importTasks(String filePath);
}
