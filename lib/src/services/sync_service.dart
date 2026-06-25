import 'dart:convert';
import '../core/core.dart';
import '../models/models.dart';
import '../storage/task_storage.dart';
import 'interfaces/i_sync_service.dart';

/// Service for synchronizing tasks with TaskChampion sync server.
///
/// Handles all synchronization operations including upload, download,
/// and conflict resolution.
class SyncService implements ISyncService {
  /// Underlying storage implementation.
  final TaskStorage _storage;

  /// Sync configuration.
  final SyncConfig _syncConfig;

  /// Logger for this service.
  final Logger _logger;

  /// Create a new SyncService instance.
  SyncService(this._storage, this._syncConfig, {Logger? logger})
    : _logger = logger ?? const DebugPrintLogger();

  @override
  Future<SyncResult> sync() async {
    try {
      final resultData = await _storage.syncWithServer(
        _syncConfig.serverUrl,
        _syncConfig.clientId,
        _syncConfig.encryptionSecret,
      );

      return SyncResult(
        success: resultData.success,
        versionsSynced: resultData.versionsSynced.toInt(),
        tasksAdded: resultData.tasksAdded.toInt(),
        tasksUpdated: resultData.tasksUpdated.toInt(),
        tasksDeleted: resultData.tasksDeleted.toInt(),
        errorMessage: resultData.errorMessage,
        durationMs: resultData.durationMs?.toInt(),
      );
    } catch (e, st) {
      _logger.error('Sync failed', error: e, stackTrace: st);
      return SyncResult(
        success: false,
        errorMessage: 'Sync failed: $e',
        completedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getSnapshot() async {
    try {
      final jsonStr = await _storage.getSnapshot(
        _syncConfig.serverUrl,
        _syncConfig.clientId,
        _syncConfig.encryptionSecret,
      );

      if (jsonStr == 'null') {
        return null;
      }

      return Map<String, dynamic>.from(json.decode(jsonStr));
    } catch (e, st) {
      _logger.error('Failed to get snapshot', error: e, stackTrace: st);
      return null;
    }
  }
}
