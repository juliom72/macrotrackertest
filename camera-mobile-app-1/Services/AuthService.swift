//
//  AuthService.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import AuthenticationServices
import GoogleSignIn
import UIKit
import CryptoKit

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case networkError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 8 characters"
        case .emailAlreadyInUse:
            return "An account with this email already exists"
        case .userNotFound:
            return "No account found with this email"
        case .wrongPassword:
            return "Incorrect password"
        case .networkError:
            return "Network error. Please check your connection"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

protocol AuthServiceProtocol {
    func signUp(email: String, password: String, userData: UserProfileData) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signInWithApple(authorization: ASAuthorizationAppleIDCredential, rawNonce: String) async throws -> User
    func signInWithGoogle() async throws -> User
    func signOut() async throws
    func resetPassword(email: String) async throws
    func getCurrentUser() async throws -> User?
    func updateUserProfile(_ data: UserProfileData) async throws
}

struct UserProfileData {
    let weight: Double
    let height: Double
    let age: Int
    let goal: Goal
}

class FirebaseAuthService: AuthServiceProtocol {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let keychain = KeychainHelper.shared
    
    // MARK: - Email/Password Authentication
    
    func signUp(email: String, password: String, userData: UserProfileData) async throws -> User {
        // Validate password strength
        guard password.count >= 8 else {
            throw AuthError.weakPassword
        }
        
        // Validate email format
        guard email.isValidEmail else {
            throw AuthError.invalidEmail
        }
        
        do {
            // Create Firebase user
            let authResult = try await auth.createUser(withEmail: email, password: password)
            
            // Send email verification
            try await authResult.user.sendEmailVerification()
            
            // Create user document in Firestore
            let user = User(
                id: UUID(uuidString: authResult.user.uid) ?? UUID(),
                email: email,
                password: "", // Don't store password
                weight: userData.weight,
                height: userData.height,
                age: userData.age,
                goal: userData.goal
            )
            
            try await saveUserToFirestore(user, uid: authResult.user.uid)
            
            // Store auth token securely
            do {
                let token = try await authResult.user.getIDToken()
                keychain.save(token, forKey: "authToken")
            } catch {
                // Token retrieval failed, but user is still authenticated
                print("Warning: Failed to get ID token: \(error)")
            }
            
            return user
        } catch let error as NSError {
            if error.domain == "FIRAuthErrorDomain" {
                switch error.code {
                case 17007: // Email already in use
                    throw AuthError.emailAlreadyInUse
                case 17008: // Invalid email
                    throw AuthError.invalidEmail
                case 17026: // Weak password
                    throw AuthError.weakPassword
                default:
                    throw AuthError.unknown(error)
                }
            }
            throw AuthError.unknown(error)
        }
    }
    
    func signIn(email: String, password: String) async throws -> User {
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            
            // Load user data from Firestore
            guard let user = try await loadUserFromFirestore(uid: authResult.user.uid) else {
                throw AuthError.userNotFound
            }
            
            // Store auth token securely
            do {
                let token = try await authResult.user.getIDToken()
                keychain.save(token, forKey: "authToken")
            } catch {
                // Token retrieval failed, but user is still authenticated
                print("Warning: Failed to get ID token: \(error)")
            }
            
            return user
        } catch let error as NSError {
            if error.domain == "FIRAuthErrorDomain" {
                switch error.code {
                case 17011: // User not found
                    throw AuthError.userNotFound
                case 17009: // Wrong password
                    throw AuthError.wrongPassword
                case 17020: // Network error
                    throw AuthError.networkError
                default:
                    throw AuthError.unknown(error)
                }
            }
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Apple Sign In
    
    /// Generates a random nonce string for Apple Sign In security
    /// Uses SecRandomCopyBytes as recommended by Firebase documentation
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    /// SHA256 hash of the nonce for Apple Sign In
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func signInWithApple(authorization: ASAuthorizationAppleIDCredential, rawNonce: String) async throws -> User {
        print("🟢 AuthService: Starting Apple Sign In...")
        print("🟢 AuthService: Raw nonce length: \(rawNonce.count)")
        
        guard let appleIDToken = authorization.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("🔴 AuthService: Failed to get Apple ID token")
            throw AuthError.unknown(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get Apple ID token"]))
        }
        
        print("🟢 AuthService: Got Apple ID token, length: \(idTokenString.count)")
        
        // Use OAuthProvider.appleCredential() - the correct Firebase method for Apple Sign In
        // This is the static method specifically designed for Apple authentication
        // It includes the fullName from the Apple credential for better user experience
        print("🟢 AuthService: Creating Apple credential with ID token and nonce...")
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: rawNonce,
            fullName: authorization.fullName
        )
        print("🟢 AuthService: Apple credential created successfully")
        
        do {
            print("Attempting Firebase sign in with Apple credential...")
            let authResult = try await auth.signIn(with: credential)
            print("Firebase sign in successful. User ID: \(authResult.user.uid)")
            
            // Check if user already exists in Firestore
            if let existingUser = try await loadUserFromFirestore(uid: authResult.user.uid) {
                print("Existing user found in Firestore")
                do {
                    let token = try await authResult.user.getIDToken()
                    keychain.save(token, forKey: "authToken")
                } catch {
                    print("Warning: Failed to get ID token: \(error)")
                }
                return existingUser
            }
            
            // New user - create default profile
            print("Creating new user profile...")
            let email = authorization.email ?? authResult.user.email ?? ""
            let user = User(
                id: UUID(uuidString: authResult.user.uid) ?? UUID(),
                email: email,
                password: "",
                weight: 70,
                height: 175,
                age: 30,
                goal: .maintain
            )
            
            try await saveUserToFirestore(user, uid: authResult.user.uid)
            print("New user saved to Firestore")
            
            do {
                let token = try await authResult.user.getIDToken()
                keychain.save(token, forKey: "authToken")
            } catch {
                print("Warning: Failed to get ID token: \(error)")
            }
            
            return user
        } catch {
            print("Firebase sign in error: \(error.localizedDescription)")
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() async throws -> User {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.unknown(NSError(domain: "GoogleSignIn", code: -1))
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.unknown(NSError(domain: "GoogleSignIn", code: -2))
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.unknown(NSError(domain: "GoogleSignIn", code: -3))
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
        
        do {
            let authResult = try await auth.signIn(with: credential)
            
            // Check if user already exists
            if let existingUser = try await loadUserFromFirestore(uid: authResult.user.uid) {
                do {
                    let token = try await authResult.user.getIDToken()
                    keychain.save(token, forKey: "authToken")
                } catch {
                    print("Warning: Failed to get ID token: \(error)")
                }
                return existingUser
            }
            
            // New user - create default profile
            let email = authResult.user.email ?? ""
            let user = User(
                id: UUID(uuidString: authResult.user.uid) ?? UUID(),
                email: email,
                password: "",
                weight: 70,
                height: 175,
                age: 30,
                goal: .maintain
            )
            
            try await saveUserToFirestore(user, uid: authResult.user.uid)
            
            do {
                let token = try await authResult.user.getIDToken()
                keychain.save(token, forKey: "authToken")
            } catch {
                print("Warning: Failed to get ID token: \(error)")
            }
            
            return user
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async throws {
        guard email.isValidEmail else {
            throw AuthError.invalidEmail
        }
        
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() async throws {
        do {
            try auth.signOut()
            keychain.delete(forKey: "authToken")
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Current User
    
    func getCurrentUser() async throws -> User? {
        guard let currentUser = auth.currentUser else {
            return nil
        }
        
        return try await loadUserFromFirestore(uid: currentUser.uid)
    }
    
    // MARK: - Update Profile
    
    func updateUserProfile(_ data: UserProfileData) async throws {
        guard let uid = auth.currentUser?.uid else {
            throw AuthError.userNotFound
        }
        
        let userRef = db.collection("users").document(uid)
        try await userRef.updateData([
            "weight": data.weight,
            "height": data.height,
            "age": data.age,
            "goal": data.goal.rawValue
        ])
    }
    
    // MARK: - Private Helpers
    
    private func saveUserToFirestore(_ user: User, uid: String) async throws {
        let userRef = db.collection("users").document(uid)
        
        let data: [String: Any] = [
            "id": user.id.uuidString,
            "email": user.email,
            "weight": user.weight,
            "height": user.height,
            "age": user.age,
            "goal": user.goal.rawValue,
            "createdAt": Timestamp(date: user.createdAt)
        ]
        
        try await userRef.setData(data)
    }
    
    private func loadUserFromFirestore(uid: String) async throws -> User? {
        let userRef = db.collection("users").document(uid)
        let document = try await userRef.getDocument()
        
        guard let data = document.data() else {
            return nil
        }
        
        return User(
            id: UUID(uuidString: data["id"] as? String ?? uid) ?? UUID(),
            email: data["email"] as? String ?? "",
            password: "", // Never load password
            weight: data["weight"] as? Double ?? 70,
            height: data["height"] as? Double ?? 175,
            age: data["age"] as? Int ?? 30,
            goal: Goal(rawValue: data["goal"] as? String ?? "Maintain") ?? .maintain
        )
    }
}

// MARK: - Email Validation Extension

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}
