import 'package:flutter/foundation.dart';
import 'package:taskchampion_client_rust/src/rust_bridge/rust_bridge.dart';
import '../models/models.dart';

/// Service for retrieving distinct tag values from tasks
///
/// Provides access to tags (both regular and virtual) filtered by pattern
/// and sorted alphabetically.
class TaskTagService {
  /// Path to the task database
  final String taskdbPath;

  /// Create a new TaskTagService instance
  TaskTagService(this.taskdbPath);

  /// Retrieve distinct tag values from tasks.
  ///
  /// * `filter` – optional [TaskFilter] to limit the tasks considered.
  /// * `includeVirtualTags` – when true, include virtual tags in the results.
  /// * `pattern` – optional case‑insensitive substring that a tag must contain.
  ///
  /// Returns a sorted list of distinct tag strings.
  /// Returns an empty list and logs an error on failure.
  Future<List<String>> getTags({
    TaskFilter? filter,
    bool includeVirtualTags = false,
    String? pattern,
  }) async {
    try {
      return RustBridge.getTags(
        taskdbPath,
        filter,
        includeVirtualTags,
        pattern,
      );
    } catch (e) {
      debugPrint('Error getting tags: $e');
      return [];
    }
  }
}
