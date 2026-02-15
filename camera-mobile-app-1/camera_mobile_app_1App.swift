//
//  camera_mobile_app_1App.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import SwiftUI
import FirebaseCore

@main
struct camera_mobile_app_1App: App {
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var nutritionViewModel = NutritionViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if userViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(userViewModel)
                    .environmentObject(nutritionViewModel)
            } else {
                WelcomeView()
                    .environmentObject(userViewModel)
            }
        }
    }
}
