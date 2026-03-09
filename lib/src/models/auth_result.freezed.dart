// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthResult {

/// Whether authentication was successful
 bool get success;/// Error message if authentication failed
 String? get errorMessage;/// Server information
 String? get serverUrl;/// Client ID that was authenticated
 String? get clientId;/// Whether the client is allowed to sync
 bool get canSync;/// Server version information
 String? get serverVersion;/// Timestamp when authentication completed
 DateTime? get authenticatedAt;
/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResultCopyWith<AuthResult> get copyWith => _$AuthResultCopyWithImpl<AuthResult>(this as AuthResult, _$identity);

  /// Serializes this AuthResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResult&&(identical(other.success, success) || other.success == success)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.canSync, canSync) || other.canSync == canSync)&&(identical(other.serverVersion, serverVersion) || other.serverVersion == serverVersion)&&(identical(other.authenticatedAt, authenticatedAt) || other.authenticatedAt == authenticatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,errorMessage,serverUrl,clientId,canSync,serverVersion,authenticatedAt);

@override
String toString() {
  return 'AuthResult(success: $success, errorMessage: $errorMessage, serverUrl: $serverUrl, clientId: $clientId, canSync: $canSync, serverVersion: $serverVersion, authenticatedAt: $authenticatedAt)';
}


}

/// @nodoc
abstract mixin class $AuthResultCopyWith<$Res>  {
  factory $AuthResultCopyWith(AuthResult value, $Res Function(AuthResult) _then) = _$AuthResultCopyWithImpl;
@useResult
$Res call({
 bool success, String? errorMessage, String? serverUrl, String? clientId, bool canSync, String? serverVersion, DateTime? authenticatedAt
});




}
/// @nodoc
class _$AuthResultCopyWithImpl<$Res>
    implements $AuthResultCopyWith<$Res> {
  _$AuthResultCopyWithImpl(this._self, this._then);

  final AuthResult _self;
  final $Res Function(AuthResult) _then;

/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? errorMessage = freezed,Object? serverUrl = freezed,Object? clientId = freezed,Object? canSync = null,Object? serverVersion = freezed,Object? authenticatedAt = freezed,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,serverUrl: freezed == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,canSync: null == canSync ? _self.canSync : canSync // ignore: cast_nullable_to_non_nullable
as bool,serverVersion: freezed == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as String?,authenticatedAt: freezed == authenticatedAt ? _self.authenticatedAt : authenticatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthResult].
extension AuthResultPatterns on AuthResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthResult value)  $default,){
final _that = this;
switch (_that) {
case _AuthResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthResult value)?  $default,){
final _that = this;
switch (_that) {
case _AuthResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String? errorMessage,  String? serverUrl,  String? clientId,  bool canSync,  String? serverVersion,  DateTime? authenticatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthResult() when $default != null:
return $default(_that.success,_that.errorMessage,_that.serverUrl,_that.clientId,_that.canSync,_that.serverVersion,_that.authenticatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String? errorMessage,  String? serverUrl,  String? clientId,  bool canSync,  String? serverVersion,  DateTime? authenticatedAt)  $default,) {final _that = this;
switch (_that) {
case _AuthResult():
return $default(_that.success,_that.errorMessage,_that.serverUrl,_that.clientId,_that.canSync,_that.serverVersion,_that.authenticatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String? errorMessage,  String? serverUrl,  String? clientId,  bool canSync,  String? serverVersion,  DateTime? authenticatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AuthResult() when $default != null:
return $default(_that.success,_that.errorMessage,_that.serverUrl,_that.clientId,_that.canSync,_that.serverVersion,_that.authenticatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthResult implements AuthResult {
  const _AuthResult({required this.success, this.errorMessage, this.serverUrl, this.clientId, this.canSync = false, this.serverVersion, this.authenticatedAt});
  factory _AuthResult.fromJson(Map<String, dynamic> json) => _$AuthResultFromJson(json);

/// Whether authentication was successful
@override final  bool success;
/// Error message if authentication failed
@override final  String? errorMessage;
/// Server information
@override final  String? serverUrl;
/// Client ID that was authenticated
@override final  String? clientId;
/// Whether the client is allowed to sync
@override@JsonKey() final  bool canSync;
/// Server version information
@override final  String? serverVersion;
/// Timestamp when authentication completed
@override final  DateTime? authenticatedAt;

/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthResultCopyWith<_AuthResult> get copyWith => __$AuthResultCopyWithImpl<_AuthResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthResult&&(identical(other.success, success) || other.success == success)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.canSync, canSync) || other.canSync == canSync)&&(identical(other.serverVersion, serverVersion) || other.serverVersion == serverVersion)&&(identical(other.authenticatedAt, authenticatedAt) || other.authenticatedAt == authenticatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,errorMessage,serverUrl,clientId,canSync,serverVersion,authenticatedAt);

@override
String toString() {
  return 'AuthResult(success: $success, errorMessage: $errorMessage, serverUrl: $serverUrl, clientId: $clientId, canSync: $canSync, serverVersion: $serverVersion, authenticatedAt: $authenticatedAt)';
}


}

/// @nodoc
abstract mixin class _$AuthResultCopyWith<$Res> implements $AuthResultCopyWith<$Res> {
  factory _$AuthResultCopyWith(_AuthResult value, $Res Function(_AuthResult) _then) = __$AuthResultCopyWithImpl;
@override @useResult
$Res call({
 bool success, String? errorMessage, String? serverUrl, String? clientId, bool canSync, String? serverVersion, DateTime? authenticatedAt
});




}
/// @nodoc
class __$AuthResultCopyWithImpl<$Res>
    implements _$AuthResultCopyWith<$Res> {
  __$AuthResultCopyWithImpl(this._self, this._then);

  final _AuthResult _self;
  final $Res Function(_AuthResult) _then;

/// Create a copy of AuthResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? errorMessage = freezed,Object? serverUrl = freezed,Object? clientId = freezed,Object? canSync = null,Object? serverVersion = freezed,Object? authenticatedAt = freezed,}) {
  return _then(_AuthResult(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,serverUrl: freezed == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,canSync: null == canSync ? _self.canSync : canSync // ignore: cast_nullable_to_non_nullable
as bool,serverVersion: freezed == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as String?,authenticatedAt: freezed == authenticatedAt ? _self.authenticatedAt : authenticatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
