import 'dart:async';

import '../models/models.dart';

/// Manages streams for task changes and sync events.
///
/// Centralises lifecycle management of broadcast streams so that
/// [TaskChampionClient] does not directly own [StreamController]s.
class TaskEventManager {
  final _taskChangesController = StreamController<Task>.broadcast();
  final _syncEventsController = StreamController<SyncResult>.broadcast();

  /// Stream of task change events.
  Stream<Task> get taskChanges => _taskChangesController.stream;

  /// Stream of sync result events.
  Stream<SyncResult> get syncEvents => _syncEventsController.stream;

  /// Emit a task change event.
  void emitTaskChange(Task task) {
    if (!_taskChangesController.isClosed) {
      _taskChangesController.add(task);
    }
  }

  /// Emit a sync result event.
  void emitSyncResult(SyncResult result) {
    if (!_syncEventsController.isClosed) {
      _syncEventsController.add(result);
    }
  }

  /// Dispose and close all streams.
  void dispose() {
    _taskChangesController.close();
    _syncEventsController.close();
  }
}
