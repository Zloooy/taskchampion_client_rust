import '../../models/models.dart';

/// Abstract interface for task tag retrieval operations.
abstract interface class ITaskTagService {
  /// Retrieve distinct tag values from tasks.
  Future<List<String>> getTags({
    TaskFilter? filter,
    bool includeVirtualTags = false,
    String? pattern,
  });
}
