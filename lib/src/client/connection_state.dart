import '../core/core.dart';
import '../models/models.dart';
import '../services/interfaces/interfaces.dart';

/// Tracks the client's connection state to the sync server.
///
/// Wraps auth validation so the client does not hold boolean flags
/// directly.
class ConnectionState {
  final IAuthService _authService;
  bool _connected = false;

  /// Create a [ConnectionState] backed by [authService].
  ConnectionState(this._authService);

  /// Whether the client is currently connected.
  bool get isConnected => _connected;

  /// Validate credentials and update the connection state.
  ///
  /// Returns the [AuthResult] from the auth service.  Catches
  /// [AuthException] and converts it into a failed [AuthResult]
  /// so callers do not need to handle two different error shapes.
  Future<AuthResult> validateAndConnect() async {
    try {
      final result = await _authService.validateCredentials();
      _connected = result.success;
      return result;
    } on AuthException catch (e) {
      _connected = false;
      return AuthResult(success: false, errorMessage: e.message);
    } catch (e) {
      _connected = false;
      return AuthResult(success: false, errorMessage: 'Connection error: $e');
    }
  }

  /// Mark the connection as disconnected.
  void disconnect() {
    _connected = false;
  }
}
