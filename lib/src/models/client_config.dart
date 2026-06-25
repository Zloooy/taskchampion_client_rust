import 'package:freezed_annotation/freezed_annotation.dart';
import 'sync_config.dart';
import 'auth_config.dart';

part 'client_config.freezed.dart';
part 'client_config.g.dart';

/// Complete configuration for TaskChampion client
///
/// Combines sync and authentication configuration with additional
/// client settings.
@freezed
abstract class ClientConfig with _$ClientConfig {
  const factory ClientConfig({
    /// Path to the task database directory
    required String taskdbPath,

    /// Sync server configuration
    required SyncConfig syncConfig,

    /// Authentication configuration
    required AuthConfig authConfig,

    /// Enable debug logging
    @Default(false) bool debugLogging,

    /// Enable automatic sync after task changes
    @Default(false) bool autoSyncOnTaskChange,
  }) = _ClientConfig;

  /// Create a ClientConfig from a JSON map
  factory ClientConfig.fromJson(Map<String, dynamic> json) =>
      _$ClientConfigFromJson(json);

  /// Create a ClientConfig with minimal required parameters
  factory ClientConfig.createMinimal({
    required String serverUrl,
    required String clientId,
    required String encryptionSecret,
    String? taskdbPath,
    bool autoSyncOnTaskChange = false,
    bool debugLogging = false,
  }) {
    final syncConfig = SyncConfig(
      serverUrl: serverUrl,
      clientId: clientId,
      encryptionSecret: encryptionSecret,
    );

    final authConfig = AuthConfig(
      clientId: clientId,
      encryptionSecret: encryptionSecret,
      serverUrl: serverUrl,
    );

    return ClientConfig(
      taskdbPath: taskdbPath ?? 'taskchampion_db',
      syncConfig: syncConfig,
      authConfig: authConfig,
      autoSyncOnTaskChange: autoSyncOnTaskChange,
      debugLogging: debugLogging,
    );
  }
}
