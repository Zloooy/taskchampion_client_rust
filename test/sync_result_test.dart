import 'package:flutter_test/flutter_test.dart';
import 'package:taskchampion_client_rust/src/models/models.dart';
import 'package:taskchampion_client_rust/src/rust_bridge/models.dart'
    show SyncResultData;

/// Tests for [SyncResult] construction, FFI mapping and the user-facing
/// [SyncResultExtensions.summary] semantics.
void main() {
  group('SyncResult', () {
    test('defaults counters to zero', () {
      const result = SyncResult(success: true);

      expect(result.versionsSynced, 0);
      expect(result.tasksAdded, 0);
      expect(result.tasksUpdated, 0);
      expect(result.tasksDeleted, 0);
      expect(result.errorMessage, isNull);
    });

    test('success factory sets success and keeps counters', () {
      final result = SyncResult.success(
        versionsSynced: 3,
        tasksAdded: 1,
        tasksUpdated: 2,
        tasksDeleted: 4,
        durationMs: 150,
      );

      expect(result.success, isTrue);
      expect(result.versionsSynced, 3);
      expect(result.tasksAdded, 1);
      expect(result.tasksUpdated, 2);
      expect(result.tasksDeleted, 4);
      expect(result.durationMs, 150);
      expect(result.completedAt, isNotNull);
    });

    test('failure factory records the error message', () {
      final result = SyncResult.failure('boom', durationMs: 42);

      expect(result.success, isFalse);
      expect(result.errorMessage, 'boom');
      expect(result.durationMs, 42);
    });

    test('fromJson maps camelCase keys and defaults missing ones to 0', () {
      final result = SyncResult.fromJson({
        'success': true,
        'versionsSynced': 7,
        // tasks* intentionally absent -> default 0
      });

      expect(result.success, isTrue);
      expect(result.versionsSynced, 7);
      expect(result.tasksAdded, 0);
      expect(result.tasksUpdated, 0);
      expect(result.tasksDeleted, 0);
    });

    test('toJson round-trips through fromJson', () {
      const original = SyncResult(
        success: true,
        versionsSynced: 5,
        tasksAdded: 1,
        tasksUpdated: 2,
        tasksDeleted: 3,
        durationMs: 99,
      );

      final copy = SyncResult.fromJson(original.toJson());

      expect(copy, original);
    });
  });

  group('SyncResult <- SyncResultData (FFI mapping)', () {
    /// Mirrors the production mapping in `SyncService.sync()` so that a
    /// regression in field names or `.toInt()` on the BigInt FFI values is
    /// caught here without needing the Rust bridge.
    SyncResult mapFromFfi(SyncResultData data) => SyncResult(
          success: data.success,
          versionsSynced: data.versionsSynced.toInt(),
          tasksAdded: data.tasksAdded.toInt(),
          tasksUpdated: data.tasksUpdated.toInt(),
          tasksDeleted: data.tasksDeleted.toInt(),
          errorMessage: data.errorMessage,
          durationMs: data.durationMs?.toInt(),
        );

    test('maps every counter from the FFI payload', () {
      final ffi = SyncResultData(
        success: true,
        versionsSynced: BigInt.from(12),
        tasksAdded: BigInt.from(2),
        tasksUpdated: BigInt.from(3),
        tasksDeleted: BigInt.from(1),
      );

      final result = mapFromFfi(ffi);

      expect(result.success, isTrue);
      expect(result.versionsSynced, 12);
      expect(result.tasksAdded, 2);
      expect(result.tasksUpdated, 3);
      expect(result.tasksDeleted, 1);
      expect(result.errorMessage, isNull);
      expect(result.durationMs, isNull);
    });

    test('maps error message and duration when present', () {
      final ffi = SyncResultData(
        success: false,
        versionsSynced: BigInt.zero,
        tasksAdded: BigInt.zero,
        tasksUpdated: BigInt.zero,
        tasksDeleted: BigInt.zero,
        errorMessage: 'server unreachable',
        durationMs: BigInt.from(1234),
      );

      final result = mapFromFfi(ffi);

      expect(result.success, isFalse);
      expect(result.errorMessage, 'server unreachable');
      expect(result.durationMs, 1234);
    });
  });

  group('SyncResultExtensions.totalChanges', () {
    test('is zero when nothing happened', () {
      const result = SyncResult(success: true);

      expect(result.totalChanges, 0);
    });

    test('counts task-level changes', () {
      const result = SyncResult(
        success: true,
        tasksAdded: 1,
        tasksUpdated: 2,
        tasksDeleted: 3,
      );

      expect(result.totalChanges, 6);
    });

    test('counts synced versions as changes even with no per-task counters',
        () {
      // Regression guard: the Rust side currently only reports
      // `versions_synced`; a sync that pulled new tasks from the server must
      // not look like "no changes".
      const result = SyncResult(success: true, versionsSynced: 4);

      expect(result.totalChanges, 4);
    });
  });

  group('SyncResultExtensions.summary', () {
    test('reports failure reason when sync failed', () {
      final result = SyncResult.failure('bad credentials');

      expect(result.summary, 'Sync failed: bad credentials');
    });

    test('reports no changes when truly nothing happened', () {
      const result = SyncResult(success: true);

      expect(result.summary, 'Sync completed: No changes');
    });

    test('lists all non-zero categories', () {
      const result = SyncResult(
        success: true,
        versionsSynced: 5,
        tasksAdded: 1,
        tasksUpdated: 2,
        tasksDeleted: 3,
      );

      expect(
        result.summary,
        'Sync completed: 5 versions synced, +1 added, 2 updated, -3 deleted',
      );
    });

    test('does not report "No changes" when versions were synced', () {
      // The reported bug: remote tasks fetched during sync were invisible to
      // the summary because only tasks* counters were considered.
      const result = SyncResult(success: true, versionsSynced: 3);

      expect(result.summary, isNot(contains('No changes')));
      expect(result.summary, contains('3 versions synced'));
    });

    test('omits zero-valued categories', () {
      const result = SyncResult(success: true, tasksAdded: 2);

      expect(result.summary, 'Sync completed: +2 added');
    });
  });
}
