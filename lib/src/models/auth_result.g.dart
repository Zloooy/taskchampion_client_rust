// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthResult _$AuthResultFromJson(Map<String, dynamic> json) => _AuthResult(
  success: json['success'] as bool,
  errorMessage: json['errorMessage'] as String?,
  serverUrl: json['serverUrl'] as String?,
  clientId: json['clientId'] as String?,
  canSync: json['canSync'] as bool? ?? false,
  serverVersion: json['serverVersion'] as String?,
  authenticatedAt: json['authenticatedAt'] == null
      ? null
      : DateTime.parse(json['authenticatedAt'] as String),
);

Map<String, dynamic> _$AuthResultToJson(_AuthResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'errorMessage': instance.errorMessage,
      'serverUrl': instance.serverUrl,
      'clientId': instance.clientId,
      'canSync': instance.canSync,
      'serverVersion': instance.serverVersion,
      'authenticatedAt': instance.authenticatedAt?.toIso8601String(),
    };
