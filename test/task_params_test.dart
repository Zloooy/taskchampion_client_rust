import 'package:flutter_test/flutter_test.dart';
import 'package:taskchampion_client_rust/src/models/models.dart';
// ignore: implementation_imports
import 'package:taskchampion_client_rust/src/rust_bridge/models.dart' as frb;

void main() {
  group('TaskParams.toTaskDto', () {
    final due = DateTime.utc(2026, 8, 1, 12, 30);
    final wait = DateTime.utc(2026, 7, 25);
    final scheduled = DateTime.utc(2026, 8, 1, 9);
    final until = DateTime.utc(2026, 8, 31, 23, 59, 59);
    final entry = DateTime.utc(2026, 8, 1, 8, 0);
    final end = DateTime.utc(2026, 8, 2);

    test('maps every field to the generated TaskDto', () {
      final params = TaskParams(
        description: 'Buy milk',
        status: TaskStatus.completed,
        priority: TaskPriority.high,
        project: null,
        tags: ['shopping', 'urgent'],
        depends: ['uuid-a', 'uuid-b'],
        due: due,
        wait: wait,
        scheduled: scheduled,
        until: until,
        entry: entry,
        end: end,
        recur: 'weekly',
        udas: {'custom.key': 'value1', 'recur': 'ignored'},
      );

      final dto = params.toTaskDto();

      expect(dto.uuid, isEmpty); // backend allocates on create
      expect(dto.description, 'Buy milk');
      expect(dto.status, frb.TaskStatusDto.completed);
      expect(dto.priority, 'H');
      expect(dto.due, '2026-08-01T12:30:00.000Z');
      expect(dto.wait, '2026-07-25T00:00:00.000Z');
      expect(dto.scheduled, '2026-08-01T09:00:00.000Z');
      expect(dto.until, '2026-08-31T23:59:59.000Z');
      expect(dto.entry, '2026-08-01T08:00:00.000Z');
      expect(dto.end, '2026-08-02T00:00:00.000Z');
      expect(dto.recur, 'weekly');
      expect(dto.tags, ['shopping', 'urgent']);
      expect(dto.depends, ['uuid-a', 'uuid-b']);
      // Annotations are always sent as a concrete list; an empty one means
      // "clear all" on the backend.
      expect(dto.annotations, isA<List<frb.AnnotationDto>>());
      expect(dto.annotations, isEmpty);
      expect(dto.udas, {'custom.key': 'value1'});
      // Promoted fields must not leak into the UDA map.
      expect(dto.udas.containsKey('recur'), isFalse);
      expect(dto.udas.containsKey('scheduled'), isFalse);
      expect(dto.udas.containsKey('until'), isFalse);
    });

    test('encodes priorities with canonical codes and defaults', () {
      expect(TaskParams(description: 'a').priority, TaskPriority.none);
      expect(TaskParams(description: 'a').toTaskDto().priority, isNull);

      expect(
        TaskParams(description: 'a', priority: TaskPriority.medium)
            .toTaskDto()
            .priority,
        'M',
      );
      expect(
        TaskParams(description: 'a', priority: TaskPriority.low)
            .toTaskDto()
            .priority,
        'L',
      );
      expect(
        TaskParams(description: 'a', status: TaskStatus.deleted)
            .toTaskDto()
            .status,
        frb.TaskStatusDto.deleted,
      );
    });

    test('local datetimes are normalized to their UTC instant', () {
      // A naive (local) datetime must serialize to the same instant as its
      // UTC equivalent, regardless of the host timezone.
      final utcInstant = DateTime.utc(2026, 8, 1, 12, 0);
      final local = DateTime.fromMillisecondsSinceEpoch(
        utcInstant.millisecondsSinceEpoch,
      );
      final dto = TaskParams(description: 'a', due: local).toTaskDto();

      expect(DateTime.parse(dto.due!), utcInstant);
      expect(dto.due, endsWith('Z'));
    });

    test('empty or absent optional values map to null', () {
      final dto = TaskParams(description: 'a', recur: '').toTaskDto();

      expect(dto.due, isNull);
      expect(dto.wait, isNull);
      expect(dto.scheduled, isNull);
      expect(dto.until, isNull);
      expect(dto.entry, isNull);
      expect(dto.end, isNull);
      expect(dto.modified, isNull);
      expect(dto.recur, isNull);
      expect(dto.tags, isEmpty);
      expect(dto.depends, isEmpty);
      expect(dto.udas, isEmpty);
    });

    test('project is routed through the conventional project UDA', () {
      final dto = TaskParams(description: 'a', project: 'Work')
          .toTaskDto();

      expect(dto.udas, {'project': 'Work'});
    });

    test('annotations map to RFC-3339 entries in the DTO', () {
      final first = DateTime.utc(2026, 8, 1, 8, 0);
      final second = DateTime.utc(2026, 8, 2, 9, 30);
      final params = TaskParams(
        description: 'a',
        annotations: [
          Annotation(entry: first, description: 'note A'),
          Annotation(entry: second, description: 'note B'),
        ],
      );

      final dto = params.toTaskDto();

      final annotations = dto.annotations;
      expect(annotations, isNotNull);
      expect(annotations, hasLength(2));
      expect(annotations![0].entry, '2026-08-01T08:00:00.000Z');
      expect(annotations[0].description, 'note A');
      expect(annotations[1].entry, '2026-08-02T09:30:00.000Z');
      expect(annotations[1].description, 'note B');
    });

    test('an empty annotation list is an explicit (non-null) clear', () {
      final dto = TaskParams(description: 'a', annotations: const [])
          .toTaskDto();

      expect(dto.annotations, isNotNull);
      expect(dto.annotations, isEmpty);
    });
  });

  group('TaskParams.fromTask round-trip', () {
    Task buildTask({
      Map<String, String>? extraUdas,
      List<Annotation>? annotations,
    }) =>
        Task(
          uuid: '12345678-1234-1234-1234-123456789012',
          description: 'Round trip task',
          status: TaskStatus.pending,
          priority: TaskPriority.low,
          project: 'Home',
          tags: ['a', 'b'],
          due: DateTime.utc(2026, 8, 1),
          wait: DateTime.utc(2026, 7, 1),
          scheduled: DateTime.utc(2026, 8, 2),
          until: DateTime.utc(2026, 8, 30),
          entry: DateTime.utc(2026, 7, 15),
          modified: DateTime.utc(2026, 7, 20),
          end: null,
          parent: '99999999-9999-9999-9999-999999999999',
          depends: ['dep-1'],
          annotations: annotations ?? const [],
          udas: {
            'project': 'Home',
            'parent': '99999999-9999-9999-9999-999999999999',
            'urgency': '3.5',
            'recur': 'daily',
            'custom': 'kept',
            ...?extraUdas,
          },
        );

    test('carries main fields into the DTO under the task uuid', () {
      final task = buildTask();
      final dto = TaskParams.fromTask(task).toTaskDto(uuid: task.uuid);

      expect(dto.uuid, task.uuid);
      expect(dto.description, 'Round trip task');
      expect(dto.status, frb.TaskStatusDto.pending);
      expect(dto.priority, 'L');
      expect(dto.due, '2026-08-01T00:00:00.000Z');
      expect(dto.wait, '2026-07-01T00:00:00.000Z');
      expect(dto.scheduled, '2026-08-02T00:00:00.000Z');
      expect(dto.until, '2026-08-30T00:00:00.000Z');
      expect(dto.entry, '2026-07-15T00:00:00.000Z');
      expect(dto.end, isNull);
      expect(dto.recur, 'daily');
      expect(dto.tags, ['a', 'b']);
      expect(dto.depends, ['dep-1']);
      // Managed UDAs are re-expressed via dedicated fields, not duplicated.
      expect(dto.udas['project'], 'Home');
      expect(dto.udas['custom'], 'kept');
      for (final key in ['parent', 'urgency', 'recur']) {
        expect(dto.udas.containsKey(key), isFalse, reason: key);
      }
    });

    test(
      'saving a loaded task round-trips its annotations unchanged',
      () {
        final task = buildTask(
          annotations: [
            Annotation(
              entry: DateTime.utc(2026, 7, 16, 10, 30),
              description: 'started work',
            ),
            Annotation(
              entry: DateTime.utc(2026, 7, 17),
              description: 'blocked on review',
            ),
          ],
        );

        // Plain load → edit (description only) → save.
        final edited = task.copyWith(description: 'Round trip task v2');
        final dto = TaskParams.fromTask(edited).toTaskDto(uuid: edited.uuid);

        final annotations = dto.annotations;
        expect(annotations, isNotNull);
        expect(annotations, hasLength(2));
        expect(
          annotations![0].entry,
          '2026-07-16T10:30:00.000Z',
        );
        expect(annotations[0].description, 'started work');
        expect(annotations[1].entry, '2026-07-17T00:00:00.000Z');
        expect(annotations[1].description, 'blocked on review');
      },
    );

    test('copyWith-ed task keeps its identity and new state', () {
      final task = buildTask();
      final updated = task.copyWith(status: TaskStatus.completed);

      expect(updated.uuid, task.uuid);
      final dto = TaskParams.fromTask(updated).toTaskDto(uuid: updated.uuid);

      expect(dto.uuid, task.uuid);
      expect(dto.status, frb.TaskStatusDto.completed);
      expect(dto.description, task.description);
    });
  });
}
