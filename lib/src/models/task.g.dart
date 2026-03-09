// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  uuid: json['uuid'] as String,
  description: json['description'] as String,
  status:
      $enumDecodeNullable(
        _$TaskStatusEnumMap,
        json['status'],
        unknownValue: TaskStatus.pending,
      ) ??
      TaskStatus.pending,
  priority:
      $enumDecodeNullable(
        _$TaskPriorityEnumMap,
        json['priority'],
        unknownValue: TaskPriority.none,
      ) ??
      TaskPriority.none,
  project: json['project'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  due: json['due'] == null ? null : DateTime.parse(json['due'] as String),
  wait: json['wait'] == null ? null : DateTime.parse(json['wait'] as String),
  scheduled: json['scheduled'] == null
      ? null
      : DateTime.parse(json['scheduled'] as String),
  until: json['until'] == null ? null : DateTime.parse(json['until'] as String),
  entry: DateTime.parse(json['entry'] as String),
  modified: json['modified'] == null
      ? null
      : DateTime.parse(json['modified'] as String),
  end: json['end'] == null ? null : DateTime.parse(json['end'] as String),
  udas:
      (json['udas'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  urgency: (json['urgency'] as num?)?.toDouble(),
  parent: json['parent'] as String?,
  depends:
      (json['depends'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'description': instance.description,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'project': instance.project,
  'tags': instance.tags,
  'due': instance.due?.toIso8601String(),
  'wait': instance.wait?.toIso8601String(),
  'scheduled': instance.scheduled?.toIso8601String(),
  'until': instance.until?.toIso8601String(),
  'entry': instance.entry.toIso8601String(),
  'modified': instance.modified?.toIso8601String(),
  'end': instance.end?.toIso8601String(),
  'udas': instance.udas,
  'urgency': instance.urgency,
  'parent': instance.parent,
  'depends': instance.depends,
};

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.completed: 'completed',
  TaskStatus.deleted: 'deleted',
};

const _$TaskPriorityEnumMap = {
  TaskPriority.high: 'high',
  TaskPriority.medium: 'medium',
  TaskPriority.low: 'low',
  TaskPriority.none: 'none',
};
