//
//  MainTabView.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var nutritionViewModel: NutritionViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .environmentObject(userViewModel)
                .environmentObject(nutritionViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            GraphView()
                .environmentObject(userViewModel)
                .environmentObject(nutritionViewModel)
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
            
            // Camera Tab - Shows camera immediately
            CameraView()
                .environmentObject(nutritionViewModel)
                .tabItem {
                    Label("Camera", systemImage: "camera.fill")
                }
                .tag(2)
            
            ProfileView()
                .environmentObject(userViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView()
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
