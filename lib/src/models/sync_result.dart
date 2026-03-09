import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_result.freezed.dart';
part 'sync_result.g.dart';

/// Result of a synchronization operation
///
/// Contains information about the sync operation including
/// success status, statistics, and any errors that occurred.
@freezed
abstract class SyncResult with _$SyncResult {
  const factory SyncResult({
    /// Whether the sync was successful
    required bool success,

    /// Number of versions synced
    @Default(0) int versionsSynced,

    /// Number of tasks added
    @Default(0) int tasksAdded,

    /// Number of tasks updated
    @Default(0) int tasksUpdated,

    /// Number of tasks deleted
    @Default(0) int tasksDeleted,

    /// Error message if sync failed
    String? errorMessage,

    /// Duration of the sync operation in milliseconds
    int? durationMs,

    /// Timestamp when sync completed
    DateTime? completedAt,

    /// Whether a snapshot was downloaded
    @Default(false) bool snapshotDownloaded,

    /// Whether a snapshot was uploaded
    @Default(false) bool snapshotUploaded,
  }) = _SyncResult;

  /// Create a SyncResult from a JSON map
  factory SyncResult.fromJson(Map<String, dynamic> json) =>
      _$SyncResultFromJson(json);

  /// Create a successful sync result
  factory SyncResult.success({
    int versionsSynced = 0,
    int tasksAdded = 0,
    int tasksUpdated = 0,
    int tasksDeleted = 0,
    int? durationMs,
    bool snapshotDownloaded = false,
    bool snapshotUploaded = false,
  }) {
    return SyncResult(
      success: true,
      versionsSynced: versionsSynced,
      tasksAdded: tasksAdded,
      tasksUpdated: tasksUpdated,
      tasksDeleted: tasksDeleted,
      durationMs: durationMs,
      completedAt: DateTime.now(),
      snapshotDownloaded: snapshotDownloaded,
      snapshotUploaded: snapshotUploaded,
    );
  }

  /// Create a failed sync result
  factory SyncResult.failure(String errorMessage, {int? durationMs}) {
    return SyncResult(
      success: false,
      errorMessage: errorMessage,
      durationMs: durationMs,
      completedAt: DateTime.now(),
    );
  }
}

/// Extension methods for SyncResult
extension SyncResultExtensions on SyncResult {
  /// Check if the sync failed
  bool get hasError => errorMessage != null;

  /// Get total number of changes
  int get totalChanges => tasksAdded + tasksUpdated + tasksDeleted;

  /// Get a human-readable summary
  String get summary {
    if (!success) {
      return 'Sync failed: $errorMessage';
    }

    if (totalChanges == 0) {
      return 'Sync completed: No changes';
    }

    final parts = <String>[];
    if (tasksAdded > 0) parts.add('+$tasksAdded added');
    if (tasksUpdated > 0) parts.add('$tasksUpdated updated');
    if (tasksDeleted > 0) parts.add('-$tasksDeleted deleted');

    return 'Sync completed: ${parts.join(', ')}';
  }
}
