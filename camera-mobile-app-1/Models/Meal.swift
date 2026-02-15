//
//  Meal.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import Foundation

struct Meal: Codable, Identifiable {
    let id: UUID
    var name: String
    var calories: Double
    var protein: Double // in grams
    var carbs: Double // in grams
    var fats: Double // in grams
    var healthyFats: Double // in grams
    var saturatedFats: Double // in grams
    var timestamp: Date
    var imageData: Data? // Optional: store captured image
    
    init(id: UUID = UUID(), name: String, calories: Double, protein: Double, carbs: Double, fats: Double, healthyFats: Double, saturatedFats: Double, timestamp: Date = Date(), imageData: Data? = nil) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.healthyFats = healthyFats
        self.saturatedFats = saturatedFats
        self.timestamp = timestamp
        self.imageData = imageData
    }
}
