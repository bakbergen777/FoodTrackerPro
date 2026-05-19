//
//  ProfileView.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Profile Settings")
                    .font(.title)
                    .foregroundColor(.textGray)
                
                Text("User profile and app settings")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundGray)
            .greenNavigationBar(title: "tab.profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppModel())
        .environmentObject(LocalizationManager.shared)
}