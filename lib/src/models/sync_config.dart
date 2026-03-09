import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_config.freezed.dart';
part 'sync_config.g.dart';

/// Configuration for TaskChampion sync server
///
/// Contains all necessary information to connect and synchronize
/// with a TaskChampion sync server.
@freezed
abstract class SyncConfig with _$SyncConfig {
  const factory SyncConfig({
    /// URL of the TaskChampion sync server
    required String serverUrl,

    /// Client ID for authentication (UUID v4)
    required String clientId,

    /// Encryption secret for secure data transmission
    required String encryptionSecret,

    /// Timeout for sync operations in milliseconds
    @Default(30000) int timeout,

    /// Enable automatic sync on task changes
    @Default(false) bool autoSync,

    /// Enable verbose logging for debugging
    @Default(false) bool verboseLogging,
  }) = _SyncConfig;

  /// Create a SyncConfig from a JSON map
  factory SyncConfig.fromJson(Map<String, dynamic> json) =>
      _$SyncConfigFromJson(json);
}

/// Extension methods for SyncConfig
extension SyncConfigExtensions on SyncConfig {
  /// Check if the server URL is valid
  bool get isValidServerUrl {
    try {
      final uri = Uri.parse(serverUrl);
      return uri.host.isNotEmpty && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Check if the client ID is valid UUID
  bool get isValidClientId {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(clientId);
  }

  /// Check if the encryption secret is valid (non-empty)
  bool get isValidEncryptionSecret => encryptionSecret.isNotEmpty;

  /// Check if all configuration values are valid
  bool get isValid =>
      isValidServerUrl && isValidClientId && isValidEncryptionSecret;

  /// Get a sanitized version of the config for logging (hides secrets)
  Map<String, dynamic> toSafeMap() {
    return {
      'serverUrl': serverUrl,
      'clientId': clientId,
      'encryptionSecret': encryptionSecret.isEmpty ? '(empty)' : '(hidden)',
      'timeout': timeout,
      'autoSync': autoSync,
      'verboseLogging': verboseLogging,
    };
  }
}
