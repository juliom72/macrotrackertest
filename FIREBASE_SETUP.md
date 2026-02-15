# Firebase Setup Guide

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "MacroTracker" (or your preferred name)
4. Enable Google Analytics (recommended)
5. Create project

## Step 2: Add iOS App to Firebase

1. In Firebase Console, click "Add app" → iOS
2. Enter your bundle ID: `yeux.tech.camera-mobile-app-1` (check in Xcode project settings)
3. Register app
4. Download `GoogleService-Info.plist`
5. **Drag `GoogleService-Info.plist` into your Xcode project** (make sure "Copy items if needed" is checked)

## Step 3: Install Firebase SDK

### Option A: Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter: `https://github.com/firebase/firebase-ios-sdk`
3. Select these products:
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseCore
4. Click "Add Package"

### Option B: CocoaPods

Add to `Podfile`:
```ruby
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
```

## Step 4: Enable Authentication Methods

1. In Firebase Console, go to **Authentication → Sign-in method**
2. Enable:
   - ✅ **Email/Password** (click Enable)
   - ✅ **Apple** (click Enable, follow setup)
   - ✅ **Google** (click Enable, follow setup)

### Apple Sign In Setup:
- Requires Apple Developer account
- Add your app's bundle ID
- Download the OAuth key
- Upload to Firebase

Select project in Xcode Project navigator
Select main application target
Go to General tab
Scroll down to "Frameworks, Libraries, and Embedded Content"
Add `AuthenticationServices.framework`

### Google Sign In Setup:
- Requires Google Cloud Console project
- Add iOS client ID
- Configure OAuth consent screen

File -> Add Packages
https://github.com/google/GoogleSignIn-iOS
GoogleSignIn


## Step 5: Configure Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Start in **test mode** (for development)
4. Choose location (closest to your users)
5. Enable

### Security Rules (Update after testing):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /meals/{mealId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 6: Update Info.plist

Add to your Info.plist (or via Xcode Info tab):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.668371708912-qoknq7viql48l5hl9uvdkc5pm4i0vr4n</string>
        </array>
    </dict>
</array>
```

Get `YOUR_CLIENT_ID` from `GoogleService-Info.plist` → `REVERSED_CLIENT_ID`

## Step 7: Update AppDelegate (if needed)

If you have an AppDelegate, add:

```swift
import FirebaseCore

func application(_ application: UIApplication, 
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
}
```

**Note:** The app already initializes Firebase in `camera_mobile_app_1App.swift`, so this may not be needed.

## Step 8: Test Authentication

1. Build and run the app
2. Try signing up with email/password
3. Check Firebase Console → Authentication → Users (should see new user)
4. Check Firestore → users collection (should see user document)

## Troubleshooting

### "No such module 'FirebaseAuth'"
- Clean build folder: Product → Clean Build Folder
- Restart Xcode
- Verify package is added correctly

### "GoogleService-Info.plist not found"
- Make sure file is in project root
- Check "Copy Bundle Resources" in Build Phases

### Apple Sign In not working
- Verify bundle ID matches Firebase
- Check OAuth key is uploaded
- Ensure Sign in with Apple capability is enabled in Xcode

### Google Sign In not working
- Verify URL scheme in Info.plist
- Check client ID matches GoogleService-Info.plist
- Ensure Google Sign In SDK is installed

## Next Steps

1. ✅ Test all authentication methods
2. ✅ Set up proper Firestore security rules
3. ✅ Enable email verification
4. ✅ Set up password reset email templates
5. ✅ Configure Firebase Analytics (optional)
6. ✅ Set up Firebase Crashlytics (optional)

## Production Checklist

Before launching:
- [ ] Update Firestore security rules
- [ ] Enable email verification requirement
- [ ] Set up custom email templates
- [ ] Configure domain verification (for custom emails)
- [ ] Set up Firebase App Check (anti-abuse)
- [ ] Enable Firebase Performance Monitoring
- [ ] Set up alerts in Firebase Console
