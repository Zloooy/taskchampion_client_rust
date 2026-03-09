// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncConfig {

/// URL of the TaskChampion sync server
 String get serverUrl;/// Client ID for authentication (UUID v4)
 String get clientId;/// Encryption secret for secure data transmission
 String get encryptionSecret;/// Timeout for sync operations in milliseconds
 int get timeout;/// Enable automatic sync on task changes
 bool get autoSync;/// Enable verbose logging for debugging
 bool get verboseLogging;
/// Create a copy of SyncConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncConfigCopyWith<SyncConfig> get copyWith => _$SyncConfigCopyWithImpl<SyncConfig>(this as SyncConfig, _$identity);

  /// Serializes this SyncConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncConfig&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.encryptionSecret, encryptionSecret) || other.encryptionSecret == encryptionSecret)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.autoSync, autoSync) || other.autoSync == autoSync)&&(identical(other.verboseLogging, verboseLogging) || other.verboseLogging == verboseLogging));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serverUrl,clientId,encryptionSecret,timeout,autoSync,verboseLogging);

@override
String toString() {
  return 'SyncConfig(serverUrl: $serverUrl, clientId: $clientId, encryptionSecret: $encryptionSecret, timeout: $timeout, autoSync: $autoSync, verboseLogging: $verboseLogging)';
}


}

/// @nodoc
abstract mixin class $SyncConfigCopyWith<$Res>  {
  factory $SyncConfigCopyWith(SyncConfig value, $Res Function(SyncConfig) _then) = _$SyncConfigCopyWithImpl;
@useResult
$Res call({
 String serverUrl, String clientId, String encryptionSecret, int timeout, bool autoSync, bool verboseLogging
});




}
/// @nodoc
class _$SyncConfigCopyWithImpl<$Res>
    implements $SyncConfigCopyWith<$Res> {
  _$SyncConfigCopyWithImpl(this._self, this._then);

  final SyncConfig _self;
  final $Res Function(SyncConfig) _then;

/// Create a copy of SyncConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serverUrl = null,Object? clientId = null,Object? encryptionSecret = null,Object? timeout = null,Object? autoSync = null,Object? verboseLogging = null,}) {
  return _then(_self.copyWith(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,encryptionSecret: null == encryptionSecret ? _self.encryptionSecret : encryptionSecret // ignore: cast_nullable_to_non_nullable
as String,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int,autoSync: null == autoSync ? _self.autoSync : autoSync // ignore: cast_nullable_to_non_nullable
as bool,verboseLogging: null == verboseLogging ? _self.verboseLogging : verboseLogging // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncConfig].
extension SyncConfigPatterns on SyncConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncConfig value)  $default,){
final _that = this;
switch (_that) {
case _SyncConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SyncConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String serverUrl,  String clientId,  String encryptionSecret,  int timeout,  bool autoSync,  bool verboseLogging)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncConfig() when $default != null:
return $default(_that.serverUrl,_that.clientId,_that.encryptionSecret,_that.timeout,_that.autoSync,_that.verboseLogging);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String serverUrl,  String clientId,  String encryptionSecret,  int timeout,  bool autoSync,  bool verboseLogging)  $default,) {final _that = this;
switch (_that) {
case _SyncConfig():
return $default(_that.serverUrl,_that.clientId,_that.encryptionSecret,_that.timeout,_that.autoSync,_that.verboseLogging);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String serverUrl,  String clientId,  String encryptionSecret,  int timeout,  bool autoSync,  bool verboseLogging)?  $default,) {final _that = this;
switch (_that) {
case _SyncConfig() when $default != null:
return $default(_that.serverUrl,_that.clientId,_that.encryptionSecret,_that.timeout,_that.autoSync,_that.verboseLogging);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncConfig implements SyncConfig {
  const _SyncConfig({required this.serverUrl, required this.clientId, required this.encryptionSecret, this.timeout = 30000, this.autoSync = false, this.verboseLogging = false});
  factory _SyncConfig.fromJson(Map<String, dynamic> json) => _$SyncConfigFromJson(json);

/// URL of the TaskChampion sync server
@override final  String serverUrl;
/// Client ID for authentication (UUID v4)
@override final  String clientId;
/// Encryption secret for secure data transmission
@override final  String encryptionSecret;
/// Timeout for sync operations in milliseconds
@override@JsonKey() final  int timeout;
/// Enable automatic sync on task changes
@override@JsonKey() final  bool autoSync;
/// Enable verbose logging for debugging
@override@JsonKey() final  bool verboseLogging;

/// Create a copy of SyncConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncConfigCopyWith<_SyncConfig> get copyWith => __$SyncConfigCopyWithImpl<_SyncConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncConfig&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.encryptionSecret, encryptionSecret) || other.encryptionSecret == encryptionSecret)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.autoSync, autoSync) || other.autoSync == autoSync)&&(identical(other.verboseLogging, verboseLogging) || other.verboseLogging == verboseLogging));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serverUrl,clientId,encryptionSecret,timeout,autoSync,verboseLogging);

@override
String toString() {
  return 'SyncConfig(serverUrl: $serverUrl, clientId: $clientId, encryptionSecret: $encryptionSecret, timeout: $timeout, autoSync: $autoSync, verboseLogging: $verboseLogging)';
}


}

/// @nodoc
abstract mixin class _$SyncConfigCopyWith<$Res> implements $SyncConfigCopyWith<$Res> {
  factory _$SyncConfigCopyWith(_SyncConfig value, $Res Function(_SyncConfig) _then) = __$SyncConfigCopyWithImpl;
@override @useResult
$Res call({
 String serverUrl, String clientId, String encryptionSecret, int timeout, bool autoSync, bool verboseLogging
});




}
/// @nodoc
class __$SyncConfigCopyWithImpl<$Res>
    implements _$SyncConfigCopyWith<$Res> {
  __$SyncConfigCopyWithImpl(this._self, this._then);

  final _SyncConfig _self;
  final $Res Function(_SyncConfig) _then;

/// Create a copy of SyncConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serverUrl = null,Object? clientId = null,Object? encryptionSecret = null,Object? timeout = null,Object? autoSync = null,Object? verboseLogging = null,}) {
  return _then(_SyncConfig(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,encryptionSecret: null == encryptionSecret ? _self.encryptionSecret : encryptionSecret // ignore: cast_nullable_to_non_nullable
as String,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int,autoSync: null == autoSync ? _self.autoSync : autoSync // ignore: cast_nullable_to_non_nullable
as bool,verboseLogging: null == verboseLogging ? _self.verboseLogging : verboseLogging // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
