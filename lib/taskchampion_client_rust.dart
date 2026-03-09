/// TaskChampion Client Library for Flutter
///
/// A comprehensive Flutter/Dart client library for TaskChampion with Rust FFI bindings.
/// Provides task storage, synchronization with taskchampion-sync-server, and authentication capabilities.
///
/// ## Features
///
/// - **Task Management**: Create, read, update, and delete tasks
/// - **Synchronization**: Sync tasks with TaskChampion sync server
/// - **Authentication**: Secure client credential management
/// - **Offline Support**: Full offline task management with sync when online
/// - **Encryption**: End-to-end encryption for synchronized data
///
/// ## Getting Started
///
/// ```dart
/// import 'package:taskchampion_client_rust/taskchampion_client_rust.dart';
///
/// void main() async {
///   // Initialize the client
///   await TaskChampion.init();
///
///   // Create a client instance
///   final client = TaskChampionClient(
///     serverUrl: 'https://your-sync-server.com',
///     clientId: 'your-client-id',
///     encryptionSecret: 'your-encryption-secret',
///   );
///
///   // Sync tasks
///   await client.sync();
///
///   // Get all tasks
///   final tasks = await client.getAllTasks();
///
///   // Create a new task
///   final task = await client.createTask(
///     description: 'Buy milk',
///     priority: TaskPriority.high,
///   );
/// }
/// ```
///
/// ## Architecture
///
/// The library consists of several layers:
///
/// 1. **Rust FFI Layer** (`tc_helper`): Native Rust code providing TaskChampion operations
/// 2. **Dart FFI Bridge**: Generated Dart bindings for Rust functions
/// 3. **Service Layer**: High-level Dart services for tasks, sync, and auth
/// 4. **Public API**: Programmer-friendly `TaskChampionClient` class
///
/// ## Backend Support
///
/// This library uses the TaskChampion Rust crate as its backend, which provides:
/// - SQLite-based local storage
/// - HTTP/HTTPS synchronization with TaskChampion sync server
/// - Encryption using the ring cryptography library
library;

// Public API exports
export 'src/taskchampion_client.dart';
export 'src/models/models.dart';
export 'src/services/services.dart';
export 'src/utils/utils.dart';
