// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientConfig _$ClientConfigFromJson(
  Map<String, dynamic> json,
) => _ClientConfig(
  taskdbPath: json['taskdbPath'] as String,
  syncConfig: SyncConfig.fromJson(json['syncConfig'] as Map<String, dynamic>),
  authConfig: AuthConfig.fromJson(json['authConfig'] as Map<String, dynamic>),
  debugLogging: json['debugLogging'] as bool? ?? false,
  autoSyncOnTaskChange: json['autoSyncOnTaskChange'] as bool? ?? false,
);

Map<String, dynamic> _$ClientConfigToJson(_ClientConfig instance) =>
    <String, dynamic>{
      'taskdbPath': instance.taskdbPath,
      'syncConfig': instance.syncConfig,
      'authConfig': instance.authConfig,
      'debugLogging': instance.debugLogging,
      'autoSyncOnTaskChange': instance.autoSyncOnTaskChange,
    };
