# Flutter App - Pet Image Analysis Integration

Complete guide for integrating Grok AI pet image analysis into the Flutter app.

## Features

✅ **Camera Integration**
- Take photos directly from the app
- Analyze pet images using Grok AI
- Get instant pet details

✅ **Gallery Integration**
- Upload images from device gallery
- Same AI analysis as camera
- Support for all common image formats

✅ **AI Analysis Results**
- Pet Name/Type (Dog, Cat, Bird, etc.)
- Breed Identification
- Estimated Age Range
- Origin Country/Region

✅ **Search Integration**
- Automatically search for similar pets
- Uses analyzed pet type for better results
- Displays relevant listings

## Setup Instructions

### 1. Dependencies Already Installed ✅

Your `pubspec.yaml` already includes:
- `image_picker: ^1.0.7` - Camera & gallery access
- `http: ^1.2.2` - API communication
- `provider: ^6.1.1` - State management

No additional dependencies needed!

### 2. Environment Configuration

Update `.env` file in Flutter app root:

```env
API_BASE_URL=http://localhost:5001
```

For production:
```env
API_BASE_URL=https://your-api-domain.com
```

### 3. New Service Created

**File**: `lib/services/pet_analysis_service.dart`

Features:
- Image-to-API communication
- Grok AI integration
- Error handling and timeouts
- Response parsing

### 4. Dashboard Updates

**File**: `lib/screens/dashboard_screen.dart`

New methods added:
- `_pickFromGallery()` - Gallery picker
- `_captureAndSearchByCamera()` - Camera capture
- `_showPetAnalysisDialog()` - Image preview with analysis button
- `_analyzePetImage()` - AI analysis handler
- `_showAnalysisResults()` - Results display dialog
- `_buildDetailRow()` - UI helper for details

### 5. UI Changes

**Search Bar Area:**
- Camera icon now shows popup menu
- Two options: "Take Photo" and "Upload from Gallery"
- Clean, intuitive interface

**Image Analysis Flow:**
1. User selects camera or gallery
2. Image preview shown in modal
3. "Analyze Pet with AI" button
4. Loading indicator during analysis
5. Results displayed in beautiful dialog
6. Option to search for similar pets

## How to Use

### From Camera
1. Tap the camera icon in search bar
2. Select "Take Photo"
3. Take a picture of a pet
4. Tap "🔍 Analyze Pet with AI"
5. Wait for analysis (usually 2-5 seconds)
6. Review AI-detected details
7. Click "Search Similar Pets" to find listings

### From Gallery
1. Tap the camera icon in search bar
2. Select "Upload from Gallery"
3. Choose an image from your device
4. Tap "🔍 Analyze Pet with AI"
5. Wait for analysis
6. Review results
7. Optionally search for similar pets

## API Integration

### Backend Requirements
- Node.js server running at specified `API_BASE_URL`
- `/api/pets/analyze-image` endpoint active
- Grok API key configured in `.env`

### Response Format

**Success Response:**
```json
{
  "message": "Image analyzed successfully",
  "petDetails": {
    "petName": "Labrador",
    "breed": "Yellow Labrador Retriever",
    "expectedAge": "2-3 years",
    "origin": "Canada"
  }
}
```

**Error Response:**
```json
{
  "message": "Error analyzing image",
  "error": "Description of error"
}
```

## Error Handling

### Network Issues
- Timeout after 30 seconds
- User-friendly error messages
- Can retry with same image

### Invalid Images
- Clear error message shown
- Suggests trying a clearer image
- Option to take new photo

### API Errors
- Backend error messages displayed
- Helps with debugging
- Graceful fallback

## File Structure

```
PetsFYP/
├── lib/
│   ├── screens/
│   │   ├── dashboard_screen.dart (UPDATED)
│   │   └── ...
│   ├── services/
│   │   ├── pet_analysis_service.dart (NEW)
│   │   └── ...
│   └── ...
└── .env
```

## Testing

### Local Testing

1. **Start Backend:**
```bash
cd Backend
npm run dev
```

2. **Get Local IP:**
```bash
ifconfig | grep inet
```

3. **Update .env:**
```
API_BASE_URL=http://YOUR_LOCAL_IP:5001
```

4. **Run Flutter App:**
```bash
flutter run
```

5. **Test Flow:**
- Take/upload image
- Tap "Analyze Pet with AI"
- Check console for API calls
- Verify results display

### Production Testing

Before deploying:
1. Update `API_BASE_URL` to production domain
2. Ensure HTTPS is used
3. Test with real images
4. Verify timeouts and error handling

## Performance Tips

1. **Image Optimization**
   - `maxWidth: 1800` (automatic in picker)
   - `maxHeight: 1800`
   - `imageQuality: 85%`
   - Reduces upload time

2. **Request Timeout**
   - Set to 30 seconds
   - Handles slow connections
   - User feedback during wait

3. **Error Recovery**
   - Users can retry analysis
   - Can try different image
   - Clear error messages

## Permissions

Required permissions (usually auto-requested):

**Android** - `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

**iOS** - `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to identify pets</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos to analyze pet images</string>
```

## Troubleshooting

### Image Analysis Fails
**Problem:** "Failed to analyze image"
- **Solution 1:** Verify backend is running
- **Solution 2:** Check `API_BASE_URL` is correct
- **Solution 3:** Ensure Grok API key is set in backend `.env`

### Can't Access Camera/Gallery
**Problem:** Permission denied
- **iOS:** Go to Settings > Privacy > Camera/Photos
- **Android:** Settings > Apps > PetiFy > Permissions

### Timeout Errors
**Problem:** "Request timed out"
- **Solution 1:** Check internet connection
- **Solution 2:** Reduce image size
- **Solution 3:** Try later with less server load

### Results Show "Unknown"
**Problem:** AI couldn't identify pet
- **Solution:** Try a clearer, better-lit image
- **Example:** Full-body shot, clear face visible

## API Keys & Security

⚠️ **Important:**
- Grok API key stored only on backend
- Flutter app doesn't need API key
- Backend handles all AI communication
- Secure communication over HTTPS (production)

## Next Steps

1. ✅ Backend API running
2. ✅ Service created
3. ✅ Dashboard updated
4. 🔄 Update your `.env` file
5. 🔄 Run `flutter pub get`
6. 🔄 Test camera/gallery functionality
7. 🔄 Verify AI analysis works

## Support Resources

- [Image Picker Documentation](https://pub.dev/packages/image_picker)
- [HTTP Package Documentation](https://pub.dev/packages/http)
- [Flutter Camera Guide](https://flutter.dev/docs/development/packages-and-plugins/using-packages)
- [Grok API Documentation](https://docs.x.ai/api)

## Feature Roadmap

Potential future enhancements:
- [ ] Multiple pet detection in single image
- [ ] Pet health assessment
- [ ] Breed-specific care tips
- [ ] Pet matching recommendations
- [ ] Image editing before analysis
- [ ] History of analyzed pets
- [ ] Sharing pet details
