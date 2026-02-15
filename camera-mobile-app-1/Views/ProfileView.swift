//
//  ProfileView.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var weight: Double = 70
    @State private var height: Double = 175
    @State private var age: Int = 30
    @State private var selectedGoal: Goal = .maintain
    @State private var showEditMode = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let user = userViewModel.currentUser {
                        // Profile Header
                        VStack(spacing: 8) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text(user.email)
                                .font(.title2.bold())
                        }
                        .padding(.top, 20)
                        
                        // User Info Display
                        VStack(spacing: 16) {
                            InfoRow(label: "Weight", value: "\(Int(showEditMode ? weight : user.weight)) kg")
                            InfoRow(label: "Height", value: "\(Int(showEditMode ? height : user.height)) cm")
                            InfoRow(label: "Age", value: "\(showEditMode ? age : user.age) years")
                            InfoRow(label: "Goal", value: (showEditMode ? selectedGoal : user.goal).rawValue)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        if showEditMode {
                            // Editable Fields
                            VStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Weight: \(Int(weight)) kg")
                                        .font(.subheadline)
                                    Slider(value: $weight, in: 40...150, step: 1)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Height: \(Int(height)) cm")
                                        .font(.subheadline)
                                    Slider(value: $height, in: 120...220, step: 1)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Age: \(age) years")
                                        .font(.subheadline)
                                    Slider(value: Binding(
                                        get: { Double(age) },
                                        set: { age = Int($0) }
                                    ), in: 13...100, step: 1)
                                }
                                
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
                                
                                Button(action: {
                                    Task {
                                        await userViewModel.updateUser(
                                            weight: weight,
                                            height: height,
                                            age: age,
                                            goal: selectedGoal
                                        )
                                        showEditMode = false
                                    }
                                }) {
                                    Text("Save Changes")
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
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
                        
                        // Goals Summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Daily Goals")
                                .font(.headline)
                            
                            GoalRow(label: "Calories", value: "\(Int(user.dailyCalorieGoal))", unit: "kcal")
                            GoalRow(label: "Protein", value: "\(Int(user.proteinGoal))", unit: "g")
                            GoalRow(label: "Carbs", value: "\(Int(user.carbGoal))", unit: "g")
                            GoalRow(label: "Fats", value: "\(Int(user.fatGoal))", unit: "g")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Sign Out Button
                        Button(action: {
                            Task {
                                await userViewModel.signOut()
                            }
                        }) {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(showEditMode ? "Cancel" : "Edit") {
                        if !showEditMode {
                            if let user = userViewModel.currentUser {
                                weight = user.weight
                                height = user.height
                                age = user.age
                                selectedGoal = user.goal
                            }
                        }
                        showEditMode.toggle()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct GoalRow: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(value) \(unit)")
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject({
            let vm = UserViewModel()
            vm.currentUser = User(
                email: "test@example.com",
                password: "password",
                weight: 75,
                height: 180,
                age: 28,
                goal: .gainMuscle
            )
            return vm
        }())
}
