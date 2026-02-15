//
//  HomeView.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var nutritionViewModel: NutritionViewModel
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let user = userViewModel.currentUser {
                        let todayNutrition = nutritionViewModel.getTodayNutrition()
                        
                        // Quick Stats Header
                        VStack(spacing: 16) {
                            Text("Today's Progress")
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Calories Progress
                            GoalProgressCard(
                                title: "Calories",
                                current: todayNutrition.totalCalories,
                                goal: user.dailyCalorieGoal,
                                unit: "kcal",
                                color: .blue
                            )
                            
                            // Macros Grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                GoalProgressCard(
                                    title: "Protein",
                                    current: todayNutrition.totalProtein,
                                    goal: user.proteinGoal,
                                    unit: "g",
                                    color: .red
                                )
                                
                                GoalProgressCard(
                                    title: "Carbs",
                                    current: todayNutrition.totalCarbs,
                                    goal: user.carbGoal,
                                    unit: "g",
                                    color: .orange
                                )
                                
                                GoalProgressCard(
                                    title: "Fats",
                                    current: todayNutrition.totalFats,
                                    goal: user.fatGoal,
                                    unit: "g",
                                    color: .purple
                                )
                                
                                MacroBreakdownCard(
                                    healthyFats: todayNutrition.totalHealthyFats,
                                    saturatedFats: todayNutrition.totalSaturatedFats,
                                    totalFats: todayNutrition.totalFats
                                )
                            }
                        }
                        .padding()
                        
                        // Quick Camera Button
                        Button(action: {
                            selectedTab = 2 // Navigate to Camera tab
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                Text("Add Meal with Camera")
                                    .font(.headline)
                            }
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
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        // Today's Meals
                        if !todayNutrition.meals.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today's Meals")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                
                                ForEach(todayNutrition.meals) { meal in
                                    MealRow(meal: meal)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("MacroTracker")
        }
    }
}

struct GoalProgressCard: View {
    let title: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color
    
    private var percentage: Double {
        min(current / goal, 1.0)
    }
    
    private var progressColor: Color {
        if percentage >= 1.0 {
            return .green
        } else if percentage >= 0.8 {
            return .orange
        } else {
            return color
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(current))/\(Int(goal))")
                    .font(.subheadline.bold())
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * percentage, height: 8)
                        .cornerRadius(4)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: percentage)
                }
            }
            .frame(height: 8)
            
            Text("\(Int(percentage * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MacroBreakdownCard: View {
    let healthyFats: Double
    let saturatedFats: Double
    let totalFats: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Fat Breakdown")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Healthy: \(Int(healthyFats))g")
                        .font(.caption)
                }
                
                HStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                    Text("Saturated: \(Int(saturatedFats))g")
                        .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MealRow: View {
    let meal: Meal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.headline)
                Text("\(Int(meal.calories)) kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(meal.protein))g")
                        .font(.caption.bold())
                    Text("P")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(meal.carbs))g")
                        .font(.caption.bold())
                    Text("C")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(meal.fats))g")
                        .font(.caption.bold())
                    Text("F")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
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
        .environmentObject(NutritionViewModel())
}
