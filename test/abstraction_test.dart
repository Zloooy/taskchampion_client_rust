import 'package:flutter_test/flutter_test.dart';
import 'package:taskchampion_client_rust/src/core/core.dart';
import 'package:taskchampion_client_rust/src/models/models.dart';
import 'package:taskchampion_client_rust/src/rust_bridge/properties.dart';
import 'package:taskchampion_client_rust/src/services/property_type_registry.dart';

void main() {
  group('TaskParser', () {
    test('parses minimal task correctly', () {
      final json = {
        'uuid': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'description': 'Buy milk',
        'status': 'pending',
        'entry': '2024-01-01T00:00:00.000Z',
      };

      final task = TaskParser().parse(json);

      expect(task.uuid, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
      expect(task.description, 'Buy milk');
      expect(task.status, TaskStatus.pending);
      expect(task.priority, TaskPriority.none);
    });

    test('parses tags and depends as space-separated strings', () {
      final json = {
        'uuid': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'description': 'Test',
        'status': 'pending',
        'entry': '2024-01-01T00:00:00.000Z',
        'tags': 'home important',
        'depends': 'u1 u2',
      };

      final task = TaskParser().parse(json);

      expect(task.tags, ['home', 'important']);
      expect(task.depends, ['u1', 'u2']);
    });

    test('parses custom UDAs', () {
      final json = {
        'uuid': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'description': 'Test',
        'status': 'pending',
        'entry': '2024-01-01T00:00:00.000Z',
        'custom_uda': 'value123',
      };

      final task = TaskParser().parse(json);

      expect(task.udas['custom_uda'], 'value123');
    });

    test('defaults missing priority to none', () {
      final json = {
        'uuid': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'description': 'Test',
        'status': 'pending',
        'entry': '2024-01-01T00:00:00.000Z',
      };

      final task = TaskParser().parse(json);

      expect(task.priority, TaskPriority.none);
    });

    test('strips invalid scheduled / until values', () {
      final json = {
        'uuid': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'description': 'Test',
        'status': 'pending',
        'entry': '2024-01-01T00:00:00.000Z',
        'scheduled': 'not-a-date',
        'until': 'also-bad',
      };

      final task = TaskParser().parse(json);

      expect(task.scheduled, isNull);
      expect(task.until, isNull);
    });

    test('skips annotation_ prefixed keys', () {
      final json = {
        'uuid': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'description': 'Test',
        'status': 'pending',
        'entry': '2024-01-01T00:00:00.000Z',
        'annotation_1': 'foo',
      };

      final task = TaskParser().parse(json);

      expect(task.udas.containsKey('annotation_1'), isFalse);
    });
  });

  group('PropertyTypeRegistry', () {
    test('supports standard types', () {
      final registry = PropertyTypeRegistry();

      expect(registry.supports<String>(), isTrue);
      expect(registry.supports<DateTime>(), isTrue);
      expect(registry.supports<TaskStatus>(), isTrue);
      expect(registry.supports<TaskPriority>(), isTrue);
    });

    test('resolves standard types', () {
      final registry = PropertyTypeRegistry();

      expect(registry.resolve<String>(), PropertyReturnType.string);
      expect(registry.resolve<DateTime>(), PropertyReturnType.dateTime);
      expect(registry.resolve<TaskStatus>(), PropertyReturnType.enumStatus);
      expect(registry.resolve<TaskPriority>(), PropertyReturnType.enumPriority);
    });

    test('throws for unregistered type', () {
      final registry = PropertyTypeRegistry();

      expect(() => registry.resolve<int>(), throwsA(isA<ArgumentError>()));
    });

    test('allows registering new types', () {
      final registry = PropertyTypeRegistry();
      registry.register<bool>(PropertyReturnType.string);

      expect(registry.supports<bool>(), isTrue);
      expect(registry.resolve<bool>(), PropertyReturnType.string);
    });
  });

  group('EnumPropertyTypeRegistry', () {
    test('supports only enum types', () {
      final registry = EnumPropertyTypeRegistry();

      expect(registry.supports<TaskStatus>(), isTrue);
      expect(registry.supports<TaskPriority>(), isTrue);
      expect(registry.supports<String>(), isFalse);
    });

    test('throws for unregistered type', () {
      final registry = EnumPropertyTypeRegistry();

      expect(() => registry.resolve<String>(), throwsA(isA<ArgumentError>()));
    });
  });

  group('Exceptions', () {
    test('TaskStorageException carries message and cause', () {
      const ex = TaskStorageException('fail', cause: 'boom');

      expect(ex.message, 'fail');
      expect(ex.cause, 'boom');
      expect(ex.toString(), contains('TaskStorageException'));
    });

    test('AuthException is a TaskChampionException', () {
      const ex = AuthException('bad creds');

      expect(ex, isA<TaskChampionException>());
      expect(ex.message, 'bad creds');
    });

    test('ValidationException is a TaskChampionException', () {
      const ex = ValidationException('invalid');

      expect(ex, isA<TaskChampionException>());
      expect(ex.message, 'invalid');
    });
  });
}
