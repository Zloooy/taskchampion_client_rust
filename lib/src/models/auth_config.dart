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
  }) = _AuthConfig;

  /// Create an AuthConfig from a JSON map
  factory AuthConfig.fromJson(Map<String, dynamic> json) =>
      _$AuthConfigFromJson(json);
}
