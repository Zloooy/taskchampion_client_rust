# GitHub Workflows - Setup and Usage Guide

This document describes the CI/CD setup process for publishing the TaskChampion Client Rust library.

## Workflow Overview

The repository has 3 GitHub Actions workflows configured:

| Workflow | File | Description |
|----------|------|----------|
| **Publish to pub.dev** | `publish.yml` | Publishes package to pub.dev when a version tag is created |
| **CI/CD - Build & Test** | `ci-cd.yml` | Testing and building for all platforms on PR and pushes |
| **Build Release Artifacts** | `release-artifacts.yml` | Builds and publishes Rust libraries when a GitHub Release is created |

---

## Setting up pub.dev Publishing

### Step 1: First Publication (Manual)

**Important:** The first package version must be published manually!

```bash
# Make sure the version in pubspec.yaml is up to date
cat pubspec.yaml | grep version

# Log in to pub.dev
dart pub login

# Publish the package
dart pub publish
```

### Step 2: Enable Automated Publishing

1. Go to the package page on pub.dev:
   ```
   https://pub.dev/packages/taskchampion_client_rust/admin
   ```

2. In the **Admin** tab, find the **"Automated publishing"** section

3. Click **"Enable publishing from GitHub Actions"**

4. Fill out the form:
   - **Repository:** `your-org/taskchampion_client_rust` (specify your repository)
   - **Tag pattern:** `v{{version}}` (e.g., v0.1.0)

5. Save the settings

### Step 3: Publishing New Versions

After setting up automation, to publish a new version:

```bash
# 1. Update the version in pubspec.yaml
# Change: version: 0.1.0 → version: 0.1.1

# 2. Commit the changes
git add pubspec.yaml
git commit -m "Bump version to 0.1.1"

# 3. Create and push a tag
git tag v0.1.1
git push origin v0.1.1

# 4. GitHub Actions will automatically publish the package
# Check status: https://github.com/your-org/taskchampion_client_rust/actions
```

---

## Android Build Setup

### Requirements

- **Android NDK r26** (installed automatically in GitHub Actions)
- **cargo-ndk** (installed automatically)

### Local Android Build

```bash
# Install cargo-ndk
cargo install cargo-ndk

# Install Android NDK (via Android Studio or command line)
sdkmanager "ndk;26.0.10792818"

# Build libraries for all architectures
cd rust
cargo ndk \
  -t arm64-v8a \
  -t armeabi-v7a \
  -t x86_64 \
  -t x86 \
  -o ../android/app/src/main/jniLibs \
  build --release
```

### Android Library Structure

After building, the structure should look like this:

```
android/app/src/main/jniLibs/
├── arm64-v8a/
│   └── libtc_helper.so
├── armeabi-v7a/
│   └── libtc_helper.so
├── x86/
│   └── libtc_helper.so
└── x86_64/
    └── libtc_helper.so
```

---

## iOS Build Setup

### Requirements

- **macOS** with Xcode installed
- **Rust targets** for iOS

### Local iOS Build

```bash
# Add iOS targets
rustup target add aarch64-apple-ios
rustup target add aarch64-apple-ios-sim
rustup target add x86_64-apple-ios

# Build the libraries
cd rust

# For devices (ARM64)
cargo build --release --target aarch64-apple-ios

# For simulators (ARM64 + x86_64)
cargo build --release --target aarch64-apple-ios-sim
cargo build --release --target x86_64-apple-ios

# Create universal binary for simulators
mkdir -p target/ios-simulator-release
lipo -create \
  target/aarch64-apple-ios-sim/release/libtc_helper.a \
  target/x86_64-apple-ios/release/libtc_helper.a \
  -output target/ios-simulator-release/libtc_helper.a
```

### iOS Project Integration

1. Copy libraries to iOS project:
   ```bash
   cp rust/target/aarch64-apple-ios/release/libtc_helper.a ios/Frameworks/
   cp rust/target/ios-simulator-release/libtc_helper.a ios/Frameworks/
   ```

2. Add libraries to Xcode:
   - Open the project in Xcode
   - Add `.a` files to "Frameworks, Libraries, and Embedded Content"

---

## macOS Build Setup

### Local macOS Build

```bash
# Build for Apple Silicon and Intel
cd rust
cargo build --release --target aarch64-apple-darwin
cargo build --release --target x86_64-apple-darwin

# Create universal binary
mkdir -p target/macos-release
lipo -create \
  target/aarch64-apple-darwin/release/libtc_helper.dylib \
  target/x86_64-apple-darwin/release/libtc_helper.dylib \
  -output target/macos-release/libtc_helper.dylib
```

---

## Using GitHub Release Artifacts

When creating a release on GitHub, the workflow will automatically build and attach artifacts:

### Creating a Release

```bash
# Create a release via GitHub CLI
gh release create v0.1.0 \
  --title "Version 0.1.0" \
  --notes "Release notes here" \
  --generate-notes

# Or via web interface:
# https://github.com/your-org/taskchampion_client_rust/releases/new
```

### Downloading Artifacts

After the build completes, artifacts will be available in the release:

- `taskchampion_client_rust-android-0.1.0.zip` - Android JNI libraries
- `taskchampion_client_rust-ios-0.1.0.zip` - iOS static libraries
- `taskchampion_client_rust-macos-0.1.0.zip` - macOS dynamic libraries

---

## Troubleshooting

### Error: "Publishing is not enabled for this package"

**Solution:** Make sure you completed Step 2 (setting up Automated publishing on pub.dev).

### Error: "Tag already exists"

**Solution:** Delete the existing tag and create a new one:
```bash
git tag -d v0.1.0
git push origin :refs/tags/v0.1.0
git tag v0.1.0
git push origin v0.1.0
```

### Android Build Error: "NDK not found"

**Solution:** Install Android NDK:
```bash
sdkmanager "ndk;26.0.10792818"
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/26.0.10792818
```

### iOS Build Error: "ld: symbol(s) not found"

**Solution:** Make sure all taskchampion dependencies are built for iOS:
```bash
cargo build --release --target aarch64-apple-ios --verbose
```

### Workflow Not Starting

**Solution:** Check:
1. GitHub Actions are enabled in repository settings
2. You have permissions to run workflows
3. The branch matches the triggers (main/master/develop)

---

## Additional Settings

### Tag Protection

To prevent accidental publication, set up tag protection:

1. Go to **Settings → Branches → Add rule**
2. Specify pattern: `v*`
3. Enable **"Require pull request before merging"**
4. Enable **"Require status checks to pass"**

### Using Deployment Environment

For additional security:

1. On pub.dev: enable **"Require GitHub Actions environment"**
2. In GitHub: **Settings → Environments → New environment**
3. Create environment `pub.dev`
4. Configure required reviewers
5. Update `publish.yml` to add:
   ```yaml
   jobs:
     publish:
       environment: pub.dev
   ```

### Customizing Workflows

To change Flutter/Rust versions, edit the workflow files:

```yaml
# In publish.yml or ci-cd.yml
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.41.3'  # Change to desired version

- uses: dtolnay/rust-toolchain@stable
  with:
    toolchain: stable  # Or specific version: 1.75.0
```

---

## References

- [pub.dev Official Documentation](https://dart.dev/tools/pub/publishing)
- [Automated Publishing](https://dart.dev/tools/pub/automated-publishing)
- [flutter_rust_bridge Documentation](https://github.com/fzyzcjy/flutter_rust_bridge)
- [cargo-ndk Documentation](https://github.com/bbqsrc/cargo-ndk)
