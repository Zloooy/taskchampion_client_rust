import 'package:flutter/foundation.dart';
import 'package:taskchampion_client_rust/src/rust_bridge/rust_bridge.dart';
import 'package:taskchampion_client_rust/src/rust_bridge/properties.dart';
import '../models/models.dart';

/// Service for retrieving distinct values of task properties
///
/// Provides access to the property values (descriptions, projects, etc.)
/// that exist across tasks in the database.
class TaskPropertyService {
  /// Path to the task database
  final String taskdbPath;

  /// Create a new TaskPropertyService instance
  TaskPropertyService(this.taskdbPath);

  /// Retrieve distinct values for a given task property.
  ///
  /// * `property` – name of the property to query (e.g. "description", "project", "due").
  /// * `filter` – optional [TaskFilter] to limit the tasks considered.
  /// * `sort` – optional [TaskSort] that may affect the order of the returned list.
  ///
  /// Returns a sorted list of distinct string values.
  /// Returns an empty list and logs an error on failure.
  Future<List<String>> getPropertyValues({
    required String property,
    TaskFilter? filter,
    TaskSort? sort,
  }) async {
    try {
      return RustBridge.getTaskPropertyValues(
        taskdbPath,
        property,
        filter,
        sort,
      );
    } catch (e) {
      debugPrint('Error getting property values: $e');
      return [];
    }
  }

  /// Retrieve distinct property values stored in the database with typed conversion.
  ///
  /// This is the typed version of [getPropertyValues]. It queries the database
  /// for distinct values of the given property and converts them to the requested
  /// type [T].
  ///
  /// Supported types:
  /// * [String] – returns raw string values (description, project, etc.)
  /// * [DateTime] – returns parsed [DateTime] objects (due, wait, etc.)
  /// * [TaskStatus] – returns [TaskStatus] enum values
  /// * [TaskPriority] – returns [TaskPriority] enum values
  ///
  /// Throws [ArgumentError] if [T] is not a supported type.
  Future<List<T>> getStoredPropertyValues<T>({
    required String property,
    TaskFilter? filter,
    TaskSort? sort,
  }) async {
    final returnType = _mapTypeToPropertyReturnType<T>();

    try {
      final values = await RustBridge.getTaskPropertyValuesTyped(
        taskdbPath,
        property,
        returnType,
        filter,
        sort,
      );
      return values.cast<T>();
    } catch (e) {
      debugPrint('Error getting property values for $property: $e');
      return [];
    }
  }

  /// Retrieve all possible enum values for a given type, independent of stored data.
  ///
  /// This method returns every possible value for the requested type, regardless
  /// of what's actually stored in the database. It only supports enum types:
  /// * [TaskStatus] – returns all [TaskStatus] values
  /// * [TaskPriority] – returns all [TaskPriority] values
  ///
  /// Throws [ArgumentError] if [T] is not [TaskStatus] or [TaskPriority].
  Future<List<T>> getAllPropertyValues<T>() async {
    final returnType = _mapTypeToEnumPropertyReturnType<T>();

    final values = await RustBridge.getAllEnumValues(returnType);
    return values.cast<T>();
  }

  /// Map a Dart generic type to a [PropertyReturnType] enum value.
  ///
  /// Throws [ArgumentError] if the type is not supported.
  PropertyReturnType _mapTypeToPropertyReturnType<T>() {
    if (T == String) return PropertyReturnType.string;
    if (T == DateTime) return PropertyReturnType.dateTime;
    if (T == TaskStatus) return PropertyReturnType.enumStatus;
    if (T == TaskPriority) return PropertyReturnType.enumPriority;

    throw ArgumentError(
      'Unsupported generic type $T. Supported types: String, DateTime, TaskStatus, TaskPriority',
    );
  }

  /// Map a Dart generic type to a [PropertyReturnType] for enum-only queries.
  ///
  /// Only [TaskStatus] and [TaskPriority] are supported. Throws [ArgumentError]
  /// for any other type.
  PropertyReturnType _mapTypeToEnumPropertyReturnType<T>() {
    if (T == TaskStatus) return PropertyReturnType.enumStatus;
    if (T == TaskPriority) return PropertyReturnType.enumPriority;

    throw ArgumentError(
      'Unsupported generic type $T for getAllPropertyValues. Supported types: TaskStatus, TaskPriority',
    );
  }
}
