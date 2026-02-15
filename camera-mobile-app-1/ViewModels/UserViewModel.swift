//
//  UserViewModel.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import AuthenticationServices

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = FirebaseAuthService()) {
        self.authService = authService
        Task {
            await checkAuthState()
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, weight: Double, height: Double, age: Int, goal: Goal) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let userData = UserProfileData(weight: weight, height: height, age: age, goal: goal)
            let user = try await authService.signUp(email: email, password: password, userData: userData)
            currentUser = user
            isAuthenticated = true
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            currentUser = user
            isAuthenticated = true
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Apple Sign In - Uses nonce for security
    func signInWithApple(authorization: ASAuthorizationAppleIDCredential, rawNonce: String) async {
        print("🔵 UserViewModel: Starting Apple Sign In...")
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔵 UserViewModel: Calling authService.signInWithApple...")
            let user = try await authService.signInWithApple(authorization: authorization, rawNonce: rawNonce)
            print("🔵 UserViewModel: Sign in successful! User email: \(user.email)")
            currentUser = user
            isAuthenticated = true
            print("🔵 UserViewModel: isAuthenticated set to true")
        } catch let error as AuthError {
            print("🔴 UserViewModel: AuthError - \(error.errorDescription ?? "Unknown")")
            errorMessage = error.errorDescription
        } catch {
            print("🔴 UserViewModel: Error - \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        print("🔵 UserViewModel: Apple Sign In completed. isAuthenticated: \(isAuthenticated)")
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signInWithGoogle()
            currentUser = user
            isAuthenticated = true
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        
        do {
            try await authService.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.resetPassword(email: email)
            errorMessage = nil // Success - show success message in view
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - User Profile
    
    func updateUser(weight: Double? = nil, height: Double? = nil, age: Int? = nil, goal: Goal? = nil) async {
        guard let currentUser = currentUser else { return }
        
        let userData = UserProfileData(
            weight: weight ?? currentUser.weight,
            height: height ?? currentUser.height,
            age: age ?? currentUser.age,
            goal: goal ?? currentUser.goal
        )
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.updateUserProfile(userData)
            
            // Update local user
            var updatedUser = currentUser
            if let weight = weight { updatedUser.weight = weight }
            if let height = height { updatedUser.height = height }
            if let age = age { updatedUser.age = age }
            if let goal = goal { updatedUser.goal = goal }
            
            self.currentUser = updatedUser
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func checkAuthState() async {
        do {
            if let user = try await authService.getCurrentUser() {
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            // Not authenticated
            isAuthenticated = false
        }
    }
}
