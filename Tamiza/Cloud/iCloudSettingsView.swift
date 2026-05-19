//
//  iCloudSettingsView.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import CloudKit

struct iCloudSettingsView: View {
    @StateObject private var iCloudManager = iCloudManager()
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingClearDataAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingConflictResolution = false
    
    var body: some View {
        NavigationView {
            List {
                // Status Section
                Section("iCloud Status") {
                    HStack {
                        Image(systemName: iCloudManager.statusIcon)
                            .foregroundColor(iCloudManager.statusColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("iCloud Sync")
                                .font(.headline)
                                .foregroundColor(DesignSystem.primaryText)
                            
                            Text(iCloudManager.syncStatus.displayText)
                                .font(.subheadline)
                                .foregroundColor(DesignSystem.secondaryText)
                        }
                        
                        Spacer()
                        
                        if case .syncing = iCloudManager.syncStatus {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if let lastSync = iCloudManager.lastSyncDate {
                        HStack {
                            Text("Last Sync")
                                .foregroundColor(DesignSystem.secondaryText)
                            
                            Spacer()
                            
                            Text(lastSync, style: .relative)
                                .font(.caption)
                                .foregroundColor(DesignSystem.secondaryText)
                        }
                    }
                }
                
                if iCloudManager.syncStatus.isAvailable {
                    // Sync Settings Section
                    Section("Sync Settings") {
                        Toggle("Automatic Sync", isOn: Binding(
                            get: { iCloudManager.isAutoSyncEnabled },
                            set: { enabled in
                                if enabled {
                                    iCloudManager.enableAutomaticSync()
                                } else {
                                    iCloudManager.disableAutomaticSync()
                                }
                            }
                        ))
                        .tint(DesignSystem.primaryGreen)
                        
                        if iCloudManager.isAutoSyncEnabled {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(DesignSystem.accentBlue)
                                
                                Text("Your meals will be automatically synced to iCloud when you add them.")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.secondaryText)
                            }
                        }
                    }
                    
                    // Actions Section
                    Section("Actions") {
                        Button(action: {
                            performManualSync()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise.icloud")
                                    .foregroundColor(DesignSystem.primaryGreen)
                                
                                Text("Sync Now")
                                    .foregroundColor(DesignSystem.primaryText)
                                
                                Spacer()
                                
                                if case .syncing = iCloudManager.syncStatus {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                        }
                        .disabled(!iCloudManager.syncStatus.isAvailable)
                        
                        if !iCloudManager.syncConflicts.isEmpty {
                            Button(action: {
                                showingConflictResolution = true
                            }) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(DesignSystem.warningOrange)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Resolve Conflicts")
                                            .foregroundColor(DesignSystem.primaryText)
                                        
                                        Text("\(iCloudManager.syncConflicts.count) conflicts found")
                                            .font(.caption)
                                            .foregroundColor(DesignSystem.warningOrange)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(DesignSystem.secondaryText)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    
                    // Storage Section
                    Section("Storage") {
                        HStack {
                            Image(systemName: "icloud")
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Cloud Storage Used")
                                    .foregroundColor(DesignSystem.primaryText)
                                
                                Text(iCloudManager.cloudStorageUsage)
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.secondaryText)
                            }
                            
                            Spacer()
                        }
                        
                        Button(action: {
                            showingClearDataAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(DesignSystem.errorRed)
                                
                                Text("Clear Cloud Data")
                                    .foregroundColor(DesignSystem.errorRed)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Data Types Section
                    Section("Synced Data") {
                        DataSyncRow(
                            icon: "fork.knife",
                            title: "Meals",
                            description: "All logged meals and nutrition data",
                            isEnabled: true
                        )
                        
                        DataSyncRow(
                            icon: "calendar",
                            title: "Timestamps",
                            description: "When meals were consumed",
                            isEnabled: true
                        )
                        
                        DataSyncRow(
                            icon: "chart.bar",
                            title: "Nutrition Data",
                            description: "Calories, protein, fat, and carbs",
                            isEnabled: true
                        )
                    }
                } else {
                    // Setup Section
                    Section("Setup") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "icloud.slash")
                                    .foregroundColor(DesignSystem.errorRed)
                                    .font(.title2)
                                
                                Text("iCloud Not Available")
                                    .font(.headline)
                                    .foregroundColor(DesignSystem.primaryText)
                            }
                            
                            Text(iCloudSetupMessage)
                                .font(.subheadline)
                                .foregroundColor(DesignSystem.secondaryText)
                            
                            Button("Check Again") {
                                iCloudManager.checkiCloudStatus()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(DesignSystem.primaryGreen)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Help Section
                Section("Help") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About iCloud Sync")
                            .font(.headline)
                            .foregroundColor(DesignSystem.primaryText)
                        
                        Text("iCloud sync keeps your meal data synchronized across all your devices. Your data is encrypted and stored securely in your personal iCloud account.")
                            .font(.caption)
                            .foregroundColor(DesignSystem.secondaryText)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("iCloud Sync")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                iCloudManager.checkiCloudStatus()
            }
            .alert("Clear Cloud Data", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearCloudData()
                }
            } message: {
                Text("This will permanently delete all your meal data from iCloud. Data on your device will not be affected.")
            }
            .alert("Sync Error", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingConflictResolution) {
                ConflictResolutionView(conflicts: iCloudManager.syncConflicts)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var iCloudSetupMessage: String {
        switch iCloudManager.syncStatus {
        case .noAccount:
            return "Sign in to iCloud in Settings to sync your meal data across devices."
        case .restricted:
            return "iCloud access is restricted. Check your device restrictions in Settings."
        case .error(let error):
            return "iCloud error: \(error.localizedDescription)"
        default:
            return "iCloud is not available on this device."
        }
    }
    
    // MARK: - Actions
    
    private func performManualSync() {
        Task {
            do {
                // Get all items from SwiftData (this would need to be implemented)
                let items: [Item] = [] // Placeholder - would fetch from modelContext
                let result = try await iCloudManager.performFullSync(localItems: items)
                
                if result.hasConflicts {
                    await MainActor.run {
                        showingConflictResolution = true
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            }
        }
    }
    
    private func clearCloudData() {
        Task {
            do {
                try await iCloudManager.clearCloudData()
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct DataSyncRow: View {
    let icon: String
    let title: String
    let description: String
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(DesignSystem.primaryGreen)
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
            
            if isEnabled {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(DesignSystem.successGreen)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Conflict Resolution View

struct ConflictResolutionView: View {
    let conflicts: [SyncConflict]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Sync Conflicts") {
                    ForEach(Array(conflicts.enumerated()), id: \.offset) { index, conflict in
                        ConflictRow(conflict: conflict, index: index + 1)
                    }
                }
                
                Section("Resolution Options") {
                    Button("Keep Local Data") {
                        resolveAllConflicts(preferLocal: true)
                    }
                    .foregroundColor(DesignSystem.primaryGreen)
                    
                    Button("Keep Cloud Data") {
                        resolveAllConflicts(preferLocal: false)
                    }
                    .foregroundColor(DesignSystem.accentBlue)
                }
            }
            .navigationTitle("Resolve Conflicts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func resolveAllConflicts(preferLocal: Bool) {
        // Implementation would resolve conflicts based on preference
        print("Resolving \(conflicts.count) conflicts, prefer local: \(preferLocal)")
        dismiss()
    }
}

struct ConflictRow: View {
    let conflict: SyncConflict
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Conflict \(index)")
                    .font(.headline)
                    .foregroundColor(DesignSystem.primaryText)
                
                Spacer()
                
                Text(conflict.conflictType == .dataConflict ? "Data Mismatch" : "Timestamp Conflict")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(DesignSystem.warningOrange.opacity(0.2))
                    .foregroundColor(DesignSystem.warningOrange)
                    .cornerRadius(4)
            }
            
            Text(conflict.localItem.name)
                .font(.subheadline)
                .foregroundColor(DesignSystem.secondaryText)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Local")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.primaryGreen)
                    
                    Text("\(conflict.localItem.calories) kcal")
                        .font(.caption)
                        .foregroundColor(DesignSystem.secondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Cloud")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.accentBlue)
                    
                    Text("\(conflict.cloudRecord.calories) kcal")
                        .font(.caption)
                        .foregroundColor(DesignSystem.secondaryText)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    iCloudSettingsView()
}