import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskchampion_client_rust/src/models/models.dart';

void main() {
  group('TaskSort.toJson', () {
    test('produces the expected wire shape', () {
      final sort = StringPropertySort(
        const StringPropertyRef('project'),
        SortDirection.descending,
      );

      expect(
        sort.toJson(),
        equals({
          'property': {'name': 'project'},
          'direction': 'descending',
        }),
      );
    });

    test('defaults to ascending direction', () {
      final sort = DateTimePropertySort(const DateTimePropertyRef('due'));

      expect(
        sort.toJson(),
        equals({
          'property': {'name': 'due'},
          'direction': 'ascending',
        }),
      );
    });
  });

  group('List<TaskSort> array encoding', () {
    test('encodes a list of sorts to a JSON array of objects', () {
      final sorts = <TaskSort>[
        DateTimePropertySort(
          const DateTimePropertyRef('due'),
          SortDirection.descending,
        ),
        StringPropertySort(const StringPropertyRef('project')),
      ];

      final encoded = json.encode(sorts.map((s) => s.toJson()).toList());

      expect(
        encoded,
        equals(
          json.encode([
            {
              'property': {'name': 'due'},
              'direction': 'descending',
            },
            {
              'property': {'name': 'project'},
              'direction': 'ascending',
            },
          ]),
        ),
      );

      final decoded = json.decode(encoded);
      expect(decoded, isA<List>());
      expect(decoded, hasLength(2));
      expect(decoded[0], isA<Map<String, dynamic>>());
      expect(decoded[1], isA<Map<String, dynamic>>());
    });

    test('single sort encodes to a one-element array', () {
      final sorts = <TaskSort>[IntPropertySort(const IntPropertyRef('id'))];

      final encoded = json.encode(sorts.map((s) => s.toJson()).toList());
      final decoded = json.decode(encoded);

      expect(decoded, hasLength(1));
      expect(
        decoded[0],
        equals({
          'property': {'name': 'id'},
          'direction': 'ascending',
        }),
      );
    });

    test(
      'property-value path encodes only the first sort as a single object',
      () {
        final sorts = <TaskSort>[
          StringPropertySort(
            const StringPropertyRef('description'),
            SortDirection.descending,
          ),
          DateTimePropertySort(const DateTimePropertyRef('due')),
        ];

        final encoded = json.encode(sorts.first.toJson());
        final decoded = json.decode(encoded);

        expect(decoded, isA<Map<String, dynamic>>());
        expect(
          decoded,
          equals({
            'property': {'name': 'description'},
            'direction': 'descending',
          }),
        );
      },
    );
  });

  group('asc() / desc() on TaskPropertyRef subclasses', () {
    test('StringPropertyRef produces StringPropertySort', () {
      final ref = const StringPropertyRef('project');

      final asc = ref.asc();
      final desc = ref.desc();

      expect(asc, isA<StringPropertySort>());
      expect(asc.direction, equals(SortDirection.ascending));
      expect(asc.property, equals(ref));

      expect(desc, isA<StringPropertySort>());
      expect(desc.direction, equals(SortDirection.descending));
      expect(desc.property, equals(ref));
    });

    test('DateTimePropertyRef produces DateTimePropertySort', () {
      final ref = const DateTimePropertyRef('due');

      final asc = ref.asc();
      final desc = ref.desc();

      expect(asc, isA<DateTimePropertySort>());
      expect(asc.direction, equals(SortDirection.ascending));
      expect(asc.property, equals(ref));

      expect(desc, isA<DateTimePropertySort>());
      expect(desc.direction, equals(SortDirection.descending));
      expect(desc.property, equals(ref));
    });

    test('IntPropertyRef produces IntPropertySort', () {
      final ref = const IntPropertyRef('id');

      final asc = ref.asc();
      final desc = ref.desc();

      expect(asc, isA<IntPropertySort>());
      expect(asc.direction, equals(SortDirection.ascending));
      expect(asc.property, equals(ref));

      expect(desc, isA<IntPropertySort>());
      expect(desc.direction, equals(SortDirection.descending));
      expect(desc.property, equals(ref));
    });

    test('DoublePropertyRef produces DoublePropertySort', () {
      final ref = const DoublePropertyRef('urgency');

      final asc = ref.asc();
      final desc = ref.desc();

      expect(asc, isA<DoublePropertySort>());
      expect(asc.direction, equals(SortDirection.ascending));
      expect(asc.property, equals(ref));

      expect(desc, isA<DoublePropertySort>());
      expect(desc.direction, equals(SortDirection.descending));
      expect(desc.property, equals(ref));
    });
  });
}
