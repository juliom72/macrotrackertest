//
//  SignUpView.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

enum SignUpStep {
    case userInfo
    case authMethod
    case emailPassword
}

struct SignUpView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep: SignUpStep = .userInfo
    
    // Step 1: User Info
    @State private var weight: Double = 70
    @State private var height: Double = 175
    @State private var age: Int = 30
    @State private var selectedGoal: Goal = .maintain
    
    // Step 3: Email/Password
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var passwordStrength: PasswordStrength = .none
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                if currentStep != .userInfo {
                    ProgressView(value: progressValue)
                        .tint(.blue)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Step 1: User Info
                        if currentStep == .userInfo {
                            userInfoStep
                        }
                        
                        // Step 2: Auth Method
                        if currentStep == .authMethod {
                            authMethodStep
                        }
                        
                        // Step 3: Email/Password
                        if currentStep == .emailPassword {
                            emailPasswordStep
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var progressValue: Double {
        switch currentStep {
        case .userInfo: return 0.0
        case .authMethod: return 0.5
        case .emailPassword: return 0.75
        }
    }
    
    private var navigationTitle: String {
        switch currentStep {
        case .userInfo: return "Sign Up"
        case .authMethod: return "Choose Sign Up Method"
        case .emailPassword: return "Create Account"
        }
    }
    
    // MARK: - Step 1: User Info
    private var userInfoStep: some View {
        VStack(spacing: 24) {
            Text("Tell us about yourself")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Weight
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight: \(Int(weight)) kg")
                    .font(.subheadline)
                Slider(value: $weight, in: 40...150, step: 1)
            }
            
            // Height
            VStack(alignment: .leading, spacing: 8) {
                Text("Height: \(Int(height)) cm")
                    .font(.subheadline)
                Slider(value: $height, in: 120...220, step: 1)
            }
            
            // Age
            VStack(alignment: .leading, spacing: 8) {
                Text("Age: \(age) years")
                    .font(.subheadline)
                Slider(value: Binding(
                    get: { Double(age) },
                    set: { age = Int($0) }
                ), in: 13...100, step: 1)
            }
            
            // Goal
            VStack(alignment: .leading, spacing: 8) {
                Text("Goal")
                    .font(.subheadline)
                Picker("Goal", selection: $selectedGoal) {
                    ForEach(Goal.allCases, id: \.self) { goal in
                        Text(goal.rawValue).tag(goal)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Continue Button
            Button(action: {
                currentStep = .authMethod
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
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
            }
        }
    }
    
    // MARK: - Step 2: Auth Method
    private var authMethodStep: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("Choose how you'd like to sign up")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 40)
            
            // Center the buttons vertically
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
                                    await signUpWithApple(authorization: appleIDCredential, rawNonce: rawNonce)
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
                
                // Google Sign In - matching Sign In page style
                Button(action: {
                    Task {
                        await signUpWithGoogle()
                    }
                }) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Sign up with Google")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Email Sign Up
                Button(action: {
                    currentStep = .emailPassword
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Sign up with Email")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
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
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            
            // Error Message
            if let errorMessage = userViewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.top, 16)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Step 3: Email/Password
    private var emailPasswordStep: some View {
        VStack(spacing: 24) {
            Text("Create your account")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                HStack {
                    if showPassword {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .onChange(of: password) { _, newValue in
                    passwordStrength = calculatePasswordStrength(newValue)
                }
                
                if !password.isEmpty {
                    PasswordStrengthView(strength: passwordStrength)
                }
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                
                if !confirmPassword.isEmpty && password != confirmPassword {
                    Text("Passwords do not match")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Error Message
            if let errorMessage = userViewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            // Sign Up Button
            Button(action: {
                guard password == confirmPassword else {
                    userViewModel.errorMessage = "Passwords do not match"
                    return
                }
                
                Task {
                    await userViewModel.signUp(
                        email: email,
                        password: password,
                        weight: weight,
                        height: height,
                        age: age,
                        goal: selectedGoal
                    )
                }
            }) {
                if userViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign Up")
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
            .disabled(email.isEmpty || password.isEmpty || password != confirmPassword || userViewModel.isLoading)
            .opacity(email.isEmpty || password.isEmpty || password != confirmPassword || userViewModel.isLoading ? 0.6 : 1.0)
        }
    }
    
    // MARK: - Helper Methods
    private func goToPreviousStep() {
        switch currentStep {
        case .userInfo:
            dismiss()
        case .authMethod:
            currentStep = .userInfo
        case .emailPassword:
            currentStep = .authMethod
        }
    }
    
    private func signUpWithApple(authorization: ASAuthorizationAppleIDCredential, rawNonce: String) async {
        await userViewModel.signInWithApple(authorization: authorization, rawNonce: rawNonce)
        
        // After successful Apple sign-in, update user profile with collected info
        if userViewModel.isAuthenticated {
            await userViewModel.updateUser(
                weight: weight,
                height: height,
                age: age,
                goal: selectedGoal
            )
        }
    }
    
    private func signUpWithGoogle() async {
        await userViewModel.signInWithGoogle()
        
        // After successful Google sign-in, update user profile with collected info
        if userViewModel.isAuthenticated {
            await userViewModel.updateUser(
                weight: weight,
                height: height,
                age: age,
                goal: selectedGoal
            )
        }
    }
    
    private func calculatePasswordStrength(_ password: String) -> PasswordStrength {
        var strength = 0
        
        if password.count >= 8 { strength += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { strength += 1 }
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil { strength += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { strength += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*")) != nil { strength += 1 }
        
        switch strength {
        case 0...2: return .weak
        case 3...4: return .medium
        case 5: return .strong
        default: return .none
        }
    }
}

enum PasswordStrength {
    case none
    case weak
    case medium
    case strong
    
    var color: Color {
        switch self {
        case .none: return .gray
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        }
    }
    
    var text: String {
        switch self {
        case .none: return ""
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }
}

struct PasswordStrengthView: View {
    let strength: PasswordStrength
    
    var body: some View {
        if strength != .none {
            HStack {
                Text("Password strength: \(strength.text)")
                    .font(.caption)
                Spacer()
                RoundedRectangle(cornerRadius: 2)
                    .fill(strength.color)
                    .frame(width: 60, height: 4)
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(UserViewModel())
}
