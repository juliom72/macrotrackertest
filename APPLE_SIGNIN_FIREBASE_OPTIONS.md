# Apple Sign In - Firebase Options & Solutions

## Current Error
```
Fatal error: Sign in with Apple is not supported via generic IDP; 
You must use the Apple SDK for Sign in with Apple.
```

This error occurs because Firebase 12.7.0 doesn't allow using `OAuthProvider` for Apple Sign In in the way we're trying.

## Option 1: Use getCredentialWithUIDelegate (Recommended)

Firebase may require using the async `getCredentialWithUIDelegate` method instead of creating the credential directly.

**Implementation:**
```swift
func signInWithApple(authorization: ASAuthorizationAppleIDCredential) async throws -> User {
    guard let appleIDToken = authorization.identityToken,
          let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        throw AuthError.unknown(NSError(domain: "AppleSignIn", code: -1))
    }
    
    let provider = OAuthProvider(providerID: "apple.com")
    
    // Use getCredentialWithUIDelegate instead of credential()
    let credential = try await provider.getCredentialWith(nil)
    
    // Continue with sign in...
}
```

**Note:** This method may require additional setup or may not work if Firebase expects a different flow.

## Option 2: Upgrade Firebase Version

Firebase 12.7.0 may have a bug or API limitation. Try upgrading to:
- **Firebase 11.0.0+** (stable, well-tested)
- **Latest Firebase version** (may have fixes)

**How to upgrade:**
1. In Xcode: File → Packages → Update to Latest Package Versions
2. Or manually update `Package.resolved` to a newer version

## Option 3: Use OAuthCredential Directly (If Available)

Some Firebase versions allow creating `OAuthCredential` directly without `OAuthProvider`:

```swift
// This may not be available in all Firebase versions
let credential = OAuthCredential(
    providerID: "apple.com",
    idToken: idTokenString,
    rawNonce: nil
)
```

## Option 4: Temporarily Disable Apple Sign In

If you need to ship quickly, you can:
1. Comment out Apple Sign In in the UI
2. Keep email/password and Google Sign In
3. Add Apple Sign In later when Firebase version is updated

## Option 5: Check Firebase Console Configuration

Ensure Apple Sign In is properly configured in Firebase Console:
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable "Apple" provider
3. Configure with your Apple Developer credentials:
   - Service ID
   - Apple Team ID
   - Private Key
   - Key ID

**Missing configuration can cause this error.**

## Option 6: Use Different Authentication Flow

Instead of using `OAuthProvider`, you might need to:
1. Get the Apple ID token
2. Send it directly to Firebase Auth REST API
3. Handle the response manually

This is more complex but may work around the limitation.

## Recommended Next Steps

1. **First, verify Firebase Console setup** - Make sure Apple Sign In is enabled and configured
2. **Try Option 1** - Use `getCredentialWithUIDelegate` method
3. **If that fails, try Option 2** - Upgrade Firebase to 11.0.0 or latest
4. **If still failing, use Option 4** - Temporarily disable and focus on other auth methods

## Testing Checklist

- [ ] Apple Sign In capability enabled in Xcode
- [ ] Apple Sign In enabled in Firebase Console
- [ ] Service ID configured in Firebase
- [ ] Private Key uploaded to Firebase
- [ ] Testing on real device (not simulator)
- [ ] User has Apple ID with 2FA enabled

## Additional Resources

- [Firebase Apple Sign In Docs](https://firebase.google.com/docs/auth/ios/apple)
- [Firebase Auth Errors](https://firebase.google.com/docs/auth/ios/errors)
- [Firebase Troubleshooting](https://firebase.google.com/docs/ios/troubleshooting-faq)
