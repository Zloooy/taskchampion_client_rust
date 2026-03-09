import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_result.freezed.dart';
part 'auth_result.g.dart';

/// Result of an authentication operation
///
/// Contains information about authentication status and any errors.
@freezed
abstract class AuthResult with _$AuthResult {
  const factory AuthResult({
    /// Whether authentication was successful
    required bool success,

    /// Error message if authentication failed
    String? errorMessage,

    /// Server information
    String? serverUrl,

    /// Client ID that was authenticated
    String? clientId,

    /// Whether the client is allowed to sync
    @Default(false) bool canSync,

    /// Server version information
    String? serverVersion,

    /// Timestamp when authentication completed
    DateTime? authenticatedAt,
  }) = _AuthResult;

  /// Create an AuthResult from a JSON map
  factory AuthResult.fromJson(Map<String, dynamic> json) =>
      _$AuthResultFromJson(json);

  /// Create a successful auth result
  factory AuthResult.success({
    required String serverUrl,
    required String clientId,
    bool canSync = true,
    String? serverVersion,
  }) {
    return AuthResult(
      success: true,
      serverUrl: serverUrl,
      clientId: clientId,
      canSync: canSync,
      serverVersion: serverVersion,
      authenticatedAt: DateTime.now(),
    );
  }

  /// Create a failed auth result
  factory AuthResult.failure(String errorMessage) {
    return AuthResult(
      success: false,
      errorMessage: errorMessage,
      authenticatedAt: DateTime.now(),
    );
  }
}

/// Extension methods for AuthResult
extension AuthResultExtensions on AuthResult {
  /// Check if authentication failed
  bool get hasError => errorMessage != null;

  /// Get a human-readable status message
  String get statusMessage {
    if (success) {
      return 'Authenticated successfully with server $serverUrl';
    } else {
      return 'Authentication failed: $errorMessage';
    }
  }
}
