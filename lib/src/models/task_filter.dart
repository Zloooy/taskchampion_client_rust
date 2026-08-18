import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'task_property_ref.dart';

part 'task_filter.freezed.dart';
part 'task_filter.g.dart';

/// Serializes a [TaskPropertyRef] to its JSON form. Used as a named `toJson`
/// so json_serializable recurses into the property reference instead of
/// storing a raw object in the output map.
Map<String, dynamic> _propertyToJson(TaskPropertyRef value) => value.toJson();

/// Serializes a list of nested [FilterExpression]s to a list of JSON maps.
/// Used as a named `toJson` so json_serializable recurses into each child
/// expression instead of storing raw objects in the output map.
List<Map<String, dynamic>> _filtersToJson(List<FilterExpression> value) =>
    value.map((e) => e.toJson()).toList();

/// Serializes a single nested [FilterExpression] to its JSON map form. Used as
/// a named `toJson` so json_serializable recurses into the inner expression
/// (e.g. for the `Not` variant) instead of storing a raw object.
Map<String, dynamic> _innerToJson(FilterExpression value) => value.toJson();

/// Main filter expression type (taskwarrior-compatible)
@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.pascal)
abstract class FilterExpression with _$FilterExpression {
  @FreezedUnionValue('AndGroup')
  const factory FilterExpression.andGroup({
    @JsonKey(toJson: _filtersToJson) required List<FilterExpression> filters,
  }) = _FilterExpressionAndGroup;

  @FreezedUnionValue('OrGroup')
  const factory FilterExpression.orGroup({
    @JsonKey(toJson: _filtersToJson) required List<FilterExpression> filters,
  }) = _FilterExpressionOrGroup;

  @FreezedUnionValue('XorGroup')
  const factory FilterExpression.xorGroup({
    @JsonKey(toJson: _filtersToJson) required List<FilterExpression> filters,
  }) = _FilterExpressionXorGroup;

  @FreezedUnionValue('Not')
  const factory FilterExpression.not({
    @JsonKey(toJson: _innerToJson) required FilterExpression inner,
  }) = _FilterExpressionNot;

  @FreezedUnionValue('Tag')
  const factory FilterExpression.tag({
    required String tag,
    @Default(false) bool exclude,
  }) = _FilterExpressionTag;

  @FreezedUnionValue('VirtualTag')
  const factory FilterExpression.virtualTag({
    required String tag,
    @Default(false) bool exclude,
  }) = _FilterExpressionVirtualTag;

  @FreezedUnionValue('EqualsFilter')
  const factory FilterExpression.equals({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required dynamic value,
  }) = _FilterExpressionEquals;

  @FreezedUnionValue('NotEqualsFilter')
  const factory FilterExpression.notEquals({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required dynamic value,
  }) = _FilterExpressionNotEquals;

  @FreezedUnionValue('InFilter')
  const factory FilterExpression.inValues({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required List<dynamic> values,
  }) = _FilterExpressionInValues;

  @FreezedUnionValue('NotInFilter')
  const factory FilterExpression.notInValues({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required List<dynamic> values,
  }) = _FilterExpressionNotInValues;

  @FreezedUnionValue('ContainsFilter')
  const factory FilterExpression.contains({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required String value,
    @Default(false)
    @JsonKey(name: 'case_sensitive')
    bool caseSensitive,
  }) = _FilterExpressionContains;

  @FreezedUnionValue('NotContainsFilter')
  const factory FilterExpression.notContains({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required String value,
    @Default(false)
    @JsonKey(name: 'case_sensitive')
    bool caseSensitive,
  }) = _FilterExpressionNotContains;

  @FreezedUnionValue('StartsWithFilter')
  const factory FilterExpression.startsWith({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required String value,
    @Default(false)
    @JsonKey(name: 'case_sensitive')
    bool caseSensitive,
  }) = _FilterExpressionStartsWith;

  @FreezedUnionValue('EndsWithFilter')
  const factory FilterExpression.endsWith({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required String value,
    @Default(false)
    @JsonKey(name: 'case_sensitive')
    bool caseSensitive,
  }) = _FilterExpressionEndsWith;

  @FreezedUnionValue('WordFilter')
  const factory FilterExpression.word({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required String value,
    @Default(false)
    @JsonKey(name: 'case_sensitive')
    bool caseSensitive,
  }) = _FilterExpressionWord;

  @FreezedUnionValue('NoWordFilter')
  const factory FilterExpression.noWord({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required String value,
    @Default(false)
    @JsonKey(name: 'case_sensitive')
    bool caseSensitive,
  }) = _FilterExpressionNoWord;

  @FreezedUnionValue('RegexFilter')
  const factory FilterExpression.regex({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required String pattern,
    @Default(false)
    @JsonKey(name: 'case_sensitive')
    bool caseSensitive,
  }) = _FilterExpressionRegex;

  @FreezedUnionValue('NoneFilter')
  const factory FilterExpression.none({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
  }) = _FilterExpressionNone;

  @FreezedUnionValue('AnyFilter')
  const factory FilterExpression.any({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
  }) = _FilterExpressionAny;

  @FreezedUnionValue('DateBeforeFilter')
  const factory FilterExpression.dateBefore({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required DateTime date,
  }) = _FilterExpressionDateBefore;

  @FreezedUnionValue('DateAfterFilter')
  const factory FilterExpression.dateAfter({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required DateTime date,
  }) = _FilterExpressionDateAfter;

  @FreezedUnionValue('DateByFilter')
  const factory FilterExpression.dateBy({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required DateTime date,
  }) = _FilterExpressionDateBy;

  @FreezedUnionValue('DateFromFilter')
  const factory FilterExpression.dateFrom({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required DateTime from,
  }) = _FilterExpressionDateFrom;

  @FreezedUnionValue('DateToFilter')
  const factory FilterExpression.dateTo({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required DateTime to,
  }) = _FilterExpressionDateTo;

  @FreezedUnionValue('LessThanFilter')
  const factory FilterExpression.lessThan({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required double value,
  }) = _FilterExpressionLessThan;

  @FreezedUnionValue('LessThanOrEqualFilter')
  const factory FilterExpression.lessThanOrEqual({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required double value,
  }) = _FilterExpressionLessThanOrEqual;

  @FreezedUnionValue('GreaterThanFilter')
  const factory FilterExpression.greaterThan({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required double value,
  }) = _FilterExpressionGreaterThan;

  @FreezedUnionValue('GreaterThanOrEqualFilter')
  const factory FilterExpression.greaterThanOrEqual({
    @JsonKey(toJson: _propertyToJson) required TaskPropertyRef property,
    required double value,
  }) = _FilterExpressionGreaterThanOrEqual;

  factory FilterExpression.fromJson(Map<String, dynamic> json) =>
      _$FilterExpressionFromJson(json);
}

/// Main filter class that wraps a filter expression
class TaskFilter {
  final FilterExpression filter;

  const TaskFilter(this.filter);

  /// Match all tasks (empty filter)
  static const TaskFilter matchAll = TaskFilter(
    FilterExpression.andGroup(filters: []),
  );

  /// Create a filter that matches tasks with a specific tag
  static TaskFilter hasTag(String tag) =>
      TaskFilter(FilterExpression.tag(tag: tag, exclude: false));

  /// Create a filter that excludes tasks with a specific tag
  static TaskFilter excludeTag(String tag) =>
      TaskFilter(FilterExpression.tag(tag: tag, exclude: true));

  /// Create a filter for virtual tags (e.g., ACTIVE, PENDING, BLOCKED)
  static TaskFilter virtualTag(String tag, {bool exclude = false}) => TaskFilter(
        FilterExpression.virtualTag(
          tag: tag.toUpperCase(),
          exclude: exclude,
        ),
      );

  /// Serialize filter to JSON string for passing to Rust
  String toJson() => jsonEncode({'filter': filter.toJson()});

  /// Deserialize filter from JSON string received from Rust
  factory TaskFilter.fromJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return TaskFilter(
      FilterExpression.fromJson(decoded['filter'] as Map<String, dynamic>),
    );
  }
}

/// Common property references
extension TaskPropertyRefs on TaskFilter {
  static const description = StringPropertyRef('description');
  static const status = StringPropertyRef('status');
  static const priority = StringPropertyRef('priority');
  static const project = StringPropertyRef('project');
  static const due = DateTimePropertyRef('due');
  static const wait = DateTimePropertyRef('wait');
  static const entry = DateTimePropertyRef('entry');
  static const modified = DateTimePropertyRef('modified');
  static const scheduled = DateTimePropertyRef('scheduled');
  static const until = DateTimePropertyRef('until');
  static const id = IntPropertyRef('id');
  static const urgency = DoublePropertyRef('urgency');
}
