// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncResult _$SyncResultFromJson(Map<String, dynamic> json) => _SyncResult(
  success: json['success'] as bool,
  versionsSynced: (json['versionsSynced'] as num?)?.toInt() ?? 0,
  tasksAdded: (json['tasksAdded'] as num?)?.toInt() ?? 0,
  tasksUpdated: (json['tasksUpdated'] as num?)?.toInt() ?? 0,
  tasksDeleted: (json['tasksDeleted'] as num?)?.toInt() ?? 0,
  errorMessage: json['errorMessage'] as String?,
  durationMs: (json['durationMs'] as num?)?.toInt(),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  snapshotDownloaded: json['snapshotDownloaded'] as bool? ?? false,
  snapshotUploaded: json['snapshotUploaded'] as bool? ?? false,
);

Map<String, dynamic> _$SyncResultToJson(_SyncResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'versionsSynced': instance.versionsSynced,
      'tasksAdded': instance.tasksAdded,
      'tasksUpdated': instance.tasksUpdated,
      'tasksDeleted': instance.tasksDeleted,
      'errorMessage': instance.errorMessage,
      'durationMs': instance.durationMs,
      'completedAt': instance.completedAt?.toIso8601String(),
      'snapshotDownloaded': instance.snapshotDownloaded,
      'snapshotUploaded': instance.snapshotUploaded,
    };
