import 'package:flutter/foundation.dart';

/// Abstract logger interface for the TaskChampion client.
///
/// Allows consumers to inject their own logging implementation
/// (e.g., structured logging, crash reporting) without depending
/// directly on `debugPrint`.
abstract interface class Logger {
  /// Log a debug message.
  void debug(String message);

  /// Log an informational message.
  void info(String message);

  /// Log a warning message.
  void warning(String message);

  /// Log an error message.
  void error(String message, {Object? error, StackTrace? stackTrace});
}

/// Default logger implementation that delegates to [debugPrint].
final class DebugPrintLogger implements Logger {
  final String _prefix;

  /// Create a logger with an optional [prefix].
  const DebugPrintLogger({String prefix = '[TaskChampion]'}) : _prefix = prefix;

  @override
  void debug(String message) => debugPrint('$_prefix [DEBUG] $message');

  @override
  void info(String message) => debugPrint('$_prefix [INFO] $message');

  @override
  void warning(String message) => debugPrint('$_prefix [WARN] $message');

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('$_prefix [ERROR] $message');
    if (error != null) {
      debugPrint('$_prefix [ERROR] Cause: $error');
    }
    if (stackTrace != null) {
      debugPrint('$_prefix [ERROR] StackTrace: $stackTrace');
    }
  }
}

/// No-op logger for use in tests or when logging should be suppressed.
final class NoOpLogger implements Logger {
  const NoOpLogger();

  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void warning(String message) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}
