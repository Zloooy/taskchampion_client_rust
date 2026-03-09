import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taskchampion_client_rust/taskchampion_client_rust.dart';
import 'permission_service.dart';

/// Service for exporting and importing tasks
///
/// Uses the app's private directory for file storage
class TaskStorageService {
  final TaskChampionClient? client;

  TaskStorageService({this.client});

  /// Export tasks to a JSON file in the app's private directory
  /// and share the file via system dialog
  Future<bool> exportTasks() async {
    if (client == null) {
      throw Exception('Client not initialized');
    }

    // Request storage permission
    final permissionGranted = await PermissionService.requestStoragePermission();
    if (!permissionGranted) {
      throw Exception('Storage permission not granted. Cannot export tasks.');
    }

    try {
      // Get all tasks
      final tasks = await client!.getAllTasks();

      // Serialize to JSON
      final tasksJson = tasks.map((task) => task.toJson()).toList();
      final jsonData = JsonEncoder.withIndent('  ').convert(tasksJson);

      // Get app's private directory
      final directory = await getApplicationDocumentsDirectory();
      final tasksDir = Directory('${directory.path}/tasks');

      // Create directory if it doesn't exist
      if (!await tasksDir.exists()) {
        await tasksDir.create(recursive: true);
      }

      // Create file with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
      final fileName = 'tasks_export_$timestamp.json';
      final filePath = '${tasksDir.path}/$fileName';
      final file = File(filePath);

      // Write file
      await file.writeAsString(jsonData);

      // Share file via system dialog
      final xFile = XFile(filePath);
      await SharePlus.instance.share(ShareParams(previewThumbnail: xFile, subject: 'TaskChampion Tasks Export'));

      debugPrint('Tasks exported to: $filePath');
      return true;
    } catch (e) {
      debugPrint('Error exporting tasks: $e');
      rethrow;
    }
  }

  /// Import tasks from a selected JSON file
  Future<ImportResult> importTasks() async {
    if (client == null) {
      throw Exception('Client not initialized');
    }

    // Request storage permission
    final permissionGranted = await PermissionService.requestStoragePermission();
    if (!permissionGranted) {
      return ImportResult(
        success: false,
        errorMessage: 'Storage permission not granted. Cannot import tasks.',
        tasksImported: 0,
      );
    }

    try {
      // Select file via file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(
          success: false,
          errorMessage: 'File selection cancelled',
          tasksImported: 0,
        );
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        return ImportResult(
          success: false,
          errorMessage: 'Could not get file path',
          tasksImported: 0,
        );
      }

      final file = File(filePath);
      final jsonString = await file.readAsString();
      final List<dynamic> tasksJson = jsonDecode(jsonString);

      int importedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      // Import each task
      for (final taskData in tasksJson) {
        try {
          final task = Task.fromJson(taskData);

          // Check if task with this UUID already exists
          final existingTask = await client!.getTask(task.uuid);
          if (existingTask != null) {
            // Update existing task
            await client!.updateTask(
              uuid: task.uuid,
              description: task.description,
              status: task.status,
              priority: task.priority,
              project: task.project,
              tags: task.tags,
              due: task.due,
            );
            skippedCount++;
          } else {
            // Create new task
            await client!.createTask(
              description: task.description,
              priority: task.priority,
              project: task.project,
              tags: task.tags,
              due: task.due,
              wait: task.wait,
            );
            importedCount++;
          }
        } catch (e) {
          debugPrint('Error importing task: $e');
          errorCount++;
        }
      }

      // Sync with server after import
      await client!.sync();

      debugPrint(
        'Import completed: $importedCount imported, '
        '$skippedCount skipped, $errorCount errors',
      );

      return ImportResult(
        success: true,
        tasksImported: importedCount,
        tasksSkipped: skippedCount,
        tasksFailed: errorCount,
      );
    } catch (e) {
      debugPrint('Error importing tasks: $e');
      return ImportResult(
        success: false,
        errorMessage: e.toString(),
        tasksImported: 0,
      );
    }
  }

  /// Get list of exported files
  Future<List<File>> getExportedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final tasksDir = Directory('${directory.path}/tasks');

      if (!await tasksDir.exists()) {
        return [];
      }

      final files = await tasksDir.list().toList();
      return files
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();
    } catch (e) {
      debugPrint('Error getting exported files: $e');
      return [];
    }
  }

  /// Clear all exported files
  Future<void> clearExportedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final tasksDir = Directory('${directory.path}/tasks');

      if (await tasksDir.exists()) {
        await tasksDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing exported files: $e');
      rethrow;
    }
  }
}

/// Result of task import
class ImportResult {
  final bool success;
  final int tasksImported;
  final int tasksSkipped;
  final int tasksFailed;
  final String? errorMessage;

  ImportResult({
    required this.success,
    required this.tasksImported,
    this.tasksSkipped = 0,
    this.tasksFailed = 0,
    this.errorMessage,
  });

  String get summary {
    if (!success) {
      return 'Import failed: $errorMessage';
    }
    return 'Imported: $tasksImported, Skipped: $tasksSkipped, Failed: $tasksFailed';
  }
}
