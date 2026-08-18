// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FilterExpressionAndGroup _$FilterExpressionAndGroupFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionAndGroup(
  filters: (json['filters'] as List<dynamic>)
      .map((e) => FilterExpression.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionAndGroupToJson(
  _FilterExpressionAndGroup instance,
) => <String, dynamic>{
  'filters': _filtersToJson(instance.filters),
  'type': instance.$type,
};

_FilterExpressionOrGroup _$FilterExpressionOrGroupFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionOrGroup(
  filters: (json['filters'] as List<dynamic>)
      .map((e) => FilterExpression.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionOrGroupToJson(
  _FilterExpressionOrGroup instance,
) => <String, dynamic>{
  'filters': _filtersToJson(instance.filters),
  'type': instance.$type,
};

_FilterExpressionXorGroup _$FilterExpressionXorGroupFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionXorGroup(
  filters: (json['filters'] as List<dynamic>)
      .map((e) => FilterExpression.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionXorGroupToJson(
  _FilterExpressionXorGroup instance,
) => <String, dynamic>{
  'filters': _filtersToJson(instance.filters),
  'type': instance.$type,
};

_FilterExpressionNot _$FilterExpressionNotFromJson(Map<String, dynamic> json) =>
    _FilterExpressionNot(
      inner: FilterExpression.fromJson(json['inner'] as Map<String, dynamic>),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$FilterExpressionNotToJson(
  _FilterExpressionNot instance,
) => <String, dynamic>{
  'inner': _innerToJson(instance.inner),
  'type': instance.$type,
};

_FilterExpressionTag _$FilterExpressionTagFromJson(Map<String, dynamic> json) =>
    _FilterExpressionTag(
      tag: json['tag'] as String,
      exclude: json['exclude'] as bool? ?? false,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$FilterExpressionTagToJson(
  _FilterExpressionTag instance,
) => <String, dynamic>{
  'tag': instance.tag,
  'exclude': instance.exclude,
  'type': instance.$type,
};

_FilterExpressionVirtualTag _$FilterExpressionVirtualTagFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionVirtualTag(
  tag: json['tag'] as String,
  exclude: json['exclude'] as bool? ?? false,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionVirtualTagToJson(
  _FilterExpressionVirtualTag instance,
) => <String, dynamic>{
  'tag': instance.tag,
  'exclude': instance.exclude,
  'type': instance.$type,
};

_FilterExpressionEquals _$FilterExpressionEqualsFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionEquals(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  value: json['value'],
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionEqualsToJson(
  _FilterExpressionEquals instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'value': instance.value,
  'type': instance.$type,
};

_FilterExpressionNotEquals _$FilterExpressionNotEqualsFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionNotEquals(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  value: json['value'],
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionNotEqualsToJson(
  _FilterExpressionNotEquals instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'value': instance.value,
  'type': instance.$type,
};

_FilterExpressionInValues _$FilterExpressionInValuesFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionInValues(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  values: json['values'] as List<dynamic>,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionInValuesToJson(
  _FilterExpressionInValues instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'values': instance.values,
  'type': instance.$type,
};

_FilterExpressionNotInValues _$FilterExpressionNotInValuesFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionNotInValues(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  values: json['values'] as List<dynamic>,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionNotInValuesToJson(
  _FilterExpressionNotInValues instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'values': instance.values,
  'type': instance.$type,
};

_FilterExpressionContains _$FilterExpressionContainsFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionContains(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  value: json['value'] as String,
  caseSensitive: json['case_sensitive'] as bool? ?? false,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionContainsToJson(
  _FilterExpressionContains instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'value': instance.value,
  'case_sensitive': instance.caseSensitive,
  'type': instance.$type,
};

_FilterExpressionNotContains _$FilterExpressionNotContainsFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionNotContains(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  value: json['value'] as String,
  caseSensitive: json['case_sensitive'] as bool? ?? false,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionNotContainsToJson(
  _FilterExpressionNotContains instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'value': instance.value,
  'case_sensitive': instance.caseSensitive,
  'type': instance.$type,
};

_FilterExpressionStartsWith _$FilterExpressionStartsWithFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionStartsWith(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  value: json['value'] as String,
  caseSensitive: json['case_sensitive'] as bool? ?? false,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionStartsWithToJson(
  _FilterExpressionStartsWith instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'value': instance.value,
  'case_sensitive': instance.caseSensitive,
  'type': instance.$type,
};

_FilterExpressionEndsWith _$FilterExpressionEndsWithFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionEndsWith(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  value: json['value'] as String,
  caseSensitive: json['case_sensitive'] as bool? ?? false,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionEndsWithToJson(
  _FilterExpressionEndsWith instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'value': instance.value,
  'case_sensitive': instance.caseSensitive,
  'type': instance.$type,
};

_FilterExpressionWord _$FilterExpressionWordFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionWord(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  value: json['value'] as String,
  caseSensitive: json['case_sensitive'] as bool? ?? false,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionWordToJson(
  _FilterExpressionWord instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'value': instance.value,
  'case_sensitive': instance.caseSensitive,
  'type': instance.$type,
};

_FilterExpressionNoWord _$FilterExpressionNoWordFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionNoWord(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  value: json['value'] as String,
  caseSensitive: json['case_sensitive'] as bool? ?? false,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionNoWordToJson(
  _FilterExpressionNoWord instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'value': instance.value,
  'case_sensitive': instance.caseSensitive,
  'type': instance.$type,
};

_FilterExpressionRegex _$FilterExpressionRegexFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionRegex(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  pattern: json['pattern'] as String,
  caseSensitive: json['case_sensitive'] as bool? ?? false,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionRegexToJson(
  _FilterExpressionRegex instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'pattern': instance.pattern,
  'case_sensitive': instance.caseSensitive,
  'type': instance.$type,
};

_FilterExpressionNone _$FilterExpressionNoneFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionNone(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionNoneToJson(
  _FilterExpressionNone instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'type': instance.$type,
};

_FilterExpressionAny _$FilterExpressionAnyFromJson(Map<String, dynamic> json) =>
    _FilterExpressionAny(
      property: TaskPropertyRef.fromJson(
        json['property'] as Map<String, dynamic>,
      ),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$FilterExpressionAnyToJson(
  _FilterExpressionAny instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'type': instance.$type,
};

_FilterExpressionDateBefore _$FilterExpressionDateBeforeFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionDateBefore(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  date: DateTime.parse(json['date'] as String),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionDateBeforeToJson(
  _FilterExpressionDateBefore instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'date': instance.date.toIso8601String(),
  'type': instance.$type,
};

_FilterExpressionDateAfter _$FilterExpressionDateAfterFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionDateAfter(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  date: DateTime.parse(json['date'] as String),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionDateAfterToJson(
  _FilterExpressionDateAfter instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'date': instance.date.toIso8601String(),
  'type': instance.$type,
};

_FilterExpressionDateBy _$FilterExpressionDateByFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionDateBy(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  date: DateTime.parse(json['date'] as String),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionDateByToJson(
  _FilterExpressionDateBy instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'date': instance.date.toIso8601String(),
  'type': instance.$type,
};

_FilterExpressionDateFrom _$FilterExpressionDateFromFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionDateFrom(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  from: DateTime.parse(json['from'] as String),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionDateFromToJson(
  _FilterExpressionDateFrom instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'from': instance.from.toIso8601String(),
  'type': instance.$type,
};

_FilterExpressionDateTo _$FilterExpressionDateToFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionDateTo(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  to: DateTime.parse(json['to'] as String),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionDateToToJson(
  _FilterExpressionDateTo instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'to': instance.to.toIso8601String(),
  'type': instance.$type,
};

_FilterExpressionLessThan _$FilterExpressionLessThanFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionLessThan(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  value: (json['value'] as num).toDouble(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionLessThanToJson(
  _FilterExpressionLessThan instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'value': instance.value,
  'type': instance.$type,
};

_FilterExpressionLessThanOrEqual _$FilterExpressionLessThanOrEqualFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionLessThanOrEqual(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  value: (json['value'] as num).toDouble(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionLessThanOrEqualToJson(
  _FilterExpressionLessThanOrEqual instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'value': instance.value,
  'type': instance.$type,
};

_FilterExpressionGreaterThan _$FilterExpressionGreaterThanFromJson(
  Map<String, dynamic> json,
) => _FilterExpressionGreaterThan(
  property: TaskPropertyRef.fromJson(json['property'] as Map<String, dynamic>),
  value: (json['value'] as num).toDouble(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FilterExpressionGreaterThanToJson(
  _FilterExpressionGreaterThan instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'value': instance.value,
  'type': instance.$type,
};

_FilterExpressionGreaterThanOrEqual
_$FilterExpressionGreaterThanOrEqualFromJson(Map<String, dynamic> json) =>
    _FilterExpressionGreaterThanOrEqual(
      property: TaskPropertyRef.fromJson(
        json['property'] as Map<String, dynamic>,
      ),
      value: (json['value'] as num).toDouble(),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$FilterExpressionGreaterThanOrEqualToJson(
  _FilterExpressionGreaterThanOrEqual instance,
) => <String, dynamic>{
  'property': _propertyToJson(instance.property),
  'value': instance.value,
  'type': instance.$type,
};
