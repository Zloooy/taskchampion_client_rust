import 'dart:convert';

import 'package:taskchampion_client_rust/src/models/task_property_ref.dart';

/// Main filter class that wraps a filter expression
class TaskFilter {
  final FilterExpression filter;

  const TaskFilter(this.filter);

  /// Match all tasks (empty filter)
  static const TaskFilter matchAll = TaskFilter(AndFilterGroup([]));

  /// Create a filter that matches tasks with a specific tag
  static TaskFilter hasTag(String tag) => TaskFilter(TagFilter(tag: tag, exclude: false));

  /// Create a filter that excludes tasks with a specific tag
  static TaskFilter excludeTag(String tag) => TaskFilter(TagFilter(tag: tag, exclude: true));

  /// Create a filter for virtual tags (e.g., ACTIVE, PENDING, BLOCKED)
  static TaskFilter virtualTag(String tag, {bool exclude = false}) =>
      TaskFilter(VirtualTagFilter(tag: tag.toUpperCase(), exclude: exclude));

  /// Serialize filter to JSON string for passing to Rust
  String toJson() => jsonEncode(filter.toJson());
}

/// Base sealed class for all filter expressions
sealed class FilterExpression {
  const FilterExpression();

  Map<String, dynamic> toJson();
}

/// A container for a list of property filters combined with a logical operator
sealed class FilterGroup extends FilterExpression {
  final List<FilterExpression> filters;

  const FilterGroup(this.filters);

  @override
  String toString() => 'FilterGroup(${filters.length} filters)';

  @override
  Map<String, dynamic> toJson();
}

/// Combines all contained filters with logical AND
final class AndFilterGroup extends FilterGroup {
  const AndFilterGroup(super.filters);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'AndGroup',
        'filters': filters.map((f) => f.toJson()).toList(),
      };
}

/// Combines all contained filters with logical OR
final class OrFilterGroup extends FilterGroup {
  const OrFilterGroup(super.filters);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'OrGroup',
        'filters': filters.map((f) => f.toJson()).toList(),
      };
}

/// Combines all contained filters with logical XOR
/// Matches if exactly one of the contained filters matches
final class XorFilterGroup extends FilterGroup {
  const XorFilterGroup(super.filters);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'XorGroup',
        'filters': filters.map((f) => f.toJson()).toList(),
      };
}

/// Negates a single filter expression
final class NotFilter extends FilterExpression {
  final FilterExpression inner;

  const NotFilter(this.inner);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'Not',
        'inner': inner.toJson(),
      };
}

/// Base class for filters on a property of type T
sealed class PropertyFilter<T> extends FilterExpression {
  final TaskPropertyRef<T> property;

  const PropertyFilter(this.property);

  @override
  Map<String, dynamic> toJson();
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

// ============================================================================
// String Comparison Filters (taskwarrior attribute modifiers)
// ============================================================================

/// Matches if the property value is exactly equal to [value] (==)
/// Equivalent to `.is:` or `=` modifier in taskwarrior
final class EqualsFilter<T> extends PropertyFilter<T> {
  final T value;

  const EqualsFilter({
    required TaskPropertyRef<T> property,
    required this.value,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'EqualsFilter',
        'property': property.toJson(),
        'value': value is DateTime ? (value as DateTime).toIso8601String() : value,
      };
}

/// Matches if the property value is NOT equal to [value] (!=)
/// Equivalent to `.isnt:`, `.not:`, or `!=` modifier in taskwarrior
final class NotEqualsFilter<T> extends PropertyFilter<T> {
  final T value;

  const NotEqualsFilter({
    required TaskPropertyRef<T> property,
    required this.value,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'NotEqualsFilter',
        'property': property.toJson(),
        'value': value is DateTime ? (value as DateTime).toIso8601String() : value,
      };
}

/// Matches if the property value is in the set [values]
final class InFilter<T> extends PropertyFilter<T> {
  final Set<T> values;

  const InFilter({
    required TaskPropertyRef<T> property,
    required this.values,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'InFilter',
        'property': property.toJson(),
        'values': values
            .map((v) => v is DateTime ? (v as DateTime).toIso8601String() : v)
            .toList(),
      };
}

/// Matches if the property value is NOT in the set [values]
final class NotInFilter<T> extends PropertyFilter<T> {
  final Set<T> values;

  const NotInFilter({
    required TaskPropertyRef<T> property,
    required this.values,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'NotInFilter',
        'property': property.toJson(),
        'values': values
            .map((v) => v is DateTime ? (v as DateTime).toIso8601String() : v)
            .toList(),
      };
}

// ============================================================================
// String Pattern Matching Filters
// ============================================================================

/// Matches if the string value contains [value] as a substring
/// Equivalent to `.has:`, `.contains:` modifier in taskwarrior
final class ContainsFilter extends PropertyFilter<String> {
  final String value;
  final bool caseSensitive;

  const ContainsFilter({
    required TaskPropertyRef<String> property,
    required this.value,
    this.caseSensitive = false,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'ContainsFilter',
        'property': property.toJson(),
        'value': value,
        'case_sensitive': caseSensitive,
      };
}

/// Matches if the string value does NOT contain [value] as a substring
/// Equivalent to `.hasnt:` modifier in taskwarrior
final class NotContainsFilter extends PropertyFilter<String> {
  final String value;
  final bool caseSensitive;

  const NotContainsFilter({
    required TaskPropertyRef<String> property,
    required this.value,
    this.caseSensitive = false,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'NotContainsFilter',
        'property': property.toJson(),
        'value': value,
        'case_sensitive': caseSensitive,
      };
}

/// Matches if the string value starts with [value]
/// Equivalent to `.startswith:`, `.left:` modifier in taskwarrior
final class StartsWithFilter extends PropertyFilter<String> {
  final String value;
  final bool caseSensitive;

  const StartsWithFilter({
    required TaskPropertyRef<String> property,
    required this.value,
    this.caseSensitive = false,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'StartsWithFilter',
        'property': property.toJson(),
        'value': value,
        'case_sensitive': caseSensitive,
      };
}

/// Matches if the string value ends with [value]
/// Equivalent to `.endswith:`, `.right:` modifier in taskwarrior
final class EndsWithFilter extends PropertyFilter<String> {
  final String value;
  final bool caseSensitive;

  const EndsWithFilter({
    required TaskPropertyRef<String> property,
    required this.value,
    this.caseSensitive = false,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'EndsWithFilter',
        'property': property.toJson(),
        'value': value,
        'case_sensitive': caseSensitive,
      };
}

/// Matches if the string value contains [value] as a whole word
/// Equivalent to `.word:` modifier in taskwarrior
final class WordFilter extends PropertyFilter<String> {
  final String value;
  final bool caseSensitive;

  const WordFilter({
    required TaskPropertyRef<String> property,
    required this.value,
    this.caseSensitive = false,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'WordFilter',
        'property': property.toJson(),
        'value': value,
        'case_sensitive': caseSensitive,
      };
}

/// Matches if the string value does NOT contain [value] as a whole word
/// Equivalent to `.noword:` modifier in taskwarrior
final class NoWordFilter extends PropertyFilter<String> {
  final String value;
  final bool caseSensitive;

  const NoWordFilter({
    required TaskPropertyRef<String> property,
    required this.value,
    this.caseSensitive = false,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'NoWordFilter',
        'property': property.toJson(),
        'value': value,
        'case_sensitive': caseSensitive,
      };
}

// ============================================================================
// Presence Filters (none/any modifiers)
// ============================================================================

/// Matches if the property has NO value (is empty/null)
/// Equivalent to `.none:` modifier in taskwarrior
final class NoneFilter<T> extends PropertyFilter<T> {
  const NoneFilter({
    required TaskPropertyRef<T> property,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'NoneFilter',
        'property': property.toJson(),
      };
}

/// Matches if the property has ANY value (is not empty/null)
/// Equivalent to `.any:` modifier in taskwarrior
final class AnyFilter<T> extends PropertyFilter<T> {
  const AnyFilter({
    required TaskPropertyRef<T> property,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'AnyFilter',
        'property': property.toJson(),
      };
}

// ============================================================================
// Date/Time Comparison Filters
// ============================================================================

/// Matches if the date property is before [date] (<)
/// Equivalent to `.before:`, `.under:`, `.below:` modifier in taskwarrior
final class DateBeforeFilter extends PropertyFilter<DateTime> {
  final DateTime date;

  const DateBeforeFilter({
    required TaskPropertyRef<DateTime> property,
    required this.date,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DateBeforeFilter',
        'property': property.toJson(),
        'date': date.toIso8601String(),
      };
}

/// Matches if the date property is after [date] (>)
/// Equivalent to `.after:`, `.over:`, `.above:` modifier in taskwarrior
final class DateAfterFilter extends PropertyFilter<DateTime> {
  final DateTime date;

  const DateAfterFilter({
    required TaskPropertyRef<DateTime> property,
    required this.date,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DateAfterFilter',
        'property': property.toJson(),
        'date': date.toIso8601String(),
      };
}

/// Matches if the date property is on or before [date] (<=)
/// Equivalent to `.by:` modifier in taskwarrior (inclusive before)
final class DateByFilter extends PropertyFilter<DateTime> {
  final DateTime date;

  const DateByFilter({
    required TaskPropertyRef<DateTime> property,
    required this.date,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DateByFilter',
        'property': property.toJson(),
        'date': date.toIso8601String(),
      };
}

/// Matches tasks where the property value is greater than or equal to [date]
final class DateFromFilter extends PropertyFilter<DateTime> {
  final DateTime from;

  const DateFromFilter({
    required TaskPropertyRef<DateTime> property,
    required this.from,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DateFromFilter',
        'property': property.toJson(),
        'from': from.toIso8601String(),
      };
}

/// Matches tasks where the property value is less than or equal to [date]
final class DateToFilter extends PropertyFilter<DateTime> {
  final DateTime to;

  const DateToFilter({
    required TaskPropertyRef<DateTime> property,
    required this.to,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DateToFilter',
        'property': property.toJson(),
        'to': to.toIso8601String(),
      };
}

// ============================================================================
// Numeric Comparison Filters
// ============================================================================

/// Matches if the numeric property is less than [value] (<)
final class LessThanFilter extends PropertyFilter<num> {
  final num value;

  const LessThanFilter({
    required TaskPropertyRef<num> property,
    required this.value,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'LessThanFilter',
        'property': property.toJson(),
        'value': value,
      };
}

/// Matches if the numeric property is less than or equal to [value] (<=)
final class LessThanOrEqualFilter extends PropertyFilter<num> {
  final num value;

  const LessThanOrEqualFilter({
    required TaskPropertyRef<num> property,
    required this.value,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'LessThanOrEqualFilter',
        'property': property.toJson(),
        'value': value,
      };
}

/// Matches if the numeric property is greater than [value] (>)
final class GreaterThanFilter extends PropertyFilter<num> {
  final num value;

  const GreaterThanFilter({
    required TaskPropertyRef<num> property,
    required this.value,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'GreaterThanFilter',
        'property': property.toJson(),
        'value': value,
      };
}

/// Matches if the numeric property is greater than or equal to [value] (>=)
final class GreaterThanOrEqualFilter extends PropertyFilter<num> {
  final num value;

  const GreaterThanOrEqualFilter({
    required TaskPropertyRef<num> property,
    required this.value,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'GreaterThanOrEqualFilter',
        'property': property.toJson(),
        'value': value,
      };
}

// ============================================================================
// Tag Filters (taskwarrior +tag / -tag syntax)
// ============================================================================

/// Filter for tasks that have (or don't have) a specific tag
final class TagFilter extends FilterExpression {
  final String tag;
  final bool exclude;

  const TagFilter({
    required this.tag,
    this.exclude = false,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'Tag',
        'tag': tag,
        'exclude': exclude,
      };
}

// ============================================================================
// Virtual Tag Filters (taskwarrior +ACTIVE, -DELETED, etc.)
// ============================================================================

/// Filter for virtual tags that are computed from task state
/// Virtual tags include: ACTIVE, ANNOTATED, BLOCKED, BLOCKING, COMPLETED,
/// DELETED, DUE, DUETODAY, INSTANCE, LATEST, MONTH, ORPHAN, OVERDUE, PARENT,
/// PENDING, PRIORITY, PROJECT, QUARTER, READY, SCHEDULED, TAGGED, TEMPLATE,
/// TODAY, TOMORROW, UDA, UNBLOCKED, UNTIL, WAITING, WEEK, YEAR, YESTERDAY
final class VirtualTagFilter extends FilterExpression {
  final String tag;
  final bool exclude;

  const VirtualTagFilter({
    required this.tag,
    this.exclude = false,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'VirtualTag',
        'tag': tag.toUpperCase(),
        'exclude': exclude,
      };
}

// ============================================================================
// Regex Filter (for advanced pattern matching)
// ============================================================================

/// Matches if the string value matches a regex pattern
final class RegexFilter extends PropertyFilter<String> {
  final String pattern;
  final bool caseSensitive;

  const RegexFilter({
    required TaskPropertyRef<String> property,
    required this.pattern,
    this.caseSensitive = false,
  }) : super(property);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'RegexFilter',
        'property': property.toJson(),
        'pattern': pattern,
        'case_sensitive': caseSensitive,
      };
}
