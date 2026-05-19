//
//  BodyTrackingView.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

struct BodyTrackingView: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Body Tracking")
                    .font(.title)
                    .foregroundColor(.textGray)
                
                Text("Body measurements and progress tracking")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundGray)
            .greenNavigationBar(title: "tab.body_tracking")
        }
    }
}

#Preview {
    BodyTrackingView()
        .environmentObject(AppModel())
}