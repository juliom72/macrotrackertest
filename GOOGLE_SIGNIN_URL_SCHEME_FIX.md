# Fix Google Sign In URL Scheme

## Quick Fix (Recommended)

Since your project uses `GENERATE_INFOPLIST_FILE = YES`, add the URL scheme via Xcode:

### Steps:

1. **Open Xcode**
2. **Select your project** in the navigator (top-level "camera-mobile-app-1")
3. **Select the target** "camera-mobile-app-1"
4. **Go to the "Info" tab**
5. **Scroll down to "URL Types"** section
6. **Click the "+" button** to add a new URL Type
7. **Fill in:**
   - **Identifier**: `GoogleSignIn` (or any identifier)
   - **URL Schemes**: Click "+" and add: `com.googleusercontent.apps.668371708912-qoknq7viql48l5hl9uvdkc5pm4i0vr4n`
8. **Save and rebuild**

### Alternative: Add via Build Settings

If you prefer to add it programmatically, you can add this to your build settings:

1. Go to **Build Settings**
2. Search for "Info.plist"
3. Add a new User-Defined Setting:
   - **Key**: `INFOPLIST_KEY_CFBundleURLTypes`
   - **Value**: (This is complex - use the Xcode Info tab method instead)

## Verify

After adding the URL scheme:
1. Clean build folder: **Product → Clean Build Folder**
2. Rebuild the app
3. Try Google Sign In again

The URL scheme should match the `REVERSED_CLIENT_ID` from your `GoogleService-Info.plist`:
- `com.googleusercontent.apps.668371708912-qoknq7viql48l5hl9uvdkc5pm4i0vr4n`
