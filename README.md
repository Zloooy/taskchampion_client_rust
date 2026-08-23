# TaskChampion Client Library (Rust/Flutter)

A comprehensive Flutter/Dart client library for [TaskChampion](https://github.com/GothenburgBitFactory/taskchampion) with Rust FFI bindings. This library provides a programmer-friendly interface for task management, synchronization with TaskChampion sync servers, and secure authentication.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Zloooy/taskchampion_client_rust)
[![zread](https://img.shields.io/badge/Zread-ask-green)](https://zread.ai/Zloooy/taskchampion_client_rust)

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
  taskchampion_client_rust: ^0.5.0
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

// Create a new task (all user-settable attributes via TaskParams)
final task = await client.createTask(TaskParams(
  description: 'Buy milk',
  priority: TaskPriority.high,
  due: DateTime.now().add(const Duration(days: 1)),
  tags: ['shopping', 'urgent'],
));

// Update a task (full state; addressed by task.uuid, which is read-only)
await client.updateTask(task.copyWith(status: TaskStatus.completed));

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
| `createTask(TaskParams)` | Create a new task from fully-typed parameters |
| `updateTask(Task)` | Update an existing task with its full desired state |
| `deleteTask(uuid)` | Delete a task |
| `completeTask(uuid)` | Mark a task as completed |
| `reopenTask(uuid)` | Mark a completed task as pending |
| `searchTasks(query)` | Search tasks by description |
| `getTasksByProject(project)` | Get tasks by project |
| `getTasksByTag(tag)` | Get tasks by tag |
| `getPropertyValues({property, filter, sort})` | Get distinct string values for a task property (description, due, project, etc.) |
| `getStoredPropertyValues<T>({property, filter, sort})` | Get distinct property values with typed conversion (String, DateTime, TaskStatus, TaskPriority) |
| `getAllPropertyValues<T>()` | Get all possible enum values for a type (TaskStatus, TaskPriority only) |
| `getTags({filter, includeVirtualTags, pattern})` | Get distinct tags with optional virtual tag inclusion and pattern filtering |
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

For more complex queries, use the `TaskFilter` system with composable filters. Every filter is a factory constructor on the sealed `FilterExpression` class (freezed union, JSON key `type`):

```dart
import 'package:taskchampion_client_rust/taskchampion_client_rust.dart';

// Filter by status (pending tasks only)
final pendingFilter = TaskFilter(
  FilterExpression.andGroup(filters: [
    FilterExpression.equals(
      property: TaskFilter.status,
      value: 'pending',
    ),
  ]),
);

// Filter by priority (high priority tasks)
final highPriorityFilter = TaskFilter(
  FilterExpression.andGroup(filters: [
    FilterExpression.equals(
      property: TaskFilter.priority,
      value: 'high',
    ),
  ]),
);

// Filter by due date (tasks due from today)
final dueSoonFilter = TaskFilter(
  FilterExpression.andGroup(filters: [
    FilterExpression.dateFrom(
      property: TaskFilter.due,
      from: DateTime.now(),
    ),
  ]),
);

// Filter by multiple tags (OR logic) - tags is a string property
final taggedFilter = TaskFilter(
  FilterExpression.orGroup(filters: [
    FilterExpression.contains(
      property: StringPropertyRef('tags'),
      value: 'urgent',
    ),
    FilterExpression.contains(
      property: StringPropertyRef('tags'),
      value: 'important',
    ),
  ]),
);

// Complex filter: pending tasks with high priority OR due this week
final complexFilter = TaskFilter(
  FilterExpression.andGroup(filters: [
    FilterExpression.equals(
      property: TaskFilter.status,
      value: 'pending',
    ),
    FilterExpression.orGroup(filters: [
      FilterExpression.equals(
        property: TaskFilter.priority,
        value: 'high',
      ),
      FilterExpression.dateTo(
        property: TaskFilter.due,
        to: DateTime.now().add(const Duration(days: 7)),
      ),
    ]),
  ]),
);

// Filter with substring search (case-insensitive)
final containsFilter = TaskFilter(
  FilterExpression.andGroup(filters: [
    FilterExpression.contains(
      property: TaskFilter.description,
      value: 'meeting',
      caseSensitive: false,
    ),
  ]),
);

// Filter by date range (tasks created in the last 30 days)
final recentTasksFilter = TaskFilter(
  FilterExpression.andGroup(filters: [
    FilterExpression.dateFrom(
      property: TaskFilter.entry,
      from: DateTime.now().subtract(const Duration(days: 30)),
    ),
    FilterExpression.dateTo(
      property: TaskFilter.entry,
      to: DateTime.now(),
    ),
  ]),
);
```

#### Available Filter Types

All filters are factory constructors on `FilterExpression`. Each serializes to a JSON object with a `"type"` key set to the PascalCase union value (e.g. `"AndGroup"`, `"EqualsFilter"`).

| Factory Constructor | Union Value (`type`) | Description | Example |
|--------|-------------|---------|---------|
| `FilterExpression.andGroup(filters:)` | `AndGroup` | All child filters must match (logical AND) | `.andGroup(filters: [...])` |
| `FilterExpression.orGroup(filters:)` | `OrGroup` | At least one child filter must match (logical OR) | `.orGroup(filters: [...])` |
| `FilterExpression.xorGroup(filters:)` | `XorGroup` | An odd number of child filters must match (logical XOR) | `.xorGroup(filters: [...])` |
| `FilterExpression.not(inner:)` | `Not` | Negates a single inner filter | `.not(inner: ...)` |
| `FilterExpression.tag(tag:, {exclude})` | `Tag` | Task has (or, when `exclude`, lacks) a tag | `.tag(tag: 'urgent')` |
| `FilterExpression.virtualTag(tag:, {exclude})` | `VirtualTag` | Task matches (or lacks) a virtual tag (ACTIVE, PENDING, BLOCKED, ...) | `.virtualTag(tag: 'PENDING')` |
| `FilterExpression.equals(property:, value:)` | `EqualsFilter` | Property equals a specific value | `.equals(property: TaskFilter.status, value: 'pending')` |
| `FilterExpression.notEquals(property:, value:)` | `NotEqualsFilter` | Property is not equal to a value | `.notEquals(property: TaskFilter.status, value: 'deleted')` |
| `FilterExpression.inValues(property:, values:)` | `InFilter` | Property is in a list of values | `.inValues(property: TaskFilter.priority, values: ['high', 'medium'])` |
| `FilterExpression.notInValues(property:, values:)` | `NotInFilter` | Property is NOT in a list of values | `.notInValues(property: TaskFilter.status, values: ['deleted'])` |
| `FilterExpression.contains(property:, value:, {caseSensitive})` | `ContainsFilter` | String property contains a substring | `.contains(property: TaskFilter.description, value: 'bug')` |
| `FilterExpression.notContains(property:, value:, {caseSensitive})` | `NotContainsFilter` | String property does not contain a substring | `.notContains(property: TaskFilter.description, value: 'bug')` |
| `FilterExpression.startsWith(property:, value:, {caseSensitive})` | `StartsWithFilter` | String property starts with a prefix | `.startsWith(property: TaskFilter.description, value: 'BUG-')` |
| `FilterExpression.endsWith(property:, value:, {caseSensitive})` | `EndsWithFilter` | String property ends with a suffix | `.endsWith(property: TaskFilter.description, value: '-done')` |
| `FilterExpression.word(property:, value:, {caseSensitive})` | `WordFilter` | String property contains a whole word | `.word(property: TaskFilter.description, value: 'milk')` |
| `FilterExpression.noWord(property:, value:, {caseSensitive})` | `NoWordFilter` | String property does not contain a whole word | `.noWord(property: TaskFilter.description, value: 'spam')` |
| `FilterExpression.regex(property:, pattern:, {caseSensitive})` | `RegexFilter` | String property matches a regular expression | `.regex(property: TaskFilter.description, pattern: r'^\d+$')` |
| `FilterExpression.none(property:)` | `NoneFilter` | Property is empty / unset | `.none(property: TaskFilter.project)` |
| `FilterExpression.any(property:)` | `AnyFilter` | Property is set / non-empty | `.any(property: TaskFilter.project)` |
| `FilterExpression.dateBefore(property:, date:)` | `DateBeforeFilter` | Date property is before a date | `.dateBefore(property: TaskFilter.due, date: DateTime.now())` |
| `FilterExpression.dateAfter(property:, date:)` | `DateAfterFilter` | Date property is after a date | `.dateAfter(property: TaskFilter.due, date: DateTime.now())` |
| `FilterExpression.dateBy(property:, date:)` | `DateByFilter` | Date property is on or before a date | `.dateBy(property: TaskFilter.due, date: DateTime.now())` |
| `FilterExpression.dateFrom(property:, from:)` | `DateFromFilter` | Date property is from a date onward | `.dateFrom(property: TaskFilter.due, from: DateTime.now())` |
| `FilterExpression.dateTo(property:, to:)` | `DateToFilter` | Date property is up to a date | `.dateTo(property: TaskFilter.due, to: DateTime.now())` |
| `FilterExpression.lessThan(property:, value:)` | `LessThanFilter` | Numeric property is less than a value | `.lessThan(property: TaskFilter.urgency, value: 5)` |
| `FilterExpression.lessThanOrEqual(property:, value:)` | `LessThanOrEqualFilter` | Numeric property is ≤ a value | `.lessThanOrEqual(property: TaskFilter.urgency, value: 5)` |
| `FilterExpression.greaterThan(property:, value:)` | `GreaterThanFilter` | Numeric property is greater than a value | `.greaterThan(property: TaskFilter.urgency, value: 0)` |
| `FilterExpression.greaterThanOrEqual(property:, value:)` | `GreaterThanOrEqualFilter` | Numeric property is ≥ a value | `.greaterThanOrEqual(property: TaskFilter.urgency, value: 0)` |

> **Note:** The string-based variants (`contains`, `notContains`, `startsWith`, `endsWith`, `word`, `noWord`, `regex`) take an optional `caseSensitive` named parameter that defaults to `false` (case-insensitive). The serialized field name is `case_sensitive`.

#### Available Property References

Property references are exposed as static members of the `TaskPropertyRefs` extension on `TaskFilter`. Each is a typed `TaskPropertyRef` (a sealed `Equatable` hierarchy) — no generics needed.

| Property | Type | Description |
|----------|------|-------------|
| `TaskFilter.description` | `StringPropertyRef` | Task description |
| `TaskFilter.status` | `StringPropertyRef` | Task status (pending, completed, deleted) |
| `TaskFilter.priority` | `StringPropertyRef` | Task priority (high, medium, low, none) |
| `TaskFilter.project` | `StringPropertyRef` | Project name |
| `TaskFilter.due` | `DateTimePropertyRef` | Due date |
| `TaskFilter.wait` | `DateTimePropertyRef` | Wait until date |
| `TaskFilter.entry` | `DateTimePropertyRef` | Creation date |
| `TaskFilter.modified` | `DateTimePropertyRef` | Last modified date |
| `TaskFilter.scheduled` | `DateTimePropertyRef` | Scheduled date |
| `TaskFilter.until` | `DateTimePropertyRef` | Until date |
| `TaskFilter.id` | `IntPropertyRef` | Task id |
| `TaskFilter.urgency` | `DoublePropertyRef` | Urgency score |

For properties not covered by the extension, construct a ref directly, e.g. `StringPropertyRef('tags')`, `DateTimePropertyRef('end')`, `IntPropertyRef('count')`, or `DoublePropertyRef('score')`.

#### Logical Group Operators

Combine multiple filters using logical group operators (factory constructors on `FilterExpression`):

- **`FilterExpression.andGroup(filters:)`** - All filters in the group must match (logical AND)
- **`FilterExpression.orGroup(filters:)`** - At least one filter in the group must match (logical OR)
- **`FilterExpression.xorGroup(filters:)`** - An odd number of filters in the group must match (logical XOR)
- **`FilterExpression.not(inner:)`** - Negates a single inner expression

```dart
// Example: (pending AND high priority) OR (due today)
final filter = TaskFilter(
  FilterExpression.orGroup(filters: [
    FilterExpression.andGroup(filters: [
      FilterExpression.equals(property: TaskFilter.status, value: 'pending'),
      FilterExpression.equals(property: TaskFilter.priority, value: 'high'),
    ]),
    FilterExpression.dateTo(property: TaskFilter.due, to: DateTime.now()),
  ]),
);
```

> **Note:** The advanced `TaskFilter` API is available for complex queries. Use `client.filterTasks(filter)` to apply custom filters. See the [API Reference](#taskchampionclient) for more details.

### Get Property Values and Tags

Retrieve distinct values for any task property, or get filtered lists of tags:

```dart
// Get distinct descriptions
final descriptions = await client.getPropertyValues(property: 'description');

// Get distinct due dates
final dueDates = await client.getPropertyValues(
  property: 'due',
  filter: TaskFilter.matchAll,
  sort: TaskFilter.due.asc(),
);

// Get all tags (without virtual tags like PENDING, OVERDUE)
final tags = await client.getTags();

// Get tags matching a pattern, including virtual tags
final allTags = await client.getTags(
  includeVirtualTags: true,
  pattern: 'urgent',
);

// Get distinct descriptions (string values)
final descriptions = await client.getStoredPropertyValues<String>(property: 'description');

// Get distinct due dates (DateTime objects)
final dueDates = await client.getStoredPropertyValues<DateTime>(property: 'due');

// Get distinct status values (TaskStatus enum)
final statuses = await client.getStoredPropertyValues<TaskStatus>(property: 'status');

// Get distinct priority values (TaskPriority enum)
final priorities = await client.getStoredPropertyValues<TaskPriority>(property: 'priority');

// Get all possible TaskStatus values (regardless of what's stored)
final allStatuses = await client.getAllPropertyValues<TaskStatus>();

// Get all possible TaskPriority values (regardless of what's stored)
final allPriorities = await client.getAllPropertyValues<TaskPriority>();
```

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

The library is built automatically when you run `flutter pub get`. The build process:

1. Installs `flutter_rust_bridge_codegen` via Cargo
2. Generates FFI bindings (Dart + Rust)
3. Runs `build_runner` for Dart code generation
4. Compiles the Rust library (`cargo build --release`)

For Linux/macOS development, a single `flutter pub get` is enough. For cross-platform builds (Android, iOS, multi-arch Linux), the CI workflow in `.github/workflows/` handles building for each platform separately.

#### Manual regeneration only

If you modify the Rust FFI interface (`rust/src/api.rs`), regenerate bindings:

```bash
cargo install flutter_rust_bridge_codegen  # once
flutter_rust_bridge_codegen generate
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running Tests

```bash
flutter pub get          # builds the Rust library automatically
flutter analyze          # static analysis
cargo clippy --all-features -- -D warnings  # Rust linting
cargo fmt --check        # Rust formatting check
cargo test --all-features # Rust unit tests
flutter test --coverage   # Dart/Flutter tests with coverage
```

No manual `LD_LIBRARY_PATH` setup is needed — the Native Assets system locates the compiled library automatically.

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

| Platform | Asset File | Library Format |
|----------|-----------|----------------|
| Android | `libtc_helper-android-<abi>.so` (e.g., `libtc_helper-android-arm64-v8a.so`) | `.so` (shared library) |
| iOS | `libtc_helper-ios-<arch>.a` (e.g., `libtc_helper-ios-aarch64.a`) | `.a` (static library) |
| macOS | `libtc_helper-macos-<arch>.dylib` (e.g., `libtc_helper-macos-x86_64.dylib`) | `.dylib` (dynamic library) |
| Linux | `libtc_helper-linux-<arch>.so` (e.g., `libtc_helper-linux-x86_64.so`) | `.so` (shared library) |

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
