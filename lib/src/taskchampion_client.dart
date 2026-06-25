import 'dart:async';
import 'package:flutter/foundation.dart';
import 'client/client.dart';
import 'models/models.dart';
import 'rust_bridge/frb_generated.dart';
import 'services/interfaces/interfaces.dart';
import 'services/task_service.dart';
import 'services/task_property_service.dart';
import 'services/task_tag_service.dart';
import 'services/sync_service.dart';
import 'services/auth_service.dart';
import 'storage/rust_task_storage.dart';
import 'storage/task_storage.dart';

/// TaskChampion Client - Main public API for TaskChampion operations
///
/// This class provides a high-level, programmer-friendly interface for:
/// - Task management (create, read, update, delete)
/// - Synchronization with TaskChampion sync server
/// - Authentication and credential management
///
/// Internally it delegates to focused subsystems:
/// - [TaskEventManager] for stream handling
/// - [AutoSyncCoordinator] for debounced background sync
/// - [ConnectionState] for auth / connectivity tracking
///
/// ## Usage Example
///
/// ```dart
/// // Initialize the library
/// await TaskChampionClient.init();
///
/// // Create a client instance
/// final client = TaskChampionClient(
///   serverUrl: 'https://your-sync-server.com',
///   clientId: 'your-client-id',
///   encryptionSecret: 'your-encryption-secret',
/// );
///
/// // Connect to the server
/// await client.connect();
///
/// // Sync tasks
/// await client.sync();
///
/// // Get all tasks
/// final tasks = await client.getAllTasks();
///
/// // Create a new task
/// final task = await client.createTask(
///   description: 'Buy milk',
///   priority: TaskPriority.high,
///   due: DateTime.now().add(Duration(days: 1)),
/// );
///
/// // Update a task
/// await client.updateTask(
///   uuid: task.uuid,
///   status: TaskStatus.completed,
/// );
///
/// // Delete a task
/// await client.deleteTask(task.uuid);
/// ```
class TaskChampionClient {
  /// Configuration for this client instance
  final ClientConfig config;

  /// Underlying storage implementation
  late final TaskStorage _storage;

  // Service layer
  late final ITaskService _taskService;
  late final ITaskPropertyService _taskPropertyService;
  late final ITaskTagService _taskTagService;
  late final ISyncService _syncService;
  late final IAuthService _authService;

  // Subsystems extracted from the former god class
  late final TaskEventManager _eventManager;
  late final AutoSyncCoordinator _autoSyncCoordinator;
  late final ConnectionState _connectionState;

  /// Initialize the TaskChampion library
  ///
  /// This must be called before creating any TaskChampionClient instances.
  /// It initializes the Rust FFI bridge and sets up necessary platform bindings.
  static Future<void> init() async {
    await RustLib.init();
    debugPrint('TaskChampionClient initialized');
  }

  /// Create a new TaskChampionClient instance
  ///
  /// [serverUrl] - URL of the TaskChampion sync server
  /// [clientId] - Client ID for authentication
  /// [encryptionSecret] - Secret key for encrypting sync data
  /// [taskdbPath] - Optional custom path for task database
  /// [autoSync] - Enable auto-sync after task changes (default: false)
  /// [debugLogging] - Enable debug logging (default: false)
  ///
  /// Optional services allow injection of mocks or decorators for testing.
  TaskChampionClient({
    required String serverUrl,
    required String clientId,
    required String encryptionSecret,
    String? taskdbPath,
    bool autoSync = false,
    bool debugLogging = false,
    ITaskService? taskService,
    ITaskPropertyService? taskPropertyService,
    ITaskTagService? taskTagService,
    ISyncService? syncService,
    IAuthService? authService,
    TaskEventManager? eventManager,
  }) : config = ClientConfig.createMinimal(
         serverUrl: serverUrl,
         clientId: clientId,
         encryptionSecret: encryptionSecret,
         taskdbPath: taskdbPath,
         autoSyncOnTaskChange: autoSync,
         debugLogging: debugLogging,
       ) {
    _storage = RustTaskStorage(config.taskdbPath);
    _taskService = taskService ?? TaskService(_storage);
    _taskPropertyService = taskPropertyService ?? TaskPropertyService(_storage);
    _taskTagService = taskTagService ?? TaskTagService(_storage);
    _syncService = syncService ?? SyncService(_storage, config.syncConfig);
    _authService = authService ?? AuthService(_storage, config.authConfig);

    _eventManager = eventManager ?? TaskEventManager();
    _autoSyncCoordinator = AutoSyncCoordinator(_syncService);
    _connectionState = ConnectionState(_authService);

    _setupAutoSyncListeners();
  }

  /// Create a TaskChampionClient with custom configuration
  ///
  /// Optional services allow injection of mocks or decorators for testing.
  TaskChampionClient.withConfig(
    this.config, {
    ITaskService? taskService,
    ITaskPropertyService? taskPropertyService,
    ITaskTagService? taskTagService,
    ISyncService? syncService,
    IAuthService? authService,
    TaskEventManager? eventManager,
  }) {
    _storage = RustTaskStorage(config.taskdbPath);
    _taskService = taskService ?? TaskService(_storage);
    _taskPropertyService = taskPropertyService ?? TaskPropertyService(_storage);
    _taskTagService = taskTagService ?? TaskTagService(_storage);
    _syncService = syncService ?? SyncService(_storage, config.syncConfig);
    _authService = authService ?? AuthService(_storage, config.authConfig);

    _eventManager = eventManager ?? TaskEventManager();
    _autoSyncCoordinator = AutoSyncCoordinator(_syncService);
    _connectionState = ConnectionState(_authService);

    _setupAutoSyncListeners();
  }

  void _setupAutoSyncListeners() {
    if (config.autoSyncOnTaskChange) {
      _eventManager.taskChanges.listen((_) {
        if (isConnected) {
          _autoSyncCoordinator.requestSync();
        }
      });
    }
  }

  /// Get the task database path
  String get taskdbPath => config.taskdbPath;

  /// Get the server URL
  String get serverUrl => config.syncConfig.serverUrl;

  /// Get the client ID
  String get clientId => config.syncConfig.clientId;

  /// Check if connected to the server
  bool get isConnected => _connectionState.isConnected;

  /// Stream of task changes
  Stream<Task> get taskChanges => _eventManager.taskChanges;

  /// Stream of sync events
  Stream<SyncResult> get syncEvents => _eventManager.syncEvents;

  /// Connect to the TaskChampion sync server
  ///
  /// This validates credentials and establishes a connection.
  /// Call this before performing sync operations.
  Future<AuthResult> connect() async {
    if (config.debugLogging) {
      debugPrint('Connecting to server: $serverUrl');
    }

    final authResult = await _connectionState.validateAndConnect();

    if (authResult.success) {
      debugPrint('Connected to server: $serverUrl');
    } else {
      debugPrint('Connection failed: ${authResult.errorMessage}');
    }

    return authResult;
  }

  /// Disconnect from the server
  void disconnect() {
    _connectionState.disconnect();
    debugPrint('Disconnected from server');
  }

  /// Synchronize tasks with the sync server
  ///
  /// This uploads local changes and downloads remote changes.
  /// Returns a [SyncResult] with synchronization statistics.
  Future<SyncResult> sync() async {
    try {
      final stopwatch = Stopwatch()..start();

      if (config.debugLogging) {
        debugPrint('Starting synchronization...');
      }

      // Perform sync
      final result = await _syncService.sync();

      stopwatch.stop();

      final syncResult = result.copyWith(
        durationMs: stopwatch.elapsedMilliseconds,
      );

      // Emit sync event
      _eventManager.emitSyncResult(syncResult);

      if (config.debugLogging) {
        debugPrint('Sync completed: ${syncResult.summary}');
      }

      return syncResult;
    } catch (e) {
      final errorResult = SyncResult(
        success: false,
        errorMessage: 'Sync error: $e',
        completedAt: DateTime.now(),
      );
      _eventManager.emitSyncResult(errorResult);
      return errorResult;
    }
  }

  /// Get all tasks from the local database
  ///
  /// Optionally filter by status and sort by a property.
  ///
  /// [sort] - Optional [TaskSort] to sort the results.
  ///          If not provided, tasks are returned in their natural order.
  Future<List<Task>> getAllTasks({TaskStatus? status, TaskSort? sort}) async {
    final tasks = await _taskService.getAllTasks(sort: sort);

    if (status != null) {
      return tasks.where((task) => task.status == status).toList();
    }

    return tasks;
  }

  /// Get tasks matching a custom filter expression
  ///
  /// [filter] - A [TaskFilter] defining the filter criteria
  /// [sort] - Optional [TaskSort] to sort the results
  ///
  /// This method allows for complex filtering using composable filter expressions
  /// such as [EqualsFilter], [InFilter], [DateFromFilter], [ContainsFilter], etc.
  /// combined with logical operators [AndFilterGroup] and [OrFilterGroup].
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Filter pending tasks with high priority
  /// final filter = TaskFilter(
  ///   AndFilterGroup([
  ///     EqualsFilter(property: TaskFilter.status, value: 'pending'),
  ///     EqualsFilter(property: TaskFilter.priority, value: 'high'),
  ///   ]),
  /// );
  ///
  /// final tasks = await client.filterTasks(filter);
  /// ```
  ///
  /// ## Available Filter Types
  ///
  /// - [EqualsFilter] - Property equals a specific value
  /// - [InFilter] - Property is in a set of values
  /// - [NotInFilter] - Property is NOT in a set of values
  /// - [DateFromFilter] - Date property is from a specific date
  /// - [DateToFilter] - Date property is up to a specific date
  /// - [ContainsFilter] - String property contains a substring
  ///
  /// ## Property References
  ///
  /// - [TaskFilter.description] - Task description
  /// - [TaskFilter.status] - Task status (pending, completed, deleted)
  /// - [TaskFilter.priority] - Task priority (high, medium, low, none)
  /// - [TaskFilter.due] - Due date
  /// - [TaskFilter.wait] - Wait until date
  /// - [TaskFilter.entry] - Creation date
  /// - [TaskFilter.modified] - Last modified date
  Future<List<Task>> filterTasks(TaskFilter filter, {TaskSort? sort}) async {
    return _taskService.filterTasks(filter, sort: sort);
  }

  /// Get distinct property values for a given property name.
  ///
  /// [property] – name of the property to query.
  /// [filter] – optional [TaskFilter] to limit the tasks considered.
  /// [sort] – optional [TaskSort] that may affect the order of the returned list.
  ///
  /// Returns a sorted list of distinct string values, or an empty list on failure.
  Future<List<String>> getPropertyValues({
    required String property,
    TaskFilter? filter,
    TaskSort? sort,
  }) async {
    return await _taskPropertyService.getPropertyValues(
      property: property,
      filter: filter,
      sort: sort,
    );
  }

  /// Get distinct property values stored in the database with typed conversion.
  ///
  /// This is the typed version of [getPropertyValues]. It queries the database
  /// for distinct values of the given property and converts them to the requested
  /// type [T].
  ///
  /// Supported types:
  /// - [String] – returns raw string values (description, project, etc.)
  /// - [DateTime] – returns parsed [DateTime] objects (due, wait, etc.)
  /// - [TaskStatus] – returns [TaskStatus] enum values
  /// - [TaskPriority] – returns [TaskPriority] enum values
  ///
  /// Throws [ArgumentError] if [T] is not a supported type.
  Future<List<T>> getStoredPropertyValues<T>({
    required String property,
    TaskFilter? filter,
    TaskSort? sort,
  }) async {
    return await _taskPropertyService.getStoredPropertyValues<T>(
      property: property,
      filter: filter,
      sort: sort,
    );
  }

  /// Get all possible enum values for a given type, independent of stored data.
  ///
  /// This method returns every possible value for the requested type, regardless
  /// of what's actually stored in the database. It only supports enum types:
  /// - [TaskStatus] – returns all [TaskStatus] values
  /// - [TaskPriority] – returns all [TaskPriority] values
  ///
  /// Throws [ArgumentError] if [T] is not [TaskStatus] or [TaskPriority].
  Future<List<T>> getAllPropertyValues<T>() async {
    return await _taskPropertyService.getAllPropertyValues<T>();
  }

  /// Get distinct tag values from tasks.
  ///
  /// [filter] – optional [TaskFilter] to limit the tasks considered.
  /// [includeVirtualTags] – when true, include virtual tags in the results.
  /// [pattern] – optional case‑insensitive substring that a tag must contain.
  ///
  /// Returns a sorted list of distinct tag strings, or an empty list on failure.
  Future<List<String>> getTags({
    TaskFilter? filter,
    bool includeVirtualTags = false,
    String? pattern,
  }) async {
    return await _taskTagService.getTags(
      filter: filter,
      includeVirtualTags: includeVirtualTags,
      pattern: pattern,
    );
  }

  /// Get a single task by UUID
  Future<Task?> getTask(String uuid) async {
    return _taskService.getTaskByUuid(uuid);
  }

  /// Create a new task
  ///
  /// [description] - Task description (required)
  /// [priority] - Task priority (default: none)
  /// [project] - Project name (optional)
  /// [tags] - List of tags (optional)
  /// [due] - Due date (optional)
  /// [wait] - Wait until date (optional)
  ///
  /// Returns the created task.
  Future<Task> createTask({
    required String description,
    TaskPriority priority = TaskPriority.none,
    String? project,
    List<String>? tags,
    DateTime? due,
    DateTime? wait,
  }) async {
    final task = await _taskService.createTask(
      description: description,
      priority: priority,
      project: project,
      tags: tags ?? [],
      due: due,
      wait: wait,
    );

    // Emit task change event
    _eventManager.emitTaskChange(task);

    // Auto-sync is handled by the event listener when connected

    return task;
  }

  /// Update an existing task
  ///
  /// [uuid] - Task UUID to update
  /// [description] - New description (optional)
  /// [status] - New status (optional)
  /// [priority] - New priority (optional)
  /// [project] - New project (optional)
  /// [tags] - New tags (optional, replaces existing)
  /// [due] - New due date (optional)
  ///
  /// Returns the updated task.
  Future<Task> updateTask({
    required String uuid,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? project,
    List<String>? tags,
    DateTime? due,
  }) async {
    final task = await _taskService.updateTask(
      uuid: uuid,
      description: description,
      status: status,
      priority: priority,
      project: project,
      tags: tags,
      due: due,
    );

    // Emit task change event
    _eventManager.emitTaskChange(task);

    // Auto-sync is handled by the event listener when connected

    return task;
  }

  /// Delete a task
  ///
  /// [uuid] - Task UUID to delete
  Future<void> deleteTask(String uuid) async {
    await _taskService.deleteTask(uuid);

    // Emit task change event (get the task before deletion)
    final task = await getTask(uuid);
    if (task != null) {
      _eventManager.emitTaskChange(task);
    }

    // Auto-sync is handled by the event listener when connected
  }

  /// Get task statistics
  Future<TaskStats> getStats() async {
    return _taskService.getStats();
  }

  /// Export tasks to a JSON file
  Future<int> exportTasks(String filePath) async {
    return _taskService.exportTasks(filePath);
  }

  /// Import tasks from a JSON file
  Future<int> importTasks(String filePath) async {
    final count = await _taskService.importTasks(filePath);

    // Emit task change events for imported tasks
    final tasks = await getAllTasks();
    for (final task in tasks.take(count)) {
      _eventManager.emitTaskChange(task);
    }

    return count;
  }

  /// Get the latest snapshot from the server
  Future<Map<String, dynamic>?> getSnapshot() async {
    return _syncService.getSnapshot();
  }

  /// Dispose of the client and release resources
  void dispose() {
    _autoSyncCoordinator.dispose();
    _eventManager.dispose();
    disconnect();
    debugPrint('TaskChampionClient disposed');
  }
}
