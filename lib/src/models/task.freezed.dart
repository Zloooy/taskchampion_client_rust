// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Task {

/// Unique identifier for the task (UUID v4)
 String get uuid;/// Task description
 String get description;/// Current task status
/// All unknown values fallback to pending
@JsonKey(unknownEnumValue: TaskStatus.pending) TaskStatus get status;/// Task priority (high, medium, low, or none)
/// All unknown values fallback to none
@JsonKey(unknownEnumValue: TaskPriority.none) TaskPriority get priority;/// Project name (optional) - stored as UDA in TaskChampion
 String? get project;/// List of tags associated with the task
 List<String> get tags;/// Due date (optional)
 DateTime? get due;/// Wait until date (task is hidden until this date)
 DateTime? get wait;/// Scheduled date (optional) - stored as UDA in TaskChampion
 DateTime? get scheduled;/// Until date (task is deleted after this date) - stored as UDA in TaskChampion
 DateTime? get until;/// Task creation timestamp
 DateTime get entry;/// Last modification timestamp
 DateTime? get modified;/// End/completion timestamp
 DateTime? get end;/// User Defined Attributes (UDAs)
/// This includes all custom attributes that are not part of the standard TaskChampion data model
/// Standard fields like 'project', 'scheduled', 'until', 'parent', 'urgency' are also stored as UDAs
 Map<String, String> get udas;/// Urgency score (stored as UDA in TaskChampion, calculated by clients)
 double? get urgency;/// Parent task UUID (for subtasks) - stored as UDA in TaskChampion
 String? get parent;/// List of dependent task UUIDs
 List<String> get depends;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.project, project) || other.project == project)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.due, due) || other.due == due)&&(identical(other.wait, wait) || other.wait == wait)&&(identical(other.scheduled, scheduled) || other.scheduled == scheduled)&&(identical(other.until, until) || other.until == until)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.modified, modified) || other.modified == modified)&&(identical(other.end, end) || other.end == end)&&const DeepCollectionEquality().equals(other.udas, udas)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.parent, parent) || other.parent == parent)&&const DeepCollectionEquality().equals(other.depends, depends));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,description,status,priority,project,const DeepCollectionEquality().hash(tags),due,wait,scheduled,until,entry,modified,end,const DeepCollectionEquality().hash(udas),urgency,parent,const DeepCollectionEquality().hash(depends));

@override
String toString() {
  return 'Task(uuid: $uuid, description: $description, status: $status, priority: $priority, project: $project, tags: $tags, due: $due, wait: $wait, scheduled: $scheduled, until: $until, entry: $entry, modified: $modified, end: $end, udas: $udas, urgency: $urgency, parent: $parent, depends: $depends)';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 String uuid, String description,@JsonKey(unknownEnumValue: TaskStatus.pending) TaskStatus status,@JsonKey(unknownEnumValue: TaskPriority.none) TaskPriority priority, String? project, List<String> tags, DateTime? due, DateTime? wait, DateTime? scheduled, DateTime? until, DateTime entry, DateTime? modified, DateTime? end, Map<String, String> udas, double? urgency, String? parent, List<String> depends
});




}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? description = null,Object? status = null,Object? priority = null,Object? project = freezed,Object? tags = null,Object? due = freezed,Object? wait = freezed,Object? scheduled = freezed,Object? until = freezed,Object? entry = null,Object? modified = freezed,Object? end = freezed,Object? udas = null,Object? urgency = freezed,Object? parent = freezed,Object? depends = null,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,due: freezed == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as DateTime?,wait: freezed == wait ? _self.wait : wait // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduled: freezed == scheduled ? _self.scheduled : scheduled // ignore: cast_nullable_to_non_nullable
as DateTime?,until: freezed == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as DateTime?,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as DateTime,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,udas: null == udas ? _self.udas : udas // ignore: cast_nullable_to_non_nullable
as Map<String, String>,urgency: freezed == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as double?,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as String?,depends: null == depends ? _self.depends : depends // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String description, @JsonKey(unknownEnumValue: TaskStatus.pending)  TaskStatus status, @JsonKey(unknownEnumValue: TaskPriority.none)  TaskPriority priority,  String? project,  List<String> tags,  DateTime? due,  DateTime? wait,  DateTime? scheduled,  DateTime? until,  DateTime entry,  DateTime? modified,  DateTime? end,  Map<String, String> udas,  double? urgency,  String? parent,  List<String> depends)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.uuid,_that.description,_that.status,_that.priority,_that.project,_that.tags,_that.due,_that.wait,_that.scheduled,_that.until,_that.entry,_that.modified,_that.end,_that.udas,_that.urgency,_that.parent,_that.depends);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String description, @JsonKey(unknownEnumValue: TaskStatus.pending)  TaskStatus status, @JsonKey(unknownEnumValue: TaskPriority.none)  TaskPriority priority,  String? project,  List<String> tags,  DateTime? due,  DateTime? wait,  DateTime? scheduled,  DateTime? until,  DateTime entry,  DateTime? modified,  DateTime? end,  Map<String, String> udas,  double? urgency,  String? parent,  List<String> depends)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.uuid,_that.description,_that.status,_that.priority,_that.project,_that.tags,_that.due,_that.wait,_that.scheduled,_that.until,_that.entry,_that.modified,_that.end,_that.udas,_that.urgency,_that.parent,_that.depends);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String description, @JsonKey(unknownEnumValue: TaskStatus.pending)  TaskStatus status, @JsonKey(unknownEnumValue: TaskPriority.none)  TaskPriority priority,  String? project,  List<String> tags,  DateTime? due,  DateTime? wait,  DateTime? scheduled,  DateTime? until,  DateTime entry,  DateTime? modified,  DateTime? end,  Map<String, String> udas,  double? urgency,  String? parent,  List<String> depends)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.uuid,_that.description,_that.status,_that.priority,_that.project,_that.tags,_that.due,_that.wait,_that.scheduled,_that.until,_that.entry,_that.modified,_that.end,_that.udas,_that.urgency,_that.parent,_that.depends);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Task implements Task {
  const _Task({required this.uuid, required this.description, @JsonKey(unknownEnumValue: TaskStatus.pending) this.status = TaskStatus.pending, @JsonKey(unknownEnumValue: TaskPriority.none) this.priority = TaskPriority.none, this.project, final  List<String> tags = const [], this.due, this.wait, this.scheduled, this.until, required this.entry, this.modified, this.end, final  Map<String, String> udas = const {}, this.urgency, this.parent, final  List<String> depends = const []}): _tags = tags,_udas = udas,_depends = depends;
  factory _Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

/// Unique identifier for the task (UUID v4)
@override final  String uuid;
/// Task description
@override final  String description;
/// Current task status
/// All unknown values fallback to pending
@override@JsonKey(unknownEnumValue: TaskStatus.pending) final  TaskStatus status;
/// Task priority (high, medium, low, or none)
/// All unknown values fallback to none
@override@JsonKey(unknownEnumValue: TaskPriority.none) final  TaskPriority priority;
/// Project name (optional) - stored as UDA in TaskChampion
@override final  String? project;
/// List of tags associated with the task
 final  List<String> _tags;
/// List of tags associated with the task
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// Due date (optional)
@override final  DateTime? due;
/// Wait until date (task is hidden until this date)
@override final  DateTime? wait;
/// Scheduled date (optional) - stored as UDA in TaskChampion
@override final  DateTime? scheduled;
/// Until date (task is deleted after this date) - stored as UDA in TaskChampion
@override final  DateTime? until;
/// Task creation timestamp
@override final  DateTime entry;
/// Last modification timestamp
@override final  DateTime? modified;
/// End/completion timestamp
@override final  DateTime? end;
/// User Defined Attributes (UDAs)
/// This includes all custom attributes that are not part of the standard TaskChampion data model
/// Standard fields like 'project', 'scheduled', 'until', 'parent', 'urgency' are also stored as UDAs
 final  Map<String, String> _udas;
/// User Defined Attributes (UDAs)
/// This includes all custom attributes that are not part of the standard TaskChampion data model
/// Standard fields like 'project', 'scheduled', 'until', 'parent', 'urgency' are also stored as UDAs
@override@JsonKey() Map<String, String> get udas {
  if (_udas is EqualUnmodifiableMapView) return _udas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_udas);
}

/// Urgency score (stored as UDA in TaskChampion, calculated by clients)
@override final  double? urgency;
/// Parent task UUID (for subtasks) - stored as UDA in TaskChampion
@override final  String? parent;
/// List of dependent task UUIDs
 final  List<String> _depends;
/// List of dependent task UUIDs
@override@JsonKey() List<String> get depends {
  if (_depends is EqualUnmodifiableListView) return _depends;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_depends);
}


/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.project, project) || other.project == project)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.due, due) || other.due == due)&&(identical(other.wait, wait) || other.wait == wait)&&(identical(other.scheduled, scheduled) || other.scheduled == scheduled)&&(identical(other.until, until) || other.until == until)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.modified, modified) || other.modified == modified)&&(identical(other.end, end) || other.end == end)&&const DeepCollectionEquality().equals(other._udas, _udas)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.parent, parent) || other.parent == parent)&&const DeepCollectionEquality().equals(other._depends, _depends));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,description,status,priority,project,const DeepCollectionEquality().hash(_tags),due,wait,scheduled,until,entry,modified,end,const DeepCollectionEquality().hash(_udas),urgency,parent,const DeepCollectionEquality().hash(_depends));

@override
String toString() {
  return 'Task(uuid: $uuid, description: $description, status: $status, priority: $priority, project: $project, tags: $tags, due: $due, wait: $wait, scheduled: $scheduled, until: $until, entry: $entry, modified: $modified, end: $end, udas: $udas, urgency: $urgency, parent: $parent, depends: $depends)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String description,@JsonKey(unknownEnumValue: TaskStatus.pending) TaskStatus status,@JsonKey(unknownEnumValue: TaskPriority.none) TaskPriority priority, String? project, List<String> tags, DateTime? due, DateTime? wait, DateTime? scheduled, DateTime? until, DateTime entry, DateTime? modified, DateTime? end, Map<String, String> udas, double? urgency, String? parent, List<String> depends
});




}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? description = null,Object? status = null,Object? priority = null,Object? project = freezed,Object? tags = null,Object? due = freezed,Object? wait = freezed,Object? scheduled = freezed,Object? until = freezed,Object? entry = null,Object? modified = freezed,Object? end = freezed,Object? udas = null,Object? urgency = freezed,Object? parent = freezed,Object? depends = null,}) {
  return _then(_Task(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,due: freezed == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as DateTime?,wait: freezed == wait ? _self.wait : wait // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduled: freezed == scheduled ? _self.scheduled : scheduled // ignore: cast_nullable_to_non_nullable
as DateTime?,until: freezed == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as DateTime?,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as DateTime,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,udas: null == udas ? _self._udas : udas // ignore: cast_nullable_to_non_nullable
as Map<String, String>,urgency: freezed == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as double?,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as String?,depends: null == depends ? _self._depends : depends // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
