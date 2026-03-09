// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthConfig _$AuthConfigFromJson(Map<String, dynamic> json) => _AuthConfig(
  clientId: json['clientId'] as String,
  encryptionSecret: json['encryptionSecret'] as String,
  serverUrl: json['serverUrl'] as String,
  validateCertificates: json['validateCertificates'] as bool? ?? true,
  certificatePath: json['certificatePath'] as String?,
  keyPath: json['keyPath'] as String?,
);

Map<String, dynamic> _$AuthConfigToJson(_AuthConfig instance) =>
    <String, dynamic>{
      'clientId': instance.clientId,
      'encryptionSecret': instance.encryptionSecret,
      'serverUrl': instance.serverUrl,
      'validateCertificates': instance.validateCertificates,
      'certificatePath': instance.certificatePath,
      'keyPath': instance.keyPath,
    };
