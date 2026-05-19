//
//  PerformanceOptimizationView.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import Charts

struct PerformanceOptimizationView: View {
    @StateObject private var optimizer = PerformanceOptimizer.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingAdvancedOptions = false
    
    var body: some View {
        NavigationView {
            List {
                performanceMetricsSection
                optimizationActionsSection
                advancedOptionsSection
                performanceHistorySection
            }
            .navigationTitle(LocalizationKey.performanceOptimization.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizationKey.close.localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationKey.optimizeNow.localized) {
                        Task {
                            await optimizer.optimizeApp()
                        }
                    }
                    .disabled(optimizer.isOptimizing)
                }
            }
        }
    }
    
    private var performanceMetricsSection: some View {
        Section(LocalizationKey.performanceMetrics.localized) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizationKey.memoryUsage.localized)
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.primaryText)
                    
                    Text(String(format: "%.1f MB", optimizer.memoryUsage))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(memoryUsageColor)
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: min(optimizer.memoryUsage / 100.0, 1.0),
                    color: memoryUsageColor
                )
                .frame(width: 50, height: 50)
            }
            .padding(.vertical, 8)
            
            if optimizer.isOptimizing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    
                    Text(LocalizationKey.optimizingPerformance.localized)
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.secondaryText)
                }
                .padding(.vertical, 4)
            }
            
            if let lastOptimization = optimizer.lastOptimizationDate {
                HStack {
                    Text(LocalizationKey.lastOptimization.localized)
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.secondaryText)
                    
                    Spacer()
                    
                    Text(lastOptimization, style: .relative)
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.primaryText)
                }
            }
        }
    }
    
    private var optimizationActionsSection: some View {
        Section(LocalizationKey.optimizationActions.localized) {
            OptimizationActionRow(
                title: LocalizationKey.clearCache.localized,
                description: LocalizationKey.clearCacheDescription.localized,
                icon: "trash.fill",
                color: .orange
            ) {
                optimizer.clearCaches()
            }
            
            OptimizationActionRow(
                title: LocalizationKey.optimizeDatabase.localized,
                description: LocalizationKey.optimizeDatabaseDescription.localized,
                icon: "cylinder.fill",
                color: .blue
            ) {
                Task {
                    await optimizer.optimizeApp()
                }
            }
            
            OptimizationActionRow(
                title: LocalizationKey.cleanupTempFiles.localized,
                description: LocalizationKey.cleanupTempFilesDescription.localized,
                icon: "folder.fill.badge.minus",
                color: .red
            ) {
                Task {
                    await optimizer.optimizeApp()
                }
            }
        }
    }
    
    private var advancedOptionsSection: some View {
        Section(LocalizationKey.advancedOptions.localized) {
            DisclosureGroup(
                LocalizationKey.showAdvancedOptions.localized,
                isExpanded: $showingAdvancedOptions
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(LocalizationKey.autoOptimization.localized, isOn: .constant(true))
                        .disabled(true)
                    
                    Toggle(LocalizationKey.backgroundOptimization.localized, isOn: .constant(true))
                        .disabled(true)
                    
                    HStack {
                        Text(LocalizationKey.optimizationFrequency.localized)
                        Spacer()
                        Text(LocalizationKey.daily.localized)
                            .foregroundColor(DesignSystem.secondaryText)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    private var performanceHistorySection: some View {
        Section(LocalizationKey.performanceHistory.localized) {
            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizationKey.memoryUsageOverTime.localized)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                // Placeholder for performance chart
                RoundedRectangle(cornerRadius: 8)
                    .fill(DesignSystem.surfaceColor)
                    .frame(height: 120)
                    .overlay(
                        Text(LocalizationKey.performanceChartPlaceholder.localized)
                            .foregroundColor(DesignSystem.secondaryText)
                            .font(.caption)
                    )
            }
            .padding(.vertical, 8)
        }
    }
    
    private var memoryUsageColor: Color {
        switch optimizer.memoryUsage {
        case 0..<50:
            return DesignSystem.successGreen
        case 50..<80:
            return DesignSystem.warningOrange
        default:
            return DesignSystem.errorRed
        }
    }
}

struct OptimizationActionRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(DesignSystem.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(DesignSystem.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(DesignSystem.secondaryText)
                    .font(.caption)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    PerformanceOptimizationView()
}