//
//  AnalyticsView.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Analytics View")
                    .font(.title)
                    .foregroundColor(.textGray)
                
                Text("Charts and insights coming soon")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundGray)
            .greenNavigationBar(title: "tab.analytics")
        }
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(AppModel())
}