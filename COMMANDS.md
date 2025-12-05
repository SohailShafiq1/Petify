# Flutter Commands Cheat Sheet

## 🚀 Essential Commands

### Installation & Setup
```bash
# Navigate to project
cd /Users/mc/workspace/PetsFYP

# Get dependencies
flutter pub get

# Check Flutter setup
flutter doctor

# Check Flutter version
flutter --version
```

### Running the App
```bash
# Run on default device
flutter run

# Run in release mode (faster)
flutter run --release

# Run in profile mode (with performance profiling)
flutter run --profile

# Run with verbose output
flutter run --verbose

# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on Chrome (web)
flutter run -d chrome

# Run on iOS simulator
flutter run -d "iPhone 14"

# Run on Android emulator
flutter run -d emulator-5554
```

### Development
```bash
# Hot reload (while app is running)
# Press: r

# Hot restart (while app is running)
# Press: R

# Quit app (while app is running)
# Press: q

# Open DevTools (while app is running)
# Press: v

# Format all Dart files
flutter format .

# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Clean build artifacts
flutter clean

# Clean and reinstall
flutter clean && flutter pub get
```

### Building
```bash
# Build Android APK (debug)
flutter build apk

# Build Android APK (release)
flutter build apk --release

# Build Android App Bundle
flutter build appbundle

# Build iOS (requires Mac)
flutter build ios

# Build iOS release
flutter build ios --release

# Build for web
flutter build web

# Build with verbose output
flutter build apk --release --verbose
```

### Device Management
```bash
# List all devices
flutter devices

# List all emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator-id>

# Cold boot emulator
flutter emulators --launch <emulator-id> --cold-boot
```

### Debugging
```bash
# Run with debugging enabled
flutter run --debug

# Enable Dart DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade

# Get specific package version
flutter pub add <package>:<version>
```

### Performance
```bash
# Run performance profiling
flutter run --profile

# Measure app size
flutter build apk --analyze-size

# Generate build report
flutter build apk --release --analyze-size
```

### Maintenance
```bash
# Update Flutter
flutter upgrade

# Downgrade Flutter
flutter downgrade

# Switch Flutter channel
flutter channel stable
flutter channel beta
flutter channel dev

# Doctor with verbose output
flutter doctor -v

# Clear Flutter cache
flutter clean
rm -rf ~/.pub-cache
flutter pub get
```

---

## 📱 Device-Specific Commands

### Android
```bash
# Check connected Android devices
adb devices

# Install APK manually
adb install build/app/outputs/flutter-apk/app-release.apk

# Clear app data
adb shell pm clear com.example.petify

# View logs
adb logcat

# View Flutter logs
flutter logs
```

### iOS (Mac only)
```bash
# List iOS simulators
xcrun simctl list devices

# Boot simulator
xcrun simctl boot <device-id>

# Install on simulator
flutter install -d <device-id>

# Open iOS simulator
open -a Simulator

# View logs
flutter logs
```

---

## 🔧 Project-Specific Commands

### PetiFy App
```bash
# First-time setup
cd /Users/mc/workspace/PetsFYP
flutter pub get
flutter run

# Clean build (if errors occur)
flutter clean
flutter pub get
flutter run

# Build release APK
flutter build apk --release

# Build release for iOS
flutter build ios --release --no-codesign
```

### Hive Database
```bash
# If you need to regenerate adapters (after model changes)
flutter pub run build_runner build

# Force regeneration
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes
flutter pub run build_runner watch
```

### Code Generation
```bash
# Generate code (for future use)
flutter pub run build_runner build

# Watch and auto-generate
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## 🐛 Troubleshooting Commands

### Common Issues

**Issue: Gradle build failed**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

**Issue: Pod install failed (iOS)**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

**Issue: Dependency conflicts**
```bash
flutter clean
rm pubspec.lock
flutter pub get
```

**Issue: Cache issues**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**Issue: Build artifacts corrupted**
```bash
flutter clean
rm -rf build/
rm -rf .dart_tool/
flutter pub get
flutter run
```

---

## 📊 Useful Info Commands

```bash
# Flutter info
flutter --version
flutter doctor -v
flutter config

# Check app size
flutter build apk --analyze-size --target-platform android-arm64

# List available upgrades
flutter pub outdated

# Show package tree
flutter pub deps

# Verify installation
which flutter
which dart

# Check environment
echo $PATH | tr ':' '\n' | grep flutter
```

---

## 🎯 Keyboard Shortcuts (while app is running)

| Key | Action |
|-----|--------|
| `r` | Hot reload |
| `R` | Hot restart |
| `h` | Help (show all shortcuts) |
| `d` | Detach (keep app running) |
| `c` | Clear screen |
| `q` | Quit |
| `v` | Open DevTools |
| `w` | Dump widget hierarchy |
| `t` | Dump rendering tree |
| `L` | Dump layer tree |
| `S` | Dump accessibility tree |
| `U` | Dump semantics tree |
| `i` | Toggle widget inspector |
| `p` | Toggle debug painting |
| `I` | Toggle platform brightness |
| `o` | Simulate OS toggle |
| `b` | Toggle platform brightness |
| `P` | Toggle performance overlay |
| `a` | Toggle timeline events for all processes |

---

## 📝 Quick Reference

### Start Development Session
```bash
cd /Users/mc/workspace/PetsFYP
flutter pub get
flutter run
# Press 'r' for hot reload during development
```

### Build for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Fix Common Errors
```bash
flutter clean
flutter pub get
flutter run
```

---

**Pro Tip**: Create an alias in your `~/.zshrc` for quick access:
```bash
alias frun='flutter run'
alias fbuild='flutter build apk --release'
alias fclean='flutter clean && flutter pub get'
```

Then use:
```bash
frun      # Instead of flutter run
fbuild    # Instead of flutter build apk --release  
fclean    # Instead of flutter clean && flutter pub get
```

---

Last updated: December 2025
