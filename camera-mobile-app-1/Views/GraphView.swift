//
//  GraphView.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import SwiftUI
import Charts

struct GraphView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var nutritionViewModel: NutritionViewModel
    @State private var selectedMetric: NutritionMetric = .calories
    
    enum NutritionMetric: String, CaseIterable {
        case calories = "Calories"
        case protein = "Protein"
        case carbs = "Carbs"
        case fats = "Fats"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let user = userViewModel.currentUser {
                        // Metric Selector
                        Picker("Metric", selection: $selectedMetric) {
                            ForEach(NutritionMetric.allCases, id: \.self) { metric in
                                Text(metric.rawValue).tag(metric)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        
                        // Chart
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Last 7 Days")
                                .font(.title2.bold())
                                .padding(.horizontal)
                            
                            chartView(user: user)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }
                        
                        // Daily Breakdown
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Daily Breakdown")
                                .font(.title2.bold())
                                .padding(.horizontal)
                            
                            ForEach(nutritionViewModel.getLast7DaysNutrition().enumerated().map { index, nutrition in
                                (day: index, nutrition: nutrition, date: nutrition.date)
                            }, id: \.day) { item in
                                DailyBreakdownCard(
                                    date: item.date,
                                    nutrition: item.nutrition,
                                    user: user,
                                    metric: selectedMetric
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("7-Day Progress")
        }
    }
    
    private func getValue(for nutrition: DailyNutrition, metric: NutritionMetric) -> Double {
        switch metric {
        case .calories:
            return nutrition.totalCalories
        case .protein:
            return nutrition.totalProtein
        case .carbs:
            return nutrition.totalCarbs
        case .fats:
            return nutrition.totalFats
        }
    }
    
    private func getGoal(for user: User, metric: NutritionMetric) -> Double {
        switch metric {
        case .calories:
            return user.dailyCalorieGoal
        case .protein:
            return user.proteinGoal
        case .carbs:
            return user.carbGoal
        case .fats:
            return user.fatGoal
        }
    }
    
    @ViewBuilder
    private func chartView(user: User) -> some View {
        let last7Days = nutritionViewModel.getLast7DaysNutrition()
        let goalValue = getGoal(for: user, metric: selectedMetric)
        let lineGradient = LinearGradient(
            colors: [.green, .blue],
            startPoint: .leading,
            endPoint: .trailing
        )
        let areaGradient = LinearGradient(
            colors: [.green.opacity(0.3), .blue.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
        
        Chart {
            ForEach(last7Days, id: \.id) { nutrition in
                let value = getValue(for: nutrition, metric: selectedMetric)
                
                LineMark(
                    x: .value("Day", nutrition.date, unit: .day),
                    y: .value("Value", value)
                )
                .foregroundStyle(lineGradient)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                AreaMark(
                    x: .value("Day", nutrition.date, unit: .day),
                    y: .value("Value", value)
                )
                .foregroundStyle(areaGradient)
            }
            
            RuleMark(y: .value("Goal", goalValue))
                .foregroundStyle(.orange)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
        }
        .frame(height: 300)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
    }
}

struct DailyBreakdownCard: View {
    let date: Date
    let nutrition: DailyNutrition
    let user: User
    let metric: GraphView.NutritionMetric
    
    private var dateString: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
    
    private var currentValue: Double {
        switch metric {
        case .calories:
            return nutrition.totalCalories
        case .protein:
            return nutrition.totalProtein
        case .carbs:
            return nutrition.totalCarbs
        case .fats:
            return nutrition.totalFats
        }
    }
    
    private var goalValue: Double {
        switch metric {
        case .calories:
            return user.dailyCalorieGoal
        case .protein:
            return user.proteinGoal
        case .carbs:
            return user.carbGoal
        case .fats:
            return user.fatGoal
        }
    }
    
    private var unit: String {
        switch metric {
        case .calories:
            return "kcal"
        default:
            return "g"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dateString)
                    .font(.headline)
                Spacer()
                Text("\(Int(currentValue))/\(Int(goalValue)) \(unit)")
                    .font(.subheadline.bold())
                    .foregroundColor(currentValue >= goalValue ? .green : .secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(currentValue >= goalValue ? Color.green : Color.blue)
                        .frame(width: min(geometry.size.width * (currentValue / goalValue), geometry.size.width), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            if !nutrition.meals.isEmpty {
                Text("\(nutrition.meals.count) meal\(nutrition.meals.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    GraphView()
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
