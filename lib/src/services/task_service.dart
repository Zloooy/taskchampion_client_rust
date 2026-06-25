import 'dart:convert';
import '../core/core.dart';
import '../models/models.dart';
import '../storage/task_storage.dart';
import 'interfaces/i_task_service.dart';

/// Service for managing tasks in TaskChampion.
///
/// Provides low-level task operations that interact with the storage layer.
class TaskService implements ITaskService {
  /// Underlying storage implementation.
  final TaskStorage _storage;

  /// Logger for this service.
  final Logger _logger;

  /// Create a new TaskService instance.
  TaskService(this._storage, {Logger? logger})
    : _logger = logger ?? const DebugPrintLogger();

  @override
  Future<List<Task>> getAllTasks({TaskSort? sort}) async {
    try {
      final jsonStr = sort != null
          ? await _storage.getAllTasksWithSortJson(sort)
          : await _storage.getAllTasksJson();
      final List<dynamic> jsonList = json.decode(jsonStr);

      return jsonList
          .map((json) => Task.fromRawJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e, st) {
      _logger.error('Failed to get all tasks', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<List<Task>> filterTasks(TaskFilter filter, {TaskSort? sort}) async {
    try {
      final jsonStr = await _storage.getTasksWithFilterAndSortJson(
        filter,
        sort,
      );
      final List<dynamic> jsonList = json.decode(jsonStr);

      return jsonList
          .map((json) => Task.fromRawJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e, st) {
      _logger.error('Failed to filter tasks', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<Task?> getTaskByUuid(String uuid) async {
    try {
      final jsonStr = await _storage.getTaskByUuid(uuid);

      if (jsonStr == null) {
        return null;
      }

      final jsonData = json.decode(jsonStr);
      return Task.fromRawJson(Map<String, dynamic>.from(jsonData));
    } catch (e, st) {
      _logger.error('Failed to get task by UUID', error: e, stackTrace: st);
      return null;
    }
  }

  @override
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

      final uuid = await _storage.addTask(taskData);

      final task = await getTaskByUuid(uuid);
      if (task == null) {
        throw const TaskStorageException('Failed to retrieve created task');
      }

      return task;
    } on TaskChampionException {
      rethrow;
    } catch (e, st) {
      _logger.error('Failed to create task', error: e, stackTrace: st);
      throw TaskStorageException('Failed to create task', cause: e);
    }
  }

  @override
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

      await _storage.updateTask(uuid, taskData);

      final task = await getTaskByUuid(uuid);
      if (task == null) {
        throw const TaskStorageException('Failed to retrieve updated task');
      }

      return task;
    } on TaskChampionException {
      rethrow;
    } catch (e, st) {
      _logger.error('Failed to update task', error: e, stackTrace: st);
      throw TaskStorageException('Failed to update task', cause: e);
    }
  }

  @override
  Future<void> deleteTask(String uuid) async {
    try {
      await _storage.deleteTask(uuid);
    } catch (e, st) {
      _logger.error('Failed to delete task', error: e, stackTrace: st);
      throw TaskStorageException('Failed to delete task', cause: e);
    }
  }

  @override
  Future<TaskStats> getStats() async {
    try {
      final jsonStr = await _storage.getTaskdbStats();
      final Map<String, dynamic> jsonData = json.decode(jsonStr);

      return TaskStats(
        total: jsonData['total_tasks'],
        pending: jsonData['pending'],
        completed: jsonData['completed'],
        deleted: jsonData['deleted'],
      );
    } catch (e, st) {
      _logger.error('Failed to get task stats', error: e, stackTrace: st);
      return const TaskStats(total: 0, pending: 0, completed: 0, deleted: 0);
    }
  }

  @override
  Future<int> exportTasks(String filePath) async {
    try {
      return _storage.exportTasks(filePath);
    } catch (e, st) {
      _logger.error('Failed to export tasks', error: e, stackTrace: st);
      throw TaskStorageException('Failed to export tasks', cause: e);
    }
  }

  @override
  Future<int> importTasks(String filePath) async {
    try {
      return _storage.importTasks(filePath);
    } catch (e, st) {
      _logger.error('Failed to import tasks', error: e, stackTrace: st);
      throw TaskStorageException('Failed to import tasks', cause: e);
    }
  }
}
