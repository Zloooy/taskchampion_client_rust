import 'dart:async';
import 'dart:convert';

import 'api.dart' as frb_api;
import 'models.dart';
import '../models/task_filter.dart';
import '../models/task_sort.dart';
import 'package:taskchampion_client_rust/src/rust_bridge/properties.dart';

/// Rust Bridge - Wrapper for FFI calls to Rust
///
/// This class provides static methods that call into the Rust FFI layer
/// using the generated flutter_rust_bridge code.
class RustBridge {
  // ============================================================================
  // TASK OPERATIONS
  // ============================================================================

  /// Get all tasks as JSON string
  static Future<String> getAllTasksJson(String taskdbDirPath) async {
    return frb_api.getAllTasksJson(taskdbDirPath: taskdbDirPath);
  }

  /// Add a new task
  static Future<String> addTask(
    String taskdbDirPath,
    Map<String, String> taskData,
  ) async {
    return frb_api.addTask(taskdbDirPath: taskdbDirPath, taskData: taskData);
  }

  /// Update an existing task
  static Future<void> updateTask(
    String taskdbDirPath,
    String uuidStr,
    Map<String, String> taskData,
  ) async {
    await frb_api.updateTask(
      taskdbDirPath: taskdbDirPath,
      uuidStr: uuidStr,
      taskData: taskData,
    );
  }

  /// Delete a task
  static Future<void> deleteTask(String taskdbDirPath, String uuidStr) async {
    await frb_api.deleteTask(taskdbDirPath: taskdbDirPath, uuidStr: uuidStr);
  }

  /// Get a task by UUID
  static Future<String?> getTaskByUuid(
    String taskdbDirPath,
    String uuidStr,
  ) async {
    return frb_api.getTaskByUuid(
      taskdbDirPath: taskdbDirPath,
      uuidStr: uuidStr,
    );
  }

  /// Get all tasks with sorting
  static Future<String> getAllTasksWithSortJson(
    String taskdbDirPath,
    TaskSort sort,
  ) async {
    return frb_api.getAllTasksWithSortJson(
      taskdbDirPath: taskdbDirPath,
      sortJson: json.encode(sort.toJson()),
    );
  }

  /// Get tasks filtered by a filter expression with sorting
  static Future<String> getTasksWithFilterAndSortJson(
    String taskdbDirPath,
    TaskFilter filter,
    TaskSort? sort,
  ) async {
    return frb_api.getTasksWithFilterAndSortJson(
      taskdbDirPath: taskdbDirPath,
      filterJson: filter.toJson(),
      sortJson: sort != null
          ? json.encode(sort.toJson())
          : json.encode(const {
              'property': {'name': 'entry'},
              'direction': 'ascending',
            }),
    );
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Sync with server
  static Future<SyncResultData> syncWithServer(
    String taskdbDirPath,
    String serverUrl,
    String clientId,
    String encryptionSecret,
  ) async {
    return frb_api.syncWithServer(
      taskdbDirPath: taskdbDirPath,
      serverUrl: serverUrl,
      clientId: clientId,
      encryptionSecret: encryptionSecret,
    );
  }

  /// Get snapshot from server
  static Future<String> getSnapshot(
    String taskdbDirPath,
    String serverUrl,
    String clientId,
    String encryptionSecret,
  ) async {
    return frb_api.getSnapshot(
      taskdbDirPath: taskdbDirPath,
      serverUrl: serverUrl,
      clientId: clientId,
      encryptionSecret: encryptionSecret,
    );
  }

  // ============================================================================
  // AUTH OPERATIONS
  // ============================================================================

  /// Validate credentials
  static Future<String> validateCredentials(
    String serverUrl,
    String clientId,
    String encryptionSecret,
  ) async {
    return frb_api.validateCredentials(
      serverUrl: serverUrl,
      clientId: clientId,
      encryptionSecret: encryptionSecret,
    );
  }

  // ============================================================================
  // UTILITY OPERATIONS
  // ============================================================================

  /// Get task database statistics
  static Future<String> getTaskdbStats(String taskdbDirPath) async {
    return frb_api.getTaskdbStats(taskdbDirPath: taskdbDirPath);
  }

  /// Export tasks to file
  static Future<int> exportTasks(
    String taskdbDirPath,
    String exportFilePath,
  ) async {
    return frb_api.exportTasks(
      taskdbDirPath: taskdbDirPath,
      exportFilePath: exportFilePath,
    );
  }

  /// Import tasks from file
  static Future<int> importTasks(
    String taskdbDirPath,
    String importFilePath,
  ) async {
    return frb_api.importTasks(
      taskdbDirPath: taskdbDirPath,
      importFilePath: importFilePath,
    );
  }

  // ============================================================================
  // PROPERTY OPERATIONS
  // ============================================================================

  /// Retrieve distinct values for a given task property
  static Future<List<String>> getTaskPropertyValues(
    String taskdbDirPath,
    String property,
    TaskFilter? filter,
    TaskSort? sort,
  ) async {
    return frb_api.getTaskPropertyValues(
      taskdbDirPath: taskdbDirPath,
      property: property,
      filterJson: filter?.toJson(),
      sortJson: sort != null ? json.encode(sort.toJson()) : null,
    );
  }

  /// Retrieve distinct tag values from tasks
  static Future<List<String>> getTags(
    String taskdbDirPath,
    TaskFilter? filter,
    bool includeVirtualTags,
    String? pattern,
  ) async {
    return frb_api.getTags(
      taskdbDirPath: taskdbDirPath,
      filterJson: filter?.toJson(),
      includeVirtualTags: includeVirtualTags,
      pattern: pattern,
    );
  }

  // ============================================================================
  // TYPED PROPERTY OPERATIONS
  // ============================================================================

  /// Retrieve distinct property values with typed conversion
  static Future<List<String>> getTaskPropertyValuesTyped(
    String taskdbDirPath,
    String property,
    PropertyReturnType returnType,
    TaskFilter? filter,
    TaskSort? sort,
  ) async {
    return frb_api.getTaskPropertyValuesTyped(
      taskdbDirPath: taskdbDirPath,
      property: property,
      returnType: returnType,
      filterJson: filter?.toJson(),
      sortJson: sort != null ? json.encode(sort.toJson()) : null,
    );
  }

  /// Retrieve all possible enum values for a given property type
  static Future<List<String>> getAllEnumValues(
    PropertyReturnType returnType,
  ) async {
    return frb_api.getAllEnumValues(returnType: returnType);
  }
}
