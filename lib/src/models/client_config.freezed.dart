// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientConfig {

/// Path to the task database directory
 String get taskdbPath;/// Sync server configuration
 SyncConfig get syncConfig;/// Authentication configuration
 AuthConfig get authConfig;/// Enable debug logging
 bool get debugLogging;/// Enable automatic sync after task changes
 bool get autoSyncOnTaskChange;
/// Create a copy of ClientConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientConfigCopyWith<ClientConfig> get copyWith => _$ClientConfigCopyWithImpl<ClientConfig>(this as ClientConfig, _$identity);

  /// Serializes this ClientConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientConfig&&(identical(other.taskdbPath, taskdbPath) || other.taskdbPath == taskdbPath)&&(identical(other.syncConfig, syncConfig) || other.syncConfig == syncConfig)&&(identical(other.authConfig, authConfig) || other.authConfig == authConfig)&&(identical(other.debugLogging, debugLogging) || other.debugLogging == debugLogging)&&(identical(other.autoSyncOnTaskChange, autoSyncOnTaskChange) || other.autoSyncOnTaskChange == autoSyncOnTaskChange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskdbPath,syncConfig,authConfig,debugLogging,autoSyncOnTaskChange);

@override
String toString() {
  return 'ClientConfig(taskdbPath: $taskdbPath, syncConfig: $syncConfig, authConfig: $authConfig, debugLogging: $debugLogging, autoSyncOnTaskChange: $autoSyncOnTaskChange)';
}


}

/// @nodoc
abstract mixin class $ClientConfigCopyWith<$Res>  {
  factory $ClientConfigCopyWith(ClientConfig value, $Res Function(ClientConfig) _then) = _$ClientConfigCopyWithImpl;
@useResult
$Res call({
 String taskdbPath, SyncConfig syncConfig, AuthConfig authConfig, bool debugLogging, bool autoSyncOnTaskChange
});


$SyncConfigCopyWith<$Res> get syncConfig;$AuthConfigCopyWith<$Res> get authConfig;

}
/// @nodoc
class _$ClientConfigCopyWithImpl<$Res>
    implements $ClientConfigCopyWith<$Res> {
  _$ClientConfigCopyWithImpl(this._self, this._then);

  final ClientConfig _self;
  final $Res Function(ClientConfig) _then;

/// Create a copy of ClientConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskdbPath = null,Object? syncConfig = null,Object? authConfig = null,Object? debugLogging = null,Object? autoSyncOnTaskChange = null,}) {
  return _then(_self.copyWith(
taskdbPath: null == taskdbPath ? _self.taskdbPath : taskdbPath // ignore: cast_nullable_to_non_nullable
as String,syncConfig: null == syncConfig ? _self.syncConfig : syncConfig // ignore: cast_nullable_to_non_nullable
as SyncConfig,authConfig: null == authConfig ? _self.authConfig : authConfig // ignore: cast_nullable_to_non_nullable
as AuthConfig,debugLogging: null == debugLogging ? _self.debugLogging : debugLogging // ignore: cast_nullable_to_non_nullable
as bool,autoSyncOnTaskChange: null == autoSyncOnTaskChange ? _self.autoSyncOnTaskChange : autoSyncOnTaskChange // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ClientConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SyncConfigCopyWith<$Res> get syncConfig {
  
  return $SyncConfigCopyWith<$Res>(_self.syncConfig, (value) {
    return _then(_self.copyWith(syncConfig: value));
  });
}/// Create a copy of ClientConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthConfigCopyWith<$Res> get authConfig {
  
  return $AuthConfigCopyWith<$Res>(_self.authConfig, (value) {
    return _then(_self.copyWith(authConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClientConfig].
extension ClientConfigPatterns on ClientConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientConfig value)  $default,){
final _that = this;
switch (_that) {
case _ClientConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ClientConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taskdbPath,  SyncConfig syncConfig,  AuthConfig authConfig,  bool debugLogging,  bool autoSyncOnTaskChange)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientConfig() when $default != null:
return $default(_that.taskdbPath,_that.syncConfig,_that.authConfig,_that.debugLogging,_that.autoSyncOnTaskChange);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taskdbPath,  SyncConfig syncConfig,  AuthConfig authConfig,  bool debugLogging,  bool autoSyncOnTaskChange)  $default,) {final _that = this;
switch (_that) {
case _ClientConfig():
return $default(_that.taskdbPath,_that.syncConfig,_that.authConfig,_that.debugLogging,_that.autoSyncOnTaskChange);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taskdbPath,  SyncConfig syncConfig,  AuthConfig authConfig,  bool debugLogging,  bool autoSyncOnTaskChange)?  $default,) {final _that = this;
switch (_that) {
case _ClientConfig() when $default != null:
return $default(_that.taskdbPath,_that.syncConfig,_that.authConfig,_that.debugLogging,_that.autoSyncOnTaskChange);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientConfig implements ClientConfig {
  const _ClientConfig({required this.taskdbPath, required this.syncConfig, required this.authConfig, this.debugLogging = false, this.autoSyncOnTaskChange = false});
  factory _ClientConfig.fromJson(Map<String, dynamic> json) => _$ClientConfigFromJson(json);

/// Path to the task database directory
@override final  String taskdbPath;
/// Sync server configuration
@override final  SyncConfig syncConfig;
/// Authentication configuration
@override final  AuthConfig authConfig;
/// Enable debug logging
@override@JsonKey() final  bool debugLogging;
/// Enable automatic sync after task changes
@override@JsonKey() final  bool autoSyncOnTaskChange;

/// Create a copy of ClientConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientConfigCopyWith<_ClientConfig> get copyWith => __$ClientConfigCopyWithImpl<_ClientConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientConfig&&(identical(other.taskdbPath, taskdbPath) || other.taskdbPath == taskdbPath)&&(identical(other.syncConfig, syncConfig) || other.syncConfig == syncConfig)&&(identical(other.authConfig, authConfig) || other.authConfig == authConfig)&&(identical(other.debugLogging, debugLogging) || other.debugLogging == debugLogging)&&(identical(other.autoSyncOnTaskChange, autoSyncOnTaskChange) || other.autoSyncOnTaskChange == autoSyncOnTaskChange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskdbPath,syncConfig,authConfig,debugLogging,autoSyncOnTaskChange);

@override
String toString() {
  return 'ClientConfig(taskdbPath: $taskdbPath, syncConfig: $syncConfig, authConfig: $authConfig, debugLogging: $debugLogging, autoSyncOnTaskChange: $autoSyncOnTaskChange)';
}


}

/// @nodoc
abstract mixin class _$ClientConfigCopyWith<$Res> implements $ClientConfigCopyWith<$Res> {
  factory _$ClientConfigCopyWith(_ClientConfig value, $Res Function(_ClientConfig) _then) = __$ClientConfigCopyWithImpl;
@override @useResult
$Res call({
 String taskdbPath, SyncConfig syncConfig, AuthConfig authConfig, bool debugLogging, bool autoSyncOnTaskChange
});


@override $SyncConfigCopyWith<$Res> get syncConfig;@override $AuthConfigCopyWith<$Res> get authConfig;

}
/// @nodoc
class __$ClientConfigCopyWithImpl<$Res>
    implements _$ClientConfigCopyWith<$Res> {
  __$ClientConfigCopyWithImpl(this._self, this._then);

  final _ClientConfig _self;
  final $Res Function(_ClientConfig) _then;

/// Create a copy of ClientConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskdbPath = null,Object? syncConfig = null,Object? authConfig = null,Object? debugLogging = null,Object? autoSyncOnTaskChange = null,}) {
  return _then(_ClientConfig(
taskdbPath: null == taskdbPath ? _self.taskdbPath : taskdbPath // ignore: cast_nullable_to_non_nullable
as String,syncConfig: null == syncConfig ? _self.syncConfig : syncConfig // ignore: cast_nullable_to_non_nullable
as SyncConfig,authConfig: null == authConfig ? _self.authConfig : authConfig // ignore: cast_nullable_to_non_nullable
as AuthConfig,debugLogging: null == debugLogging ? _self.debugLogging : debugLogging // ignore: cast_nullable_to_non_nullable
as bool,autoSyncOnTaskChange: null == autoSyncOnTaskChange ? _self.autoSyncOnTaskChange : autoSyncOnTaskChange // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ClientConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SyncConfigCopyWith<$Res> get syncConfig {
  
  return $SyncConfigCopyWith<$Res>(_self.syncConfig, (value) {
    return _then(_self.copyWith(syncConfig: value));
  });
}/// Create a copy of ClientConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthConfigCopyWith<$Res> get authConfig {
  
  return $AuthConfigCopyWith<$Res>(_self.authConfig, (value) {
    return _then(_self.copyWith(authConfig: value));
  });
}
}

// dart format on
