/// Base exception for all TaskChampion client errors.
sealed class TaskChampionException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Optional underlying cause.
  final Object? cause;

  const TaskChampionException(this.message, {this.cause});

  @override
  String toString() {
    if (cause != null) {
      return '$runtimeType: $message (caused by $cause)';
    }
    return '$runtimeType: $message';
  }
}

/// Exception thrown when task storage operations fail.
final class TaskStorageException extends TaskChampionException {
  const TaskStorageException(super.message, {super.cause});
}

/// Exception thrown when synchronization fails.
final class SyncException extends TaskChampionException {
  const SyncException(super.message, {super.cause});
}

/// Exception thrown when authentication fails.
final class AuthException extends TaskChampionException {
  const AuthException(super.message, {super.cause});
}

/// Exception thrown when input validation fails.
final class ValidationException extends TaskChampionException {
  const ValidationException(super.message, {super.cause});
}
