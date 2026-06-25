import 'dart:convert';
import '../core/core.dart';
import '../models/models.dart';
import '../storage/task_storage.dart';
import 'interfaces/i_auth_service.dart';

/// Service for authentication with TaskChampion sync server.
///
/// Handles credential validation and authentication operations.
class AuthService implements IAuthService {
  /// Underlying storage implementation.
  final TaskStorage _storage;

  /// Authentication configuration.
  final AuthConfig _authConfig;

  /// Logger for this service.
  final Logger _logger;

  /// Create a new AuthService instance.
  AuthService(this._storage, this._authConfig, {Logger? logger})
    : _logger = logger ?? const DebugPrintLogger();

  @override
  Future<AuthResult> validateCredentials() async {
    try {
      final jsonStr = await _storage.validateCredentials(
        _authConfig.serverUrl,
        _authConfig.clientId,
        _authConfig.encryptionSecret,
      );

      final Map<String, dynamic> jsonData = json.decode(jsonStr);

      final success = jsonData['valid'] == true;

      if (success) {
        return AuthResult(
          success: true,
          serverUrl: _authConfig.serverUrl,
          clientId: _authConfig.clientId,
          canSync: true,
        );
      } else {
        return const AuthResult(
          success: false,
          errorMessage: 'Invalid credentials',
        );
      }
    } catch (e, st) {
      _logger.error('Authentication failed', error: e, stackTrace: st);
      throw AuthException('Authentication failed', cause: e);
    }
  }
}
