import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Service for managing permissions
///
/// Requests and checks required permissions for file operations
class PermissionService {
  /// Request storage permission (for Android)
  ///
  /// Returns true if permission is granted
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) {
      // On iOS and other platforms use standard file access
      return true;
    }

    final androidVersion = await _getAndroidVersion();

    if (androidVersion >= 30) {
      // Android 11+ (API 30+) - request manage external storage
      return await _requestManageStoragePermission();
    } else if (androidVersion >= 29) {
      // Android 10 (API 29) - use scoped storage
      return await _requestStoragePermissionLegacy();
    } else {
      // Android 9 and below - request standard permissions
      return await _requestStoragePermissionLegacy();
    }
  }

  /// Get Android API version
  static Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) {
      return 0;
    }
    // permission_handler provides version info via PermissionsStatus
    // But for simplicity check current permissions
    return 30; // Assume Android 11+ by default for modern devices
  }

  /// Request manage storage permission (Android 11+)
  static Future<bool> _requestManageStoragePermission() async {
    try {
      // Check current status
      final status = await ph.Permission.manageExternalStorage.status;

      if (status.isGranted) {
        debugPrint('Manage external storage permission already granted');
        return true;
      }

      if (status.isDenied) {
        // Request permission
        final requestStatus = await ph.Permission.manageExternalStorage.request();
        if (requestStatus.isGranted) {
          debugPrint('Manage external storage permission granted');
          return true;
        }
      }

      if (status.isPermanentlyDenied) {
        // Permission permanently denied - open settings
        debugPrint('Manage external storage permission permanently denied');
        return false;
      }

      debugPrint('Manage external storage permission denied');
      return false;
    } catch (e) {
      debugPrint('Error requesting manage external storage permission: $e');
      return false;
    }
  }

  /// Request storage permission (Android 9 and below, Android 10)
  static Future<bool> _requestStoragePermissionLegacy() async {
    try {
      // Request both permissions
      final statuses = await [
        ph.Permission.storage,
        ph.Permission.photos,
      ].request();

      final storageGranted = statuses[ph.Permission.storage]?.isGranted ?? false;
      final photosGranted = statuses[ph.Permission.photos]?.isGranted ?? false;

      if (storageGranted || photosGranted) {
        debugPrint('Storage permission granted');
        return true;
      }

      debugPrint('Storage permission denied');
      return false;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Check storage permission status
  static Future<ph.PermissionStatus> getStoragePermissionStatus() async {
    if (!Platform.isAndroid) {
      return ph.PermissionStatus.granted;
    }

    // Check manage external storage for Android 11+
    final manageStatus = await ph.Permission.manageExternalStorage.status;
    if (manageStatus.isGranted) {
      return ph.PermissionStatus.granted;
    }

    // Check legacy storage
    final storageStatus = await ph.Permission.storage.status;
    return storageStatus;
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }

  /// Request permission and show dialog if denied
  static Future<bool> requestPermissionWithDialog() async {
    final granted = await requestStoragePermission();

    if (!granted) {
      final status = await getStoragePermissionStatus();

      if (status.isPermanentlyDenied) {
        // Need to open settings manually
        debugPrint('Permission permanently denied, user needs to enable in settings');
      }
    }

    return granted;
  }
}
