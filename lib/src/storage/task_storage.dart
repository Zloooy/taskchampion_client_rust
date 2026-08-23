import 'dart:async';

import '../models/models.dart';
import '../rust_bridge/models.dart';
import '../rust_bridge/properties.dart';

/// Abstract interface for all task storage operations.
///
/// This interface abstracts the underlying storage mechanism
/// (e.g., Rust FFI, in-memory, mock) from the service layer.
abstract interface class TaskStorage {
  // ============================================================================
  // TASK OPERATIONS
  // ============================================================================

  /// Get all tasks as a JSON string.
  Future<String> getAllTasksJson();

  /// Get all tasks with sorting as a JSON string.
  Future<String> getAllTasksWithSortJson(TaskSort sort);

  /// Get tasks filtered by a [filter] expression with optional [sort].
  Future<String> getTasksWithFilterAndSortJson(
    TaskFilter filter,
    TaskSort? sort,
  );

  /// Get a single task by its UUID, or `null` if not found.
  Future<String?> getTaskByUuid(String uuid);

  /// Add a new task and return the created task's UUID.
  @Deprecated('Use addTaskDto with a fully-typed TaskDto instead')
  Future<String> addTask(Map<String, String> taskData);

  /// Update an existing task.
  @Deprecated('Use updateTaskDto with a fully-typed TaskDto instead')
  Future<void> updateTask(String uuid, Map<String, String> taskData);

  /// Add a new task from a typed [dto] and return the created task's UUID.
  ///
  /// The `uuid` field of [dto] is ignored; the backend allocates it.
  Future<String> addTaskDto(TaskDto dto);

  /// Replace an existing task's mutable fields from a typed [dto].
  ///
  /// The task is addressed by [uuid]; the `uuid` field of [dto] is ignored.
  Future<void> updateTaskDto(String uuid, TaskDto dto);

  /// Delete a task by its UUID.
  Future<void> deleteTask(String uuid);

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Synchronize with the sync server.
  Future<SyncResultData> syncWithServer(
    String serverUrl,
    String clientId,
    String encryptionSecret,
  );

  /// Get the latest snapshot from the sync server.
  Future<String> getSnapshot(
    String serverUrl,
    String clientId,
    String encryptionSecret,
  );

  // ============================================================================
  // AUTH OPERATIONS
  // ============================================================================

  /// Validate credentials against the sync server.
  Future<String> validateCredentials(
    String serverUrl,
    String clientId,
    String encryptionSecret,
  );

  // ============================================================================
  // STATISTICS / UTILITY
  // ============================================================================

  /// Get task database statistics as a JSON string.
  Future<String> getTaskdbStats();

  /// Export tasks to [exportFilePath]. Returns the number of tasks exported.
  Future<int> exportTasks(String exportFilePath);

  /// Import tasks from [importFilePath]. Returns the number of tasks imported.
  Future<int> importTasks(String importFilePath);

  // ============================================================================
  // PROPERTY OPERATIONS
  // ============================================================================

  /// Retrieve distinct values for a given task property.
  Future<List<String>> getTaskPropertyValues(
    String property,
    TaskFilter? filter,
    TaskSort? sort,
  );

  /// Retrieve distinct values for a given task property with typed conversion.
  Future<List<String>> getTaskPropertyValuesTyped(
    String property,
    PropertyReturnType returnType,
    TaskFilter? filter,
    TaskSort? sort,
  );

  /// Retrieve all possible enum values for a given property type.
  Future<List<String>> getAllEnumValues(PropertyReturnType returnType);

  // ============================================================================
  // TAG OPERATIONS
  // ============================================================================

  /// Retrieve distinct tag values from tasks.
  Future<List<String>> getTags(
    TaskFilter? filter,
    bool includeVirtualTags,
    String? pattern,
  );
}
