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
  }) = _SyncConfig;

  /// Create a SyncConfig from a JSON map
  factory SyncConfig.fromJson(Map<String, dynamic> json) =>
      _$SyncConfigFromJson(json);
}
