//
//  DailyNutrition.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import Foundation

struct DailyNutrition: Codable, Identifiable {
    let id: UUID
    var date: Date
    var meals: [Meal]
    
    init(id: UUID = UUID(), date: Date, meals: [Meal] = []) {
        self.id = id
        self.date = date
        self.meals = meals
    }
    
    var totalCalories: Double {
        meals.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        meals.reduce(0) { $0 + $1.protein }
    }
    
    var totalCarbs: Double {
        meals.reduce(0) { $0 + $1.carbs }
    }
    
    var totalFats: Double {
        meals.reduce(0) { $0 + $1.fats }
    }
    
    var totalHealthyFats: Double {
        meals.reduce(0) { $0 + $1.healthyFats }
    }
    
    var totalSaturatedFats: Double {
        meals.reduce(0) { $0 + $1.saturatedFats }
    }
}
