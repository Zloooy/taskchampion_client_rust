import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../rust_bridge/rust_bridge.dart';
import '../taskchampion_client.dart' show TaskStats;

/// Service for managing tasks in TaskChampion
///
/// Provides low-level task operations that interact with the Rust FFI layer.
class TaskService {
  /// Path to the task database
  final String taskdbPath;

  /// Create a new TaskService instance
  TaskService(this.taskdbPath);

  /// Get all tasks from the database
  Future<List<Task>> getAllTasks({TaskSort? sort}) async {
    try {
      final jsonStr = sort != null
          ? await RustBridge.getAllTasksWithSortJson(taskdbPath, sort)
          : await RustBridge.getAllTasksJson(taskdbPath);
      final List<dynamic> jsonList = json.decode(jsonStr);

      return jsonList
          .map((json) => Task.fromRawJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Error getting tasks: $e');
      return [];
    }
  }

  /// Get all tasks from the database
  Future<List<Task>> filterTasks(TaskFilter filter, {TaskSort? sort}) async {
    try {
      final jsonStr = await RustBridge.getTasksWithFilterAndSortJson(taskdbPath, filter, sort);
      final List<dynamic> jsonList = json.decode(jsonStr);

      return jsonList
          .map((json) => Task.fromRawJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Error getting tasks: $e');
      return [];
    }
  }

  /// Get a task by UUID
  Future<Task?> getTaskByUuid(String uuid) async {
    try {
      final jsonStr = await RustBridge.getTaskByUuid(taskdbPath, uuid);

      if (jsonStr == null) {
        return null;
      }

      final jsonData = json.decode(jsonStr);
      return Task.fromRawJson(Map<String, dynamic>.from(jsonData));
    } catch (e) {
      debugPrint('Error getting task: $e');
      return null;
    }
  }

  /// Create a new task
  Future<Task> createTask({
    required String description,
    TaskPriority priority = TaskPriority.none,
    String? project,
    List<String>? tags,
    DateTime? due,
    DateTime? wait,
  }) async {
    try {
      final taskData = <String, String>{
        'description': description,
        'status': 'pending',
        if (priority != TaskPriority.none) 'priority': priority.name,
        ...((project != null) ? {'project': project} : {}),
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(' '),
      };

      if (due != null) taskData['due'] = due.toIso8601String();
      if (wait != null) taskData['wait'] = wait.toIso8601String();

      final uuid = await RustBridge.addTask(taskdbPath, taskData);

      // Fetch the created task
      final task = await getTaskByUuid(uuid);
      if (task == null) {
        throw Exception('Failed to retrieve created task');
      }

      return task;
    } catch (e) {
      debugPrint('Error creating task: $e');
      rethrow;
    }
  }

  /// Update an existing task
  Future<Task> updateTask({
    required String uuid,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? project,
    List<String>? tags,
    DateTime? due,
  }) async {
    try {
      final taskData = <String, String>{};

      if (description != null) taskData['description'] = description;
      if (status != null) taskData['status'] = status.name;
      if (priority != null) taskData['priority'] = priority.name;
      if (project != null) taskData['project'] = project;
      if (tags != null) taskData['tags'] = tags.join(' ');
      if (due != null) taskData['due'] = due.toIso8601String();

      await RustBridge.updateTask(taskdbPath, uuid, taskData);

      // Fetch the updated task
      final task = await getTaskByUuid(uuid);
      if (task == null) {
        throw Exception('Failed to retrieve updated task');
      }

      return task;
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  /// Delete a task
  Future<void> deleteTask(String uuid, {bool permanent = false}) async {
    try {
      if (permanent) {
        // For permanent deletion, we'd need additional Rust FFI support
        // For now, just mark as deleted
        await RustBridge.deleteTask(taskdbPath, uuid);
      } else {
        await RustBridge.deleteTask(taskdbPath, uuid);
      }
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  /// Get task statistics
  Future<TaskStats> getStats() async {
    try {
      final jsonStr = await RustBridge.getTaskdbStats(taskdbPath);
      final Map<String, dynamic> jsonData = json.decode(jsonStr);
      
      
      return TaskStats(
        total: jsonData['total_tasks'],
        pending: jsonData['pending'],
        completed: jsonData['completed'],
        deleted: jsonData['deleted'],
      );
    } catch (e) {
      debugPrint('Error getting stats: $e');
      return const TaskStats(total: 0, pending: 0, completed: 0, deleted: 0);
    }
  }

  /// Export tasks to a file
  Future<int> exportTasks(String filePath) async {
    try {
      return RustBridge.exportTasks(taskdbPath, filePath);
    } catch (e) {
      debugPrint('Error exporting tasks: $e');
      rethrow;
    }
  }

  /// Import tasks from a file
  Future<int> importTasks(String filePath) async {
    try {
      return RustBridge.importTasks(taskdbPath, filePath);
    } catch (e) {
      debugPrint('Error importing tasks: $e');
      rethrow;
    }
  }
}
