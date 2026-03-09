import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models/models.dart';
import 'services/services.dart';
import 'rust_bridge/frb_generated.dart';
import 'utils/native_assets.dart';

/// TaskChampion Client - Main public API for TaskChampion operations
///
/// This class provides a high-level, programmer-friendly interface for:
/// - Task management (create, read, update, delete)
/// - Synchronization with TaskChampion sync server
/// - Authentication and credential management
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

  /// Task service for managing tasks
  late final TaskService _taskService;

  /// Sync service for synchronization
  late final SyncService _syncService;

  /// Auth service for authentication
  late final AuthService _authService;

  /// Whether the client is connected to the server
  bool _isConnected = false;

  /// Stream controller for task changes
  final _taskChangesController = StreamController<Task>.broadcast();

  /// Stream controller for sync events
  final _syncEventsController = StreamController<SyncResult>.broadcast();

  /// Initialize the TaskChampion library
  ///
  /// This must be called before creating any TaskChampionClient instances.
  /// It initializes the Rust FFI bridge and sets up necessary platform bindings.
  ///
  /// The initialization process:
  /// 1. Loads native assets from GitHub Releases or local build
  /// 2. Initializes the Rust FFI bridge
  /// 3. Sets up platform-specific bindings
  static Future<void> init() async {
    // Initialize native assets loader
    await NativeAssetsLoader.init();

    // Initialize Rust FFI bridge
    await RustLib.init();

    debugPrint('TaskChampionClient initialized with Native Assets');
  }

  /// Create a new TaskChampionClient instance
  ///
  /// [serverUrl] - URL of the TaskChampion sync server
  /// [clientId] - Client ID for authentication
  /// [encryptionSecret] - Secret key for encrypting sync data
  /// [taskdbPath] - Optional custom path for task database
  TaskChampionClient({
    required String serverUrl,
    required String clientId,
    required String encryptionSecret,
    String? taskdbPath,
    bool autoSync = false,
    bool debugLogging = false,
  }) : config = ClientConfig.createMinimal(
         serverUrl: serverUrl,
         clientId: clientId,
         encryptionSecret: encryptionSecret,
         taskdbPath: taskdbPath,
       ) {
    _initializeServices();
  }

  /// Create a TaskChampionClient with custom configuration
  TaskChampionClient.withConfig(this.config) {
    _initializeServices();
  }

  /// Initialize internal services
  void _initializeServices() {
    _taskService = TaskService(config.taskdbPath);
    _syncService = SyncService(config.taskdbPath, config.syncConfig);
    _authService = AuthService(config.authConfig);

    // Listen to sync events if auto-sync is enabled
    if (config.autoSyncOnTaskChange) {
      _taskChangesController.stream.listen((_) {
        // Debounce auto-sync
        _debouncedSync();
      });
    }
  }

  /// Debounce timer for auto-sync
  Timer? _syncDebounceTimer;

  /// Debounced sync operation
  void _debouncedSync() {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(const Duration(seconds: 2), () {
      sync();
    });
  }

  /// Get the task database path
  String get taskdbPath => config.taskdbPath;

  /// Get the server URL
  String get serverUrl => config.syncConfig.serverUrl;

  /// Get the client ID
  String get clientId => config.syncConfig.clientId;

  /// Check if connected to the server
  bool get isConnected => _isConnected;

  /// Stream of task changes
  Stream<Task> get taskChanges => _taskChangesController.stream;

  /// Stream of sync events
  Stream<SyncResult> get syncEvents => _syncEventsController.stream;

  /// Connect to the TaskChampion sync server
  ///
  /// This validates credentials and establishes a connection.
  /// Call this before performing sync operations.
  Future<AuthResult> connect() async {
    try {
      if (config.debugLogging) {
        debugPrint('Connecting to server: $serverUrl');
      }

      // Validate credentials
      final authResult = await _authService.validateCredentials();

      if (authResult.success) {
        _isConnected = true;
        debugPrint('Connected to server: $serverUrl');
      } else {
        debugPrint('Connection failed: ${authResult.errorMessage}');
      }

      return authResult;
    } catch (e) {
      _isConnected = false;
      return AuthResult(
        success: false,
        errorMessage: 'Connection error: $e',
        authenticatedAt: DateTime.now(),
      );
    }
  }

  /// Disconnect from the server
  void disconnect() {
    _isConnected = false;
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
      _syncEventsController.add(syncResult);

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
      _syncEventsController.add(errorResult);
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
    _taskChangesController.add(task);

    // Auto-sync if enabled
    if (config.autoSyncOnTaskChange && _isConnected) {
      _debouncedSync();
    }

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
    _taskChangesController.add(task);

    // Auto-sync if enabled
    if (config.autoSyncOnTaskChange && _isConnected) {
      _debouncedSync();
    }

    return task;
  }

  /// Delete a task
  ///
  /// [uuid] - Task UUID to delete
  /// [permanent] - If true, permanently delete (default: false, marks as deleted)
  Future<void> deleteTask(String uuid, {bool permanent = false}) async {
    await _taskService.deleteTask(uuid, permanent: permanent);

    // Emit task change event (get the task before deletion)
    final task = await getTask(uuid);
    if (task != null) {
      _taskChangesController.add(task);
    }

    // Auto-sync if enabled
    if (config.autoSyncOnTaskChange && _isConnected) {
      _debouncedSync();
    }
  }

  /// Mark a task as completed
  Future<Task> completeTask(String uuid) async {
    return updateTask(uuid: uuid, status: TaskStatus.completed);
  }

  /// Mark a task as pending (reopen)
  Future<Task> reopenTask(String uuid) async {
    return updateTask(uuid: uuid, status: TaskStatus.pending);
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
      _taskChangesController.add(task);
    }

    return count;
  }

  /// Validate current credentials
  Future<AuthResult> validateCredentials() async {
    return _authService.validateCredentials();
  }

  /// Get the latest snapshot from the server
  Future<Map<String, dynamic>?> getSnapshot() async {
    return _syncService.getSnapshot();
  }

  /// Dispose of the client and release resources
  void dispose() {
    _syncDebounceTimer?.cancel();
    _taskChangesController.close();
    _syncEventsController.close();
    disconnect();
    debugPrint('TaskChampionClient disposed');
  }
}

/// Task statistics data class
class TaskStats {
  /// Total number of tasks
  final int total;

  /// Number of pending tasks
  final int pending;

  /// Number of completed tasks
  final int completed;

  /// Number of deleted tasks
  final int deleted;

  const TaskStats({
    required this.total,
    required this.pending,
    required this.completed,
    required this.deleted,
  });

  /// Create TaskStats from a map
  factory TaskStats.fromMap(Map<String, int> map) {
    return TaskStats(
      total: map['total_tasks'] ?? 0,
      pending: map['pending'] ?? 0,
      completed: map['completed'] ?? 0,
      deleted: map['deleted'] ?? 0,
    );
  }
}
