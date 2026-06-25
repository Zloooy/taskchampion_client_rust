// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncConfig _$SyncConfigFromJson(Map<String, dynamic> json) => _SyncConfig(
  serverUrl: json['serverUrl'] as String,
  clientId: json['clientId'] as String,
  encryptionSecret: json['encryptionSecret'] as String,
);

Map<String, dynamic> _$SyncConfigToJson(_SyncConfig instance) =>
    <String, dynamic>{
      'serverUrl': instance.serverUrl,
      'clientId': instance.clientId,
      'encryptionSecret': instance.encryptionSecret,
    };
