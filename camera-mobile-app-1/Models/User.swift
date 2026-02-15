//
//  User.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import Foundation

enum Goal: String, CaseIterable, Codable {
    case gainMuscle = "Gain Muscle"
    case maintain = "Maintain"
    case loseFat = "Lose Fat"
}

struct User: Codable, Identifiable {
    let id: UUID
    var email: String
    var password: String // In production, this should be hashed
    var weight: Double // in kg
    var height: Double // in cm
    var age: Int
    var goal: Goal
    var createdAt: Date
    
    init(id: UUID = UUID(), email: String, password: String, weight: Double, height: Double, age: Int, goal: Goal) {
        self.id = id
        self.email = email
        self.password = password
        self.weight = weight
        self.height = height
        self.age = age
        self.goal = goal
        self.createdAt = Date()
    }
    
    // Calculate BMR using Mifflin-St Jeor Equation
    // Using average formula (simplified - in production, add gender field)
    var bmr: Double {
        let weightInKg = weight
        let heightInCm = height
        // Average of male and female formulas for simplicity
        // Male: (10 * weight) + (6.25 * height) - (5 * age) + 5
        // Female: (10 * weight) + (6.25 * height) - (5 * age) - 161
        // Using average: (10 * weight) + (6.25 * height) - (5 * age) - 78
        let baseBMR = (10 * weightInKg) + (6.25 * heightInCm) - (5 * Double(age)) - 78
        return max(baseBMR, 1200) // Minimum BMR for safety
    }
    
    // Calculate daily calorie goal based on goal type
    var dailyCalorieGoal: Double {
        let activityMultiplier = 1.5 // Moderate activity level
        let tdee = bmr * activityMultiplier
        
        switch goal {
        case .gainMuscle:
            return tdee + 300 // Surplus for muscle gain
        case .maintain:
            return tdee
        case .loseFat:
            return tdee - 500 // Deficit for fat loss
        }
    }
    
    // Calculate macro goals (simplified)
    var proteinGoal: Double {
        return weight * 2.2 // 2.2g per kg of body weight
    }
    
    var carbGoal: Double {
        let proteinCalories = proteinGoal * 4
        let fatCalories = (dailyCalorieGoal * 0.25) // 25% from fat
        let remainingCalories = dailyCalorieGoal - proteinCalories - fatCalories
        return remainingCalories / 4 // 4 calories per gram of carbs
    }
    
    var fatGoal: Double {
        return (dailyCalorieGoal * 0.25) / 9 // 25% from fat, 9 calories per gram
    }
    
    var healthyFatGoal: Double {
        return fatGoal * 0.7 // 70% healthy fats
    }
    
    var saturatedFatGoal: Double {
        return fatGoal * 0.3 // 30% saturated fats
    }
}
