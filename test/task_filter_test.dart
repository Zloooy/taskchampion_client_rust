import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskchampion_client_rust/src/models/models.dart';

void main() {
  group('wire format', () {
    const prop = StringPropertyRef('description');

    test('andGroup', () {
      final expr = FilterExpression.andGroup(filters: [
        FilterExpression.tag(tag: 't1', exclude: false),
        FilterExpression.tag(tag: 't2', exclude: true),
      ]);
      expect(expr.toJson(), {
        'type': 'AndGroup',
        'filters': [
          {'type': 'Tag', 'tag': 't1', 'exclude': false},
          {'type': 'Tag', 'tag': 't2', 'exclude': true},
        ],
      });
    });

    test('orGroup', () {
      final expr = FilterExpression.orGroup(filters: [
        FilterExpression.equals(property: prop, value: 'a'),
      ]);
      expect(expr.toJson(), {
        'type': 'OrGroup',
        'filters': [
          {
            'type': 'EqualsFilter',
            'property': {'name': 'description'},
            'value': 'a',
          },
        ],
      });
    });

    test('xorGroup', () {
      final expr = FilterExpression.xorGroup(filters: []);
      expect(expr.toJson(), {
        'type': 'XorGroup',
        'filters': <Map<String, Object?>>[],
      });
    });

    test('not', () {
      final expr = FilterExpression.not(
        inner: FilterExpression.equals(property: prop, value: 'x'),
      );
      expect(expr.toJson(), {
        'type': 'Not',
        'inner': {
          'type': 'EqualsFilter',
          'property': {'name': 'description'},
          'value': 'x',
        },
      });
    });

    test('tag', () {
      final expr = FilterExpression.tag(tag: 'home', exclude: false);
      expect(expr.toJson(), {
        'type': 'Tag',
        'tag': 'home',
        'exclude': false,
      });
    });

    test('virtualTag', () {
      final expr = FilterExpression.virtualTag(tag: 'PENDING', exclude: true);
      expect(expr.toJson(), {
        'type': 'VirtualTag',
        'tag': 'PENDING',
        'exclude': true,
      });
    });

    test('equals', () {
      final expr = FilterExpression.equals(property: prop, value: 'val');
      expect(expr.toJson(), {
        'type': 'EqualsFilter',
        'property': {'name': 'description'},
        'value': 'val',
      });
    });

    test('notEquals', () {
      final expr = FilterExpression.notEquals(property: prop, value: 'val');
      expect(expr.toJson(), {
        'type': 'NotEqualsFilter',
        'property': {'name': 'description'},
        'value': 'val',
      });
    });

    test('inValues', () {
      final expr = FilterExpression.inValues(property: prop, values: ['a', 'b']);
      expect(expr.toJson(), {
        'type': 'InFilter',
        'property': {'name': 'description'},
        'values': ['a', 'b'],
      });
    });

    test('notInValues', () {
      final expr =
          FilterExpression.notInValues(property: prop, values: ['a', 'b']);
      expect(expr.toJson(), {
        'type': 'NotInFilter',
        'property': {'name': 'description'},
        'values': ['a', 'b'],
      });
    });

    test('contains', () {
      final expr = FilterExpression.contains(
        property: prop,
        value: 'v',
        caseSensitive: true,
      );
      expect(expr.toJson(), {
        'type': 'ContainsFilter',
        'property': {'name': 'description'},
        'value': 'v',
        'case_sensitive': true,
      });
    });

    test('notContains', () {
      final expr = FilterExpression.notContains(
        property: prop,
        value: 'v',
        caseSensitive: false,
      );
      expect(expr.toJson(), {
        'type': 'NotContainsFilter',
        'property': {'name': 'description'},
        'value': 'v',
        'case_sensitive': false,
      });
    });

    test('startsWith', () {
      final expr = FilterExpression.startsWith(
        property: prop,
        value: 'v',
        caseSensitive: true,
      );
      expect(expr.toJson(), {
        'type': 'StartsWithFilter',
        'property': {'name': 'description'},
        'value': 'v',
        'case_sensitive': true,
      });
    });

    test('endsWith', () {
      final expr = FilterExpression.endsWith(
        property: prop,
        value: 'v',
        caseSensitive: false,
      );
      expect(expr.toJson(), {
        'type': 'EndsWithFilter',
        'property': {'name': 'description'},
        'value': 'v',
        'case_sensitive': false,
      });
    });

    test('word', () {
      final expr = FilterExpression.word(
        property: prop,
        value: 'v',
        caseSensitive: true,
      );
      expect(expr.toJson(), {
        'type': 'WordFilter',
        'property': {'name': 'description'},
        'value': 'v',
        'case_sensitive': true,
      });
    });

    test('noWord', () {
      final expr = FilterExpression.noWord(
        property: prop,
        value: 'v',
        caseSensitive: false,
      );
      expect(expr.toJson(), {
        'type': 'NoWordFilter',
        'property': {'name': 'description'},
        'value': 'v',
        'case_sensitive': false,
      });
    });

    test('regex', () {
      final expr = FilterExpression.regex(
        property: prop,
        pattern: r'^\d+$',
        caseSensitive: true,
      );
      expect(expr.toJson(), {
        'type': 'RegexFilter',
        'property': {'name': 'description'},
        'pattern': r'^\d+$',
        'case_sensitive': true,
      });
    });

    test('none', () {
      final expr = FilterExpression.none(property: prop);
      expect(expr.toJson(), {
        'type': 'NoneFilter',
        'property': {'name': 'description'},
      });
    });

    test('any', () {
      final expr = FilterExpression.any(property: prop);
      expect(expr.toJson(), {
        'type': 'AnyFilter',
        'property': {'name': 'description'},
      });
    });

    test('dateBefore', () {
      final dt = DateTime.utc(2024, 1, 1, 12, 0, 0);
      final expr = FilterExpression.dateBefore(property: prop, date: dt);
      expect(expr.toJson(), {
        'type': 'DateBeforeFilter',
        'property': {'name': 'description'},
        'date': '2024-01-01T12:00:00.000Z',
      });
    });

    test('dateAfter', () {
      final dt = DateTime.utc(2024, 6, 15, 0, 0, 0);
      final expr = FilterExpression.dateAfter(property: prop, date: dt);
      expect(expr.toJson(), {
        'type': 'DateAfterFilter',
        'property': {'name': 'description'},
        'date': '2024-06-15T00:00:00.000Z',
      });
    });

    test('dateBy', () {
      final dt = DateTime.utc(2024, 3, 3, 3, 3, 3);
      final expr = FilterExpression.dateBy(property: prop, date: dt);
      expect(expr.toJson(), {
        'type': 'DateByFilter',
        'property': {'name': 'description'},
        'date': '2024-03-03T03:03:03.000Z',
      });
    });

    test('dateFrom', () {
      final dt = DateTime.utc(2024, 1, 1);
      final expr = FilterExpression.dateFrom(property: prop, from: dt);
      expect(expr.toJson(), {
        'type': 'DateFromFilter',
        'property': {'name': 'description'},
        'from': '2024-01-01T00:00:00.000Z',
      });
    });

    test('dateTo', () {
      final dt = DateTime.utc(2024, 12, 31, 23, 59, 59);
      final expr = FilterExpression.dateTo(property: prop, to: dt);
      expect(expr.toJson(), {
        'type': 'DateToFilter',
        'property': {'name': 'description'},
        'to': '2024-12-31T23:59:59.000Z',
      });
    });

    test('lessThan', () {
      final expr = FilterExpression.lessThan(
        property: DoublePropertyRef('urgency'),
        value: 5.5,
      );
      expect(expr.toJson(), {
        'type': 'LessThanFilter',
        'property': {'name': 'urgency'},
        'value': 5.5,
      });
    });

    test('lessThanOrEqual', () {
      final expr = FilterExpression.lessThanOrEqual(
        property: DoublePropertyRef('urgency'),
        value: 10.0,
      );
      expect(expr.toJson(), {
        'type': 'LessThanOrEqualFilter',
        'property': {'name': 'urgency'},
        'value': 10.0,
      });
    });

    test('greaterThan', () {
      final expr = FilterExpression.greaterThan(
        property: DoublePropertyRef('urgency'),
        value: 2.0,
      );
      expect(expr.toJson(), {
        'type': 'GreaterThanFilter',
        'property': {'name': 'urgency'},
        'value': 2.0,
      });
    });

    test('greaterThanOrEqual', () {
      final expr = FilterExpression.greaterThanOrEqual(
        property: DoublePropertyRef('urgency'),
        value: 0.0,
      );
      expect(expr.toJson(), {
        'type': 'GreaterThanOrEqualFilter',
        'property': {'name': 'urgency'},
        'value': 0.0,
      });
    });
  });

  group('deserialization', () {
    const propName = 'description';

    FilterExpression fromJson(Map<String, Object?> map) {
      return FilterExpression.fromJson(map);
    }

    test('andGroup', () {
      final decoded = fromJson({
        'type': 'AndGroup',
        'filters': [
          {'type': 'Tag', 'tag': 'a', 'exclude': false},
        ],
      });
      expect(
        decoded.maybeWhen(
          andGroup: (filters) => filters.length == 1,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('orGroup', () {
      final decoded = fromJson({
        'type': 'OrGroup',
        'filters': [
          {'type': 'EqualsFilter', 'property': {'name': propName}, 'value': 'v'},
        ],
      });
      expect(
        decoded.maybeWhen(
          orGroup: (filters) => filters.length == 1,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('xorGroup', () {
      final decoded = fromJson({
        'type': 'XorGroup',
        'filters': <Map<String, Object?>>[],
      });
      expect(
        decoded.maybeWhen(
          xorGroup: (filters) => filters.isEmpty,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('not', () {
      final decoded = fromJson({
        'type': 'Not',
        'inner': {'type': 'Tag', 'tag': 'x', 'exclude': false},
      });
      expect(
        decoded.maybeWhen(
          not: (inner) =>
              inner.maybeWhen(tag: (t, e) => t == 'x' && !e, orElse: () => false),
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('tag', () {
      final decoded = fromJson({
        'type': 'Tag',
        'tag': 'home',
        'exclude': true,
      });
      expect(
        decoded.maybeWhen(
          tag: (tag, exclude) => tag == 'home' && exclude == true,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('virtualTag', () {
      final decoded = fromJson({
        'type': 'VirtualTag',
        'tag': 'PENDING',
        'exclude': false,
      });
      expect(
        decoded.maybeWhen(
          virtualTag: (tag, exclude) => tag == 'PENDING' && !exclude,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('equals', () {
      final decoded = fromJson({
        'type': 'EqualsFilter',
        'property': {'name': propName},
        'value': 'val',
      });
      expect(
        decoded.maybeWhen(
          equals: (p, v) => p.name == propName && v == 'val',
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('notEquals', () {
      final decoded = fromJson({
        'type': 'NotEqualsFilter',
        'property': {'name': propName},
        'value': 'val',
      });
      expect(
        decoded.maybeWhen(
          notEquals: (p, v) => p.name == propName && v == 'val',
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('inValues', () {
      final decoded = fromJson({
        'type': 'InFilter',
        'property': {'name': propName},
        'values': ['a', 'b'],
      });
      expect(
        decoded.maybeWhen(
          inValues: (p, v) => p.name == propName && v.length == 2,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('notInValues', () {
      final decoded = fromJson({
        'type': 'NotInFilter',
        'property': {'name': propName},
        'values': ['a', 'b'],
      });
      expect(
        decoded.maybeWhen(
          notInValues: (p, v) => p.name == propName && v.length == 2,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('contains', () {
      final decoded = fromJson({
        'type': 'ContainsFilter',
        'property': {'name': propName},
        'value': 'v',
        'case_sensitive': true,
      });
      expect(
        decoded.maybeWhen(
          contains: (p, v, cs) => p.name == propName && v == 'v' && cs,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('notContains', () {
      final decoded = fromJson({
        'type': 'NotContainsFilter',
        'property': {'name': propName},
        'value': 'v',
        'case_sensitive': false,
      });
      expect(
        decoded.maybeWhen(
          notContains: (p, v, cs) => p.name == propName && v == 'v' && !cs,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('startsWith', () {
      final decoded = fromJson({
        'type': 'StartsWithFilter',
        'property': {'name': propName},
        'value': 'v',
        'case_sensitive': true,
      });
      expect(
        decoded.maybeWhen(
          startsWith: (p, v, cs) => p.name == propName && v == 'v' && cs,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('endsWith', () {
      final decoded = fromJson({
        'type': 'EndsWithFilter',
        'property': {'name': propName},
        'value': 'v',
        'case_sensitive': false,
      });
      expect(
        decoded.maybeWhen(
          endsWith: (p, v, cs) => p.name == propName && v == 'v' && !cs,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('word', () {
      final decoded = fromJson({
        'type': 'WordFilter',
        'property': {'name': propName},
        'value': 'v',
        'case_sensitive': true,
      });
      expect(
        decoded.maybeWhen(
          word: (p, v, cs) => p.name == propName && v == 'v' && cs,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('noWord', () {
      final decoded = fromJson({
        'type': 'NoWordFilter',
        'property': {'name': propName},
        'value': 'v',
        'case_sensitive': false,
      });
      expect(
        decoded.maybeWhen(
          noWord: (p, v, cs) => p.name == propName && v == 'v' && !cs,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('regex', () {
      final decoded = fromJson({
        'type': 'RegexFilter',
        'property': {'name': propName},
        'pattern': r'^\d+$',
        'case_sensitive': true,
      });
      expect(
        decoded.maybeWhen(
          regex: (p, pat, cs) =>
              p.name == propName && pat == r'^\d+$' && cs,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('none', () {
      final decoded = fromJson({
        'type': 'NoneFilter',
        'property': {'name': propName},
      });
      expect(
        decoded.maybeWhen(
          none: (p) => p.name == propName,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('any', () {
      final decoded = fromJson({
        'type': 'AnyFilter',
        'property': {'name': propName},
      });
      expect(
        decoded.maybeWhen(
          any: (p) => p.name == propName,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('dateBefore', () {
      final decoded = fromJson({
        'type': 'DateBeforeFilter',
        'property': {'name': propName},
        'date': '2024-01-01T12:00:00.000Z',
      });
      expect(
        decoded.maybeWhen(
          dateBefore: (p, d) =>
              p.name == propName && d == DateTime.utc(2024, 1, 1, 12),
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('dateAfter', () {
      final decoded = fromJson({
        'type': 'DateAfterFilter',
        'property': {'name': propName},
        'date': '2024-06-15T00:00:00.000Z',
      });
      expect(
        decoded.maybeWhen(
          dateAfter: (p, d) =>
              p.name == propName && d == DateTime.utc(2024, 6, 15),
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('dateBy', () {
      final decoded = fromJson({
        'type': 'DateByFilter',
        'property': {'name': propName},
        'date': '2024-03-03T03:03:03.000Z',
      });
      expect(
        decoded.maybeWhen(
          dateBy: (p, d) =>
              p.name == propName && d == DateTime.utc(2024, 3, 3, 3, 3, 3),
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('dateFrom', () {
      final decoded = fromJson({
        'type': 'DateFromFilter',
        'property': {'name': propName},
        'from': '2024-01-01T00:00:00.000Z',
      });
      expect(
        decoded.maybeWhen(
          dateFrom: (p, f) =>
              p.name == propName && f == DateTime.utc(2024, 1, 1),
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('dateTo', () {
      final decoded = fromJson({
        'type': 'DateToFilter',
        'property': {'name': propName},
        'to': '2024-12-31T23:59:59.000Z',
      });
      expect(
        decoded.maybeWhen(
          dateTo: (p, t) =>
              p.name == propName && t == DateTime.utc(2024, 12, 31, 23, 59, 59),
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('lessThan', () {
      final decoded = fromJson({
        'type': 'LessThanFilter',
        'property': {'name': 'urgency'},
        'value': 5.5,
      });
      expect(
        decoded.maybeWhen(
          lessThan: (p, v) => p.name == 'urgency' && v == 5.5,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('lessThanOrEqual', () {
      final decoded = fromJson({
        'type': 'LessThanOrEqualFilter',
        'property': {'name': 'urgency'},
        'value': 10.0,
      });
      expect(
        decoded.maybeWhen(
          lessThanOrEqual: (p, v) => p.name == 'urgency' && v == 10.0,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('greaterThan', () {
      final decoded = fromJson({
        'type': 'GreaterThanFilter',
        'property': {'name': 'urgency'},
        'value': 2.0,
      });
      expect(
        decoded.maybeWhen(
          greaterThan: (p, v) => p.name == 'urgency' && v == 2.0,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('greaterThanOrEqual', () {
      final decoded = fromJson({
        'type': 'GreaterThanOrEqualFilter',
        'property': {'name': 'urgency'},
        'value': 0.0,
      });
      expect(
        decoded.maybeWhen(
          greaterThanOrEqual: (p, v) => p.name == 'urgency' && v == 0.0,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('nested recursion', () {
      final map = {
        'type': 'AndGroup',
        'filters': [
          {
            'type': 'OrGroup',
            'filters': [
              {'type': 'Tag', 'tag': 'home', 'exclude': false},
              {
                'type': 'ContainsFilter',
                'property': {'name': 'description'},
                'value': 'milk',
                'case_sensitive': false,
              },
            ],
          },
          {
            'type': 'Not',
            'inner': {
              'type': 'EqualsFilter',
              'property': {'name': 'status'},
              'value': 'completed',
            },
          },
        ],
      };
      final decoded = FilterExpression.fromJson(map);

      final ok = decoded.maybeWhen(
        andGroup: (filters) {
          expect(filters.length, 2);
          final ok0 = filters[0].maybeWhen(
            orGroup: (inner) {
              expect(inner.length, 2);
              final okTag = inner[0].maybeWhen(
                tag: (tag, exclude) {
                  expect(tag, 'home');
                  expect(exclude, false);
                  return true;
                },
                orElse: () => false,
              );
              expect(okTag, isTrue);
              final okContains = inner[1].maybeWhen(
                contains: (prop, value, cs) {
                  expect(prop.name, 'description');
                  expect(value, 'milk');
                  expect(cs, false);
                  return true;
                },
                orElse: () => false,
              );
              expect(okContains, isTrue);
              return true;
            },
            orElse: () => false,
          );
          expect(ok0, isTrue);
          final ok1 = filters[1].maybeWhen(
            not: (inner) {
              final okInner = inner.maybeWhen(
                equals: (prop, value) {
                  expect(prop.name, 'status');
                  expect(value, 'completed');
                  return true;
                },
                orElse: () => false,
              );
              expect(okInner, isTrue);
              return true;
            },
            orElse: () => false,
          );
          expect(ok1, isTrue);
          return true;
        },
        orElse: () => false,
      );
      expect(ok, isTrue);
    });
  });

  group('round-trip safe subset', () {
    const prop = StringPropertyRef('description');

    void expectRoundTrip(FilterExpression expr) {
      final json = expr.toJson();
      final back = FilterExpression.fromJson(json);
      expect(back, equals(expr));
    }

    test('andGroup', () {
      expectRoundTrip(FilterExpression.andGroup(filters: [
        FilterExpression.tag(tag: 'a', exclude: false),
      ]));
    });

    test('orGroup', () {
      expectRoundTrip(FilterExpression.orGroup(filters: [
        FilterExpression.tag(tag: 'b', exclude: true),
      ]));
    });

    test('xorGroup', () {
      expectRoundTrip(FilterExpression.xorGroup(filters: []));
    });

    test('not', () {
      expectRoundTrip(FilterExpression.not(
        inner: FilterExpression.tag(tag: 'x', exclude: false),
      ));
    });

    test('tag', () {
      expectRoundTrip(FilterExpression.tag(tag: 'home', exclude: false));
    });

    test('virtualTag', () {
      expectRoundTrip(
        FilterExpression.virtualTag(tag: 'PENDING', exclude: true),
      );
    });

    test('equals', () {
      expectRoundTrip(
        FilterExpression.equals(property: prop, value: 'val'),
      );
    });

    test('notEquals', () {
      expectRoundTrip(
        FilterExpression.notEquals(property: prop, value: 'val'),
      );
    });

    test('inValues', () {
      expectRoundTrip(
        FilterExpression.inValues(property: prop, values: ['a', 'b']),
      );
    });

    test('notInValues', () {
      expectRoundTrip(
        FilterExpression.notInValues(property: prop, values: ['a', 'b']),
      );
    });

    test('contains', () {
      expectRoundTrip(
        FilterExpression.contains(
          property: prop,
          value: 'v',
          caseSensitive: true,
        ),
      );
    });

    test('notContains', () {
      expectRoundTrip(
        FilterExpression.notContains(
          property: prop,
          value: 'v',
          caseSensitive: false,
        ),
      );
    });

    test('startsWith', () {
      expectRoundTrip(
        FilterExpression.startsWith(
          property: prop,
          value: 'v',
          caseSensitive: true,
        ),
      );
    });

    test('endsWith', () {
      expectRoundTrip(
        FilterExpression.endsWith(
          property: prop,
          value: 'v',
          caseSensitive: false,
        ),
      );
    });

    test('word', () {
      expectRoundTrip(
        FilterExpression.word(
          property: prop,
          value: 'v',
          caseSensitive: true,
        ),
      );
    });

    test('noWord', () {
      expectRoundTrip(
        FilterExpression.noWord(
          property: prop,
          value: 'v',
          caseSensitive: false,
        ),
      );
    });

    test('regex', () {
      expectRoundTrip(
        FilterExpression.regex(
          property: prop,
          pattern: r'^\d+$',
          caseSensitive: true,
        ),
      );
    });

    test('none', () {
      expectRoundTrip(FilterExpression.none(property: prop));
    });

    test('any', () {
      expectRoundTrip(FilterExpression.any(property: prop));
    });
  });

  group('TaskFilter', () {
    test('matchAll toJson', () {
      final json = TaskFilter.matchAll.toJson();
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      expect(decoded, {
        'filter': {'type': 'AndGroup', 'filters': <Map<String, Object?>>[]},
      });
    });

    test('hasTag string format', () {
      final tf = TaskFilter.hasTag('work');
      final decoded = jsonDecode(tf.toJson()) as Map<String, dynamic>;
      expect(decoded, {
        'filter': {
          'type': 'Tag',
          'tag': 'work',
          'exclude': false,
        },
      });
    });

    test('virtualTag string format', () {
      final tf = TaskFilter.virtualTag('BLOCKED', exclude: true);
      final decoded = jsonDecode(tf.toJson()) as Map<String, dynamic>;
      expect(decoded, {
        'filter': {
          'type': 'VirtualTag',
          'tag': 'BLOCKED',
          'exclude': true,
        },
      });
    });

    test('fromJson returns expected variant', () {
      const jsonStr =
          '{"filter":{"type":"Tag","tag":"home","exclude":false}}';
      final tf = TaskFilter.fromJson(jsonStr);
      expect(
        tf.filter.maybeWhen(
          tag: (tag, exclude) => tag == 'home' && !exclude,
          orElse: () => false,
        ),
        isTrue,
      );
    });
  });
}
