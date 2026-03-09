import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskchampion_client_rust/taskchampion_client_rust.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// App configuration notifier with secure storage
class AppConfig extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
      sharedPreferencesName: 'taskchampion_secure_prefs',
      preferencesKeyPrefix: 'tc_',
    ),
    iOptions: IOSOptions(
      accountName: 'TaskChampion',
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  TaskChampionClient? _client;
  bool _isConnected = false;
  bool _isSyncing = false;
  bool _isInitialized = false;

  // Mutable server configuration
  String _serverUrl = 'https://your-sync-server.com';
  String _clientId = 'your-client-id';
  String _encryptionSecret = 'your-encryption-secret';

  String get serverUrl => _serverUrl;
  String get clientId => _clientId;
  String get encryptionSecret => _encryptionSecret;

  TaskChampionClient? get client => _client;
  bool get isConnected => _isConnected;
  bool get isSyncing => _isSyncing;
  bool get isInitialized => _isInitialized;

  /// Initialize the app and load credentials from secure storage
  Future<void> initialize() async {
    // Load credentials from secure storage
    await _loadCredentials();

    // Initialize the client
    await initClient();

    _isInitialized = true;
    notifyListeners();
  }

  /// Load credentials from secure storage
  Future<void> _loadCredentials() async {
    final serverUrl = await _storage.read(key: _SecureStorageKeys.serverUrl);
    final clientId = await _storage.read(key: _SecureStorageKeys.clientId);
    final encryptionSecret =
        await _storage.read(key: _SecureStorageKeys.encryptionSecret);

    if (serverUrl != null) _serverUrl = serverUrl;
    if (clientId != null) _clientId = clientId;
    if (encryptionSecret != null) _encryptionSecret = encryptionSecret;
  }

  /// Save credentials to secure storage
  Future<void> _saveCredentials() async {
    await _storage.write(key: _SecureStorageKeys.serverUrl, value: _serverUrl);
    await _storage.write(key: _SecureStorageKeys.clientId, value: _clientId);
    await _storage.write(
      key: _SecureStorageKeys.encryptionSecret,
      value: _encryptionSecret,
    );
  }

  /// Update server configuration and reconnect
  Future<void> updateConfiguration({
    required String serverUrl,
    required String clientId,
    required String encryptionSecret,
  }) async {
    _serverUrl = serverUrl;
    _clientId = clientId;
    _encryptionSecret = encryptionSecret;

    // Save to secure storage
    await _saveCredentials();

    // Disconnect current client
    disconnect();

    // Initialize new client with updated configuration
    await initClient();
  }

  /// Initialize the client
  Future<void> initClient() async {
    // Get the app's documents directory for the task database
    final dir = await getApplicationDocumentsDirectory();
    final taskdbPath = '${dir.path}/taskchampion';

    _client = TaskChampionClient(
      serverUrl: _serverUrl,
      clientId: _clientId,
      encryptionSecret: _encryptionSecret,
      taskdbPath: taskdbPath,
      autoSync: true,
      debugLogging: true,
    );

    // Connect to server
    final result = await _client!.connect();
    _isConnected = result.success;

    // Listen to sync events
    _client!.syncEvents.listen((event) {
      _isSyncing = false;
      notifyListeners();

      // Show toast notification with sync results
      if (event.success) {
        final versionsCount = event.versionsSynced;
        if (versionsCount > 0) {
          Fluttertoast.showToast(
            msg: 'Synced $versionsCount version${versionsCount > 1 ? 's' : ''}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        else {
          Fluttertoast.showToast(
            msg: 'No tasks for sync',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else if (event.errorMessage != null) {
        Fluttertoast.showToast(
          msg: 'Sync failed: ${event.errorMessage}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });

    notifyListeners();
  }

  /// Sync tasks
  Future<void> sync() async {
    if (_client == null || !_isConnected) return;

    _isSyncing = true;
    notifyListeners();

    await _client!.sync();
  }

  /// Disconnect from server
  void disconnect() {
    _client?.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  /// Clear all credentials from secure storage
  Future<void> clearCredentials() async {
    await _storage.deleteAll();
    _serverUrl = 'https://your-sync-server.com';
    _clientId = 'your-client-id';
    _encryptionSecret = 'your-encryption-secret';
    notifyListeners();
  }
}

/// Secure storage keys
class _SecureStorageKeys {
  static const String serverUrl = 'server_url';
  static const String clientId = 'client_id';
  static const String encryptionSecret = 'encryption_secret';
}