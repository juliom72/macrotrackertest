# Setup Notes

## Camera Permissions

The app requires camera permissions to function. Since this project uses `GENERATE_INFOPLIST_FILE = YES`, you need to add the permission keys via Xcode Build Settings:

### Add Camera Permissions in Xcode:
1. Open the project in Xcode
2. Select the project in the navigator (top-level "camera-mobile-app-1")
3. Select the target "camera-mobile-app-1"
4. Go to the **"Info"** tab
5. Click the **"+"** button to add new keys
6. Add the following keys:
   - **Key**: `Privacy - Camera Usage Description` (or `NSCameraUsageDescription`)
     **Value**: "We need access to your camera to take photos of your meals and estimate their nutritional content."
   - **Key**: `Privacy - Photo Library Usage Description` (or `NSPhotoLibraryUsageDescription`)
     **Value**: "We need access to your photo library to save meal photos."

Alternatively, you can add these in the Build Settings:
- Search for "Info.plist" in Build Settings
- Add `INFOPLIST_KEY_NSCameraUsageDescription` with the description text
- Add `INFOPLIST_KEY_NSPhotoLibraryUsageDescription` with the description text

## Features Implemented

✅ User authentication and sign-up flow
✅ User profile with editable information (weight, height, age, goal)
✅ Camera view for meal photo capture
✅ Macro estimation (placeholder - ready for ML model integration)
✅ Daily calorie and macro tracking
✅ 7-day rolling graph visualization
✅ Home page with goals progress
✅ Quick camera access from home page and tab bar
✅ Tab navigation (Home, Progress, Camera, Profile)

## Next Steps for Production

1. **ML Model Integration**: Replace the placeholder macro estimation in `CameraView.swift` with a real ML model (Core ML, Vision framework, or API)
2. **Backend Integration**: Replace UserDefaults storage with a backend service (Firebase, AWS, etc.)
3. **Google Sign In**: Implement actual Google Sign In integration
4. **Image Storage**: Implement cloud storage for meal images
5. **Data Persistence**: Consider using Core Data or CloudKit for better data management
6. **Gender Field**: Add gender to User model for more accurate BMR calculation
7. **Activity Level**: Add activity level selection for more accurate TDEE calculation
