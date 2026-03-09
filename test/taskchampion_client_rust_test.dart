import 'package:flutter_test/flutter_test.dart';
import 'package:taskchampion_client_rust/taskchampion_client_rust.dart';

void main() {
  test('generates valid UUID', () {
    final uuid = TaskChampionHelpers.generateUuid();
    expect(TaskChampionHelpers.isValidUuid(uuid), isTrue);
  });

  test('hashString produces valid hash', () {
    final hash = TaskChampionHelpers.hashString('test');
    expect(hash.length, equals(64)); // SHA-256 produces 64 character hex string
  });

  test('isValidUrl validates URLs', () {
    expect(TaskChampionHelpers.isValidUrl('https://example.com'), isTrue);
    expect(TaskChampionHelpers.isValidUrl('http://example.com'), isTrue);
    expect(TaskChampionHelpers.isValidUrl('invalid-url'), isFalse);
  });

  group('Task UDA handling', () {
    test('Task.fromRawJson parses UDAs correctly', () {
      final rawJson = {
        'uuid': '12345678-1234-1234-1234-123456789012',
        'description': 'Test task',
        'status': 'pending',
        'priority': 'none',
        'entry': DateTime.now().toIso8601String(),
        'tags': '',
        'depends': '',
        // Standard UDAs
        'project': 'TestProject',
        'scheduled': DateTime.now().toIso8601String(),
        'until': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'parent': '87654321-4321-4321-4321-210987654321',
        'urgency': '3.5',
        // Custom UDAs
        'github.id': '12345',
        'jira.url': 'https://jira.example.com/ISSUE-1',
        'custom_field': 'custom_value',
      };

      final task = Task.fromRawJson(rawJson);

      expect(task.uuid, equals('12345678-1234-1234-1234-123456789012'));
      expect(task.description, equals('Test task'));
      expect(task.project, equals('TestProject'));
      expect(task.parent, equals('87654321-4321-4321-4321-210987654321'));
      expect(task.urgency, equals(3.5));
      expect(task.scheduled, isA<DateTime>());
      expect(task.until, isA<DateTime>());
      
      // Custom UDAs should be in udas map
      expect(task.udas['github.id'], equals('12345'));
      expect(task.udas['jira.url'], equals('https://jira.example.com/ISSUE-1'));
      expect(task.udas['custom_field'], equals('custom_value'));
      
      // Special UDAs should also be in udas map for preservation
      expect(task.udas['project'], equals('TestProject'));
      expect(task.udas['parent'], equals('87654321-4321-4321-4321-210987654321'));
      expect(task.udas['urgency'], equals('3.5'));
    });

    test('Task.fromRawJson handles tags and depends as space-separated strings', () {
      final rawJson = {
        'uuid': '12345678-1234-1234-1234-123456789012',
        'description': 'Test task',
        'status': 'pending',
        'priority': 'none',
        'entry': DateTime.now().toIso8601String(),
        'tags': 'tag1 tag2 tag3',
        'depends': 'uuid1 uuid2 uuid3',
      };

      final task = Task.fromRawJson(rawJson);

      expect(task.tags, equals(['tag1', 'tag2', 'tag3']));
      expect(task.depends, equals(['uuid1', 'uuid2', 'uuid3']));
    });

    test('Task.fromRawJson handles empty tags and depends', () {
      final rawJson = {
        'uuid': '12345678-1234-1234-1234-123456789012',
        'description': 'Test task',
        'status': 'pending',
        'priority': 'none',
        'entry': DateTime.now().toIso8601String(),
        'tags': '',
        'depends': '',
      };

      final task = Task.fromRawJson(rawJson);

      expect(task.tags, isEmpty);
      expect(task.depends, isEmpty);
    });

    test('Task.fromRawJson handles annotations with annotation_ prefix', () {
      final now = DateTime.now();
      final rawJson = {
        'uuid': '12345678-1234-1234-1234-123456789012',
        'description': 'Test task',
        'status': 'pending',
        'priority': 'none',
        'entry': now.toIso8601String(),
        'tags': '',
        'depends': '',
        // Annotations should be skipped (not extracted as properties)
        'annotation_${now.millisecondsSinceEpoch}': 'Test annotation',
      };

      final task = Task.fromRawJson(rawJson);

      expect(task.uuid, equals('12345678-1234-1234-1234-123456789012'));
      // Annotations are not stored in the task model - they're in Rust only
    });
  });
}
