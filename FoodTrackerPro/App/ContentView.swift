//
//  ContentView.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appModel = AppModel()
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        Group {
            if appModel.isFirstLaunch {
                ProfileSetupView()
                    .environmentObject(appModel)
                    .environmentObject(localizationManager)
            } else {
                MainTabView()
                    .environmentObject(appModel)
                    .environmentObject(localizationManager)
            }
        }
        .preferredColorScheme(.light) // Force light mode for white/green theme
        .tint(.primaryGreen)
        .task {
            await appModel.initializeApp()
        }
    }
}

#Preview {
    ContentView()
}