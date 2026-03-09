import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../rust_bridge/rust_bridge.dart';

/// Service for synchronizing tasks with TaskChampion sync server
///
/// Handles all synchronization operations including upload, download,
/// and conflict resolution.
class SyncService {
  /// Path to the task database
  final String taskdbPath;

  /// Sync configuration
  final SyncConfig syncConfig;

  /// Create a new SyncService instance
  SyncService(this.taskdbPath, this.syncConfig);

  /// Synchronize with the sync server
  Future<SyncResult> sync() async {
    try {
      final resultData = await RustBridge.syncWithServer(
        taskdbPath,
        syncConfig.serverUrl,
        syncConfig.clientId,
        syncConfig.encryptionSecret,
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
    } catch (e) {
      debugPrint('Sync error: $e');
      return SyncResult(
        success: false,
        errorMessage: 'Sync failed: $e',
        completedAt: DateTime.now(),
      );
    }
  }

  /// Get the latest snapshot from the server
  Future<Map<String, dynamic>?> getSnapshot() async {
    try {
      final jsonStr = await RustBridge.getSnapshot(
        taskdbPath,
        syncConfig.serverUrl,
        syncConfig.clientId,
        syncConfig.encryptionSecret,
      );

      if (jsonStr == 'null') {
        return null;
      }

      return Map<String, dynamic>.from(json.decode(jsonStr));
    } catch (e) {
      debugPrint('Error getting snapshot: $e');
      return null;
    }
  }

  /// Check if sync is possible (server is reachable)
  Future<bool> canSync() async {
    try {
      final result = await sync();
      return result.success;
    } catch (e) {
      return false;
    }
  }
}
