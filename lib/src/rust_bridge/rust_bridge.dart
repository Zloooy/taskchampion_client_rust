import 'dart:async';
import 'dart:convert';

import 'api.dart' as frb_api;
import 'frb_generated.dart';
import '../models/task_filter.dart';
import '../models/task_sort.dart';

/// Rust Bridge - Wrapper for FFI calls to Rust
///
/// This class provides static methods that call into the Rust FFI layer
/// using the generated flutter_rust_bridge code.
class RustBridge {
  /// Initialize the Rust library
  ///
  /// This must be called before any other Rust FFI calls.
  static Future<void> init() async {
    await RustLib.init();
  }

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

  /// Get pending tasks as JSON string
  ///
  /// This is optimized to use TaskChampion's built-in pending tasks query
  static Future<String> getPendingTasksJson(String taskdbDirPath) async {
    return frb_api.getPendingTasksJson(taskdbDirPath: taskdbDirPath);
  }

  /// Get tasks filtered by a filter expression
  ///
  /// This method automatically optimizes queries:
  /// - For status=Pending filters, uses TaskChampion's built-in pending_tasks()
  /// - For other filters, loads all tasks and filters in-memory
  static Future<String> getTasksWithFilterJson(
    String taskdbDirPath,
    TaskFilter filter,
  ) async {
    return frb_api.getTasksWithFilterJson(
      taskdbDirPath: taskdbDirPath,
      filterJson: filter.toJson(),
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
    if (sort != null) {
      return frb_api.getTasksWithFilterAndSortJson(
        taskdbDirPath: taskdbDirPath,
        filterJson: filter.toJson(),
        sortJson: json.encode(sort.toJson()),
      );
    }
    return frb_api.getTasksWithFilterJson(
      taskdbDirPath: taskdbDirPath,
      filterJson: filter.toJson(),
    );
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Sync with server
  static Future<frb_api.SyncResultData> syncWithServer(
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

  /// Generate a new client ID
  static Future<String> generateClientId() async {
    return frb_api.generateClientId();
  }

  /// Generate a new encryption secret
  static Future<String> generateEncryptionSecret() async {
    return frb_api.generateEncryptionSecret();
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
}
