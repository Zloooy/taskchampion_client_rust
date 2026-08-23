// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'annotation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Annotation {

/// Timestamp of when the annotation was added (UTC).
 DateTime get entry;/// The free-form annotation text.
 String get description;
/// Create a copy of Annotation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnotationCopyWith<Annotation> get copyWith => _$AnnotationCopyWithImpl<Annotation>(this as Annotation, _$identity);

  /// Serializes this Annotation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Annotation&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,entry,description);

@override
String toString() {
  return 'Annotation(entry: $entry, description: $description)';
}


}

/// @nodoc
abstract mixin class $AnnotationCopyWith<$Res>  {
  factory $AnnotationCopyWith(Annotation value, $Res Function(Annotation) _then) = _$AnnotationCopyWithImpl;
@useResult
$Res call({
 DateTime entry, String description
});




}
/// @nodoc
class _$AnnotationCopyWithImpl<$Res>
    implements $AnnotationCopyWith<$Res> {
  _$AnnotationCopyWithImpl(this._self, this._then);

  final Annotation _self;
  final $Res Function(Annotation) _then;

/// Create a copy of Annotation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entry = null,Object? description = null,}) {
  return _then(_self.copyWith(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Annotation].
extension AnnotationPatterns on Annotation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Annotation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Annotation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Annotation value)  $default,){
final _that = this;
switch (_that) {
case _Annotation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Annotation value)?  $default,){
final _that = this;
switch (_that) {
case _Annotation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime entry,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Annotation() when $default != null:
return $default(_that.entry,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime entry,  String description)  $default,) {final _that = this;
switch (_that) {
case _Annotation():
return $default(_that.entry,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime entry,  String description)?  $default,) {final _that = this;
switch (_that) {
case _Annotation() when $default != null:
return $default(_that.entry,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Annotation implements Annotation {
  const _Annotation({required this.entry, required this.description});
  factory _Annotation.fromJson(Map<String, dynamic> json) => _$AnnotationFromJson(json);

/// Timestamp of when the annotation was added (UTC).
@override final  DateTime entry;
/// The free-form annotation text.
@override final  String description;

/// Create a copy of Annotation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnotationCopyWith<_Annotation> get copyWith => __$AnnotationCopyWithImpl<_Annotation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnnotationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Annotation&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,entry,description);

@override
String toString() {
  return 'Annotation(entry: $entry, description: $description)';
}


}

/// @nodoc
abstract mixin class _$AnnotationCopyWith<$Res> implements $AnnotationCopyWith<$Res> {
  factory _$AnnotationCopyWith(_Annotation value, $Res Function(_Annotation) _then) = __$AnnotationCopyWithImpl;
@override @useResult
$Res call({
 DateTime entry, String description
});




}
/// @nodoc
class __$AnnotationCopyWithImpl<$Res>
    implements _$AnnotationCopyWith<$Res> {
  __$AnnotationCopyWithImpl(this._self, this._then);

  final _Annotation _self;
  final $Res Function(_Annotation) _then;

/// Create a copy of Annotation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entry = null,Object? description = null,}) {
  return _then(_Annotation(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
