//
//  MainTabView.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("tab.calendar".localized)
                }
                .tag(0)
            
            TodayView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("tab.today".localized)
                }
                .tag(1)
            
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("tab.analytics".localized)
                }
                .tag(2)
            
            BodyTrackingView()
                .tabItem {
                    Image(systemName: "figure.arms.open")
                    Text("tab.body_tracking".localized)
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("tab.profile".localized)
                }
                .tag(4)
        }
        .accentColor(.primaryGreen)
        .background(Color.backgroundGray)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            // Selected item color
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primaryGreen)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color.primaryGreen)
            ]
            
            // Normal item color
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppModel())
        .environmentObject(LocalizationManager.shared)
}