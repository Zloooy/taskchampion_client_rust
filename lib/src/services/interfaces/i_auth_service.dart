import '../../models/models.dart';

/// Abstract interface for authentication operations.
abstract interface class IAuthService {
  /// Validate credentials with the sync server.
  Future<AuthResult> validateCredentials();
}
