import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Helper utilities for TaskChampion client
class TaskChampionHelpers {
  /// Generate a new UUID v4
  static String generateUuid() {
    const uuid = Uuid();
    return uuid.v4();
  }

  /// Hash a string using SHA-256
  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Validate a UUID string
  static bool isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  /// Validate a URL string
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

}
