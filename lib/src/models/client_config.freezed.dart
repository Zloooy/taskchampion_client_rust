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
 bool get debugLogging;/// Enable automatic sync on startup
 bool get autoSyncOnStartup;/// Enable automatic sync after task changes
 bool get autoSyncOnTaskChange;/// Sync interval in minutes (for periodic sync)
 int get syncIntervalMinutes;/// Maximum number of tasks to keep in history
 int get maxHistorySize;/// Enable task encryption at rest
 bool get encryptAtRest;
/// Create a copy of ClientConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientConfigCopyWith<ClientConfig> get copyWith => _$ClientConfigCopyWithImpl<ClientConfig>(this as ClientConfig, _$identity);

  /// Serializes this ClientConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientConfig&&(identical(other.taskdbPath, taskdbPath) || other.taskdbPath == taskdbPath)&&(identical(other.syncConfig, syncConfig) || other.syncConfig == syncConfig)&&(identical(other.authConfig, authConfig) || other.authConfig == authConfig)&&(identical(other.debugLogging, debugLogging) || other.debugLogging == debugLogging)&&(identical(other.autoSyncOnStartup, autoSyncOnStartup) || other.autoSyncOnStartup == autoSyncOnStartup)&&(identical(other.autoSyncOnTaskChange, autoSyncOnTaskChange) || other.autoSyncOnTaskChange == autoSyncOnTaskChange)&&(identical(other.syncIntervalMinutes, syncIntervalMinutes) || other.syncIntervalMinutes == syncIntervalMinutes)&&(identical(other.maxHistorySize, maxHistorySize) || other.maxHistorySize == maxHistorySize)&&(identical(other.encryptAtRest, encryptAtRest) || other.encryptAtRest == encryptAtRest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskdbPath,syncConfig,authConfig,debugLogging,autoSyncOnStartup,autoSyncOnTaskChange,syncIntervalMinutes,maxHistorySize,encryptAtRest);

@override
String toString() {
  return 'ClientConfig(taskdbPath: $taskdbPath, syncConfig: $syncConfig, authConfig: $authConfig, debugLogging: $debugLogging, autoSyncOnStartup: $autoSyncOnStartup, autoSyncOnTaskChange: $autoSyncOnTaskChange, syncIntervalMinutes: $syncIntervalMinutes, maxHistorySize: $maxHistorySize, encryptAtRest: $encryptAtRest)';
}


}

/// @nodoc
abstract mixin class $ClientConfigCopyWith<$Res>  {
  factory $ClientConfigCopyWith(ClientConfig value, $Res Function(ClientConfig) _then) = _$ClientConfigCopyWithImpl;
@useResult
$Res call({
 String taskdbPath, SyncConfig syncConfig, AuthConfig authConfig, bool debugLogging, bool autoSyncOnStartup, bool autoSyncOnTaskChange, int syncIntervalMinutes, int maxHistorySize, bool encryptAtRest
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
@pragma('vm:prefer-inline') @override $Res call({Object? taskdbPath = null,Object? syncConfig = null,Object? authConfig = null,Object? debugLogging = null,Object? autoSyncOnStartup = null,Object? autoSyncOnTaskChange = null,Object? syncIntervalMinutes = null,Object? maxHistorySize = null,Object? encryptAtRest = null,}) {
  return _then(_self.copyWith(
taskdbPath: null == taskdbPath ? _self.taskdbPath : taskdbPath // ignore: cast_nullable_to_non_nullable
as String,syncConfig: null == syncConfig ? _self.syncConfig : syncConfig // ignore: cast_nullable_to_non_nullable
as SyncConfig,authConfig: null == authConfig ? _self.authConfig : authConfig // ignore: cast_nullable_to_non_nullable
as AuthConfig,debugLogging: null == debugLogging ? _self.debugLogging : debugLogging // ignore: cast_nullable_to_non_nullable
as bool,autoSyncOnStartup: null == autoSyncOnStartup ? _self.autoSyncOnStartup : autoSyncOnStartup // ignore: cast_nullable_to_non_nullable
as bool,autoSyncOnTaskChange: null == autoSyncOnTaskChange ? _self.autoSyncOnTaskChange : autoSyncOnTaskChange // ignore: cast_nullable_to_non_nullable
as bool,syncIntervalMinutes: null == syncIntervalMinutes ? _self.syncIntervalMinutes : syncIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,maxHistorySize: null == maxHistorySize ? _self.maxHistorySize : maxHistorySize // ignore: cast_nullable_to_non_nullable
as int,encryptAtRest: null == encryptAtRest ? _self.encryptAtRest : encryptAtRest // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taskdbPath,  SyncConfig syncConfig,  AuthConfig authConfig,  bool debugLogging,  bool autoSyncOnStartup,  bool autoSyncOnTaskChange,  int syncIntervalMinutes,  int maxHistorySize,  bool encryptAtRest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientConfig() when $default != null:
return $default(_that.taskdbPath,_that.syncConfig,_that.authConfig,_that.debugLogging,_that.autoSyncOnStartup,_that.autoSyncOnTaskChange,_that.syncIntervalMinutes,_that.maxHistorySize,_that.encryptAtRest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taskdbPath,  SyncConfig syncConfig,  AuthConfig authConfig,  bool debugLogging,  bool autoSyncOnStartup,  bool autoSyncOnTaskChange,  int syncIntervalMinutes,  int maxHistorySize,  bool encryptAtRest)  $default,) {final _that = this;
switch (_that) {
case _ClientConfig():
return $default(_that.taskdbPath,_that.syncConfig,_that.authConfig,_that.debugLogging,_that.autoSyncOnStartup,_that.autoSyncOnTaskChange,_that.syncIntervalMinutes,_that.maxHistorySize,_that.encryptAtRest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taskdbPath,  SyncConfig syncConfig,  AuthConfig authConfig,  bool debugLogging,  bool autoSyncOnStartup,  bool autoSyncOnTaskChange,  int syncIntervalMinutes,  int maxHistorySize,  bool encryptAtRest)?  $default,) {final _that = this;
switch (_that) {
case _ClientConfig() when $default != null:
return $default(_that.taskdbPath,_that.syncConfig,_that.authConfig,_that.debugLogging,_that.autoSyncOnStartup,_that.autoSyncOnTaskChange,_that.syncIntervalMinutes,_that.maxHistorySize,_that.encryptAtRest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientConfig implements ClientConfig {
  const _ClientConfig({required this.taskdbPath, required this.syncConfig, required this.authConfig, this.debugLogging = false, this.autoSyncOnStartup = false, this.autoSyncOnTaskChange = false, this.syncIntervalMinutes = 15, this.maxHistorySize = 1000, this.encryptAtRest = true});
  factory _ClientConfig.fromJson(Map<String, dynamic> json) => _$ClientConfigFromJson(json);

/// Path to the task database directory
@override final  String taskdbPath;
/// Sync server configuration
@override final  SyncConfig syncConfig;
/// Authentication configuration
@override final  AuthConfig authConfig;
/// Enable debug logging
@override@JsonKey() final  bool debugLogging;
/// Enable automatic sync on startup
@override@JsonKey() final  bool autoSyncOnStartup;
/// Enable automatic sync after task changes
@override@JsonKey() final  bool autoSyncOnTaskChange;
/// Sync interval in minutes (for periodic sync)
@override@JsonKey() final  int syncIntervalMinutes;
/// Maximum number of tasks to keep in history
@override@JsonKey() final  int maxHistorySize;
/// Enable task encryption at rest
@override@JsonKey() final  bool encryptAtRest;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientConfig&&(identical(other.taskdbPath, taskdbPath) || other.taskdbPath == taskdbPath)&&(identical(other.syncConfig, syncConfig) || other.syncConfig == syncConfig)&&(identical(other.authConfig, authConfig) || other.authConfig == authConfig)&&(identical(other.debugLogging, debugLogging) || other.debugLogging == debugLogging)&&(identical(other.autoSyncOnStartup, autoSyncOnStartup) || other.autoSyncOnStartup == autoSyncOnStartup)&&(identical(other.autoSyncOnTaskChange, autoSyncOnTaskChange) || other.autoSyncOnTaskChange == autoSyncOnTaskChange)&&(identical(other.syncIntervalMinutes, syncIntervalMinutes) || other.syncIntervalMinutes == syncIntervalMinutes)&&(identical(other.maxHistorySize, maxHistorySize) || other.maxHistorySize == maxHistorySize)&&(identical(other.encryptAtRest, encryptAtRest) || other.encryptAtRest == encryptAtRest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskdbPath,syncConfig,authConfig,debugLogging,autoSyncOnStartup,autoSyncOnTaskChange,syncIntervalMinutes,maxHistorySize,encryptAtRest);

@override
String toString() {
  return 'ClientConfig(taskdbPath: $taskdbPath, syncConfig: $syncConfig, authConfig: $authConfig, debugLogging: $debugLogging, autoSyncOnStartup: $autoSyncOnStartup, autoSyncOnTaskChange: $autoSyncOnTaskChange, syncIntervalMinutes: $syncIntervalMinutes, maxHistorySize: $maxHistorySize, encryptAtRest: $encryptAtRest)';
}


}

/// @nodoc
abstract mixin class _$ClientConfigCopyWith<$Res> implements $ClientConfigCopyWith<$Res> {
  factory _$ClientConfigCopyWith(_ClientConfig value, $Res Function(_ClientConfig) _then) = __$ClientConfigCopyWithImpl;
@override @useResult
$Res call({
 String taskdbPath, SyncConfig syncConfig, AuthConfig authConfig, bool debugLogging, bool autoSyncOnStartup, bool autoSyncOnTaskChange, int syncIntervalMinutes, int maxHistorySize, bool encryptAtRest
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
@override @pragma('vm:prefer-inline') $Res call({Object? taskdbPath = null,Object? syncConfig = null,Object? authConfig = null,Object? debugLogging = null,Object? autoSyncOnStartup = null,Object? autoSyncOnTaskChange = null,Object? syncIntervalMinutes = null,Object? maxHistorySize = null,Object? encryptAtRest = null,}) {
  return _then(_ClientConfig(
taskdbPath: null == taskdbPath ? _self.taskdbPath : taskdbPath // ignore: cast_nullable_to_non_nullable
as String,syncConfig: null == syncConfig ? _self.syncConfig : syncConfig // ignore: cast_nullable_to_non_nullable
as SyncConfig,authConfig: null == authConfig ? _self.authConfig : authConfig // ignore: cast_nullable_to_non_nullable
as AuthConfig,debugLogging: null == debugLogging ? _self.debugLogging : debugLogging // ignore: cast_nullable_to_non_nullable
as bool,autoSyncOnStartup: null == autoSyncOnStartup ? _self.autoSyncOnStartup : autoSyncOnStartup // ignore: cast_nullable_to_non_nullable
as bool,autoSyncOnTaskChange: null == autoSyncOnTaskChange ? _self.autoSyncOnTaskChange : autoSyncOnTaskChange // ignore: cast_nullable_to_non_nullable
as bool,syncIntervalMinutes: null == syncIntervalMinutes ? _self.syncIntervalMinutes : syncIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,maxHistorySize: null == maxHistorySize ? _self.maxHistorySize : maxHistorySize // ignore: cast_nullable_to_non_nullable
as int,encryptAtRest: null == encryptAtRest ? _self.encryptAtRest : encryptAtRest // ignore: cast_nullable_to_non_nullable
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
