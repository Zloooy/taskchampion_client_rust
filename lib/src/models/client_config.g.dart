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
  autoSyncOnStartup: json['autoSyncOnStartup'] as bool? ?? false,
  autoSyncOnTaskChange: json['autoSyncOnTaskChange'] as bool? ?? false,
  syncIntervalMinutes: (json['syncIntervalMinutes'] as num?)?.toInt() ?? 15,
  maxHistorySize: (json['maxHistorySize'] as num?)?.toInt() ?? 1000,
  encryptAtRest: json['encryptAtRest'] as bool? ?? true,
);

Map<String, dynamic> _$ClientConfigToJson(_ClientConfig instance) =>
    <String, dynamic>{
      'taskdbPath': instance.taskdbPath,
      'syncConfig': instance.syncConfig,
      'authConfig': instance.authConfig,
      'debugLogging': instance.debugLogging,
      'autoSyncOnStartup': instance.autoSyncOnStartup,
      'autoSyncOnTaskChange': instance.autoSyncOnTaskChange,
      'syncIntervalMinutes': instance.syncIntervalMinutes,
      'maxHistorySize': instance.maxHistorySize,
      'encryptAtRest': instance.encryptAtRest,
    };
