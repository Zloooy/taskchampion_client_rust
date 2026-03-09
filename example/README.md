# TaskChampion Client Library Example

This example demonstrates how to use the TaskChampion client library in a Flutter application.

## Getting Started

1. Update the server configuration in `lib/main.dart`:

```dart
const serverUrl = 'https://your-sync-server.com';
const clientId = 'your-client-id';
const encryptionSecret = 'your-encryption-secret';
```

2. Run the example:

```bash
cd example
flutter pub get
flutter run
```

## Features Demonstrated

- ✅ Initializing the TaskChampion library
- ✅ Creating a client instance
- ✅ Connecting to a sync server
- ✅ Creating, updating, and deleting tasks
- ✅ Syncing tasks with the server
- ✅ Filtering and searching tasks
- ✅ Reactive UI updates with streams

## Example Screenshots

The example app includes:
- Task list view with filtering
- Task creation/edit form
- Sync status indicator
- Settings screen for server configuration
