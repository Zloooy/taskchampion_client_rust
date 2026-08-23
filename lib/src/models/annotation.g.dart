// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Annotation _$AnnotationFromJson(Map<String, dynamic> json) => _Annotation(
  entry: DateTime.parse(json['entry'] as String),
  description: json['description'] as String,
);

Map<String, dynamic> _$AnnotationToJson(_Annotation instance) =>
    <String, dynamic>{
      'entry': instance.entry.toIso8601String(),
      'description': instance.description,
    };
