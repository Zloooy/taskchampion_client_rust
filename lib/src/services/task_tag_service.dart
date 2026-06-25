import '../core/core.dart';
import '../models/models.dart';
import '../storage/task_storage.dart';
import 'interfaces/i_task_tag_service.dart';

/// Service for retrieving distinct tag values from tasks.
///
/// Provides access to tags (both regular and virtual) filtered by pattern
/// and sorted alphabetically.
class TaskTagService implements ITaskTagService {
  /// Underlying storage implementation.
  final TaskStorage _storage;

  /// Logger for this service.
  final Logger _logger;

  /// Create a new TaskTagService instance.
  TaskTagService(this._storage, {Logger? logger})
    : _logger = logger ?? const DebugPrintLogger();

  @override
  Future<List<String>> getTags({
    TaskFilter? filter,
    bool includeVirtualTags = false,
    String? pattern,
  }) async {
    try {
      return _storage.getTags(filter, includeVirtualTags, pattern);
    } catch (e, st) {
      _logger.error('Failed to get tags', error: e, stackTrace: st);
      return [];
    }
  }
}
