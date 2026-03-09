import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_config.freezed.dart';
part 'auth_config.g.dart';

/// Configuration for authentication with TaskChampion sync server
///
/// Contains credentials and settings for authenticating with the server.
@freezed
abstract class AuthConfig with _$AuthConfig {
  const factory AuthConfig({
    /// Client ID for authentication (UUID v4)
    required String clientId,

    /// Encryption secret for secure communication
    required String encryptionSecret,

    /// Server URL to authenticate against
    required String serverUrl,

    /// Whether to validate SSL certificates
    @Default(true) bool validateCertificates,

    /// Custom certificate paths (optional)
    String? certificatePath,

    /// Custom key paths (optional)
    String? keyPath,
  }) = _AuthConfig;

  /// Create an AuthConfig from a JSON map
  factory AuthConfig.fromJson(Map<String, dynamic> json) =>
      _$AuthConfigFromJson(json);
}

/// Extension methods for AuthConfig
extension AuthConfigExtensions on AuthConfig {
  /// Check if credentials are valid
  bool get hasValidCredentials =>
      clientId.isNotEmpty &&
      encryptionSecret.isNotEmpty &&
      serverUrl.isNotEmpty;

  /// Get a sanitized version for logging
  Map<String, dynamic> toSafeMap() {
    return {
      'clientId': clientId,
      'encryptionSecret': encryptionSecret.isEmpty ? '(empty)' : '(hidden)',
      'serverUrl': serverUrl,
      'validateCertificates': validateCertificates,
      'hasCertificate': certificatePath != null,
      'hasKey': keyPath != null,
    };
  }
}
