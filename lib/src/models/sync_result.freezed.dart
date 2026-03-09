// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncResult {

/// Whether the sync was successful
 bool get success;/// Number of versions synced
 int get versionsSynced;/// Number of tasks added
 int get tasksAdded;/// Number of tasks updated
 int get tasksUpdated;/// Number of tasks deleted
 int get tasksDeleted;/// Error message if sync failed
 String? get errorMessage;/// Duration of the sync operation in milliseconds
 int? get durationMs;/// Timestamp when sync completed
 DateTime? get completedAt;/// Whether a snapshot was downloaded
 bool get snapshotDownloaded;/// Whether a snapshot was uploaded
 bool get snapshotUploaded;
/// Create a copy of SyncResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncResultCopyWith<SyncResult> get copyWith => _$SyncResultCopyWithImpl<SyncResult>(this as SyncResult, _$identity);

  /// Serializes this SyncResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncResult&&(identical(other.success, success) || other.success == success)&&(identical(other.versionsSynced, versionsSynced) || other.versionsSynced == versionsSynced)&&(identical(other.tasksAdded, tasksAdded) || other.tasksAdded == tasksAdded)&&(identical(other.tasksUpdated, tasksUpdated) || other.tasksUpdated == tasksUpdated)&&(identical(other.tasksDeleted, tasksDeleted) || other.tasksDeleted == tasksDeleted)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.snapshotDownloaded, snapshotDownloaded) || other.snapshotDownloaded == snapshotDownloaded)&&(identical(other.snapshotUploaded, snapshotUploaded) || other.snapshotUploaded == snapshotUploaded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,versionsSynced,tasksAdded,tasksUpdated,tasksDeleted,errorMessage,durationMs,completedAt,snapshotDownloaded,snapshotUploaded);

@override
String toString() {
  return 'SyncResult(success: $success, versionsSynced: $versionsSynced, tasksAdded: $tasksAdded, tasksUpdated: $tasksUpdated, tasksDeleted: $tasksDeleted, errorMessage: $errorMessage, durationMs: $durationMs, completedAt: $completedAt, snapshotDownloaded: $snapshotDownloaded, snapshotUploaded: $snapshotUploaded)';
}


}

/// @nodoc
abstract mixin class $SyncResultCopyWith<$Res>  {
  factory $SyncResultCopyWith(SyncResult value, $Res Function(SyncResult) _then) = _$SyncResultCopyWithImpl;
@useResult
$Res call({
 bool success, int versionsSynced, int tasksAdded, int tasksUpdated, int tasksDeleted, String? errorMessage, int? durationMs, DateTime? completedAt, bool snapshotDownloaded, bool snapshotUploaded
});




}
/// @nodoc
class _$SyncResultCopyWithImpl<$Res>
    implements $SyncResultCopyWith<$Res> {
  _$SyncResultCopyWithImpl(this._self, this._then);

  final SyncResult _self;
  final $Res Function(SyncResult) _then;

/// Create a copy of SyncResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? versionsSynced = null,Object? tasksAdded = null,Object? tasksUpdated = null,Object? tasksDeleted = null,Object? errorMessage = freezed,Object? durationMs = freezed,Object? completedAt = freezed,Object? snapshotDownloaded = null,Object? snapshotUploaded = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,versionsSynced: null == versionsSynced ? _self.versionsSynced : versionsSynced // ignore: cast_nullable_to_non_nullable
as int,tasksAdded: null == tasksAdded ? _self.tasksAdded : tasksAdded // ignore: cast_nullable_to_non_nullable
as int,tasksUpdated: null == tasksUpdated ? _self.tasksUpdated : tasksUpdated // ignore: cast_nullable_to_non_nullable
as int,tasksDeleted: null == tasksDeleted ? _self.tasksDeleted : tasksDeleted // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,snapshotDownloaded: null == snapshotDownloaded ? _self.snapshotDownloaded : snapshotDownloaded // ignore: cast_nullable_to_non_nullable
as bool,snapshotUploaded: null == snapshotUploaded ? _self.snapshotUploaded : snapshotUploaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncResult].
extension SyncResultPatterns on SyncResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncResult value)  $default,){
final _that = this;
switch (_that) {
case _SyncResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncResult value)?  $default,){
final _that = this;
switch (_that) {
case _SyncResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  int versionsSynced,  int tasksAdded,  int tasksUpdated,  int tasksDeleted,  String? errorMessage,  int? durationMs,  DateTime? completedAt,  bool snapshotDownloaded,  bool snapshotUploaded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncResult() when $default != null:
return $default(_that.success,_that.versionsSynced,_that.tasksAdded,_that.tasksUpdated,_that.tasksDeleted,_that.errorMessage,_that.durationMs,_that.completedAt,_that.snapshotDownloaded,_that.snapshotUploaded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  int versionsSynced,  int tasksAdded,  int tasksUpdated,  int tasksDeleted,  String? errorMessage,  int? durationMs,  DateTime? completedAt,  bool snapshotDownloaded,  bool snapshotUploaded)  $default,) {final _that = this;
switch (_that) {
case _SyncResult():
return $default(_that.success,_that.versionsSynced,_that.tasksAdded,_that.tasksUpdated,_that.tasksDeleted,_that.errorMessage,_that.durationMs,_that.completedAt,_that.snapshotDownloaded,_that.snapshotUploaded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  int versionsSynced,  int tasksAdded,  int tasksUpdated,  int tasksDeleted,  String? errorMessage,  int? durationMs,  DateTime? completedAt,  bool snapshotDownloaded,  bool snapshotUploaded)?  $default,) {final _that = this;
switch (_that) {
case _SyncResult() when $default != null:
return $default(_that.success,_that.versionsSynced,_that.tasksAdded,_that.tasksUpdated,_that.tasksDeleted,_that.errorMessage,_that.durationMs,_that.completedAt,_that.snapshotDownloaded,_that.snapshotUploaded);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncResult implements SyncResult {
  const _SyncResult({required this.success, this.versionsSynced = 0, this.tasksAdded = 0, this.tasksUpdated = 0, this.tasksDeleted = 0, this.errorMessage, this.durationMs, this.completedAt, this.snapshotDownloaded = false, this.snapshotUploaded = false});
  factory _SyncResult.fromJson(Map<String, dynamic> json) => _$SyncResultFromJson(json);

/// Whether the sync was successful
@override final  bool success;
/// Number of versions synced
@override@JsonKey() final  int versionsSynced;
/// Number of tasks added
@override@JsonKey() final  int tasksAdded;
/// Number of tasks updated
@override@JsonKey() final  int tasksUpdated;
/// Number of tasks deleted
@override@JsonKey() final  int tasksDeleted;
/// Error message if sync failed
@override final  String? errorMessage;
/// Duration of the sync operation in milliseconds
@override final  int? durationMs;
/// Timestamp when sync completed
@override final  DateTime? completedAt;
/// Whether a snapshot was downloaded
@override@JsonKey() final  bool snapshotDownloaded;
/// Whether a snapshot was uploaded
@override@JsonKey() final  bool snapshotUploaded;

/// Create a copy of SyncResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncResultCopyWith<_SyncResult> get copyWith => __$SyncResultCopyWithImpl<_SyncResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncResult&&(identical(other.success, success) || other.success == success)&&(identical(other.versionsSynced, versionsSynced) || other.versionsSynced == versionsSynced)&&(identical(other.tasksAdded, tasksAdded) || other.tasksAdded == tasksAdded)&&(identical(other.tasksUpdated, tasksUpdated) || other.tasksUpdated == tasksUpdated)&&(identical(other.tasksDeleted, tasksDeleted) || other.tasksDeleted == tasksDeleted)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.snapshotDownloaded, snapshotDownloaded) || other.snapshotDownloaded == snapshotDownloaded)&&(identical(other.snapshotUploaded, snapshotUploaded) || other.snapshotUploaded == snapshotUploaded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,versionsSynced,tasksAdded,tasksUpdated,tasksDeleted,errorMessage,durationMs,completedAt,snapshotDownloaded,snapshotUploaded);

@override
String toString() {
  return 'SyncResult(success: $success, versionsSynced: $versionsSynced, tasksAdded: $tasksAdded, tasksUpdated: $tasksUpdated, tasksDeleted: $tasksDeleted, errorMessage: $errorMessage, durationMs: $durationMs, completedAt: $completedAt, snapshotDownloaded: $snapshotDownloaded, snapshotUploaded: $snapshotUploaded)';
}


}

/// @nodoc
abstract mixin class _$SyncResultCopyWith<$Res> implements $SyncResultCopyWith<$Res> {
  factory _$SyncResultCopyWith(_SyncResult value, $Res Function(_SyncResult) _then) = __$SyncResultCopyWithImpl;
@override @useResult
$Res call({
 bool success, int versionsSynced, int tasksAdded, int tasksUpdated, int tasksDeleted, String? errorMessage, int? durationMs, DateTime? completedAt, bool snapshotDownloaded, bool snapshotUploaded
});




}
/// @nodoc
class __$SyncResultCopyWithImpl<$Res>
    implements _$SyncResultCopyWith<$Res> {
  __$SyncResultCopyWithImpl(this._self, this._then);

  final _SyncResult _self;
  final $Res Function(_SyncResult) _then;

/// Create a copy of SyncResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? versionsSynced = null,Object? tasksAdded = null,Object? tasksUpdated = null,Object? tasksDeleted = null,Object? errorMessage = freezed,Object? durationMs = freezed,Object? completedAt = freezed,Object? snapshotDownloaded = null,Object? snapshotUploaded = null,}) {
  return _then(_SyncResult(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,versionsSynced: null == versionsSynced ? _self.versionsSynced : versionsSynced // ignore: cast_nullable_to_non_nullable
as int,tasksAdded: null == tasksAdded ? _self.tasksAdded : tasksAdded // ignore: cast_nullable_to_non_nullable
as int,tasksUpdated: null == tasksUpdated ? _self.tasksUpdated : tasksUpdated // ignore: cast_nullable_to_non_nullable
as int,tasksDeleted: null == tasksDeleted ? _self.tasksDeleted : tasksDeleted // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,snapshotDownloaded: null == snapshotDownloaded ? _self.snapshotDownloaded : snapshotDownloaded // ignore: cast_nullable_to_non_nullable
as bool,snapshotUploaded: null == snapshotUploaded ? _self.snapshotUploaded : snapshotUploaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
