// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskParams {

/// Task description (required).
@Assert('description.trim().isNotEmpty') String get description;/// Initial task status (default: pending).
 TaskStatus get status;/// Task priority (default: none).
 TaskPriority get priority;/// Project name; stored as the conventional `project` UDA.
 String? get project;/// User tags. Replaced wholesale on update.
 List<String> get tags;/// UUIDs of tasks this task depends on. Replaced wholesale on update.
 List<String> get depends;/// Due date.
 DateTime? get due;/// Wait-until date (task is hidden until this date).
 DateTime? get wait;/// Scheduled-start date; stored as the conventional `scheduled` UDA.
 DateTime? get scheduled;/// Until/expiry date; stored as the conventional `until` UDA.
 DateTime? get until;/// Creation timestamp. Backend-managed when omitted; pass an explicit
/// value only when re-importing a task with a known entry date.
 DateTime? get entry;/// Completion/deletion timestamp. Normally derived from status changes;
/// an explicit value pins it.
 DateTime? get end;/// Recurrence rule/duration string (e.g. `"weekly"`); stored as the
/// conventional `recur` UDA.
 String? get recur;/// Annotations for the task, oldest-first.
///
/// Always sent as a concrete list on the wire: a populated list replaces
/// the stored annotations wholesale; an empty list explicitly clears all
/// stored annotations. [fromTask] copies the loaded task's annotations in,
/// so a plain load → edit → save round-trips them unchanged.
 List<Annotation> get annotations;/// Arbitrary user-defined attributes.
///
/// Keys `scheduled`, `until` and `recur` are ignored on write (the
/// dedicated fields own them); use those fields instead.
 Map<String, String> get udas;
/// Create a copy of TaskParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskParamsCopyWith<TaskParams> get copyWith => _$TaskParamsCopyWithImpl<TaskParams>(this as TaskParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskParams&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.project, project) || other.project == project)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.depends, depends)&&(identical(other.due, due) || other.due == due)&&(identical(other.wait, wait) || other.wait == wait)&&(identical(other.scheduled, scheduled) || other.scheduled == scheduled)&&(identical(other.until, until) || other.until == until)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.end, end) || other.end == end)&&(identical(other.recur, recur) || other.recur == recur)&&const DeepCollectionEquality().equals(other.annotations, annotations)&&const DeepCollectionEquality().equals(other.udas, udas));
}


@override
int get hashCode => Object.hash(runtimeType,description,status,priority,project,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(depends),due,wait,scheduled,until,entry,end,recur,const DeepCollectionEquality().hash(annotations),const DeepCollectionEquality().hash(udas));

@override
String toString() {
  return 'TaskParams(description: $description, status: $status, priority: $priority, project: $project, tags: $tags, depends: $depends, due: $due, wait: $wait, scheduled: $scheduled, until: $until, entry: $entry, end: $end, recur: $recur, annotations: $annotations, udas: $udas)';
}


}

/// @nodoc
abstract mixin class $TaskParamsCopyWith<$Res>  {
  factory $TaskParamsCopyWith(TaskParams value, $Res Function(TaskParams) _then) = _$TaskParamsCopyWithImpl;
@useResult
$Res call({
@Assert('description.trim().isNotEmpty') String description, TaskStatus status, TaskPriority priority, String? project, List<String> tags, List<String> depends, DateTime? due, DateTime? wait, DateTime? scheduled, DateTime? until, DateTime? entry, DateTime? end, String? recur, List<Annotation> annotations, Map<String, String> udas
});




}
/// @nodoc
class _$TaskParamsCopyWithImpl<$Res>
    implements $TaskParamsCopyWith<$Res> {
  _$TaskParamsCopyWithImpl(this._self, this._then);

  final TaskParams _self;
  final $Res Function(TaskParams) _then;

/// Create a copy of TaskParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? status = null,Object? priority = null,Object? project = freezed,Object? tags = null,Object? depends = null,Object? due = freezed,Object? wait = freezed,Object? scheduled = freezed,Object? until = freezed,Object? entry = freezed,Object? end = freezed,Object? recur = freezed,Object? annotations = null,Object? udas = null,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,depends: null == depends ? _self.depends : depends // ignore: cast_nullable_to_non_nullable
as List<String>,due: freezed == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as DateTime?,wait: freezed == wait ? _self.wait : wait // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduled: freezed == scheduled ? _self.scheduled : scheduled // ignore: cast_nullable_to_non_nullable
as DateTime?,until: freezed == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as DateTime?,entry: freezed == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as DateTime?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,recur: freezed == recur ? _self.recur : recur // ignore: cast_nullable_to_non_nullable
as String?,annotations: null == annotations ? _self.annotations : annotations // ignore: cast_nullable_to_non_nullable
as List<Annotation>,udas: null == udas ? _self.udas : udas // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskParams].
extension TaskParamsPatterns on TaskParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskParams value)  $default,){
final _that = this;
switch (_that) {
case _TaskParams():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskParams value)?  $default,){
final _that = this;
switch (_that) {
case _TaskParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@Assert('description.trim().isNotEmpty')  String description,  TaskStatus status,  TaskPriority priority,  String? project,  List<String> tags,  List<String> depends,  DateTime? due,  DateTime? wait,  DateTime? scheduled,  DateTime? until,  DateTime? entry,  DateTime? end,  String? recur,  List<Annotation> annotations,  Map<String, String> udas)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskParams() when $default != null:
return $default(_that.description,_that.status,_that.priority,_that.project,_that.tags,_that.depends,_that.due,_that.wait,_that.scheduled,_that.until,_that.entry,_that.end,_that.recur,_that.annotations,_that.udas);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@Assert('description.trim().isNotEmpty')  String description,  TaskStatus status,  TaskPriority priority,  String? project,  List<String> tags,  List<String> depends,  DateTime? due,  DateTime? wait,  DateTime? scheduled,  DateTime? until,  DateTime? entry,  DateTime? end,  String? recur,  List<Annotation> annotations,  Map<String, String> udas)  $default,) {final _that = this;
switch (_that) {
case _TaskParams():
return $default(_that.description,_that.status,_that.priority,_that.project,_that.tags,_that.depends,_that.due,_that.wait,_that.scheduled,_that.until,_that.entry,_that.end,_that.recur,_that.annotations,_that.udas);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@Assert('description.trim().isNotEmpty')  String description,  TaskStatus status,  TaskPriority priority,  String? project,  List<String> tags,  List<String> depends,  DateTime? due,  DateTime? wait,  DateTime? scheduled,  DateTime? until,  DateTime? entry,  DateTime? end,  String? recur,  List<Annotation> annotations,  Map<String, String> udas)?  $default,) {final _that = this;
switch (_that) {
case _TaskParams() when $default != null:
return $default(_that.description,_that.status,_that.priority,_that.project,_that.tags,_that.depends,_that.due,_that.wait,_that.scheduled,_that.until,_that.entry,_that.end,_that.recur,_that.annotations,_that.udas);case _:
  return null;

}
}

}

/// @nodoc


class _TaskParams extends TaskParams {
  const _TaskParams({@Assert('description.trim().isNotEmpty') required this.description, this.status = TaskStatus.pending, this.priority = TaskPriority.none, this.project, final  List<String> tags = const [], final  List<String> depends = const [], this.due, this.wait, this.scheduled, this.until, this.entry, this.end, this.recur, final  List<Annotation> annotations = const [], final  Map<String, String> udas = const {}}): _tags = tags,_depends = depends,_annotations = annotations,_udas = udas,super._();
  

/// Task description (required).
@override@Assert('description.trim().isNotEmpty') final  String description;
/// Initial task status (default: pending).
@override@JsonKey() final  TaskStatus status;
/// Task priority (default: none).
@override@JsonKey() final  TaskPriority priority;
/// Project name; stored as the conventional `project` UDA.
@override final  String? project;
/// User tags. Replaced wholesale on update.
 final  List<String> _tags;
/// User tags. Replaced wholesale on update.
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// UUIDs of tasks this task depends on. Replaced wholesale on update.
 final  List<String> _depends;
/// UUIDs of tasks this task depends on. Replaced wholesale on update.
@override@JsonKey() List<String> get depends {
  if (_depends is EqualUnmodifiableListView) return _depends;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_depends);
}

/// Due date.
@override final  DateTime? due;
/// Wait-until date (task is hidden until this date).
@override final  DateTime? wait;
/// Scheduled-start date; stored as the conventional `scheduled` UDA.
@override final  DateTime? scheduled;
/// Until/expiry date; stored as the conventional `until` UDA.
@override final  DateTime? until;
/// Creation timestamp. Backend-managed when omitted; pass an explicit
/// value only when re-importing a task with a known entry date.
@override final  DateTime? entry;
/// Completion/deletion timestamp. Normally derived from status changes;
/// an explicit value pins it.
@override final  DateTime? end;
/// Recurrence rule/duration string (e.g. `"weekly"`); stored as the
/// conventional `recur` UDA.
@override final  String? recur;
/// Annotations for the task, oldest-first.
///
/// Always sent as a concrete list on the wire: a populated list replaces
/// the stored annotations wholesale; an empty list explicitly clears all
/// stored annotations. [fromTask] copies the loaded task's annotations in,
/// so a plain load → edit → save round-trips them unchanged.
 final  List<Annotation> _annotations;
/// Annotations for the task, oldest-first.
///
/// Always sent as a concrete list on the wire: a populated list replaces
/// the stored annotations wholesale; an empty list explicitly clears all
/// stored annotations. [fromTask] copies the loaded task's annotations in,
/// so a plain load → edit → save round-trips them unchanged.
@override@JsonKey() List<Annotation> get annotations {
  if (_annotations is EqualUnmodifiableListView) return _annotations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_annotations);
}

/// Arbitrary user-defined attributes.
///
/// Keys `scheduled`, `until` and `recur` are ignored on write (the
/// dedicated fields own them); use those fields instead.
 final  Map<String, String> _udas;
/// Arbitrary user-defined attributes.
///
/// Keys `scheduled`, `until` and `recur` are ignored on write (the
/// dedicated fields own them); use those fields instead.
@override@JsonKey() Map<String, String> get udas {
  if (_udas is EqualUnmodifiableMapView) return _udas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_udas);
}


/// Create a copy of TaskParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskParamsCopyWith<_TaskParams> get copyWith => __$TaskParamsCopyWithImpl<_TaskParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskParams&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.project, project) || other.project == project)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._depends, _depends)&&(identical(other.due, due) || other.due == due)&&(identical(other.wait, wait) || other.wait == wait)&&(identical(other.scheduled, scheduled) || other.scheduled == scheduled)&&(identical(other.until, until) || other.until == until)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.end, end) || other.end == end)&&(identical(other.recur, recur) || other.recur == recur)&&const DeepCollectionEquality().equals(other._annotations, _annotations)&&const DeepCollectionEquality().equals(other._udas, _udas));
}


@override
int get hashCode => Object.hash(runtimeType,description,status,priority,project,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_depends),due,wait,scheduled,until,entry,end,recur,const DeepCollectionEquality().hash(_annotations),const DeepCollectionEquality().hash(_udas));

@override
String toString() {
  return 'TaskParams(description: $description, status: $status, priority: $priority, project: $project, tags: $tags, depends: $depends, due: $due, wait: $wait, scheduled: $scheduled, until: $until, entry: $entry, end: $end, recur: $recur, annotations: $annotations, udas: $udas)';
}


}

/// @nodoc
abstract mixin class _$TaskParamsCopyWith<$Res> implements $TaskParamsCopyWith<$Res> {
  factory _$TaskParamsCopyWith(_TaskParams value, $Res Function(_TaskParams) _then) = __$TaskParamsCopyWithImpl;
@override @useResult
$Res call({
@Assert('description.trim().isNotEmpty') String description, TaskStatus status, TaskPriority priority, String? project, List<String> tags, List<String> depends, DateTime? due, DateTime? wait, DateTime? scheduled, DateTime? until, DateTime? entry, DateTime? end, String? recur, List<Annotation> annotations, Map<String, String> udas
});




}
/// @nodoc
class __$TaskParamsCopyWithImpl<$Res>
    implements _$TaskParamsCopyWith<$Res> {
  __$TaskParamsCopyWithImpl(this._self, this._then);

  final _TaskParams _self;
  final $Res Function(_TaskParams) _then;

/// Create a copy of TaskParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? status = null,Object? priority = null,Object? project = freezed,Object? tags = null,Object? depends = null,Object? due = freezed,Object? wait = freezed,Object? scheduled = freezed,Object? until = freezed,Object? entry = freezed,Object? end = freezed,Object? recur = freezed,Object? annotations = null,Object? udas = null,}) {
  return _then(_TaskParams(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,depends: null == depends ? _self._depends : depends // ignore: cast_nullable_to_non_nullable
as List<String>,due: freezed == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as DateTime?,wait: freezed == wait ? _self.wait : wait // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduled: freezed == scheduled ? _self.scheduled : scheduled // ignore: cast_nullable_to_non_nullable
as DateTime?,until: freezed == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as DateTime?,entry: freezed == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as DateTime?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,recur: freezed == recur ? _self.recur : recur // ignore: cast_nullable_to_non_nullable
as String?,annotations: null == annotations ? _self._annotations : annotations // ignore: cast_nullable_to_non_nullable
as List<Annotation>,udas: null == udas ? _self._udas : udas // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
