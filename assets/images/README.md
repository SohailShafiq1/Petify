# Assets Folder

This folder contains the app's static assets.

## Directory Structure

- `images/` - Place your image assets here

## Usage

Images placed in this folder can be used in the app with:

```dart
Image.asset('assets/images/your_image.png')
```

Note: Make sure all assets are declared in `pubspec.yaml` under the `flutter:` section.

## Current Assets

Currently, the app uses:
- Image picker for dynamic images (camera/gallery)
- Icons from Material Design
- Emoji for category icons

You can add a logo or splash screen image here if needed.
