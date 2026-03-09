// Native Assets Build Hook for taskchampion_client_rust
//
// This build hook implements a native asset algorithm that:
// 1. Downloads prebuilt binaries matching the current library version
// 2. Verifies the SHA-256 hash of downloaded binaries
// 3. Falls back to local build if download or verification fails
//
// Requirements for local build:
// - Rust toolchain (rustup) must be installed
// - For Android: Android NDK may be required
//
// The Rust library is built from the 'rust/' directory with Cargo features
// specified in rust_builder.yaml (experimental feature).

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_rust/native_toolchain_rust.dart';
import 'package:http/http.dart' as http;

/// Manifest file path (relative to package root)
const String _manifestPath = 'manifests/native_assets.json';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final userDefines = input.userDefines;
    final localBuild = (userDefines['local_build'] ?? false) as bool;

    if (!localBuild) {
      try {
        await downloadPrebuilt(input, output);
      } catch (e) {
        await buildLocally(input, output);
      }
    } else {
      await buildLocally(input, output);
    }
  });
}

Future<void> buildLocally(BuildInput input, BuildOutputBuilder output) async {

  // Use RustBuilder from native_toolchain_rust to build the library
  return RustBuilder(
    // Path to the generated FFI bindings file
    assetName: 'lib/src/rust_bridge/frb_generated.dart',

    // Directory containing Cargo.toml (relative to package root)
    cratePath: 'rust',

    // Enable the 'experimental' feature as specified in rust_builder.yaml
    features: ['experimental'],

    // Use release mode for optimized builds
    buildMode: BuildMode.release,
  ).run(input: input, output: output);
}

/// Downloads and verifies prebuilt binary for the current platform
Future<void> downloadPrebuilt(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  // Load the manifest to get version and asset info
  final manifest = await _loadManifest();

  // Determine current platform and architecture
  final targetOS = input.config.code.targetOS;
  final architecture = _getArchitectureName();


  // Get the asset key for this platform/architecture
  final assetKey = _getAssetKey(targetOS, architecture);
  if (assetKey == null) {
    throw UnsupportedError(
      'Unsupported platform/architecture: $targetOS-$architecture',
    );
  }

  final assets = manifest['assets'] as Map<String, dynamic>;
  final assetInfo = assets[assetKey];
  if (assetInfo == null) {
    throw Exception('No prebuilt binary found for $assetKey');
  }

  final assetMap = assetInfo as Map<String, dynamic>;
  final downloadUrl = assetMap['url'] as String;
  final expectedHash = assetMap['sha256'] as String;


  // Download the binary
  final response = await http.get(Uri.parse(downloadUrl));
  if (response.statusCode != 200) {
    throw Exception(
      'Failed to download prebuilt binary: HTTP ${response.statusCode}',
    );
  }

  final downloadedBytes = response.bodyBytes;

  // Verify the hash
  final actualHash = sha256.convert(downloadedBytes).toString();
  if (actualHash != expectedHash) {
    throw Exception(
      'Hash verification failed!\n'
      '  Expected: $expectedHash\n'
      '  Actual:   $actualHash',
    );
  }

  // Determine the output filename based on platform
  final outputFilename = _getOutputFilename(targetOS, architecture);
  final outputFile = input.outputDirectory.resolve(outputFilename);

  // Write the binary to the output directory
  await File.fromUri(outputFile).parent.create(recursive: true);
  await File.fromUri(outputFile).writeAsBytes(downloadedBytes);

  // Create a CodeAsset for the Flutter build system
  output.assets.code.add(
    CodeAsset(
      package: input.packageName,
      name: 'lib/src/rust_bridge/frb_generated.dart',
      linkMode: DynamicLoadingBundled(),
      file: outputFile,
    ),
  );

}

/// Loads the native assets manifest from the package
Future<Map<String, dynamic>> _loadManifest() async {
  final manifestFile = File(_manifestPath);
  if (!manifestFile.existsSync()) {
    throw Exception(
      'Native assets manifest not found at: $_manifestPath\n'
      'Please ensure the manifest file exists.',
    );
  }

  final manifestContent = await manifestFile.readAsString();
  return jsonDecode(manifestContent) as Map<String, dynamic>;
}

/// Gets the architecture name from Platform.version
String _getArchitectureName() {
  final version = Platform.version;
  if (version.contains('arm64') || version.contains('aarch64')) {
    return 'arm64';
  } else if (version.contains('x64') || version.contains('x86_64')) {
    return 'x64';
  } else if (version.contains('arm')) {
    return 'arm';
  } else if (version.contains('ia32') || version.contains('x86')) {
    return 'ia32';
  }
  throw UnsupportedError('Unknown architecture: $version');
}

/// Converts platform and architecture to asset key
String? _getAssetKey(OS targetOS, String architecture) {
  switch (targetOS) {
    case OS.android:
      // Android uses different ABI names
      switch (architecture) {
        case 'arm64':
          return 'android-arm64-v8a';
        case 'arm':
          return 'android-armeabi-v7a';
        case 'x64':
          return 'android-x86_64';
        case 'ia32':
          return 'android-x86';
        default:
          return null;
      }
    case OS.iOS:
      switch (architecture) {
        case 'arm64':
          return 'ios-aarch64';
        case 'x64':
          return 'ios-simulator-x86_64';
        default:
          return null;
      }
    case OS.macOS:
      switch (architecture) {
        case 'arm64':
          return 'macos-aarch64';
        case 'x64':
          return 'macos-x86_64';
        default:
          return null;
      }
    case OS.linux:
      switch (architecture) {
        case 'arm64':
          return 'linux-aarch64';
        case 'x64':
          return 'linux-x86_64';
        default:
          return null;
      }
    case OS.windows:
      // Windows not supported yet
      return null;
    default:
      return null;
  }
}

/// Returns the appropriate output filename for the platform
String _getOutputFilename(OS targetOS, String architecture) {
  switch (targetOS) {
    case OS.android:
      return 'libtc_helper.so';
    case OS.iOS:
      return 'libtc_helper.a';
    case OS.macOS:
      return 'libtc_helper.dylib';
    case OS.linux:
      return 'libtc_helper.so';
    case OS.windows:
      return 'tc_helper.dll';
    default:
      throw UnsupportedError('Unsupported target OS: $targetOS');
  }
}
