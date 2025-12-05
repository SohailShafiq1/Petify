# PetiFy - Pet Trading Mobile Application

A complete Flutter mobile application for buying and selling pets locally, with all data stored locally using Hive and SharedPreferences.

## Features

### 🔐 Authentication
- **Login Screen**: Local authentication with email and password
- **Signup Screen**: Register new users locally
- All user data stored locally (no backend)

### 🏠 Dashboard
- Modern home screen with gradient header
- Drawer menu with navigation (Profile, Settings, My Pets, Logout)
- Featured pets section showing top listings
- Categories section with quick access
- Pull-to-refresh functionality
- Floating action button to add new pets

### 🐾 Pet Management
- **Add Pet**: Complete form to list pets for sale
  - Upload images from camera or gallery
  - Category selection
  - Name, age, price, description
  - Owner contact information
- **Pet Details**: Beautiful detail screen showing:
  - Full-size pet image
  - Price, category, age
  - Detailed description
  - Owner contact information
  - Posted date
- **Categories**: Browse pets by category
  - Dogs, Cats, Birds, Fish, Rabbits, Hamsters

### 💬 Chat System
- Local chat implementation per pet listing
- Send and receive messages (simulated owner responses)
- Message timestamps
- Clean, modern chat UI with bubbles
- Auto-scroll to latest message

### 👤 Profile Management
- View and edit user profile
- Update name and phone number
- Change profile picture from gallery
- Email display (read-only)

## Technology Stack

- **Flutter**: UI framework
- **Provider**: State management
- **Hive**: Local NoSQL database
- **SharedPreferences**: Key-value storage
- **GoRouter**: Navigation and routing
- **ImagePicker**: Camera and gallery access
- **GoogleFonts**: Typography (Poppins)
- **Intl**: Date formatting

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── router.dart              # Navigation configuration
├── models/                  # Data models
│   ├── user_model.dart
│   ├── pet_model.dart
│   ├── chat_message_model.dart
│   └── category_model.dart
├── providers/               # State management
│   ├── auth_provider.dart
│   ├── pets_provider.dart
│   ├── chat_provider.dart
│   └── profile_provider.dart
├── screens/                 # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── welcome_screen.dart
│   ├── dashboard_screen.dart
│   ├── add_pet_screen.dart
│   ├── pet_details_screen.dart
│   ├── categories_screen.dart
│   ├── chat_screen.dart
│   └── profile_screen.dart
├── widgets/                 # Reusable widgets
│   ├── pet_card.dart
│   ├── category_card.dart
│   └── chat_bubble.dart
└── services/                # Business logic
    └── local_storage_service.dart
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development
- VS Code or Android Studio as IDE

### Installation

1. **Install Flutter dependencies**:
   ```bash
   cd /Users/mc/workspace/PetsFYP
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

### First Launch

The app comes with dummy data pre-loaded:
- 6 sample pets across different categories
- Sample categories (Dogs, Cats, Birds, Fish, Rabbits, Hamsters)

To test the app:
1. **Sign up** a new account from the signup screen
2. Or **login** with any email you've previously created
3. Browse pets on the dashboard
4. Click "Sell Your Pet" to add new pets
5. Click on any pet to view details
6. Use "Chat With Owner" to test the chat feature

## Features in Detail

### Local Storage
- **Hive Boxes**:
  - `users`: Stores all user accounts
  - `pets`: Stores all pet listings
  - `chats`: Stores all chat messages
- **SharedPreferences**: Stores current user session

### State Management
- **AuthProvider**: Handles login, signup, logout
- **PetsProvider**: Manages pet listings and CRUD operations
- **ChatProvider**: Handles chat messages and simulated responses
- **ProfileProvider**: Manages user profile updates

### Navigation
- Uses GoRouter for declarative routing
- Protected routes (requires authentication)
- Deep linking support
- Passing data between screens using `extra` parameter

### UI/UX
- Material Design 3
- Custom color scheme with blue primary color
- Google Fonts (Poppins) for typography
- Responsive layouts
- Modern card designs
- Gradient headers
- Smooth animations and transitions

## Platform-Specific Setup

### iOS
Add these permissions to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select pet images</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take pet photos</string>
```

### Android
Permissions are automatically added via dependencies. Minimum SDK version: 21

## Development Notes

### Adding New Features
1. Create model in `lib/models/`
2. Add state management in `lib/providers/`
3. Create UI screens in `lib/screens/`
4. Add routes in `lib/router.dart`
5. Update storage service if needed

### Debugging
- All data is stored locally in device storage
- Use `flutter run --verbose` for detailed logs
- Check Hive boxes in app documents directory

## Known Limitations

Since this is a local-only app:
- Data is not synced across devices
- No real-time updates
- Chat responses are simulated
- No user authentication verification
- Images are stored as file paths (device-specific)

## Future Enhancements (Requires Backend)
- Real authentication with JWT
- Cloud storage for images
- Real-time chat with WebSocket
- Push notifications
- User reviews and ratings
- Favorites/Wishlist
- Search and filters
- Payment integration

## License

This project is created for educational purposes.

## Contact

For questions or support, please refer to the project documentation.
