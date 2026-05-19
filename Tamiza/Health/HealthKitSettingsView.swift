//
//  HealthKitSettingsView.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import HealthKit

struct HealthKitSettingsView: View {
    @StateObject private var healthManager = HealthKitManager()
    @State private var showingPermissionAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // Status Section
                Section("HealthKit Status") {
                    HStack {
                        Image(systemName: healthStatusIcon)
                            .foregroundColor(healthStatusColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Apple Health")
                                .font(.headline)
                                .foregroundColor(DesignSystem.primaryText)
                            
                            Text(healthManager.authorizationStatusDescription)
                                .font(.subheadline)
                                .foregroundColor(DesignSystem.secondaryText)
                        }
                        
                        Spacer()
                        
                        if healthManager.authorizationStatus != .sharingAuthorized {
                            Button("Connect") {
                                requestHealthKitPermission()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(DesignSystem.primaryGreen)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                if healthManager.authorizationStatus == .sharingAuthorized {
                    // Sync Settings Section
                    Section("Sync Settings") {
                        Toggle("Auto Sync", isOn: Binding(
                            get: { healthManager.isAutoSyncEnabled },
                            set: { healthManager.isAutoSyncEnabled = $0 }
                        ))
                        .tint(DesignSystem.primaryGreen)
                        
                        if healthManager.isAutoSyncEnabled {
                            Picker("Sync Frequency", selection: Binding(
                                get: { healthManager.syncFrequency },
                                set: { healthManager.syncFrequency = $0 }
                            )) {
                                ForEach(SyncFrequency.allCases, id: \.self) { frequency in
                                    VStack(alignment: .leading) {
                                        Text(frequency.displayName)
                                        Text(frequency.description)
                                            .font(.caption)
                                            .foregroundColor(DesignSystem.secondaryText)
                                    }
                                    .tag(frequency)
                                }
                            }
                        }
                    }
                    
                    // Data Types Section
                    Section("Synced Data Types") {
                        DataTypeRow(
                            icon: "flame.fill",
                            title: "Calories",
                            description: "Energy consumed from food",
                            color: DesignSystem.primaryGreen
                        )
                        
                        DataTypeRow(
                            icon: "p.circle.fill",
                            title: "Protein",
                            description: "Protein intake in grams",
                            color: DesignSystem.accentBlue
                        )
                        
                        DataTypeRow(
                            icon: "f.circle.fill",
                            title: "Fat",
                            description: "Total fat intake in grams",
                            color: DesignSystem.warningOrange
                        )
                        
                        DataTypeRow(
                            icon: "c.circle.fill",
                            title: "Carbohydrates",
                            description: "Carb intake in grams",
                            color: DesignSystem.primaryGreen
                        )
                        
                        DataTypeRow(
                            icon: "leaf.fill",
                            title: "Fiber",
                            description: "Dietary fiber in grams",
                            color: DesignSystem.successGreen
                        )
                        
                        DataTypeRow(
                            icon: "cube.fill",
                            title: "Sugar",
                            description: "Sugar intake in grams",
                            color: DesignSystem.errorRed
                        )
                    }
                    
                    // Actions Section
                    Section("Actions") {
                        Button(action: {
                            performManualSync()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(DesignSystem.primaryGreen)
                                
                                Text("Sync Now")
                                    .foregroundColor(DesignSystem.primaryText)
                                
                                Spacer()
                                
                                if healthManager.isProcessing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                        }
                        .disabled(healthManager.isProcessing)
                        
                        Button(action: {
                            healthManager.openHealthApp()
                        }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                
                                Text("Open Health App")
                                    .foregroundColor(DesignSystem.primaryText)
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.right")
                                    .foregroundColor(DesignSystem.secondaryText)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    // Privacy Section
                    Section("Privacy & Data") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Data Privacy")
                                .font(.headline)
                                .foregroundColor(DesignSystem.primaryText)
                            
                            Text("Tamiza only writes nutrition data to HealthKit and does not read personal health information without your explicit permission. All data is stored securely on your device.")
                                .font(.caption)
                                .foregroundColor(DesignSystem.secondaryText)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Help Section
                Section("Help") {
                    Button(action: {
                        showingPermissionAlert = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(DesignSystem.accentBlue)
                            
                            Text("Why connect to HealthKit?")
                                .foregroundColor(DesignSystem.primaryText)
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Health Integration")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                healthManager.checkAuthorizationStatus()
            }
            .alert("HealthKit Benefits", isPresented: $showingPermissionAlert) {
                Button("OK") { }
            } message: {
                Text("Connecting to HealthKit allows Tamiza to:\n\n• Automatically sync your nutrition data\n• Provide a complete health picture\n• Work with other health apps\n• Back up your data securely")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var healthStatusIcon: String {
        switch healthManager.authorizationStatus {
        case .sharingAuthorized:
            return "checkmark.circle.fill"
        case .sharingDenied:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        @unknown default:
            return "exclamationmark.circle.fill"
        }
    }
    
    private var healthStatusColor: Color {
        switch healthManager.authorizationStatus {
        case .sharingAuthorized:
            return DesignSystem.successGreen
        case .sharingDenied:
            return DesignSystem.errorRed
        case .notDetermined:
            return DesignSystem.warningOrange
        @unknown default:
            return DesignSystem.secondaryText
        }
    }
    
    // MARK: - Actions
    
    private func requestHealthKitPermission() {
        Task {
            do {
                try await healthManager.requestAuthorization()
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            }
        }
    }
    
    private func performManualSync() {
        Task {
            await healthManager.performBackgroundSync()
        }
    }
}

// MARK: - Supporting Views

struct DataTypeRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.primaryText)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(DesignSystem.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(DesignSystem.successGreen)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - HealthKit Integration Extension

extension HealthKitSettingsView {
    
    // Helper to sync a specific meal to HealthKit
    func syncMealToHealthKit(_ item: Item) {
        guard healthManager.authorizationStatus == .sharingAuthorized else {
            return
        }
        
        Task {
            do {
                try await healthManager.syncMealToHealthKit(item)
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to sync meal to HealthKit: \(error.localizedDescription)"
                    showingErrorAlert = true
                }
            }
        }
    }
    
    // Helper to sync daily nutrition totals
    func syncDailyNutrition(_ items: [Item], for date: Date) {
        guard healthManager.authorizationStatus == .sharingAuthorized else {
            return
        }
        
        Task {
            do {
                try await healthManager.syncDailyNutritionToHealthKit(items, date: date)
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to sync daily nutrition: \(error.localizedDescription)"
                    showingErrorAlert = true
                }
            }
        }
    }
}

#Preview {
    HealthKitSettingsView()
}