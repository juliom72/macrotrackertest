# Firebase Version Upgrade Guide

## Current Version
- **Firebase iOS SDK**: 12.9.0 (from Package.resolved)

## Recommended Version
**Upgrade to the latest stable Firebase iOS SDK** (currently **11.x or 12.x+** with latest patch)

The latest versions have:
- ✅ Better Apple Sign In API support
- ✅ Improved async/await patterns
- ✅ Better documentation
- ✅ Bug fixes for authentication flows

## Why Upgrade?

Firebase 12.9.0 appears to have API compatibility issues with Apple Sign In. The credential creation methods have changed, and the latest versions have:
- Clearer API documentation
- Better error messages
- More reliable authentication flows

## How to Upgrade

### Option 1: Update via Xcode (Recommended)

1. **Open your project in Xcode**
2. **Select your project** in the navigator
3. **Go to "Package Dependencies"** tab
4. **Find "firebase-ios-sdk"** in the list
5. **Click the update button** (or right-click → "Update to Latest Version")
6. **Wait for Xcode to resolve dependencies**
7. **Clean Build Folder**: Product → Clean Build Folder (Shift + Cmd + K)
8. **Rebuild the project**

### Option 2: Update via Package.resolved (Manual)

1. **Open** `camera-mobile-app-1.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`
2. **Find the firebase-ios-sdk entry**:
   ```json
   {
     "identity" : "firebase-ios-sdk",
     "kind" : "remoteSourceControl",
     "location" : "https://github.com/firebase/firebase-ios-sdk",
     "state" : {
       "revision" : "9b3aed4fa6226125305b82d4d86c715bef250785",
       "version" : "12.9.0"
     }
   }
   ```
3. **Change the version** to `"11.0.0"` or remove the version to get the latest
4. **Delete the revision** line (or update it)
5. **In Xcode**: File → Packages → Update to Latest Package Versions
6. **Clean and rebuild**

### Option 3: Specify Latest Version in Xcode

1. **In Xcode**, go to **File → Add Package Dependencies**
2. **Enter**: `https://github.com/firebase/firebase-ios-sdk`
3. **Set version rule**: "Up to Next Major Version" from `11.0.0` or `12.0.0`
4. **Click "Add Package"**
5. **Xcode will update your existing dependencies**

## After Updating

1. **Clean Build Folder**: Product → Clean Build Folder (Shift + Cmd + K)
2. **Update Apple Sign In code** in `AuthService.swift`:
   - The latest Firebase versions use: `provider.credential(withIDToken:rawNonce:)` 
   - Or the async method: `try await provider.getCredentialWith(nil)`
3. **Test Apple Sign In** - it should work with the updated API

## Check Current Latest Version

Visit: https://github.com/firebase/firebase-ios-sdk/releases

Or in Xcode:
- **File → Packages → Update to Latest Package Versions**
- Check what version gets resolved

## Recommended Approach

**Use the latest stable version** (11.x or 12.x with latest patch):
- More reliable
- Better documentation
- Active bug fixes
- Better Apple Sign In support

## If You Must Stay on 12.9.0

If you need to stay on 12.9.0 for compatibility reasons:
1. Check Xcode autocomplete for `OAuthProvider` methods
2. Try different method signatures based on what's available
3. Check Firebase 12.9.0 release notes for API changes
4. Consider using a different authentication flow

## Verification

After upgrading, verify:
1. ✅ Project builds without errors
2. ✅ Google Sign In still works
3. ✅ Email/Password auth still works
4. ✅ Apple Sign In API is available and works

## Troubleshooting

### "Package resolution failed"
- Check your internet connection
- Try: File → Packages → Reset Package Caches
- Restart Xcode

### "Module not found"
- Clean Build Folder
- Delete Derived Data
- Restart Xcode

### "API still not working"
- Check Firebase release notes for your version
- Verify you're using the correct method signature
- Check Firebase documentation for your specific version
