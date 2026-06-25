import 'dart:async';

import '../services/interfaces/interfaces.dart';

/// Coordinates debounced auto-sync based on task change events.
///
/// Wraps a [Timer] so the client does not hold timer logic directly.
class AutoSyncCoordinator {
  final ISyncService _syncService;
  final Duration _debounceDuration;
  Timer? _timer;

  /// Create a coordinator with the given [syncService] and optional
  /// [debounceDuration] (default 2 seconds).
  AutoSyncCoordinator(this._syncService, {Duration? debounceDuration})
    : _debounceDuration = debounceDuration ?? const Duration(seconds: 2);

  /// Request a sync after the debounce period.
  ///
  /// Each call resets the timer.  The actual sync is triggered only when
  /// no calls have been made for [_debounceDuration].
  void requestSync() {
    _timer?.cancel();
    _timer = Timer(_debounceDuration, () {
      _syncService.sync();
    });
  }

  /// Cancel any pending sync request without performing it.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose and release resources.
  void dispose() {
    cancel();
  }
}
