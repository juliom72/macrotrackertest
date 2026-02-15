//
//  NutritionViewModel.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import Foundation
import SwiftUI

@MainActor
class NutritionViewModel: ObservableObject {
    @Published var dailyNutritionRecords: [DailyNutrition] = []
    
    private let nutritionDefaultsKey = "dailyNutritionRecords"
    
    init() {
        loadNutritionData()
        // Ensure we have today's record
        ensureTodayRecord()
    }
    
    func addMeal(_ meal: Meal) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let index = dailyNutritionRecords.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            dailyNutritionRecords[index].meals.append(meal)
        } else {
            let todayRecord = DailyNutrition(date: today, meals: [meal])
            dailyNutritionRecords.append(todayRecord)
        }
        
        // Keep only last 7 days
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        dailyNutritionRecords = dailyNutritionRecords.filter { $0.date >= sevenDaysAgo }
        
        saveNutritionData()
    }
    
    func getTodayNutrition() -> DailyNutrition {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let todayRecord = dailyNutritionRecords.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            return todayRecord
        }
        
        return DailyNutrition(date: today, meals: [])
    }
    
    func getLast7DaysNutrition() -> [DailyNutrition] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var last7Days: [DailyNutrition] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dayStart = calendar.startOfDay(for: date)
                if let record = dailyNutritionRecords.first(where: { calendar.isDate($0.date, inSameDayAs: dayStart) }) {
                    last7Days.append(record)
                } else {
                    last7Days.append(DailyNutrition(date: dayStart, meals: []))
                }
            }
        }
        
        return last7Days.reversed() // Oldest to newest
    }
    
    private func ensureTodayRecord() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if !dailyNutritionRecords.contains(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            let todayRecord = DailyNutrition(date: today, meals: [])
            dailyNutritionRecords.append(todayRecord)
        }
    }
    
    private func saveNutritionData() {
        if let encoded = try? JSONEncoder().encode(dailyNutritionRecords) {
            UserDefaults.standard.set(encoded, forKey: nutritionDefaultsKey)
        }
    }
    
    private func loadNutritionData() {
        if let data = UserDefaults.standard.data(forKey: nutritionDefaultsKey),
           let records = try? JSONDecoder().decode([DailyNutrition].self, from: data) {
            dailyNutritionRecords = records
        }
    }
}
