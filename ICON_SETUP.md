# App Icon Setup Instructions

## Steps to Set Up the App Icon

1. **Save the App Icon Image:**
   - Save the provided pet app icon image as `app_icon.png`
   - Place it in: `/Users/mc/workspace/PetsFYP/assets/images/app_icon.png`
   - Recommended size: 1024x1024 pixels

2. **Generate the Icons:**
   After placing the icon image, run:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

3. **Rebuild the App:**
   ```bash
   flutter clean
   flutter build apk --debug
   ```

## Current Configuration

The app icon is configured in `pubspec.yaml`:
- Android: Enabled with adaptive icon support
- iOS: Enabled
- Background color: #17a2b8 (turquoise/teal)
- Icon path: assets/images/app_icon.png

## Notes

- The icon should be a square image (1024x1024 recommended)
- The adaptive icon will use the same image as foreground with a solid color background
- After generating icons, you'll see the new icon when you install the app
