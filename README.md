# TaskChampion Client Library (Rust/Flutter)

A comprehensive Flutter/Dart client library for [TaskChampion](https://github.com/GothenburgBitFactory/taskchampion) with Rust FFI bindings. This library provides a programmer-friendly interface for task management, synchronization with TaskChampion sync servers, and secure authentication.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Zloooy/taskwarrior_client_rust)

## Features

- ✅ **Task Management**: Full CRUD operations for tasks (create, read, update, delete)
- ✅ **Synchronization**: Sync tasks with TaskChampion sync server (GothenburgBitFactory/taskchampion-sync-server)
- ✅ **Authentication**: Secure client credential management and validation
- ✅ **Offline Support**: Full offline task management with automatic sync when online
- ✅ **Encryption**: End-to-end encryption for synchronized data using AES-256
- ✅ **Rust FFI**: High-performance native code via flutter_rust_bridge
- ✅ **Type-Safe API**: Strongly-typed Dart models with freezed code generation
- ✅ **Streams**: Reactive streams for task changes and sync events
- ✅ **Auto-Sync**: Configurable automatic synchronization

## Architecture

The library is built with a layered architecture:

```
┌─────────────────────────────────────┐
│     Public API (TaskChampionClient) │
├─────────────────────────────────────┤
│         Service Layer               │
│  ┌──────────┬──────────┬─────────┐  │
│  │  Task    │   Sync   │  Auth   │  │
│  │ Service  │ Service  │ Service │  │
│  └──────────┴──────────┴─────────┘  │
├─────────────────────────────────────┤
│      Rust FFI Bridge Layer          │
│         (flutter_rust_bridge)       │
├─────────────────────────────────────┤
│         Rust Backend                │
│      (tc_helper + taskchampion)     │
└─────────────────────────────────────┘
```

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  taskchampion_client_rust: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize the Library

```dart
import 'package:taskchampion_client_rust/taskchampion_client_rust.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the TaskChampion library
  await TaskChampionClient.init();
  
  runApp(MyApp());
}
```

### 2. Create a Client Instance

```dart
final client = TaskChampionClient(
  serverUrl: 'https://your-sync-server.com',
  clientId: 'your-client-id',
  encryptionSecret: 'your-encryption-secret',
  autoSync: true,  // Enable automatic sync
  debugLogging: true,
);
```

### 3. Connect and Sync

```dart
// Connect to the server
final authResult = await client.connect();

if (authResult.success) {
  // Sync tasks
  final syncResult = await client.sync();
  print(syncResult.summary);
}
```

### 4. Manage Tasks

```dart
// Get all pending tasks
final tasks = await client.getPendingTasks();

// Create a new task
final task = await client.createTask(
  description: 'Buy milk',
  priority: TaskPriority.high,
  due: DateTime.now().add(const Duration(days: 1)),
  tags: ['shopping', 'urgent'],
);

// Update a task
await client.updateTask(
  uuid: task.uuid,
  status: TaskStatus.completed,
);

// Delete a task
await client.deleteTask(task.uuid);
```

## API Reference

### TaskChampionClient

The main class providing all TaskChampion functionality.

#### Constructor

```dart
TaskChampionClient({
  required String serverUrl,
  required String clientId,
  required String encryptionSecret,
  String? taskdbPath,
  bool autoSync = false,
  bool debugLogging = false,
})
```

#### Key Methods

| Method | Description |
|--------|-------------|
| `connect()` | Connect and validate credentials with the server |
| `disconnect()` | Disconnect from the server |
| `sync()` | Synchronize tasks with the server |
| `getAllTasks({status})` | Get all tasks, optionally filtered by status |
| `filterTasks(filter)` | Get tasks matching a custom filter expression |
| `getTask(uuid)` | Get a single task by UUID |
| `getPendingTasks()` | Get all pending tasks |
| `getCompletedTasks()` | Get all completed tasks |
| `createTask(...)` | Create a new task |
| `updateTask(...)` | Update an existing task |
| `deleteTask(uuid)` | Delete a task |
| `completeTask(uuid)` | Mark a task as completed |
| `reopenTask(uuid)` | Mark a completed task as pending |
| `searchTasks(query)` | Search tasks by description |
| `getTasksByProject(project)` | Get tasks by project |
| `getTasksByTag(tag)` | Get tasks by tag |
| `getStats()` | Get task statistics |
| `validateCredentials()` | Validate current credentials |
| `exportTasks(filePath)` | Export tasks to a JSON file |
| `importTasks(filePath)` | Import tasks from a JSON file |

#### Streams

```dart
// Listen to task changes
client.taskChanges.listen((task) {
  print('Task changed: ${task.description}');
});

// Listen to sync events
client.syncEvents.listen((result) {
  print('Sync ${result.success ? 'succeeded' : 'failed'}');
});
```

### Models

#### Task

```dart
@freezed
class Task with _$Task {
  const factory Task({
    required String uuid,
    required String description,
    @Default(TaskStatus.pending) TaskStatus status,
    @Default(TaskPriority.none) TaskPriority priority,
    String? project,
    @Default([]) List<String> tags,
    DateTime? due,
    DateTime? wait,
    DateTime? scheduled,
    DateTime? until,
    required DateTime entry,
    DateTime? modified,
    DateTime? end,
    @Default({}) Map<String, String> annotations,
    double? urgency,
    String? parent,
    @Default([]) List<String> depends,
  }) = _Task;
}
```

#### TaskStatus

```dart
enum TaskStatus {
  pending,    // Task is active
  completed,  // Task is completed
  deleted,    // Task is deleted
}
```

#### TaskPriority

```dart
enum TaskPriority {
  high,
  medium,
  low,
  none,
}
```

#### SyncResult

```dart
@freezed
class SyncResult with _$SyncResult {
  const factory SyncResult({
    required bool success,
    @Default(0) int versionsSynced,
    @Default(0) int tasksAdded,
    @Default(0) int tasksUpdated,
    @Default(0) int tasksDeleted,
    String? errorMessage,
    int? durationMs,
    DateTime? completedAt,
    @Default(false) bool snapshotDownloaded,
    @Default(false) bool snapshotUploaded,
  }) = _SyncResult;
}
```

## Advanced Usage

### Custom Configuration

```dart
final config = ClientConfig(
  taskdbPath: '/custom/path/to/db',
  syncConfig: SyncConfig(
    serverUrl: 'https://sync.example.com',
    clientId: 'your-client-id',
    encryptionSecret: 'your-secret',
    timeout: 60000,  // 60 second timeout
    autoSync: true,
    verboseLogging: true,
  ),
  authConfig: AuthConfig(
    clientId: 'your-client-id',
    encryptionSecret: 'your-secret',
    serverUrl: 'https://sync.example.com',
    validateCertificates: true,
  ),
  autoSyncOnStartup: true,
  autoSyncOnTaskChange: true,
  syncIntervalMinutes: 10,
);

final client = TaskChampionClient.withConfig(config);
```

### Generate Credentials

```dart
// Generate a new client ID
final clientId = await AuthService.generateClientId();

// Generate a new encryption secret
final secret = await AuthService.generateEncryptionSecret();
```

### Error Handling

```dart
try {
  final result = await client.sync();
  
  if (!result.success) {
    print('Sync failed: ${result.errorMessage}');
  }
} catch (e) {
  print('Error during sync: $e');
}
```

### Filtering and Searching

The library provides multiple approaches to filter and search tasks, from simple helper methods to advanced composable filters.

#### Simple Filtering Methods

```dart
// Get tasks by project
final projectTasks = await client.getTasksByProject('Work');

// Get tasks by tag
final taggedTasks = await client.getTasksByTag('urgent');

// Search tasks by description (case-insensitive)
final searchResults = await client.searchTasks('buy');

// Get tasks by status
final pendingTasks = await client.getPendingTasks();
final completedTasks = await client.getCompletedTasks();
final allTasks = await client.getAllTasks();
final filteredTasks = await client.getAllTasks(status: TaskStatus.pending);

// Get task statistics
final stats = await client.getStats();
print('Total: ${stats.total}, Pending: ${stats.pending}');
```

#### Advanced Filtering with TaskFilter

For more complex queries, use the `TaskFilter` system with composable filters:

```dart
import 'package:taskchampion_client_rust/taskchampion_client_rust.dart';

// Filter by status (pending tasks only)
final pendingFilter = TaskFilter(
  AndFilterGroup([
    EqualsFilter(
      property: TaskFilter.status,
      value: 'pending',
    ),
  ]),
);

// Filter by priority (high priority tasks)
final highPriorityFilter = TaskFilter(
  AndFilterGroup([
    EqualsFilter(
      property: TaskFilter.priority,
      value: 'high',
    ),
  ]),
);

// Filter by due date (tasks due from today)
final dueSoonFilter = TaskFilter(
  AndFilterGroup([
    DateFromFilter(
      property: TaskFilter.due,
      from: DateTime.now(),
    ),
  ]),
);

// Filter by multiple tags (OR logic)
final taggedFilter = TaskFilter(
  AndFilterGroup([
    InFilter(
      property: TaskPropertyRef<String>('tags'),
      values: {'urgent', 'important'},
    ),
  ]),
);

// Complex filter: pending tasks with high priority OR due this week
final complexFilter = TaskFilter(
  AndFilterGroup([
    EqualsFilter(
      property: TaskFilter.status,
      value: 'pending',
    ),
    OrFilterGroup([
      EqualsFilter(
        property: TaskFilter.priority,
        value: 'high',
      ),
      DateToFilter(
        property: TaskFilter.due,
        to: DateTime.now().add(const Duration(days: 7)),
      ),
    ]),
  ]),
);

// Filter with substring search (case-insensitive)
final containsFilter = TaskFilter(
  AndFilterGroup([
    ContainsFilter(
      property: TaskFilter.description,
      value: 'meeting',
      caseSensitive: false,
    ),
  ]),
);

// Filter by date range (tasks created in the last 30 days)
final recentTasksFilter = TaskFilter(
  AndFilterGroup([
    DateFromFilter(
      property: TaskFilter.entry,
      from: DateTime.now().subtract(const Duration(days: 30)),
    ),
    DateToFilter(
      property: TaskFilter.entry,
      to: DateTime.now(),
    ),
  ]),
);
```

#### Available Filter Types

| Filter | Description | Example |
|--------|-------------|---------|
| `EqualsFilter<T>` | Property equals a specific value | `EqualsFilter(property: TaskFilter.status, value: 'pending')` |
| `InFilter<T>` | Property is in a set of values | `InFilter(property: TaskFilter.priority, values: {'high', 'medium'})` |
| `NotInFilter<T>` | Property is NOT in a set of values | `NotInFilter(property: TaskFilter.status, values: {'deleted'})` |
| `DateFromFilter` | Date property is from a specific date | `DateFromFilter(property: TaskFilter.due, from: DateTime.now())` |
| `DateToFilter` | Date property is up to a specific date | `DateToFilter(property: TaskFilter.due, to: DateTime.now())` |
| `ContainsFilter` | String property contains a substring | `ContainsFilter(property: TaskFilter.description, value: 'bug')` |

#### Available Property References

| Property | Type | Description |
|----------|------|-------------|
| `TaskFilter.description` | String | Task description |
| `TaskFilter.status` | String | Task status (pending, completed, deleted) |
| `TaskFilter.priority` | String | Task priority (high, medium, low, none) |
| `TaskFilter.due` | DateTime | Due date |
| `TaskFilter.wait` | DateTime | Wait until date |
| `TaskFilter.entry` | DateTime | Creation date |
| `TaskFilter.modified` | DateTime | Last modified date |

#### Logical Group Operators

Combine multiple filters using logical operators:

- **`AndFilterGroup`** - All filters in the group must match (logical AND)
- **`OrFilterGroup`** - At least one filter in the group must match (logical OR)

```dart
// Example: (pending AND high priority) OR (due today)
final filter = TaskFilter(
  OrFilterGroup([
    AndFilterGroup([
      EqualsFilter(property: TaskFilter.status, value: 'pending'),
      EqualsFilter(property: TaskFilter.priority, value: 'high'),
    ]),
    DateToFilter(property: TaskFilter.due, to: DateTime.now()),
  ]),
);
```

> **Note:** The advanced `TaskFilter` API is available for complex queries. Use `client.filterTasks(filter)` to apply custom filters. See the [API Reference](#taskchampionclient) for more details.

### Import/Export

```dart
// Export all tasks to a file
final count = await client.exportTasks('/path/to/export.json');
print('Exported $count tasks');

// Import tasks from a file
final imported = await client.importTasks('/path/to/import.json');
print('Imported $imported tasks');
```

## Rust Backend

The library uses a Rust backend (`tc_helper`) that provides:

- **TaskChampion Integration**: Uses the official `taskchampion` Rust crate
- **SQLite Storage**: Efficient local storage via rusqlite
- **Sync Protocol**: Implements the TaskChampion sync protocol
- **Encryption**: AES-256 encryption via the `ring` crate

### Building the Rust Library

To build the Rust library:

```bash
# 1. Install flutter_rust_bridge code generator
# Note: The package is called flutter_rust_bridge_codegen, NOT flutter_rust_bridge_generator
cargo install flutter_rust_bridge_codegen

# 2. Generate FFI bindings (uses flutter_rust_bridge.yaml config)
flutter_rust_bridge_codegen generate

# Or with command-line arguments:
# flutter_rust_bridge_codegen generate \
#   --rust-input rust/src/lib.rs \
#   --dart-output lib/src/rust_bridge/frb_generated.dart \
#   --rust-root rust

# 3. (Optional) Watch mode - auto-regenerate on Rust code changes
# flutter_rust_bridge_codegen generate --watch

# 4. Build for Android
cargo ndk -t arm64-v8a -t armeabi-v7a \
  -o android/app/src/main/jniLibs build --release

# 5. Build for iOS
cargo build --target aarch64-apple-ios --release

# 6. Build for macOS
cargo build --release

# 7. Build for Linux (for running tests)
cargo build --release
```

### Running Tests

The library includes integration tests that verify the FFI bridge between Dart and Rust. To run the tests:

```bash
# 1. Ensure the Rust library is built for your platform
# For Linux (running tests locally):
cargo build --release

# For Android:
cargo ndk -t arm64-v8a -t armeabi-v7a \
  -o android/app/src/main/jniLibs build --release

# For iOS:
cargo build --target aarch64-apple-ios --release

# For macOS:
cargo build --release

# 2. Generate FFI bindings (if not already done)
flutter_rust_bridge_codegen generate

# 3. Install Dart/Flutter dependencies
flutter pub get

# 4. Run tests
flutter test

# Run specific test file
flutter test test/filter_integration_test.dart

# Run tests with coverage
flutter test --coverage
```

**Note:** Tests require the compiled Rust library to be present in `rust/target/release/`. Make sure to build the Rust library before running tests.

### Configuration

The `flutter_rust_bridge.yaml` file configures the code generation:

```yaml
rust_input: rust/src/lib.rs
dart_output: lib/src/rust_bridge/frb_generated.dart
rust_root: rust
dart_format_line_length: 80
```

Alternatively, you can add the configuration to `pubspec.yaml`:

```yaml
flutter_rust_bridge:
  rust_input: rust/src/lib.rs
  dart_output: lib/src/rust_bridge/frb_generated.dart
  rust_root: rust
```

## Sync Server Compatibility

This library is compatible with:

- ✅ [GothenburgBitFactory/taskchampion-sync-server](https://github.com/GothenburgBitFactory/taskchampion-sync-server)
- ✅ Self-hosted TaskChampion sync servers
- ✅ TaskChampion protocol v1

## Security

- **Encryption**: All synchronized data is encrypted using AES-256-GCM
- **Key Derivation**: PBKDF2-SHA256 with 100,000 iterations
- **Secure Storage**: Credentials should be stored using flutter_secure_storage
- **Certificate Validation**: Optional SSL certificate validation

## Platform Support

| Platform | Support | Notes |
|----------|---------|-------|
| Android | ✅ Full support | Requires `cargo ndk` |
| iOS | ✅ Full support | Requires iOS target build |
| macOS | ✅ Full support | Native binary |
| Linux | ✅ Full support (dev & tests) | Native binary for development and testing |
| Windows | ⚠️ Partial | No Rust FFI |
| Web | ❌ Not supported | FFI not available on web |

## Native Assets

This package uses Dart's **Native Assets** system to distribute pre-built Rust libraries via GitHub Releases. The native libraries are automatically downloaded during the build process.

### How It Works

1. **CI/CD Pipeline**: When a version tag is pushed, GitHub Actions builds Rust libraries for all supported platforms and publishes them as artifacts in a GitHub Release.

2. **Build Hook**: During `flutter build` or `dart pub get`, the `hook/build.dart` script:
   - Downloads the appropriate native library archive from GitHub Releases
   - Extracts the library for your specific platform and architecture
   - Registers it with the Native Assets build system

3. **Runtime**: The `NativeAssetsLoader` class loads the native library and makes it available to FFI bindings.

### Release Artifacts

| Platform | Archive | Library Format |
|----------|---------|----------------|
| Android | `taskchampion_client_rust-android-v*.zip` | `.so` (shared library) |
| iOS | `taskchampion_client_rust-ios-v*.zip` | `.a` (static library) |
| macOS | `taskchampion_client_rust-macos-v*.zip` | `.dylib` (dynamic library) |
| Linux | `taskchampion_client_rust-linux-v*.zip` | `.so` (shared library) |

## Examples

See the `example/` directory for complete example applications demonstrating:

- Basic task management
- Sync server integration
- Offline-first architecture
- Reactive UI updates with streams

## Troubleshooting

### Common Issues

**"TaskChampion not initialized"**
- Make sure to call `await TaskChampionClient.init()` before creating any client instances

**"Sync failed: Connection refused"**
- Check that your sync server is running and accessible
- Verify the server URL is correct (include https://)

**"Invalid credentials"**
- Ensure client ID is a valid UUID
- Check that encryption secret matches across all clients

**"Rust FFI bridge not found"**
- Make sure the Rust library is built for your target platform
- Check that flutter_rust_bridge is properly configured

**Tests fail with "compiled library not found"**
- Build the Rust library for your platform before running tests:
  ```bash
  cargo build --release  # For Linux/macOS
  ```
- Ensure the library is in `rust/target/release/`
- Run `flutter_rust_bridge_codegen generate` to regenerate FFI bindings

**Tests fail with timezone-related assertions**
- The library uses UTC for all datetime operations
- When writing tests, use `.toUtc()` on DateTime objects:
  ```dart
  final now = DateTime.now().toUtc();
  ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [TaskChampion](https://github.com/GothenburgBitFactory/taskchampion) by the Taskwarrior team
- [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge) for FFI bindings
- [Taskwarrior-Flutter](https://github.com/CCExtractor/taskwarrior-flutter) for inspiration

## Links

- [TaskChampion Documentation](https://gothenburgbitfactory.github.io/taskchampion/)
- [TaskChampion Sync Server](https://github.com/GothenburgBitFactory/taskchampion-sync-server)
