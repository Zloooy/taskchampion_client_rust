import 'package:flutter/foundation.dart';
import 'package:taskchampion_client_rust/src/rust_bridge/rust_bridge.dart';
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
}
