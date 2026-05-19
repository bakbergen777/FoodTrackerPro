//
//  CalendarView.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Calendar component would go here
                Text("Calendar View")
                    .font(.title)
                    .foregroundColor(.textGray)
                
                Text("Coming Soon")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundGray)
            .greenNavigationBar(title: "tab.calendar")
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(AppModel())
}