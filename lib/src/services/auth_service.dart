import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../rust_bridge/rust_bridge.dart';

/// Service for authentication with TaskChampion sync server
///
/// Handles credential validation and authentication operations.
class AuthService {
  /// Authentication configuration
  final AuthConfig authConfig;

  /// Create a new AuthService instance
  AuthService(this.authConfig);

  /// Validate credentials with the sync server
  Future<AuthResult> validateCredentials() async {
    try {
      final jsonStr = await RustBridge.validateCredentials(
        authConfig.serverUrl,
        authConfig.clientId,
        authConfig.encryptionSecret,
      );

      final Map<String, dynamic> jsonData = json.decode(jsonStr);

      final success = jsonData['valid'] == 'true' || jsonData['valid'] == true;

      if (success) {
        return AuthResult(
          success: true,
          serverUrl: authConfig.serverUrl,
          clientId: authConfig.clientId,
          canSync: true,
          authenticatedAt: DateTime.now(),
        );
      } else {
        return AuthResult(
          success: false,
          errorMessage: 'Invalid credentials',
          authenticatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Auth error: $e');
      return AuthResult(
        success: false,
        errorMessage: 'Authentication failed: $e',
        authenticatedAt: DateTime.now(),
      );
    }
  }

  /// Generate a new client ID
  static Future<String> generateClientId() async {
    return RustBridge.generateClientId();
  }

  /// Generate a new encryption secret
  static Future<String> generateEncryptionSecret() async {
    return RustBridge.generateEncryptionSecret();
  }

  /// Check if credentials are valid locally (without server check)
  bool hasValidCredentials() {
    return authConfig.hasValidCredentials;
  }
}
