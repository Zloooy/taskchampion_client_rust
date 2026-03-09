// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthConfig {

/// Client ID for authentication (UUID v4)
 String get clientId;/// Encryption secret for secure communication
 String get encryptionSecret;/// Server URL to authenticate against
 String get serverUrl;/// Whether to validate SSL certificates
 bool get validateCertificates;/// Custom certificate paths (optional)
 String? get certificatePath;/// Custom key paths (optional)
 String? get keyPath;
/// Create a copy of AuthConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthConfigCopyWith<AuthConfig> get copyWith => _$AuthConfigCopyWithImpl<AuthConfig>(this as AuthConfig, _$identity);

  /// Serializes this AuthConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthConfig&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.encryptionSecret, encryptionSecret) || other.encryptionSecret == encryptionSecret)&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.validateCertificates, validateCertificates) || other.validateCertificates == validateCertificates)&&(identical(other.certificatePath, certificatePath) || other.certificatePath == certificatePath)&&(identical(other.keyPath, keyPath) || other.keyPath == keyPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,encryptionSecret,serverUrl,validateCertificates,certificatePath,keyPath);

@override
String toString() {
  return 'AuthConfig(clientId: $clientId, encryptionSecret: $encryptionSecret, serverUrl: $serverUrl, validateCertificates: $validateCertificates, certificatePath: $certificatePath, keyPath: $keyPath)';
}


}

/// @nodoc
abstract mixin class $AuthConfigCopyWith<$Res>  {
  factory $AuthConfigCopyWith(AuthConfig value, $Res Function(AuthConfig) _then) = _$AuthConfigCopyWithImpl;
@useResult
$Res call({
 String clientId, String encryptionSecret, String serverUrl, bool validateCertificates, String? certificatePath, String? keyPath
});




}
/// @nodoc
class _$AuthConfigCopyWithImpl<$Res>
    implements $AuthConfigCopyWith<$Res> {
  _$AuthConfigCopyWithImpl(this._self, this._then);

  final AuthConfig _self;
  final $Res Function(AuthConfig) _then;

/// Create a copy of AuthConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientId = null,Object? encryptionSecret = null,Object? serverUrl = null,Object? validateCertificates = null,Object? certificatePath = freezed,Object? keyPath = freezed,}) {
  return _then(_self.copyWith(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,encryptionSecret: null == encryptionSecret ? _self.encryptionSecret : encryptionSecret // ignore: cast_nullable_to_non_nullable
as String,serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,validateCertificates: null == validateCertificates ? _self.validateCertificates : validateCertificates // ignore: cast_nullable_to_non_nullable
as bool,certificatePath: freezed == certificatePath ? _self.certificatePath : certificatePath // ignore: cast_nullable_to_non_nullable
as String?,keyPath: freezed == keyPath ? _self.keyPath : keyPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthConfig].
extension AuthConfigPatterns on AuthConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthConfig value)  $default,){
final _that = this;
switch (_that) {
case _AuthConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AuthConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clientId,  String encryptionSecret,  String serverUrl,  bool validateCertificates,  String? certificatePath,  String? keyPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthConfig() when $default != null:
return $default(_that.clientId,_that.encryptionSecret,_that.serverUrl,_that.validateCertificates,_that.certificatePath,_that.keyPath);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clientId,  String encryptionSecret,  String serverUrl,  bool validateCertificates,  String? certificatePath,  String? keyPath)  $default,) {final _that = this;
switch (_that) {
case _AuthConfig():
return $default(_that.clientId,_that.encryptionSecret,_that.serverUrl,_that.validateCertificates,_that.certificatePath,_that.keyPath);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clientId,  String encryptionSecret,  String serverUrl,  bool validateCertificates,  String? certificatePath,  String? keyPath)?  $default,) {final _that = this;
switch (_that) {
case _AuthConfig() when $default != null:
return $default(_that.clientId,_that.encryptionSecret,_that.serverUrl,_that.validateCertificates,_that.certificatePath,_that.keyPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthConfig implements AuthConfig {
  const _AuthConfig({required this.clientId, required this.encryptionSecret, required this.serverUrl, this.validateCertificates = true, this.certificatePath, this.keyPath});
  factory _AuthConfig.fromJson(Map<String, dynamic> json) => _$AuthConfigFromJson(json);

/// Client ID for authentication (UUID v4)
@override final  String clientId;
/// Encryption secret for secure communication
@override final  String encryptionSecret;
/// Server URL to authenticate against
@override final  String serverUrl;
/// Whether to validate SSL certificates
@override@JsonKey() final  bool validateCertificates;
/// Custom certificate paths (optional)
@override final  String? certificatePath;
/// Custom key paths (optional)
@override final  String? keyPath;

/// Create a copy of AuthConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthConfigCopyWith<_AuthConfig> get copyWith => __$AuthConfigCopyWithImpl<_AuthConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthConfig&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.encryptionSecret, encryptionSecret) || other.encryptionSecret == encryptionSecret)&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.validateCertificates, validateCertificates) || other.validateCertificates == validateCertificates)&&(identical(other.certificatePath, certificatePath) || other.certificatePath == certificatePath)&&(identical(other.keyPath, keyPath) || other.keyPath == keyPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,encryptionSecret,serverUrl,validateCertificates,certificatePath,keyPath);

@override
String toString() {
  return 'AuthConfig(clientId: $clientId, encryptionSecret: $encryptionSecret, serverUrl: $serverUrl, validateCertificates: $validateCertificates, certificatePath: $certificatePath, keyPath: $keyPath)';
}


}

/// @nodoc
abstract mixin class _$AuthConfigCopyWith<$Res> implements $AuthConfigCopyWith<$Res> {
  factory _$AuthConfigCopyWith(_AuthConfig value, $Res Function(_AuthConfig) _then) = __$AuthConfigCopyWithImpl;
@override @useResult
$Res call({
 String clientId, String encryptionSecret, String serverUrl, bool validateCertificates, String? certificatePath, String? keyPath
});




}
/// @nodoc
class __$AuthConfigCopyWithImpl<$Res>
    implements _$AuthConfigCopyWith<$Res> {
  __$AuthConfigCopyWithImpl(this._self, this._then);

  final _AuthConfig _self;
  final $Res Function(_AuthConfig) _then;

/// Create a copy of AuthConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientId = null,Object? encryptionSecret = null,Object? serverUrl = null,Object? validateCertificates = null,Object? certificatePath = freezed,Object? keyPath = freezed,}) {
  return _then(_AuthConfig(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,encryptionSecret: null == encryptionSecret ? _self.encryptionSecret : encryptionSecret // ignore: cast_nullable_to_non_nullable
as String,serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,validateCertificates: null == validateCertificates ? _self.validateCertificates : validateCertificates // ignore: cast_nullable_to_non_nullable
as bool,certificatePath: freezed == certificatePath ? _self.certificatePath : certificatePath // ignore: cast_nullable_to_non_nullable
as String?,keyPath: freezed == keyPath ? _self.keyPath : keyPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
