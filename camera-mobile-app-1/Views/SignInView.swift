//
//  SignInView.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showPasswordReset = false
    @State private var resetEmail = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("Sign In")
                    .font(.title.bold())
            }
            .padding(.top, 40)
            
            // Email & Password
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                // Forgot Password
                Button(action: {
                    showPasswordReset = true
                }) {
                    Text("Forgot Password?")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            
            // Error Message
            if let errorMessage = userViewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            // Sign In Button
            Button(action: {
                Task {
                    await userViewModel.signIn(email: email, password: password)
                }
            }) {
                if userViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.green, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .disabled(email.isEmpty || password.isEmpty || userViewModel.isLoading)
            .opacity(email.isEmpty || password.isEmpty || userViewModel.isLoading ? 0.6 : 1.0)
            
            Divider()
                .padding(.vertical, 8)
            
            // Social Sign In Buttons
            VStack(spacing: 12) {
                // Apple Sign In
                SignInWithAppleButton(
                    onRequest: { request in
                        // Generate nonce for security
                        let nonce = FirebaseAuthService.randomNonceString()
                        let hashedNonce = FirebaseAuthService.sha256(nonce)
                        
                        // Store nonce temporarily for use after Apple authentication
                        UserDefaults.standard.set(nonce, forKey: "appleSignInNonce")
                        
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = hashedNonce
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                // Retrieve the stored nonce
                                guard let rawNonce = UserDefaults.standard.string(forKey: "appleSignInNonce") else {
                                    userViewModel.errorMessage = "Failed to retrieve nonce. Please try again."
                                    return
                                }
                                
                                // Clear the stored nonce
                                UserDefaults.standard.removeObject(forKey: "appleSignInNonce")
                                
                                Task {
                                    await userViewModel.signInWithApple(authorization: appleIDCredential, rawNonce: rawNonce)
                                }
                            }
                        case .failure(let error):
                            // Clear nonce on failure
                            UserDefaults.standard.removeObject(forKey: "appleSignInNonce")
                            userViewModel.errorMessage = error.localizedDescription
                        }
                    }
                )
                .frame(height: 50)
                .cornerRadius(12)
                
                // Google Sign In
                Button(action: {
                    Task {
                        await userViewModel.signInWithGoogle()
                    }
                }) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Sign in with Google")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPasswordReset) {
                PasswordResetView(email: $resetEmail)
                    .environmentObject(userViewModel)
            }
        }
    }
}

struct PasswordResetView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var email: String
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                if let errorMessage = userViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                if showSuccess {
                    Text("Password reset email sent! Check your inbox.")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding()
                }
                
                Button(action: {
                    Task {
                        await userViewModel.resetPassword(email: email)
                        if userViewModel.errorMessage == nil {
                            showSuccess = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                dismiss()
                            }
                        }
                    }
                }) {
                    if userViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Send Reset Link")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .disabled(email.isEmpty || userViewModel.isLoading)
                .opacity(email.isEmpty || userViewModel.isLoading ? 0.6 : 1.0)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(UserViewModel())
}
