import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskchampion_client_rust/taskchampion_client_rust.dart';

void main() {
  test('TaskService extracts tasks without virtual tags', () async {
    // Create a temporary directory for the task database.
    final tempDir = await Directory.systemTemp.createTemp('tc_test_');
    await TaskChampionClient.init();
    final taskService = TaskService(tempDir.path);

    // Create a task with user-defined tags.
    await taskService.createTask(
      description: 'Test task',
      tags: ['home', 'important'],
    );

    // Retrieve all tasks.
    final tasks = await taskService.getAllTasks();
    expect(tasks, isNotEmpty);

    // Define known virtual tags (uppercase).
    const virtualTags = {
      'ACTIVE',
      'ANNOTATED',
      'BLOCKED',
      'BLOCKING',
      'COMPLETED',
      'DELETED',
      'DUE',
      'DUETODAY',
      'TODAY',
      'INSTANCE',
      'LATEST',
      'MONTH',
      'ORPHAN',
      'OVERDUE',
      'PARENT',
      'PENDING',
      'PRIORITY',
      'PROJECT',
      'QUARTER',
      'READY',
      'SCHEDULED',
      'TAGGED',
      'TEMPLATE',
      'TOMORROW',
      'UDA',
      'UNBLOCKED',
      'UNTIL',
      'WAITING',
      'WEEK',
      'YEAR',
      'YESTERDAY',
    };

    for (final task in tasks) {
      for (final tag in task.tags) {
        expect(
          virtualTags.contains(tag.toUpperCase()),
          isFalse,
          reason: 'Found virtual tag "$tag" in task ${task.uuid}',
        );
      }
    }

    // Cleanup.
    await tempDir.delete(recursive: true);
  }, skip: false);
}
