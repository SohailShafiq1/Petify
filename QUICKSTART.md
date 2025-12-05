# Quick Start Guide

## Installation Steps

1. **Navigate to the project directory**:
   ```bash
   cd /Users/mc/workspace/PetsFYP
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Check Flutter setup** (optional):
   ```bash
   flutter doctor
   ```

4. **Run the app**:
   
   For iOS Simulator:
   ```bash
   flutter run
   ```
   
   For Android Emulator:
   ```bash
   flutter run
   ```
   
   For a specific device:
   ```bash
   flutter devices  # List available devices
   flutter run -d <device-id>
   ```

## Testing the App

### 1. First Launch - Create Account
- Open the app
- Click "Sign Up" on the login screen
- Fill in the form:
  - Full Name: John Doe
  - Email: john@example.com
  - Phone: +1234567890
  - Password: password123
- Click "Sign Up"

### 2. Browse Pets
- You'll see the welcome screen
- Click "Get Started" to go to the dashboard
- Scroll through featured pets (6 dummy pets are pre-loaded)
- Browse categories by scrolling horizontally

### 3. Add a Pet
- Click the floating "Sell Your Pet" button
- Fill in the form:
  - Add a photo (camera or gallery)
  - Pet Name: e.g., "Fluffy"
  - Category: Select from dropdown
  - Age: e.g., 6 (months)
  - Price: e.g., 250
  - Description: Brief description
  - Contact: Your phone number
- Click "Add Pet"

### 4. View Pet Details
- Click on any pet card
- View full details, images, and owner info
- Click "Chat With Owner" to test chat

### 5. Chat Feature
- Send a message to the pet owner
- Wait 2 seconds for an automatic simulated response
- Messages are stored locally

### 6. Profile Management
- Open drawer menu (tap hamburger icon)
- Click "Profile"
- Click edit icon to modify your profile
- Update name or phone
- Change profile picture
- Click "Save Changes"

### 7. Categories
- From dashboard, click "See All" in Categories section
- Or open drawer and navigate to categories
- Click on any category to see filtered pets

### 8. Logout
- Open drawer menu
- Click "Logout"
- You'll be redirected to login screen

## Troubleshooting

### Issue: "flutter: command not found"
**Solution**: Install Flutter SDK from https://flutter.dev

### Issue: No devices available
**Solution**: 
- For iOS: Open Xcode and start a simulator
- For Android: Open Android Studio and start an emulator

### Issue: Gradle build failed
**Solution**: 
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: CocoaPods errors (iOS)
**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

### Issue: Image picker not working
**Solution**: Make sure you've added the required permissions (see README.md)

## Running on Physical Device

### iOS (requires Mac):
1. Connect iPhone via USB
2. Trust the computer on your iPhone
3. Open Xcode, add Apple ID, and create provisioning profile
4. Run: `flutter run`

### Android:
1. Enable Developer Options on Android device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `flutter run`

## Build Release APK (Android)

```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Build iOS App (requires Mac)

```bash
flutter build ios --release
```

## Hot Reload During Development

While the app is running:
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

## Useful Commands

```bash
# Clean build artifacts
flutter clean

# Update dependencies
flutter pub get

# Run with verbose logging
flutter run --verbose

# Run in release mode (better performance)
flutter run --release

# List connected devices
flutter devices

# Analyze code for issues
flutter analyze

# Format code
flutter format .
```

## App Features to Test

✅ User registration and login  
✅ Dashboard with pet listings  
✅ Category browsing  
✅ Add new pet with image  
✅ Pet detail view  
✅ Local chat system  
✅ Profile management  
✅ Profile image upload  
✅ Drawer navigation  
✅ Pull-to-refresh  
✅ Data persistence (closes and reopens app)  

## Notes

- All data is stored locally using Hive
- No internet connection required
- Dummy data is auto-generated on first launch
- Chat responses are simulated after 2 seconds
- Images are stored as file paths in device storage

Enjoy using PetiFy! 🐾
