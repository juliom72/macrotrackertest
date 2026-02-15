# Apple Sign In Setup Guide

## Error You're Seeing

```
ASAuthorizationController credential request failed with error: 
Error Domain=com.apple.AuthenticationServices.AuthorizationError Code=1000
```

This error means the "Sign in with Apple" capability hasn't been enabled in your Xcode project.

## Step 1: Enable Sign in with Apple Capability in Xcode

1. **Open your project in Xcode**
2. **Select your project** in the navigator (top-level "camera-mobile-app-1")
3. **Select the target** "camera-mobile-app-1"
4. **Go to the "Signing & Capabilities" tab**
5. **Click the "+ Capability" button** (top left)
6. **Search for "Sign in with Apple"** and double-click it
7. This will automatically:
   - Add the capability to your project
   - Create/update an entitlements file
   - Add the necessary configuration

## Step 2: Verify Entitlements File

After adding the capability, Xcode should create a file called:
- `camera-mobile-app-1.entitlements` (or similar)

This file should contain:
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

## Step 3: Verify in Apple Developer Portal

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click **Identifiers**
4. Find your app identifier: `yeux.tech.camera-mobile-app-1`
5. Make sure **"Sign in with Apple"** is checked/enabled
6. If not, enable it and save

## Step 4: Clean and Rebuild

1. In Xcode, go to **Product → Clean Build Folder** (Shift + Cmd + K)
2. **Quit and restart Xcode** (optional but recommended)
3. **Build and run** the app again

## Step 5: Test on a Real Device

**Important:** Apple Sign In may not work properly in the iOS Simulator. Test on a **real iOS device** that is:
- Signed in to an iCloud account
- Has a valid Apple ID

## Troubleshooting

### Still Getting Error Code 1000?

1. **Check Bundle ID matches**: Make sure your Xcode bundle ID (`yeux.tech.camera-mobile-app-1`) matches:
   - Apple Developer Portal
   - Firebase Console
   - GoogleService-Info.plist

2. **Check Signing**: In Xcode → Signing & Capabilities:
   - Make sure "Automatically manage signing" is checked
   - Or manually select your provisioning profile that includes Sign in with Apple

3. **Check Entitlements**: Make sure the entitlements file is included in:
   - Build Settings → Code Signing Entitlements
   - Build Phases → Copy Bundle Resources

4. **Test on Real Device**: Simulator may have limitations. Always test on a real device.

### Error Code -7026 (AKAuthenticationError)

This is a secondary error that usually resolves once the capability is properly set up. If it persists:
- Make sure you're testing on a real device (not simulator)
- Verify your Apple ID is properly signed in on the device
- Check that the device has a passcode set (required for some authentication flows)

## Next Steps

Once the capability is enabled and working:
1. The Apple Sign In button will work in the UI
2. You'll need to uncomment and fix the backend implementation in `AuthService.swift` for Firebase 12.9.0
3. See the TODO comments in the code for the Firebase credential API fix

## Additional Resources

- [Apple Sign In Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Firebase Apple Sign In Guide](https://firebase.google.com/docs/auth/ios/apple)
