// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncConfig _$SyncConfigFromJson(Map<String, dynamic> json) => _SyncConfig(
  serverUrl: json['serverUrl'] as String,
  clientId: json['clientId'] as String,
  encryptionSecret: json['encryptionSecret'] as String,
  timeout: (json['timeout'] as num?)?.toInt() ?? 30000,
  autoSync: json['autoSync'] as bool? ?? false,
  verboseLogging: json['verboseLogging'] as bool? ?? false,
);

Map<String, dynamic> _$SyncConfigToJson(_SyncConfig instance) =>
    <String, dynamic>{
      'serverUrl': instance.serverUrl,
      'clientId': instance.clientId,
      'encryptionSecret': instance.encryptionSecret,
      'timeout': instance.timeout,
      'autoSync': instance.autoSync,
      'verboseLogging': instance.verboseLogging,
    };
