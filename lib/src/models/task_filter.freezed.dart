// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
FilterExpression _$FilterExpressionFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'AndGroup':
          return _FilterExpressionAndGroup.fromJson(
            json
          );
                case 'OrGroup':
          return _FilterExpressionOrGroup.fromJson(
            json
          );
                case 'XorGroup':
          return _FilterExpressionXorGroup.fromJson(
            json
          );
                case 'Not':
          return _FilterExpressionNot.fromJson(
            json
          );
                case 'Tag':
          return _FilterExpressionTag.fromJson(
            json
          );
                case 'VirtualTag':
          return _FilterExpressionVirtualTag.fromJson(
            json
          );
                case 'EqualsFilter':
          return _FilterExpressionEquals.fromJson(
            json
          );
                case 'NotEqualsFilter':
          return _FilterExpressionNotEquals.fromJson(
            json
          );
                case 'InFilter':
          return _FilterExpressionInValues.fromJson(
            json
          );
                case 'NotInFilter':
          return _FilterExpressionNotInValues.fromJson(
            json
          );
                case 'ContainsFilter':
          return _FilterExpressionContains.fromJson(
            json
          );
                case 'NotContainsFilter':
          return _FilterExpressionNotContains.fromJson(
            json
          );
                case 'StartsWithFilter':
          return _FilterExpressionStartsWith.fromJson(
            json
          );
                case 'EndsWithFilter':
          return _FilterExpressionEndsWith.fromJson(
            json
          );
                case 'WordFilter':
          return _FilterExpressionWord.fromJson(
            json
          );
                case 'NoWordFilter':
          return _FilterExpressionNoWord.fromJson(
            json
          );
                case 'RegexFilter':
          return _FilterExpressionRegex.fromJson(
            json
          );
                case 'NoneFilter':
          return _FilterExpressionNone.fromJson(
            json
          );
                case 'AnyFilter':
          return _FilterExpressionAny.fromJson(
            json
          );
                case 'DateBeforeFilter':
          return _FilterExpressionDateBefore.fromJson(
            json
          );
                case 'DateAfterFilter':
          return _FilterExpressionDateAfter.fromJson(
            json
          );
                case 'DateByFilter':
          return _FilterExpressionDateBy.fromJson(
            json
          );
                case 'DateFromFilter':
          return _FilterExpressionDateFrom.fromJson(
            json
          );
                case 'DateToFilter':
          return _FilterExpressionDateTo.fromJson(
            json
          );
                case 'LessThanFilter':
          return _FilterExpressionLessThan.fromJson(
            json
          );
                case 'LessThanOrEqualFilter':
          return _FilterExpressionLessThanOrEqual.fromJson(
            json
          );
                case 'GreaterThanFilter':
          return _FilterExpressionGreaterThan.fromJson(
            json
          );
                case 'GreaterThanOrEqualFilter':
          return _FilterExpressionGreaterThanOrEqual.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'FilterExpression',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$FilterExpression {



  /// Serializes this FilterExpression to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterExpression);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FilterExpression()';
}


}

/// @nodoc
class $FilterExpressionCopyWith<$Res>  {
$FilterExpressionCopyWith(FilterExpression _, $Res Function(FilterExpression) __);
}


/// Adds pattern-matching-related methods to [FilterExpression].
extension FilterExpressionPatterns on FilterExpression {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _FilterExpressionAndGroup value)?  andGroup,TResult Function( _FilterExpressionOrGroup value)?  orGroup,TResult Function( _FilterExpressionXorGroup value)?  xorGroup,TResult Function( _FilterExpressionNot value)?  not,TResult Function( _FilterExpressionTag value)?  tag,TResult Function( _FilterExpressionVirtualTag value)?  virtualTag,TResult Function( _FilterExpressionEquals value)?  equals,TResult Function( _FilterExpressionNotEquals value)?  notEquals,TResult Function( _FilterExpressionInValues value)?  inValues,TResult Function( _FilterExpressionNotInValues value)?  notInValues,TResult Function( _FilterExpressionContains value)?  contains,TResult Function( _FilterExpressionNotContains value)?  notContains,TResult Function( _FilterExpressionStartsWith value)?  startsWith,TResult Function( _FilterExpressionEndsWith value)?  endsWith,TResult Function( _FilterExpressionWord value)?  word,TResult Function( _FilterExpressionNoWord value)?  noWord,TResult Function( _FilterExpressionRegex value)?  regex,TResult Function( _FilterExpressionNone value)?  none,TResult Function( _FilterExpressionAny value)?  any,TResult Function( _FilterExpressionDateBefore value)?  dateBefore,TResult Function( _FilterExpressionDateAfter value)?  dateAfter,TResult Function( _FilterExpressionDateBy value)?  dateBy,TResult Function( _FilterExpressionDateFrom value)?  dateFrom,TResult Function( _FilterExpressionDateTo value)?  dateTo,TResult Function( _FilterExpressionLessThan value)?  lessThan,TResult Function( _FilterExpressionLessThanOrEqual value)?  lessThanOrEqual,TResult Function( _FilterExpressionGreaterThan value)?  greaterThan,TResult Function( _FilterExpressionGreaterThanOrEqual value)?  greaterThanOrEqual,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FilterExpressionAndGroup() when andGroup != null:
return andGroup(_that);case _FilterExpressionOrGroup() when orGroup != null:
return orGroup(_that);case _FilterExpressionXorGroup() when xorGroup != null:
return xorGroup(_that);case _FilterExpressionNot() when not != null:
return not(_that);case _FilterExpressionTag() when tag != null:
return tag(_that);case _FilterExpressionVirtualTag() when virtualTag != null:
return virtualTag(_that);case _FilterExpressionEquals() when equals != null:
return equals(_that);case _FilterExpressionNotEquals() when notEquals != null:
return notEquals(_that);case _FilterExpressionInValues() when inValues != null:
return inValues(_that);case _FilterExpressionNotInValues() when notInValues != null:
return notInValues(_that);case _FilterExpressionContains() when contains != null:
return contains(_that);case _FilterExpressionNotContains() when notContains != null:
return notContains(_that);case _FilterExpressionStartsWith() when startsWith != null:
return startsWith(_that);case _FilterExpressionEndsWith() when endsWith != null:
return endsWith(_that);case _FilterExpressionWord() when word != null:
return word(_that);case _FilterExpressionNoWord() when noWord != null:
return noWord(_that);case _FilterExpressionRegex() when regex != null:
return regex(_that);case _FilterExpressionNone() when none != null:
return none(_that);case _FilterExpressionAny() when any != null:
return any(_that);case _FilterExpressionDateBefore() when dateBefore != null:
return dateBefore(_that);case _FilterExpressionDateAfter() when dateAfter != null:
return dateAfter(_that);case _FilterExpressionDateBy() when dateBy != null:
return dateBy(_that);case _FilterExpressionDateFrom() when dateFrom != null:
return dateFrom(_that);case _FilterExpressionDateTo() when dateTo != null:
return dateTo(_that);case _FilterExpressionLessThan() when lessThan != null:
return lessThan(_that);case _FilterExpressionLessThanOrEqual() when lessThanOrEqual != null:
return lessThanOrEqual(_that);case _FilterExpressionGreaterThan() when greaterThan != null:
return greaterThan(_that);case _FilterExpressionGreaterThanOrEqual() when greaterThanOrEqual != null:
return greaterThanOrEqual(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _FilterExpressionAndGroup value)  andGroup,required TResult Function( _FilterExpressionOrGroup value)  orGroup,required TResult Function( _FilterExpressionXorGroup value)  xorGroup,required TResult Function( _FilterExpressionNot value)  not,required TResult Function( _FilterExpressionTag value)  tag,required TResult Function( _FilterExpressionVirtualTag value)  virtualTag,required TResult Function( _FilterExpressionEquals value)  equals,required TResult Function( _FilterExpressionNotEquals value)  notEquals,required TResult Function( _FilterExpressionInValues value)  inValues,required TResult Function( _FilterExpressionNotInValues value)  notInValues,required TResult Function( _FilterExpressionContains value)  contains,required TResult Function( _FilterExpressionNotContains value)  notContains,required TResult Function( _FilterExpressionStartsWith value)  startsWith,required TResult Function( _FilterExpressionEndsWith value)  endsWith,required TResult Function( _FilterExpressionWord value)  word,required TResult Function( _FilterExpressionNoWord value)  noWord,required TResult Function( _FilterExpressionRegex value)  regex,required TResult Function( _FilterExpressionNone value)  none,required TResult Function( _FilterExpressionAny value)  any,required TResult Function( _FilterExpressionDateBefore value)  dateBefore,required TResult Function( _FilterExpressionDateAfter value)  dateAfter,required TResult Function( _FilterExpressionDateBy value)  dateBy,required TResult Function( _FilterExpressionDateFrom value)  dateFrom,required TResult Function( _FilterExpressionDateTo value)  dateTo,required TResult Function( _FilterExpressionLessThan value)  lessThan,required TResult Function( _FilterExpressionLessThanOrEqual value)  lessThanOrEqual,required TResult Function( _FilterExpressionGreaterThan value)  greaterThan,required TResult Function( _FilterExpressionGreaterThanOrEqual value)  greaterThanOrEqual,}){
final _that = this;
switch (_that) {
case _FilterExpressionAndGroup():
return andGroup(_that);case _FilterExpressionOrGroup():
return orGroup(_that);case _FilterExpressionXorGroup():
return xorGroup(_that);case _FilterExpressionNot():
return not(_that);case _FilterExpressionTag():
return tag(_that);case _FilterExpressionVirtualTag():
return virtualTag(_that);case _FilterExpressionEquals():
return equals(_that);case _FilterExpressionNotEquals():
return notEquals(_that);case _FilterExpressionInValues():
return inValues(_that);case _FilterExpressionNotInValues():
return notInValues(_that);case _FilterExpressionContains():
return contains(_that);case _FilterExpressionNotContains():
return notContains(_that);case _FilterExpressionStartsWith():
return startsWith(_that);case _FilterExpressionEndsWith():
return endsWith(_that);case _FilterExpressionWord():
return word(_that);case _FilterExpressionNoWord():
return noWord(_that);case _FilterExpressionRegex():
return regex(_that);case _FilterExpressionNone():
return none(_that);case _FilterExpressionAny():
return any(_that);case _FilterExpressionDateBefore():
return dateBefore(_that);case _FilterExpressionDateAfter():
return dateAfter(_that);case _FilterExpressionDateBy():
return dateBy(_that);case _FilterExpressionDateFrom():
return dateFrom(_that);case _FilterExpressionDateTo():
return dateTo(_that);case _FilterExpressionLessThan():
return lessThan(_that);case _FilterExpressionLessThanOrEqual():
return lessThanOrEqual(_that);case _FilterExpressionGreaterThan():
return greaterThan(_that);case _FilterExpressionGreaterThanOrEqual():
return greaterThanOrEqual(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _FilterExpressionAndGroup value)?  andGroup,TResult? Function( _FilterExpressionOrGroup value)?  orGroup,TResult? Function( _FilterExpressionXorGroup value)?  xorGroup,TResult? Function( _FilterExpressionNot value)?  not,TResult? Function( _FilterExpressionTag value)?  tag,TResult? Function( _FilterExpressionVirtualTag value)?  virtualTag,TResult? Function( _FilterExpressionEquals value)?  equals,TResult? Function( _FilterExpressionNotEquals value)?  notEquals,TResult? Function( _FilterExpressionInValues value)?  inValues,TResult? Function( _FilterExpressionNotInValues value)?  notInValues,TResult? Function( _FilterExpressionContains value)?  contains,TResult? Function( _FilterExpressionNotContains value)?  notContains,TResult? Function( _FilterExpressionStartsWith value)?  startsWith,TResult? Function( _FilterExpressionEndsWith value)?  endsWith,TResult? Function( _FilterExpressionWord value)?  word,TResult? Function( _FilterExpressionNoWord value)?  noWord,TResult? Function( _FilterExpressionRegex value)?  regex,TResult? Function( _FilterExpressionNone value)?  none,TResult? Function( _FilterExpressionAny value)?  any,TResult? Function( _FilterExpressionDateBefore value)?  dateBefore,TResult? Function( _FilterExpressionDateAfter value)?  dateAfter,TResult? Function( _FilterExpressionDateBy value)?  dateBy,TResult? Function( _FilterExpressionDateFrom value)?  dateFrom,TResult? Function( _FilterExpressionDateTo value)?  dateTo,TResult? Function( _FilterExpressionLessThan value)?  lessThan,TResult? Function( _FilterExpressionLessThanOrEqual value)?  lessThanOrEqual,TResult? Function( _FilterExpressionGreaterThan value)?  greaterThan,TResult? Function( _FilterExpressionGreaterThanOrEqual value)?  greaterThanOrEqual,}){
final _that = this;
switch (_that) {
case _FilterExpressionAndGroup() when andGroup != null:
return andGroup(_that);case _FilterExpressionOrGroup() when orGroup != null:
return orGroup(_that);case _FilterExpressionXorGroup() when xorGroup != null:
return xorGroup(_that);case _FilterExpressionNot() when not != null:
return not(_that);case _FilterExpressionTag() when tag != null:
return tag(_that);case _FilterExpressionVirtualTag() when virtualTag != null:
return virtualTag(_that);case _FilterExpressionEquals() when equals != null:
return equals(_that);case _FilterExpressionNotEquals() when notEquals != null:
return notEquals(_that);case _FilterExpressionInValues() when inValues != null:
return inValues(_that);case _FilterExpressionNotInValues() when notInValues != null:
return notInValues(_that);case _FilterExpressionContains() when contains != null:
return contains(_that);case _FilterExpressionNotContains() when notContains != null:
return notContains(_that);case _FilterExpressionStartsWith() when startsWith != null:
return startsWith(_that);case _FilterExpressionEndsWith() when endsWith != null:
return endsWith(_that);case _FilterExpressionWord() when word != null:
return word(_that);case _FilterExpressionNoWord() when noWord != null:
return noWord(_that);case _FilterExpressionRegex() when regex != null:
return regex(_that);case _FilterExpressionNone() when none != null:
return none(_that);case _FilterExpressionAny() when any != null:
return any(_that);case _FilterExpressionDateBefore() when dateBefore != null:
return dateBefore(_that);case _FilterExpressionDateAfter() when dateAfter != null:
return dateAfter(_that);case _FilterExpressionDateBy() when dateBy != null:
return dateBy(_that);case _FilterExpressionDateFrom() when dateFrom != null:
return dateFrom(_that);case _FilterExpressionDateTo() when dateTo != null:
return dateTo(_that);case _FilterExpressionLessThan() when lessThan != null:
return lessThan(_that);case _FilterExpressionLessThanOrEqual() when lessThanOrEqual != null:
return lessThanOrEqual(_that);case _FilterExpressionGreaterThan() when greaterThan != null:
return greaterThan(_that);case _FilterExpressionGreaterThanOrEqual() when greaterThanOrEqual != null:
return greaterThanOrEqual(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(@JsonKey(toJson: _filtersToJson)  List<FilterExpression> filters)?  andGroup,TResult Function(@JsonKey(toJson: _filtersToJson)  List<FilterExpression> filters)?  orGroup,TResult Function(@JsonKey(toJson: _filtersToJson)  List<FilterExpression> filters)?  xorGroup,TResult Function(@JsonKey(toJson: _innerToJson)  FilterExpression inner)?  not,TResult Function( String tag,  bool exclude)?  tag,TResult Function( String tag,  bool exclude)?  virtualTag,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  dynamic value)?  equals,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  dynamic value)?  notEquals,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  List<dynamic> values)?  inValues,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  List<dynamic> values)?  notInValues,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  contains,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  notContains,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  startsWith,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  endsWith,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  word,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  noWord,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String pattern, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  regex,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property)?  none,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property)?  any,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime date)?  dateBefore,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime date)?  dateAfter,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime date)?  dateBy,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime from)?  dateFrom,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime to)?  dateTo,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  double value)?  lessThan,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  double value)?  lessThanOrEqual,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  double value)?  greaterThan,TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  double value)?  greaterThanOrEqual,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilterExpressionAndGroup() when andGroup != null:
return andGroup(_that.filters);case _FilterExpressionOrGroup() when orGroup != null:
return orGroup(_that.filters);case _FilterExpressionXorGroup() when xorGroup != null:
return xorGroup(_that.filters);case _FilterExpressionNot() when not != null:
return not(_that.inner);case _FilterExpressionTag() when tag != null:
return tag(_that.tag,_that.exclude);case _FilterExpressionVirtualTag() when virtualTag != null:
return virtualTag(_that.tag,_that.exclude);case _FilterExpressionEquals() when equals != null:
return equals(_that.property,_that.value);case _FilterExpressionNotEquals() when notEquals != null:
return notEquals(_that.property,_that.value);case _FilterExpressionInValues() when inValues != null:
return inValues(_that.property,_that.values);case _FilterExpressionNotInValues() when notInValues != null:
return notInValues(_that.property,_that.values);case _FilterExpressionContains() when contains != null:
return contains(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionNotContains() when notContains != null:
return notContains(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionStartsWith() when startsWith != null:
return startsWith(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionEndsWith() when endsWith != null:
return endsWith(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionWord() when word != null:
return word(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionNoWord() when noWord != null:
return noWord(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionRegex() when regex != null:
return regex(_that.property,_that.pattern,_that.caseSensitive);case _FilterExpressionNone() when none != null:
return none(_that.property);case _FilterExpressionAny() when any != null:
return any(_that.property);case _FilterExpressionDateBefore() when dateBefore != null:
return dateBefore(_that.property,_that.date);case _FilterExpressionDateAfter() when dateAfter != null:
return dateAfter(_that.property,_that.date);case _FilterExpressionDateBy() when dateBy != null:
return dateBy(_that.property,_that.date);case _FilterExpressionDateFrom() when dateFrom != null:
return dateFrom(_that.property,_that.from);case _FilterExpressionDateTo() when dateTo != null:
return dateTo(_that.property,_that.to);case _FilterExpressionLessThan() when lessThan != null:
return lessThan(_that.property,_that.value);case _FilterExpressionLessThanOrEqual() when lessThanOrEqual != null:
return lessThanOrEqual(_that.property,_that.value);case _FilterExpressionGreaterThan() when greaterThan != null:
return greaterThan(_that.property,_that.value);case _FilterExpressionGreaterThanOrEqual() when greaterThanOrEqual != null:
return greaterThanOrEqual(_that.property,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(@JsonKey(toJson: _filtersToJson)  List<FilterExpression> filters)  andGroup,required TResult Function(@JsonKey(toJson: _filtersToJson)  List<FilterExpression> filters)  orGroup,required TResult Function(@JsonKey(toJson: _filtersToJson)  List<FilterExpression> filters)  xorGroup,required TResult Function(@JsonKey(toJson: _innerToJson)  FilterExpression inner)  not,required TResult Function( String tag,  bool exclude)  tag,required TResult Function( String tag,  bool exclude)  virtualTag,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  dynamic value)  equals,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  dynamic value)  notEquals,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  List<dynamic> values)  inValues,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  List<dynamic> values)  notInValues,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)  contains,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)  notContains,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)  startsWith,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)  endsWith,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)  word,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)  noWord,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String pattern, @JsonKey(name: 'case_sensitive')  bool caseSensitive)  regex,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property)  none,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property)  any,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime date)  dateBefore,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime date)  dateAfter,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime date)  dateBy,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime from)  dateFrom,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime to)  dateTo,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  double value)  lessThan,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  double value)  lessThanOrEqual,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  double value)  greaterThan,required TResult Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  double value)  greaterThanOrEqual,}) {final _that = this;
switch (_that) {
case _FilterExpressionAndGroup():
return andGroup(_that.filters);case _FilterExpressionOrGroup():
return orGroup(_that.filters);case _FilterExpressionXorGroup():
return xorGroup(_that.filters);case _FilterExpressionNot():
return not(_that.inner);case _FilterExpressionTag():
return tag(_that.tag,_that.exclude);case _FilterExpressionVirtualTag():
return virtualTag(_that.tag,_that.exclude);case _FilterExpressionEquals():
return equals(_that.property,_that.value);case _FilterExpressionNotEquals():
return notEquals(_that.property,_that.value);case _FilterExpressionInValues():
return inValues(_that.property,_that.values);case _FilterExpressionNotInValues():
return notInValues(_that.property,_that.values);case _FilterExpressionContains():
return contains(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionNotContains():
return notContains(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionStartsWith():
return startsWith(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionEndsWith():
return endsWith(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionWord():
return word(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionNoWord():
return noWord(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionRegex():
return regex(_that.property,_that.pattern,_that.caseSensitive);case _FilterExpressionNone():
return none(_that.property);case _FilterExpressionAny():
return any(_that.property);case _FilterExpressionDateBefore():
return dateBefore(_that.property,_that.date);case _FilterExpressionDateAfter():
return dateAfter(_that.property,_that.date);case _FilterExpressionDateBy():
return dateBy(_that.property,_that.date);case _FilterExpressionDateFrom():
return dateFrom(_that.property,_that.from);case _FilterExpressionDateTo():
return dateTo(_that.property,_that.to);case _FilterExpressionLessThan():
return lessThan(_that.property,_that.value);case _FilterExpressionLessThanOrEqual():
return lessThanOrEqual(_that.property,_that.value);case _FilterExpressionGreaterThan():
return greaterThan(_that.property,_that.value);case _FilterExpressionGreaterThanOrEqual():
return greaterThanOrEqual(_that.property,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(@JsonKey(toJson: _filtersToJson)  List<FilterExpression> filters)?  andGroup,TResult? Function(@JsonKey(toJson: _filtersToJson)  List<FilterExpression> filters)?  orGroup,TResult? Function(@JsonKey(toJson: _filtersToJson)  List<FilterExpression> filters)?  xorGroup,TResult? Function(@JsonKey(toJson: _innerToJson)  FilterExpression inner)?  not,TResult? Function( String tag,  bool exclude)?  tag,TResult? Function( String tag,  bool exclude)?  virtualTag,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  dynamic value)?  equals,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  dynamic value)?  notEquals,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  List<dynamic> values)?  inValues,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  List<dynamic> values)?  notInValues,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  contains,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  notContains,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  startsWith,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  endsWith,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  word,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String value, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  noWord,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  String pattern, @JsonKey(name: 'case_sensitive')  bool caseSensitive)?  regex,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property)?  none,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property)?  any,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime date)?  dateBefore,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime date)?  dateAfter,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime date)?  dateBy,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime from)?  dateFrom,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  DateTime to)?  dateTo,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  double value)?  lessThan,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  double value)?  lessThanOrEqual,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  double value)?  greaterThan,TResult? Function(@JsonKey(toJson: _propertyToJson)  TaskPropertyRef property,  double value)?  greaterThanOrEqual,}) {final _that = this;
switch (_that) {
case _FilterExpressionAndGroup() when andGroup != null:
return andGroup(_that.filters);case _FilterExpressionOrGroup() when orGroup != null:
return orGroup(_that.filters);case _FilterExpressionXorGroup() when xorGroup != null:
return xorGroup(_that.filters);case _FilterExpressionNot() when not != null:
return not(_that.inner);case _FilterExpressionTag() when tag != null:
return tag(_that.tag,_that.exclude);case _FilterExpressionVirtualTag() when virtualTag != null:
return virtualTag(_that.tag,_that.exclude);case _FilterExpressionEquals() when equals != null:
return equals(_that.property,_that.value);case _FilterExpressionNotEquals() when notEquals != null:
return notEquals(_that.property,_that.value);case _FilterExpressionInValues() when inValues != null:
return inValues(_that.property,_that.values);case _FilterExpressionNotInValues() when notInValues != null:
return notInValues(_that.property,_that.values);case _FilterExpressionContains() when contains != null:
return contains(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionNotContains() when notContains != null:
return notContains(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionStartsWith() when startsWith != null:
return startsWith(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionEndsWith() when endsWith != null:
return endsWith(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionWord() when word != null:
return word(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionNoWord() when noWord != null:
return noWord(_that.property,_that.value,_that.caseSensitive);case _FilterExpressionRegex() when regex != null:
return regex(_that.property,_that.pattern,_that.caseSensitive);case _FilterExpressionNone() when none != null:
return none(_that.property);case _FilterExpressionAny() when any != null:
return any(_that.property);case _FilterExpressionDateBefore() when dateBefore != null:
return dateBefore(_that.property,_that.date);case _FilterExpressionDateAfter() when dateAfter != null:
return dateAfter(_that.property,_that.date);case _FilterExpressionDateBy() when dateBy != null:
return dateBy(_that.property,_that.date);case _FilterExpressionDateFrom() when dateFrom != null:
return dateFrom(_that.property,_that.from);case _FilterExpressionDateTo() when dateTo != null:
return dateTo(_that.property,_that.to);case _FilterExpressionLessThan() when lessThan != null:
return lessThan(_that.property,_that.value);case _FilterExpressionLessThanOrEqual() when lessThanOrEqual != null:
return lessThanOrEqual(_that.property,_that.value);case _FilterExpressionGreaterThan() when greaterThan != null:
return greaterThan(_that.property,_that.value);case _FilterExpressionGreaterThanOrEqual() when greaterThanOrEqual != null:
return greaterThanOrEqual(_that.property,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FilterExpressionAndGroup implements FilterExpression {
  const _FilterExpressionAndGroup({@JsonKey(toJson: _filtersToJson) required final  List<FilterExpression> filters, final  String? $type}): _filters = filters,$type = $type ?? 'AndGroup';
  factory _FilterExpressionAndGroup.fromJson(Map<String, dynamic> json) => _$FilterExpressionAndGroupFromJson(json);

 final  List<FilterExpression> _filters;
@JsonKey(toJson: _filtersToJson) List<FilterExpression> get filters {
  if (_filters is EqualUnmodifiableListView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filters);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionAndGroupCopyWith<_FilterExpressionAndGroup> get copyWith => __$FilterExpressionAndGroupCopyWithImpl<_FilterExpressionAndGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionAndGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionAndGroup&&const DeepCollectionEquality().equals(other._filters, _filters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_filters));

@override
String toString() {
  return 'FilterExpression.andGroup(filters: $filters)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionAndGroupCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionAndGroupCopyWith(_FilterExpressionAndGroup value, $Res Function(_FilterExpressionAndGroup) _then) = __$FilterExpressionAndGroupCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _filtersToJson) List<FilterExpression> filters
});




}
/// @nodoc
class __$FilterExpressionAndGroupCopyWithImpl<$Res>
    implements _$FilterExpressionAndGroupCopyWith<$Res> {
  __$FilterExpressionAndGroupCopyWithImpl(this._self, this._then);

  final _FilterExpressionAndGroup _self;
  final $Res Function(_FilterExpressionAndGroup) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filters = null,}) {
  return _then(_FilterExpressionAndGroup(
filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as List<FilterExpression>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionOrGroup implements FilterExpression {
  const _FilterExpressionOrGroup({@JsonKey(toJson: _filtersToJson) required final  List<FilterExpression> filters, final  String? $type}): _filters = filters,$type = $type ?? 'OrGroup';
  factory _FilterExpressionOrGroup.fromJson(Map<String, dynamic> json) => _$FilterExpressionOrGroupFromJson(json);

 final  List<FilterExpression> _filters;
@JsonKey(toJson: _filtersToJson) List<FilterExpression> get filters {
  if (_filters is EqualUnmodifiableListView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filters);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionOrGroupCopyWith<_FilterExpressionOrGroup> get copyWith => __$FilterExpressionOrGroupCopyWithImpl<_FilterExpressionOrGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionOrGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionOrGroup&&const DeepCollectionEquality().equals(other._filters, _filters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_filters));

@override
String toString() {
  return 'FilterExpression.orGroup(filters: $filters)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionOrGroupCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionOrGroupCopyWith(_FilterExpressionOrGroup value, $Res Function(_FilterExpressionOrGroup) _then) = __$FilterExpressionOrGroupCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _filtersToJson) List<FilterExpression> filters
});




}
/// @nodoc
class __$FilterExpressionOrGroupCopyWithImpl<$Res>
    implements _$FilterExpressionOrGroupCopyWith<$Res> {
  __$FilterExpressionOrGroupCopyWithImpl(this._self, this._then);

  final _FilterExpressionOrGroup _self;
  final $Res Function(_FilterExpressionOrGroup) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filters = null,}) {
  return _then(_FilterExpressionOrGroup(
filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as List<FilterExpression>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionXorGroup implements FilterExpression {
  const _FilterExpressionXorGroup({@JsonKey(toJson: _filtersToJson) required final  List<FilterExpression> filters, final  String? $type}): _filters = filters,$type = $type ?? 'XorGroup';
  factory _FilterExpressionXorGroup.fromJson(Map<String, dynamic> json) => _$FilterExpressionXorGroupFromJson(json);

 final  List<FilterExpression> _filters;
@JsonKey(toJson: _filtersToJson) List<FilterExpression> get filters {
  if (_filters is EqualUnmodifiableListView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filters);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionXorGroupCopyWith<_FilterExpressionXorGroup> get copyWith => __$FilterExpressionXorGroupCopyWithImpl<_FilterExpressionXorGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionXorGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionXorGroup&&const DeepCollectionEquality().equals(other._filters, _filters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_filters));

@override
String toString() {
  return 'FilterExpression.xorGroup(filters: $filters)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionXorGroupCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionXorGroupCopyWith(_FilterExpressionXorGroup value, $Res Function(_FilterExpressionXorGroup) _then) = __$FilterExpressionXorGroupCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _filtersToJson) List<FilterExpression> filters
});




}
/// @nodoc
class __$FilterExpressionXorGroupCopyWithImpl<$Res>
    implements _$FilterExpressionXorGroupCopyWith<$Res> {
  __$FilterExpressionXorGroupCopyWithImpl(this._self, this._then);

  final _FilterExpressionXorGroup _self;
  final $Res Function(_FilterExpressionXorGroup) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filters = null,}) {
  return _then(_FilterExpressionXorGroup(
filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as List<FilterExpression>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionNot implements FilterExpression {
  const _FilterExpressionNot({@JsonKey(toJson: _innerToJson) required this.inner, final  String? $type}): $type = $type ?? 'Not';
  factory _FilterExpressionNot.fromJson(Map<String, dynamic> json) => _$FilterExpressionNotFromJson(json);

@JsonKey(toJson: _innerToJson) final  FilterExpression inner;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionNotCopyWith<_FilterExpressionNot> get copyWith => __$FilterExpressionNotCopyWithImpl<_FilterExpressionNot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionNotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionNot&&(identical(other.inner, inner) || other.inner == inner));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inner);

@override
String toString() {
  return 'FilterExpression.not(inner: $inner)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionNotCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionNotCopyWith(_FilterExpressionNot value, $Res Function(_FilterExpressionNot) _then) = __$FilterExpressionNotCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _innerToJson) FilterExpression inner
});


$FilterExpressionCopyWith<$Res> get inner;

}
/// @nodoc
class __$FilterExpressionNotCopyWithImpl<$Res>
    implements _$FilterExpressionNotCopyWith<$Res> {
  __$FilterExpressionNotCopyWithImpl(this._self, this._then);

  final _FilterExpressionNot _self;
  final $Res Function(_FilterExpressionNot) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? inner = null,}) {
  return _then(_FilterExpressionNot(
inner: null == inner ? _self.inner : inner // ignore: cast_nullable_to_non_nullable
as FilterExpression,
  ));
}

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FilterExpressionCopyWith<$Res> get inner {
  
  return $FilterExpressionCopyWith<$Res>(_self.inner, (value) {
    return _then(_self.copyWith(inner: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class _FilterExpressionTag implements FilterExpression {
  const _FilterExpressionTag({required this.tag, this.exclude = false, final  String? $type}): $type = $type ?? 'Tag';
  factory _FilterExpressionTag.fromJson(Map<String, dynamic> json) => _$FilterExpressionTagFromJson(json);

 final  String tag;
@JsonKey() final  bool exclude;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionTagCopyWith<_FilterExpressionTag> get copyWith => __$FilterExpressionTagCopyWithImpl<_FilterExpressionTag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionTagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionTag&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.exclude, exclude) || other.exclude == exclude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tag,exclude);

@override
String toString() {
  return 'FilterExpression.tag(tag: $tag, exclude: $exclude)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionTagCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionTagCopyWith(_FilterExpressionTag value, $Res Function(_FilterExpressionTag) _then) = __$FilterExpressionTagCopyWithImpl;
@useResult
$Res call({
 String tag, bool exclude
});




}
/// @nodoc
class __$FilterExpressionTagCopyWithImpl<$Res>
    implements _$FilterExpressionTagCopyWith<$Res> {
  __$FilterExpressionTagCopyWithImpl(this._self, this._then);

  final _FilterExpressionTag _self;
  final $Res Function(_FilterExpressionTag) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tag = null,Object? exclude = null,}) {
  return _then(_FilterExpressionTag(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,exclude: null == exclude ? _self.exclude : exclude // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionVirtualTag implements FilterExpression {
  const _FilterExpressionVirtualTag({required this.tag, this.exclude = false, final  String? $type}): $type = $type ?? 'VirtualTag';
  factory _FilterExpressionVirtualTag.fromJson(Map<String, dynamic> json) => _$FilterExpressionVirtualTagFromJson(json);

 final  String tag;
@JsonKey() final  bool exclude;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionVirtualTagCopyWith<_FilterExpressionVirtualTag> get copyWith => __$FilterExpressionVirtualTagCopyWithImpl<_FilterExpressionVirtualTag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionVirtualTagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionVirtualTag&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.exclude, exclude) || other.exclude == exclude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tag,exclude);

@override
String toString() {
  return 'FilterExpression.virtualTag(tag: $tag, exclude: $exclude)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionVirtualTagCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionVirtualTagCopyWith(_FilterExpressionVirtualTag value, $Res Function(_FilterExpressionVirtualTag) _then) = __$FilterExpressionVirtualTagCopyWithImpl;
@useResult
$Res call({
 String tag, bool exclude
});




}
/// @nodoc
class __$FilterExpressionVirtualTagCopyWithImpl<$Res>
    implements _$FilterExpressionVirtualTagCopyWith<$Res> {
  __$FilterExpressionVirtualTagCopyWithImpl(this._self, this._then);

  final _FilterExpressionVirtualTag _self;
  final $Res Function(_FilterExpressionVirtualTag) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tag = null,Object? exclude = null,}) {
  return _then(_FilterExpressionVirtualTag(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,exclude: null == exclude ? _self.exclude : exclude // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionEquals implements FilterExpression {
  const _FilterExpressionEquals({@JsonKey(toJson: _propertyToJson) required this.property, required this.value, final  String? $type}): $type = $type ?? 'EqualsFilter';
  factory _FilterExpressionEquals.fromJson(Map<String, dynamic> json) => _$FilterExpressionEqualsFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  dynamic value;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionEqualsCopyWith<_FilterExpressionEquals> get copyWith => __$FilterExpressionEqualsCopyWithImpl<_FilterExpressionEquals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionEqualsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionEquals&&(identical(other.property, property) || other.property == property)&&const DeepCollectionEquality().equals(other.value, value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'FilterExpression.equals(property: $property, value: $value)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionEqualsCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionEqualsCopyWith(_FilterExpressionEquals value, $Res Function(_FilterExpressionEquals) _then) = __$FilterExpressionEqualsCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, dynamic value
});




}
/// @nodoc
class __$FilterExpressionEqualsCopyWithImpl<$Res>
    implements _$FilterExpressionEqualsCopyWith<$Res> {
  __$FilterExpressionEqualsCopyWithImpl(this._self, this._then);

  final _FilterExpressionEquals _self;
  final $Res Function(_FilterExpressionEquals) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? value = freezed,}) {
  return _then(_FilterExpressionEquals(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionNotEquals implements FilterExpression {
  const _FilterExpressionNotEquals({@JsonKey(toJson: _propertyToJson) required this.property, required this.value, final  String? $type}): $type = $type ?? 'NotEqualsFilter';
  factory _FilterExpressionNotEquals.fromJson(Map<String, dynamic> json) => _$FilterExpressionNotEqualsFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  dynamic value;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionNotEqualsCopyWith<_FilterExpressionNotEquals> get copyWith => __$FilterExpressionNotEqualsCopyWithImpl<_FilterExpressionNotEquals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionNotEqualsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionNotEquals&&(identical(other.property, property) || other.property == property)&&const DeepCollectionEquality().equals(other.value, value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'FilterExpression.notEquals(property: $property, value: $value)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionNotEqualsCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionNotEqualsCopyWith(_FilterExpressionNotEquals value, $Res Function(_FilterExpressionNotEquals) _then) = __$FilterExpressionNotEqualsCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, dynamic value
});




}
/// @nodoc
class __$FilterExpressionNotEqualsCopyWithImpl<$Res>
    implements _$FilterExpressionNotEqualsCopyWith<$Res> {
  __$FilterExpressionNotEqualsCopyWithImpl(this._self, this._then);

  final _FilterExpressionNotEquals _self;
  final $Res Function(_FilterExpressionNotEquals) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? value = freezed,}) {
  return _then(_FilterExpressionNotEquals(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionInValues implements FilterExpression {
  const _FilterExpressionInValues({@JsonKey(toJson: _propertyToJson) required this.property, required final  List<dynamic> values, final  String? $type}): _values = values,$type = $type ?? 'InFilter';
  factory _FilterExpressionInValues.fromJson(Map<String, dynamic> json) => _$FilterExpressionInValuesFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  List<dynamic> _values;
 List<dynamic> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionInValuesCopyWith<_FilterExpressionInValues> get copyWith => __$FilterExpressionInValuesCopyWithImpl<_FilterExpressionInValues>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionInValuesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionInValues&&(identical(other.property, property) || other.property == property)&&const DeepCollectionEquality().equals(other._values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'FilterExpression.inValues(property: $property, values: $values)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionInValuesCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionInValuesCopyWith(_FilterExpressionInValues value, $Res Function(_FilterExpressionInValues) _then) = __$FilterExpressionInValuesCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, List<dynamic> values
});




}
/// @nodoc
class __$FilterExpressionInValuesCopyWithImpl<$Res>
    implements _$FilterExpressionInValuesCopyWith<$Res> {
  __$FilterExpressionInValuesCopyWithImpl(this._self, this._then);

  final _FilterExpressionInValues _self;
  final $Res Function(_FilterExpressionInValues) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? values = null,}) {
  return _then(_FilterExpressionInValues(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionNotInValues implements FilterExpression {
  const _FilterExpressionNotInValues({@JsonKey(toJson: _propertyToJson) required this.property, required final  List<dynamic> values, final  String? $type}): _values = values,$type = $type ?? 'NotInFilter';
  factory _FilterExpressionNotInValues.fromJson(Map<String, dynamic> json) => _$FilterExpressionNotInValuesFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  List<dynamic> _values;
 List<dynamic> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionNotInValuesCopyWith<_FilterExpressionNotInValues> get copyWith => __$FilterExpressionNotInValuesCopyWithImpl<_FilterExpressionNotInValues>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionNotInValuesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionNotInValues&&(identical(other.property, property) || other.property == property)&&const DeepCollectionEquality().equals(other._values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'FilterExpression.notInValues(property: $property, values: $values)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionNotInValuesCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionNotInValuesCopyWith(_FilterExpressionNotInValues value, $Res Function(_FilterExpressionNotInValues) _then) = __$FilterExpressionNotInValuesCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, List<dynamic> values
});




}
/// @nodoc
class __$FilterExpressionNotInValuesCopyWithImpl<$Res>
    implements _$FilterExpressionNotInValuesCopyWith<$Res> {
  __$FilterExpressionNotInValuesCopyWithImpl(this._self, this._then);

  final _FilterExpressionNotInValues _self;
  final $Res Function(_FilterExpressionNotInValues) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? values = null,}) {
  return _then(_FilterExpressionNotInValues(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionContains implements FilterExpression {
  const _FilterExpressionContains({@JsonKey(toJson: _propertyToJson) required this.property, required this.value, @JsonKey(name: 'case_sensitive') this.caseSensitive = false, final  String? $type}): $type = $type ?? 'ContainsFilter';
  factory _FilterExpressionContains.fromJson(Map<String, dynamic> json) => _$FilterExpressionContainsFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  String value;
@JsonKey(name: 'case_sensitive') final  bool caseSensitive;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionContainsCopyWith<_FilterExpressionContains> get copyWith => __$FilterExpressionContainsCopyWithImpl<_FilterExpressionContains>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionContainsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionContains&&(identical(other.property, property) || other.property == property)&&(identical(other.value, value) || other.value == value)&&(identical(other.caseSensitive, caseSensitive) || other.caseSensitive == caseSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,value,caseSensitive);

@override
String toString() {
  return 'FilterExpression.contains(property: $property, value: $value, caseSensitive: $caseSensitive)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionContainsCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionContainsCopyWith(_FilterExpressionContains value, $Res Function(_FilterExpressionContains) _then) = __$FilterExpressionContainsCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, String value,@JsonKey(name: 'case_sensitive') bool caseSensitive
});




}
/// @nodoc
class __$FilterExpressionContainsCopyWithImpl<$Res>
    implements _$FilterExpressionContainsCopyWith<$Res> {
  __$FilterExpressionContainsCopyWithImpl(this._self, this._then);

  final _FilterExpressionContains _self;
  final $Res Function(_FilterExpressionContains) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? value = null,Object? caseSensitive = null,}) {
  return _then(_FilterExpressionContains(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,caseSensitive: null == caseSensitive ? _self.caseSensitive : caseSensitive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionNotContains implements FilterExpression {
  const _FilterExpressionNotContains({@JsonKey(toJson: _propertyToJson) required this.property, required this.value, @JsonKey(name: 'case_sensitive') this.caseSensitive = false, final  String? $type}): $type = $type ?? 'NotContainsFilter';
  factory _FilterExpressionNotContains.fromJson(Map<String, dynamic> json) => _$FilterExpressionNotContainsFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  String value;
@JsonKey(name: 'case_sensitive') final  bool caseSensitive;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionNotContainsCopyWith<_FilterExpressionNotContains> get copyWith => __$FilterExpressionNotContainsCopyWithImpl<_FilterExpressionNotContains>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionNotContainsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionNotContains&&(identical(other.property, property) || other.property == property)&&(identical(other.value, value) || other.value == value)&&(identical(other.caseSensitive, caseSensitive) || other.caseSensitive == caseSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,value,caseSensitive);

@override
String toString() {
  return 'FilterExpression.notContains(property: $property, value: $value, caseSensitive: $caseSensitive)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionNotContainsCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionNotContainsCopyWith(_FilterExpressionNotContains value, $Res Function(_FilterExpressionNotContains) _then) = __$FilterExpressionNotContainsCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, String value,@JsonKey(name: 'case_sensitive') bool caseSensitive
});




}
/// @nodoc
class __$FilterExpressionNotContainsCopyWithImpl<$Res>
    implements _$FilterExpressionNotContainsCopyWith<$Res> {
  __$FilterExpressionNotContainsCopyWithImpl(this._self, this._then);

  final _FilterExpressionNotContains _self;
  final $Res Function(_FilterExpressionNotContains) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? value = null,Object? caseSensitive = null,}) {
  return _then(_FilterExpressionNotContains(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,caseSensitive: null == caseSensitive ? _self.caseSensitive : caseSensitive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionStartsWith implements FilterExpression {
  const _FilterExpressionStartsWith({@JsonKey(toJson: _propertyToJson) required this.property, required this.value, @JsonKey(name: 'case_sensitive') this.caseSensitive = false, final  String? $type}): $type = $type ?? 'StartsWithFilter';
  factory _FilterExpressionStartsWith.fromJson(Map<String, dynamic> json) => _$FilterExpressionStartsWithFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  String value;
@JsonKey(name: 'case_sensitive') final  bool caseSensitive;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionStartsWithCopyWith<_FilterExpressionStartsWith> get copyWith => __$FilterExpressionStartsWithCopyWithImpl<_FilterExpressionStartsWith>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionStartsWithToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionStartsWith&&(identical(other.property, property) || other.property == property)&&(identical(other.value, value) || other.value == value)&&(identical(other.caseSensitive, caseSensitive) || other.caseSensitive == caseSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,value,caseSensitive);

@override
String toString() {
  return 'FilterExpression.startsWith(property: $property, value: $value, caseSensitive: $caseSensitive)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionStartsWithCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionStartsWithCopyWith(_FilterExpressionStartsWith value, $Res Function(_FilterExpressionStartsWith) _then) = __$FilterExpressionStartsWithCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, String value,@JsonKey(name: 'case_sensitive') bool caseSensitive
});




}
/// @nodoc
class __$FilterExpressionStartsWithCopyWithImpl<$Res>
    implements _$FilterExpressionStartsWithCopyWith<$Res> {
  __$FilterExpressionStartsWithCopyWithImpl(this._self, this._then);

  final _FilterExpressionStartsWith _self;
  final $Res Function(_FilterExpressionStartsWith) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? value = null,Object? caseSensitive = null,}) {
  return _then(_FilterExpressionStartsWith(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,caseSensitive: null == caseSensitive ? _self.caseSensitive : caseSensitive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionEndsWith implements FilterExpression {
  const _FilterExpressionEndsWith({@JsonKey(toJson: _propertyToJson) required this.property, required this.value, @JsonKey(name: 'case_sensitive') this.caseSensitive = false, final  String? $type}): $type = $type ?? 'EndsWithFilter';
  factory _FilterExpressionEndsWith.fromJson(Map<String, dynamic> json) => _$FilterExpressionEndsWithFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  String value;
@JsonKey(name: 'case_sensitive') final  bool caseSensitive;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionEndsWithCopyWith<_FilterExpressionEndsWith> get copyWith => __$FilterExpressionEndsWithCopyWithImpl<_FilterExpressionEndsWith>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionEndsWithToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionEndsWith&&(identical(other.property, property) || other.property == property)&&(identical(other.value, value) || other.value == value)&&(identical(other.caseSensitive, caseSensitive) || other.caseSensitive == caseSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,value,caseSensitive);

@override
String toString() {
  return 'FilterExpression.endsWith(property: $property, value: $value, caseSensitive: $caseSensitive)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionEndsWithCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionEndsWithCopyWith(_FilterExpressionEndsWith value, $Res Function(_FilterExpressionEndsWith) _then) = __$FilterExpressionEndsWithCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, String value,@JsonKey(name: 'case_sensitive') bool caseSensitive
});




}
/// @nodoc
class __$FilterExpressionEndsWithCopyWithImpl<$Res>
    implements _$FilterExpressionEndsWithCopyWith<$Res> {
  __$FilterExpressionEndsWithCopyWithImpl(this._self, this._then);

  final _FilterExpressionEndsWith _self;
  final $Res Function(_FilterExpressionEndsWith) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? value = null,Object? caseSensitive = null,}) {
  return _then(_FilterExpressionEndsWith(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,caseSensitive: null == caseSensitive ? _self.caseSensitive : caseSensitive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionWord implements FilterExpression {
  const _FilterExpressionWord({@JsonKey(toJson: _propertyToJson) required this.property, required this.value, @JsonKey(name: 'case_sensitive') this.caseSensitive = false, final  String? $type}): $type = $type ?? 'WordFilter';
  factory _FilterExpressionWord.fromJson(Map<String, dynamic> json) => _$FilterExpressionWordFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  String value;
@JsonKey(name: 'case_sensitive') final  bool caseSensitive;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionWordCopyWith<_FilterExpressionWord> get copyWith => __$FilterExpressionWordCopyWithImpl<_FilterExpressionWord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionWordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionWord&&(identical(other.property, property) || other.property == property)&&(identical(other.value, value) || other.value == value)&&(identical(other.caseSensitive, caseSensitive) || other.caseSensitive == caseSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,value,caseSensitive);

@override
String toString() {
  return 'FilterExpression.word(property: $property, value: $value, caseSensitive: $caseSensitive)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionWordCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionWordCopyWith(_FilterExpressionWord value, $Res Function(_FilterExpressionWord) _then) = __$FilterExpressionWordCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, String value,@JsonKey(name: 'case_sensitive') bool caseSensitive
});




}
/// @nodoc
class __$FilterExpressionWordCopyWithImpl<$Res>
    implements _$FilterExpressionWordCopyWith<$Res> {
  __$FilterExpressionWordCopyWithImpl(this._self, this._then);

  final _FilterExpressionWord _self;
  final $Res Function(_FilterExpressionWord) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? value = null,Object? caseSensitive = null,}) {
  return _then(_FilterExpressionWord(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,caseSensitive: null == caseSensitive ? _self.caseSensitive : caseSensitive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionNoWord implements FilterExpression {
  const _FilterExpressionNoWord({@JsonKey(toJson: _propertyToJson) required this.property, required this.value, @JsonKey(name: 'case_sensitive') this.caseSensitive = false, final  String? $type}): $type = $type ?? 'NoWordFilter';
  factory _FilterExpressionNoWord.fromJson(Map<String, dynamic> json) => _$FilterExpressionNoWordFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  String value;
@JsonKey(name: 'case_sensitive') final  bool caseSensitive;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionNoWordCopyWith<_FilterExpressionNoWord> get copyWith => __$FilterExpressionNoWordCopyWithImpl<_FilterExpressionNoWord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionNoWordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionNoWord&&(identical(other.property, property) || other.property == property)&&(identical(other.value, value) || other.value == value)&&(identical(other.caseSensitive, caseSensitive) || other.caseSensitive == caseSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,value,caseSensitive);

@override
String toString() {
  return 'FilterExpression.noWord(property: $property, value: $value, caseSensitive: $caseSensitive)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionNoWordCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionNoWordCopyWith(_FilterExpressionNoWord value, $Res Function(_FilterExpressionNoWord) _then) = __$FilterExpressionNoWordCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, String value,@JsonKey(name: 'case_sensitive') bool caseSensitive
});




}
/// @nodoc
class __$FilterExpressionNoWordCopyWithImpl<$Res>
    implements _$FilterExpressionNoWordCopyWith<$Res> {
  __$FilterExpressionNoWordCopyWithImpl(this._self, this._then);

  final _FilterExpressionNoWord _self;
  final $Res Function(_FilterExpressionNoWord) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? value = null,Object? caseSensitive = null,}) {
  return _then(_FilterExpressionNoWord(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,caseSensitive: null == caseSensitive ? _self.caseSensitive : caseSensitive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionRegex implements FilterExpression {
  const _FilterExpressionRegex({@JsonKey(toJson: _propertyToJson) required this.property, required this.pattern, @JsonKey(name: 'case_sensitive') this.caseSensitive = false, final  String? $type}): $type = $type ?? 'RegexFilter';
  factory _FilterExpressionRegex.fromJson(Map<String, dynamic> json) => _$FilterExpressionRegexFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  String pattern;
@JsonKey(name: 'case_sensitive') final  bool caseSensitive;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionRegexCopyWith<_FilterExpressionRegex> get copyWith => __$FilterExpressionRegexCopyWithImpl<_FilterExpressionRegex>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionRegexToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionRegex&&(identical(other.property, property) || other.property == property)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.caseSensitive, caseSensitive) || other.caseSensitive == caseSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,pattern,caseSensitive);

@override
String toString() {
  return 'FilterExpression.regex(property: $property, pattern: $pattern, caseSensitive: $caseSensitive)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionRegexCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionRegexCopyWith(_FilterExpressionRegex value, $Res Function(_FilterExpressionRegex) _then) = __$FilterExpressionRegexCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, String pattern,@JsonKey(name: 'case_sensitive') bool caseSensitive
});




}
/// @nodoc
class __$FilterExpressionRegexCopyWithImpl<$Res>
    implements _$FilterExpressionRegexCopyWith<$Res> {
  __$FilterExpressionRegexCopyWithImpl(this._self, this._then);

  final _FilterExpressionRegex _self;
  final $Res Function(_FilterExpressionRegex) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? pattern = null,Object? caseSensitive = null,}) {
  return _then(_FilterExpressionRegex(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String,caseSensitive: null == caseSensitive ? _self.caseSensitive : caseSensitive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionNone implements FilterExpression {
  const _FilterExpressionNone({@JsonKey(toJson: _propertyToJson) required this.property, final  String? $type}): $type = $type ?? 'NoneFilter';
  factory _FilterExpressionNone.fromJson(Map<String, dynamic> json) => _$FilterExpressionNoneFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionNoneCopyWith<_FilterExpressionNone> get copyWith => __$FilterExpressionNoneCopyWithImpl<_FilterExpressionNone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionNoneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionNone&&(identical(other.property, property) || other.property == property));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property);

@override
String toString() {
  return 'FilterExpression.none(property: $property)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionNoneCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionNoneCopyWith(_FilterExpressionNone value, $Res Function(_FilterExpressionNone) _then) = __$FilterExpressionNoneCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property
});




}
/// @nodoc
class __$FilterExpressionNoneCopyWithImpl<$Res>
    implements _$FilterExpressionNoneCopyWith<$Res> {
  __$FilterExpressionNoneCopyWithImpl(this._self, this._then);

  final _FilterExpressionNone _self;
  final $Res Function(_FilterExpressionNone) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,}) {
  return _then(_FilterExpressionNone(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionAny implements FilterExpression {
  const _FilterExpressionAny({@JsonKey(toJson: _propertyToJson) required this.property, final  String? $type}): $type = $type ?? 'AnyFilter';
  factory _FilterExpressionAny.fromJson(Map<String, dynamic> json) => _$FilterExpressionAnyFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionAnyCopyWith<_FilterExpressionAny> get copyWith => __$FilterExpressionAnyCopyWithImpl<_FilterExpressionAny>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionAnyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionAny&&(identical(other.property, property) || other.property == property));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property);

@override
String toString() {
  return 'FilterExpression.any(property: $property)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionAnyCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionAnyCopyWith(_FilterExpressionAny value, $Res Function(_FilterExpressionAny) _then) = __$FilterExpressionAnyCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property
});




}
/// @nodoc
class __$FilterExpressionAnyCopyWithImpl<$Res>
    implements _$FilterExpressionAnyCopyWith<$Res> {
  __$FilterExpressionAnyCopyWithImpl(this._self, this._then);

  final _FilterExpressionAny _self;
  final $Res Function(_FilterExpressionAny) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,}) {
  return _then(_FilterExpressionAny(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionDateBefore implements FilterExpression {
  const _FilterExpressionDateBefore({@JsonKey(toJson: _propertyToJson) required this.property, required this.date, final  String? $type}): $type = $type ?? 'DateBeforeFilter';
  factory _FilterExpressionDateBefore.fromJson(Map<String, dynamic> json) => _$FilterExpressionDateBeforeFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  DateTime date;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionDateBeforeCopyWith<_FilterExpressionDateBefore> get copyWith => __$FilterExpressionDateBeforeCopyWithImpl<_FilterExpressionDateBefore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionDateBeforeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionDateBefore&&(identical(other.property, property) || other.property == property)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,date);

@override
String toString() {
  return 'FilterExpression.dateBefore(property: $property, date: $date)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionDateBeforeCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionDateBeforeCopyWith(_FilterExpressionDateBefore value, $Res Function(_FilterExpressionDateBefore) _then) = __$FilterExpressionDateBeforeCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, DateTime date
});




}
/// @nodoc
class __$FilterExpressionDateBeforeCopyWithImpl<$Res>
    implements _$FilterExpressionDateBeforeCopyWith<$Res> {
  __$FilterExpressionDateBeforeCopyWithImpl(this._self, this._then);

  final _FilterExpressionDateBefore _self;
  final $Res Function(_FilterExpressionDateBefore) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? date = null,}) {
  return _then(_FilterExpressionDateBefore(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionDateAfter implements FilterExpression {
  const _FilterExpressionDateAfter({@JsonKey(toJson: _propertyToJson) required this.property, required this.date, final  String? $type}): $type = $type ?? 'DateAfterFilter';
  factory _FilterExpressionDateAfter.fromJson(Map<String, dynamic> json) => _$FilterExpressionDateAfterFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  DateTime date;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionDateAfterCopyWith<_FilterExpressionDateAfter> get copyWith => __$FilterExpressionDateAfterCopyWithImpl<_FilterExpressionDateAfter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionDateAfterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionDateAfter&&(identical(other.property, property) || other.property == property)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,date);

@override
String toString() {
  return 'FilterExpression.dateAfter(property: $property, date: $date)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionDateAfterCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionDateAfterCopyWith(_FilterExpressionDateAfter value, $Res Function(_FilterExpressionDateAfter) _then) = __$FilterExpressionDateAfterCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, DateTime date
});




}
/// @nodoc
class __$FilterExpressionDateAfterCopyWithImpl<$Res>
    implements _$FilterExpressionDateAfterCopyWith<$Res> {
  __$FilterExpressionDateAfterCopyWithImpl(this._self, this._then);

  final _FilterExpressionDateAfter _self;
  final $Res Function(_FilterExpressionDateAfter) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? date = null,}) {
  return _then(_FilterExpressionDateAfter(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionDateBy implements FilterExpression {
  const _FilterExpressionDateBy({@JsonKey(toJson: _propertyToJson) required this.property, required this.date, final  String? $type}): $type = $type ?? 'DateByFilter';
  factory _FilterExpressionDateBy.fromJson(Map<String, dynamic> json) => _$FilterExpressionDateByFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  DateTime date;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionDateByCopyWith<_FilterExpressionDateBy> get copyWith => __$FilterExpressionDateByCopyWithImpl<_FilterExpressionDateBy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionDateByToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionDateBy&&(identical(other.property, property) || other.property == property)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,date);

@override
String toString() {
  return 'FilterExpression.dateBy(property: $property, date: $date)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionDateByCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionDateByCopyWith(_FilterExpressionDateBy value, $Res Function(_FilterExpressionDateBy) _then) = __$FilterExpressionDateByCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, DateTime date
});




}
/// @nodoc
class __$FilterExpressionDateByCopyWithImpl<$Res>
    implements _$FilterExpressionDateByCopyWith<$Res> {
  __$FilterExpressionDateByCopyWithImpl(this._self, this._then);

  final _FilterExpressionDateBy _self;
  final $Res Function(_FilterExpressionDateBy) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? date = null,}) {
  return _then(_FilterExpressionDateBy(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionDateFrom implements FilterExpression {
  const _FilterExpressionDateFrom({@JsonKey(toJson: _propertyToJson) required this.property, required this.from, final  String? $type}): $type = $type ?? 'DateFromFilter';
  factory _FilterExpressionDateFrom.fromJson(Map<String, dynamic> json) => _$FilterExpressionDateFromFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  DateTime from;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionDateFromCopyWith<_FilterExpressionDateFrom> get copyWith => __$FilterExpressionDateFromCopyWithImpl<_FilterExpressionDateFrom>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionDateFromToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionDateFrom&&(identical(other.property, property) || other.property == property)&&(identical(other.from, from) || other.from == from));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,from);

@override
String toString() {
  return 'FilterExpression.dateFrom(property: $property, from: $from)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionDateFromCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionDateFromCopyWith(_FilterExpressionDateFrom value, $Res Function(_FilterExpressionDateFrom) _then) = __$FilterExpressionDateFromCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, DateTime from
});




}
/// @nodoc
class __$FilterExpressionDateFromCopyWithImpl<$Res>
    implements _$FilterExpressionDateFromCopyWith<$Res> {
  __$FilterExpressionDateFromCopyWithImpl(this._self, this._then);

  final _FilterExpressionDateFrom _self;
  final $Res Function(_FilterExpressionDateFrom) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? from = null,}) {
  return _then(_FilterExpressionDateFrom(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionDateTo implements FilterExpression {
  const _FilterExpressionDateTo({@JsonKey(toJson: _propertyToJson) required this.property, required this.to, final  String? $type}): $type = $type ?? 'DateToFilter';
  factory _FilterExpressionDateTo.fromJson(Map<String, dynamic> json) => _$FilterExpressionDateToFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  DateTime to;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionDateToCopyWith<_FilterExpressionDateTo> get copyWith => __$FilterExpressionDateToCopyWithImpl<_FilterExpressionDateTo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionDateToToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionDateTo&&(identical(other.property, property) || other.property == property)&&(identical(other.to, to) || other.to == to));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,to);

@override
String toString() {
  return 'FilterExpression.dateTo(property: $property, to: $to)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionDateToCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionDateToCopyWith(_FilterExpressionDateTo value, $Res Function(_FilterExpressionDateTo) _then) = __$FilterExpressionDateToCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, DateTime to
});




}
/// @nodoc
class __$FilterExpressionDateToCopyWithImpl<$Res>
    implements _$FilterExpressionDateToCopyWith<$Res> {
  __$FilterExpressionDateToCopyWithImpl(this._self, this._then);

  final _FilterExpressionDateTo _self;
  final $Res Function(_FilterExpressionDateTo) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? to = null,}) {
  return _then(_FilterExpressionDateTo(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionLessThan implements FilterExpression {
  const _FilterExpressionLessThan({@JsonKey(toJson: _propertyToJson) required this.property, required this.value, final  String? $type}): $type = $type ?? 'LessThanFilter';
  factory _FilterExpressionLessThan.fromJson(Map<String, dynamic> json) => _$FilterExpressionLessThanFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  double value;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionLessThanCopyWith<_FilterExpressionLessThan> get copyWith => __$FilterExpressionLessThanCopyWithImpl<_FilterExpressionLessThan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionLessThanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionLessThan&&(identical(other.property, property) || other.property == property)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,value);

@override
String toString() {
  return 'FilterExpression.lessThan(property: $property, value: $value)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionLessThanCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionLessThanCopyWith(_FilterExpressionLessThan value, $Res Function(_FilterExpressionLessThan) _then) = __$FilterExpressionLessThanCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, double value
});




}
/// @nodoc
class __$FilterExpressionLessThanCopyWithImpl<$Res>
    implements _$FilterExpressionLessThanCopyWith<$Res> {
  __$FilterExpressionLessThanCopyWithImpl(this._self, this._then);

  final _FilterExpressionLessThan _self;
  final $Res Function(_FilterExpressionLessThan) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? value = null,}) {
  return _then(_FilterExpressionLessThan(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionLessThanOrEqual implements FilterExpression {
  const _FilterExpressionLessThanOrEqual({@JsonKey(toJson: _propertyToJson) required this.property, required this.value, final  String? $type}): $type = $type ?? 'LessThanOrEqualFilter';
  factory _FilterExpressionLessThanOrEqual.fromJson(Map<String, dynamic> json) => _$FilterExpressionLessThanOrEqualFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  double value;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionLessThanOrEqualCopyWith<_FilterExpressionLessThanOrEqual> get copyWith => __$FilterExpressionLessThanOrEqualCopyWithImpl<_FilterExpressionLessThanOrEqual>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionLessThanOrEqualToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionLessThanOrEqual&&(identical(other.property, property) || other.property == property)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,value);

@override
String toString() {
  return 'FilterExpression.lessThanOrEqual(property: $property, value: $value)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionLessThanOrEqualCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionLessThanOrEqualCopyWith(_FilterExpressionLessThanOrEqual value, $Res Function(_FilterExpressionLessThanOrEqual) _then) = __$FilterExpressionLessThanOrEqualCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, double value
});




}
/// @nodoc
class __$FilterExpressionLessThanOrEqualCopyWithImpl<$Res>
    implements _$FilterExpressionLessThanOrEqualCopyWith<$Res> {
  __$FilterExpressionLessThanOrEqualCopyWithImpl(this._self, this._then);

  final _FilterExpressionLessThanOrEqual _self;
  final $Res Function(_FilterExpressionLessThanOrEqual) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? value = null,}) {
  return _then(_FilterExpressionLessThanOrEqual(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionGreaterThan implements FilterExpression {
  const _FilterExpressionGreaterThan({@JsonKey(toJson: _propertyToJson) required this.property, required this.value, final  String? $type}): $type = $type ?? 'GreaterThanFilter';
  factory _FilterExpressionGreaterThan.fromJson(Map<String, dynamic> json) => _$FilterExpressionGreaterThanFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  double value;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionGreaterThanCopyWith<_FilterExpressionGreaterThan> get copyWith => __$FilterExpressionGreaterThanCopyWithImpl<_FilterExpressionGreaterThan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionGreaterThanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionGreaterThan&&(identical(other.property, property) || other.property == property)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,value);

@override
String toString() {
  return 'FilterExpression.greaterThan(property: $property, value: $value)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionGreaterThanCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionGreaterThanCopyWith(_FilterExpressionGreaterThan value, $Res Function(_FilterExpressionGreaterThan) _then) = __$FilterExpressionGreaterThanCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, double value
});




}
/// @nodoc
class __$FilterExpressionGreaterThanCopyWithImpl<$Res>
    implements _$FilterExpressionGreaterThanCopyWith<$Res> {
  __$FilterExpressionGreaterThanCopyWithImpl(this._self, this._then);

  final _FilterExpressionGreaterThan _self;
  final $Res Function(_FilterExpressionGreaterThan) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? value = null,}) {
  return _then(_FilterExpressionGreaterThan(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _FilterExpressionGreaterThanOrEqual implements FilterExpression {
  const _FilterExpressionGreaterThanOrEqual({@JsonKey(toJson: _propertyToJson) required this.property, required this.value, final  String? $type}): $type = $type ?? 'GreaterThanOrEqualFilter';
  factory _FilterExpressionGreaterThanOrEqual.fromJson(Map<String, dynamic> json) => _$FilterExpressionGreaterThanOrEqualFromJson(json);

@JsonKey(toJson: _propertyToJson) final  TaskPropertyRef property;
 final  double value;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterExpressionGreaterThanOrEqualCopyWith<_FilterExpressionGreaterThanOrEqual> get copyWith => __$FilterExpressionGreaterThanOrEqualCopyWithImpl<_FilterExpressionGreaterThanOrEqual>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterExpressionGreaterThanOrEqualToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterExpressionGreaterThanOrEqual&&(identical(other.property, property) || other.property == property)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,value);

@override
String toString() {
  return 'FilterExpression.greaterThanOrEqual(property: $property, value: $value)';
}


}

/// @nodoc
abstract mixin class _$FilterExpressionGreaterThanOrEqualCopyWith<$Res> implements $FilterExpressionCopyWith<$Res> {
  factory _$FilterExpressionGreaterThanOrEqualCopyWith(_FilterExpressionGreaterThanOrEqual value, $Res Function(_FilterExpressionGreaterThanOrEqual) _then) = __$FilterExpressionGreaterThanOrEqualCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _propertyToJson) TaskPropertyRef property, double value
});




}
/// @nodoc
class __$FilterExpressionGreaterThanOrEqualCopyWithImpl<$Res>
    implements _$FilterExpressionGreaterThanOrEqualCopyWith<$Res> {
  __$FilterExpressionGreaterThanOrEqualCopyWithImpl(this._self, this._then);

  final _FilterExpressionGreaterThanOrEqual _self;
  final $Res Function(_FilterExpressionGreaterThanOrEqual) _then;

/// Create a copy of FilterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? property = null,Object? value = null,}) {
  return _then(_FilterExpressionGreaterThanOrEqual(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as TaskPropertyRef,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$TaskFilter {

 FilterExpression get filter;
/// Create a copy of TaskFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskFilterCopyWith<TaskFilter> get copyWith => _$TaskFilterCopyWithImpl<TaskFilter>(this as TaskFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskFilter&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,filter);

@override
String toString() {
  return 'TaskFilter(filter: $filter)';
}


}

/// @nodoc
abstract mixin class $TaskFilterCopyWith<$Res>  {
  factory $TaskFilterCopyWith(TaskFilter value, $Res Function(TaskFilter) _then) = _$TaskFilterCopyWithImpl;
@useResult
$Res call({
 FilterExpression filter
});


$FilterExpressionCopyWith<$Res> get filter;

}
/// @nodoc
class _$TaskFilterCopyWithImpl<$Res>
    implements $TaskFilterCopyWith<$Res> {
  _$TaskFilterCopyWithImpl(this._self, this._then);

  final TaskFilter _self;
  final $Res Function(TaskFilter) _then;

/// Create a copy of TaskFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filter = null,}) {
  return _then(_self.copyWith(
filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as FilterExpression,
  ));
}
/// Create a copy of TaskFilter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FilterExpressionCopyWith<$Res> get filter {
  
  return $FilterExpressionCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskFilter].
extension TaskFilterPatterns on TaskFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskFilter value)  $default,){
final _that = this;
switch (_that) {
case _TaskFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskFilter value)?  $default,){
final _that = this;
switch (_that) {
case _TaskFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FilterExpression filter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskFilter() when $default != null:
return $default(_that.filter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FilterExpression filter)  $default,) {final _that = this;
switch (_that) {
case _TaskFilter():
return $default(_that.filter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FilterExpression filter)?  $default,) {final _that = this;
switch (_that) {
case _TaskFilter() when $default != null:
return $default(_that.filter);case _:
  return null;

}
}

}

/// @nodoc


class _TaskFilter extends TaskFilter {
  const _TaskFilter(this.filter): super._();
  

@override final  FilterExpression filter;

/// Create a copy of TaskFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskFilterCopyWith<_TaskFilter> get copyWith => __$TaskFilterCopyWithImpl<_TaskFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskFilter&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,filter);

@override
String toString() {
  return 'TaskFilter(filter: $filter)';
}


}

/// @nodoc
abstract mixin class _$TaskFilterCopyWith<$Res> implements $TaskFilterCopyWith<$Res> {
  factory _$TaskFilterCopyWith(_TaskFilter value, $Res Function(_TaskFilter) _then) = __$TaskFilterCopyWithImpl;
@override @useResult
$Res call({
 FilterExpression filter
});


@override $FilterExpressionCopyWith<$Res> get filter;

}
/// @nodoc
class __$TaskFilterCopyWithImpl<$Res>
    implements _$TaskFilterCopyWith<$Res> {
  __$TaskFilterCopyWithImpl(this._self, this._then);

  final _TaskFilter _self;
  final $Res Function(_TaskFilter) _then;

/// Create a copy of TaskFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filter = null,}) {
  return _then(_TaskFilter(
null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as FilterExpression,
  ));
}

/// Create a copy of TaskFilter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FilterExpressionCopyWith<$Res> get filter {
  
  return $FilterExpressionCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}

// dart format on
