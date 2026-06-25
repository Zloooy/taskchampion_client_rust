import '../../models/models.dart';

/// Abstract interface for synchronization operations.
abstract interface class ISyncService {
  /// Synchronize with the sync server.
  Future<SyncResult> sync();

  /// Get the latest snapshot from the server.
  Future<Map<String, dynamic>?> getSnapshot();
}
