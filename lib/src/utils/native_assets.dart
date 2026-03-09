import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'dart:developer' as developer;

/// Native Assets loader for TaskChampion Rust library
///
/// This class handles loading the native Rust library (tc_helper) using
/// Dart's Native Assets system. The library is automatically downloaded
/// from GitHub Releases or built locally during the build process.
///
/// ## Usage
///
/// ```dart
/// void main() async {
///   // Initialize native assets before using any Rust FFI functions
///   await NativeAssetsLoader.init();
///
///   // Now you can use Rust FFI functions
///   final result = someRustFunction();
/// }
/// ```
///
/// ## Architecture
///
/// The native library loading process:
///
/// 1. **Build Time**: The `hook/build.dart` script downloads pre-built libraries
///    from GitHub Releases or builds them locally
/// 2. **Runtime**: The library is automatically loaded via FFI using the
///    `@Native` annotation or manual [DynamicLibrary.open]
///
/// ## Platform Support
///
/// | Platform | Library Format | Status |
/// |----------|---------------|--------|
/// | Android  | .so           | ✅ Full |
/// | iOS      | .a (static)   | ✅ Full |
/// | macOS    | .dylib        | ✅ Full |
/// | Windows  | .dll          | ❌ Not supported |
/// | Linux    | .so           | ❌ Not supported |
/// | Web      | N/A           | ❌ Not supported |
class NativeAssetsLoader {
  static DynamicLibrary? _library;
  static bool _initialized = false;

  /// Library name for the native Rust library
  static const String _libraryName = 'tc_helper';

  /// Initialize and load the native library
  ///
  /// This method must be called before using any Rust FFI functions.
  /// It loads the native library that was prepared by the Native Assets
  /// build system during the build process.
  ///
  /// Throws [Exception] if the library cannot be loaded.
  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      _library = _loadLibrary();
      _initialized = true;
      debugPrint('Native library loaded successfully');
    } catch (e) {
      debugPrint('Failed to load native library: $e');
      rethrow;
    }
  }

  /// Check if the native library is initialized
  static bool get isInitialized => _initialized;

  /// Get the loaded library instance
  ///
  /// Throws [Exception] if the library is not initialized.
  static DynamicLibrary get library {
    if (!_initialized || _library == null) {
      throw Exception(
        'Native library not initialized. Call NativeAssetsLoader.init() first.',
      );
    }
    return _library!;
  }

  /// Load the native library based on the platform
  static DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return _loadAndroidLibrary();
    } else if (Platform.isIOS) {
      return _loadIOSLibrary();
    } else if (Platform.isMacOS) {
      return _loadMacOSLibrary();
    } else {
      throw UnsupportedError(
        'Platform ${Platform.operatingSystem} is not supported',
      );
    }
  }

  /// Load Android library
  ///
  /// On Android, the library is loaded from the APK's native library directory.
  /// The Native Assets build system places the correct architecture-specific
  /// library in the APK during build.
  static DynamicLibrary _loadAndroidLibrary() {
    // On Android, the library is automatically available via DynamicLibrary.open
    // The Native Assets system handles the placement
    try {
      return DynamicLibrary.open('lib$_libraryName.so');
    } catch (e) {
      throw Exception(
        'Failed to load Android native library. '
        'Ensure the library is included in your APK. '
        'Error: $e',
      );
    }
  }

  /// Load iOS library
  ///
  /// On iOS, the library is statically linked into the app binary.
  /// We use DynamicLibrary.process() to access it.
  static DynamicLibrary _loadIOSLibrary() {
    try {
      // For static libraries on iOS, use process()
      return DynamicLibrary.process();
    } catch (e) {
      throw Exception(
        'Failed to load iOS native library. '
        'Ensure the library is statically linked. '
        'Error: $e',
      );
    }
  }

  /// Load macOS library
  ///
  /// On macOS, the library is loaded from the app bundle or current directory.
  static DynamicLibrary _loadMacOSLibrary() {
    try {
      return DynamicLibrary.open('lib$_libraryName.dylib');
    } catch (e) {
      // Try alternative paths
      final alternativePaths = [
        'Frameworks/lib$_libraryName.dylib',
        'lib$_libraryName.dylib',
      ];

      for (final path in alternativePaths) {
        try {
          return DynamicLibrary.open(path);
        } catch (_) {
          continue;
        }
      }

      throw Exception(
        'Failed to load macOS native library. '
        'Tried: ${alternativePaths.join(", ")}. '
        'Error: $e',
      );
    }
  }

  /// Debug print helper
  static void debugPrint(String message) {
    // In debug mode, print the message
    // In release mode, this could be disabled
    developer.log('[NativeAssetsLoader] $message');
  }

  /// Reset the loader state (useful for testing)
  static void reset() {
    _library = null;
    _initialized = false;
  }
}

/// FFI bindings for common Rust functions
///
/// These bindings use the @Native annotation which is automatically
/// resolved by the Native Assets system to load the correct library.
class RustFFI {
  /// Get the Rust library version
  ///
  /// This is an example function. Add more functions as needed.
  @Native<Handle Function()>()
  external static String getTcHelperVersion();

  /// Initialize the Rust runtime
  ///
  /// Call this before using any other FFI functions.
  @Native<Void Function()>()
  external static void initRust();

  /// Free a string allocated by Rust
  ///
  /// Use this to free strings returned from Rust functions
  /// to avoid memory leaks.
  @Native<Void Function(Pointer<Utf8>)>()
  external static void freeString(Pointer<Utf8> ptr);
}
