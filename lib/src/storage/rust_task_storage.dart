import 'dart:async';
import 'dart:convert';

import '../models/models.dart';
import '../rust_bridge/api.dart' as frb_api;
import '../rust_bridge/models.dart';
import '../rust_bridge/properties.dart';
import 'task_storage.dart';

/// Concrete implementation of [TaskStorage] backed by the Rust FFI bridge.
///
/// This class wraps the generated flutter_rust_bridge API and is the sole
/// class responsible for FFI calls.  All other layers access storage
/// exclusively through the [TaskStorage] interface.
class RustTaskStorage implements TaskStorage {
  /// Path to the task database directory.
  final String taskdbDirPath;

  /// Create a new [RustTaskStorage] for the given [taskdbDirPath].
  RustTaskStorage(this.taskdbDirPath);

  // ============================================================================
  // TASK OPERATIONS
  // ============================================================================

  @override
  Future<String> getAllTasksJson() {
    return frb_api.getAllTasksJson(taskdbDirPath: taskdbDirPath);
  }

  @override
  Future<String> getAllTasksWithSortJson(TaskSort sort) {
    return frb_api.getAllTasksWithSortJson(
      taskdbDirPath: taskdbDirPath,
      sortJson: json.encode(sort.toJson()),
    );
  }

  @override
  Future<String> getTasksWithFilterAndSortJson(
    TaskFilter filter,
    TaskSort? sort,
  ) {
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

  @override
  Future<String?> getTaskByUuid(String uuid) {
    return frb_api.getTaskByUuid(taskdbDirPath: taskdbDirPath, uuidStr: uuid);
  }

  @override
  Future<String> addTask(Map<String, String> taskData) {
    return frb_api.addTask(taskdbDirPath: taskdbDirPath, taskData: taskData);
  }

  @override
  Future<void> updateTask(String uuid, Map<String, String> taskData) {
    return frb_api.updateTask(
      taskdbDirPath: taskdbDirPath,
      uuidStr: uuid,
      taskData: taskData,
    );
  }

  @override
  Future<String> addTaskDto(TaskDto dto) {
    return frb_api.addTaskDto(taskdbDirPath: taskdbDirPath, dto: dto);
  }

  @override
  Future<void> updateTaskDto(String uuid, TaskDto dto) {
    return frb_api.updateTaskDto(
      taskdbDirPath: taskdbDirPath,
      uuidStr: uuid,
      dto: dto,
    );
  }

  @override
  Future<void> deleteTask(String uuid) {
    return frb_api.deleteTask(taskdbDirPath: taskdbDirPath, uuidStr: uuid);
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  @override
  Future<SyncResultData> syncWithServer(
    String serverUrl,
    String clientId,
    String encryptionSecret,
  ) {
    return frb_api.syncWithServer(
      taskdbDirPath: taskdbDirPath,
      serverUrl: serverUrl,
      clientId: clientId,
      encryptionSecret: encryptionSecret,
    );
  }

  @override
  Future<String> getSnapshot(
    String serverUrl,
    String clientId,
    String encryptionSecret,
  ) {
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

  @override
  Future<String> validateCredentials(
    String serverUrl,
    String clientId,
    String encryptionSecret,
  ) {
    return frb_api.validateCredentials(
      serverUrl: serverUrl,
      clientId: clientId,
      encryptionSecret: encryptionSecret,
    );
  }

  // ============================================================================
  // STATISTICS / UTILITY
  // ============================================================================

  @override
  Future<String> getTaskdbStats() {
    return frb_api.getTaskdbStats(taskdbDirPath: taskdbDirPath);
  }

  @override
  Future<int> exportTasks(String exportFilePath) {
    return frb_api.exportTasks(
      taskdbDirPath: taskdbDirPath,
      exportFilePath: exportFilePath,
    );
  }

  @override
  Future<int> importTasks(String importFilePath) {
    return frb_api.importTasks(
      taskdbDirPath: taskdbDirPath,
      importFilePath: importFilePath,
    );
  }

  // ============================================================================
  // PROPERTY OPERATIONS
  // ============================================================================

  @override
  Future<List<String>> getTaskPropertyValues(
    String property,
    TaskFilter? filter,
    TaskSort? sort,
  ) {
    return frb_api.getTaskPropertyValues(
      taskdbDirPath: taskdbDirPath,
      property: property,
      filterJson: filter?.toJson(),
      sortJson: sort != null ? json.encode(sort.toJson()) : null,
    );
  }

  @override
  Future<List<String>> getTaskPropertyValuesTyped(
    String property,
    PropertyReturnType returnType,
    TaskFilter? filter,
    TaskSort? sort,
  ) {
    return frb_api.getTaskPropertyValuesTyped(
      taskdbDirPath: taskdbDirPath,
      property: property,
      returnType: returnType,
      filterJson: filter?.toJson(),
      sortJson: sort != null ? json.encode(sort.toJson()) : null,
    );
  }

  @override
  Future<List<String>> getAllEnumValues(PropertyReturnType returnType) {
    return frb_api.getAllEnumValues(returnType: returnType);
  }

  // ============================================================================
  // TAG OPERATIONS
  // ============================================================================

  @override
  Future<List<String>> getTags(
    TaskFilter? filter,
    bool includeVirtualTags,
    String? pattern,
  ) {
    return frb_api.getTags(
      taskdbDirPath: taskdbDirPath,
      filterJson: filter?.toJson(),
      includeVirtualTags: includeVirtualTags,
      pattern: pattern,
    );
  }
}
