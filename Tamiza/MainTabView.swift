//
//  MainTabView.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            // Main Nutrition Tracking Tab
            ContentView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text(LocalizationKey.meals.localized)
                }
            
            // Analytics Dashboard Tab
            AnalyticsDashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text(LocalizationKey.analytics.localized)
                }
            
            // Settings/Profile Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text(LocalizationKey.profile.localized)
                }
        }
        .tint(DesignSystem.primaryGreen)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @State private var nutritionGoals = NutritionGoals.standard
    @State private var showingGoalEditor = false
    
    var body: some View {
        NavigationView {
            List {
                Section(LocalizationKey.nutritionGoals.localized) {
                    GoalRow(title: LocalizationKey.dailyCaloriesGoal.localized, value: "\(nutritionGoals.dailyCalories)", unit: LocalizationKey.kcal.localized)
                    GoalRow(title: LocalizationKey.proteinGoal.localized, value: String(format: "%.1f", nutritionGoals.dailyProtein), unit: LocalizationKey.grams.localized)
                    GoalRow(title: LocalizationKey.fatGoal.localized, value: String(format: "%.1f", nutritionGoals.dailyFat), unit: LocalizationKey.grams.localized)
                    GoalRow(title: LocalizationKey.carbsGoal.localized, value: String(format: "%.1f", nutritionGoals.dailyCarbs), unit: LocalizationKey.grams.localized)
                    
                    Button(LocalizationKey.editGoals.localized) {
                        showingGoalEditor = true
                    }
                    .foregroundColor(DesignSystem.primaryGreen)
                }
                
                Section(LocalizationKey.preferences.localized) {
                    NavigationLink(destination: LanguageSelectionView()) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(DesignSystem.accentBlue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizationKey.language.localized)
                                    .foregroundColor(DesignSystem.primaryText)
                                
                                Text(LocalizationManager.shared.currentLanguage.displayName)
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.secondaryText)
                            }
                        }
                    }
                    
                    NavigationLink(destination: PerformanceOptimizationView()) {
                        HStack {
                            Image(systemName: "speedometer")
                                .foregroundColor(DesignSystem.warningOrange)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizationKey.performanceOptimization.localized)
                                    .foregroundColor(DesignSystem.primaryText)
                                
                                Text("Optimize app performance and memory usage")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.secondaryText)
                            }
                        }
                    }
                }
                
                Section(LocalizationKey.healthFitness.localized) {
                    NavigationLink(destination: HealthKitSettingsView()) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizationKey.appleHealth.localized)
                                    .foregroundColor(DesignSystem.primaryText)
                                
                                Text(LocalizationKey.syncNutritionData.localized)
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.secondaryText)
                            }
                        }
                    }
                }
                
                Section(LocalizationKey.dataSync.localized) {
                    NavigationLink(destination: iCloudSettingsView()) {
                        HStack {
                            Image(systemName: "icloud.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizationKey.icloudSync.localized)
                                    .foregroundColor(DesignSystem.primaryText)
                                
                                Text(LocalizationKey.keepDataSynced.localized)
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.secondaryText)
                            }
                        }
                    }
                }
                
                Section(LocalizationKey.appInformation.localized) {
                    HStack {
                        Text(LocalizationKey.version.localized)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(DesignSystem.secondaryText)
                    }
                    
                    HStack {
                        Text(LocalizationKey.build.localized)
                        Spacer()
                        Text("2025.01.28")
                            .foregroundColor(DesignSystem.secondaryText)
                    }
                }
                
                Section(LocalizationKey.support.localized) {
                    Link(LocalizationKey.privacyPolicy.localized, destination: URL(string: "https://tamiza.app/privacy")!)
                    Link(LocalizationKey.termsOfService.localized, destination: URL(string: "https://tamiza.app/terms")!)
                    Link(LocalizationKey.contactSupport.localized, destination: URL(string: "mailto:support@tamiza.app")!)
                }
            }
            .navigationTitle(LocalizationKey.settings.localized)
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingGoalEditor) {
            GoalEditorView(goals: $nutritionGoals)
        }
    }
}

// MARK: - Goal Editor View

struct GoalEditorView: View {
    @Binding var goals: NutritionGoals
    @Environment(\.dismiss) private var dismiss
    
    @State private var caloriesText: String
    @State private var proteinText: String
    @State private var fatText: String
    @State private var carbsText: String
    
    init(goals: Binding<NutritionGoals>) {
        self._goals = goals
        self._caloriesText = State(initialValue: "\(goals.wrappedValue.dailyCalories)")
        self._proteinText = State(initialValue: String(format: "%.1f", goals.wrappedValue.dailyProtein))
        self._fatText = State(initialValue: String(format: "%.1f", goals.wrappedValue.dailyFat))
        self._carbsText = State(initialValue: String(format: "%.1f", goals.wrappedValue.dailyCarbs))
    }
    
    private var isFormValid: Bool {
        guard let calories = Int(caloriesText),
              let protein = Double(proteinText),
              let fat = Double(fatText),
              let carbs = Double(carbsText) else {
            return false
        }
        
        return calories > 0 && protein >= 0 && fat >= 0 && carbs >= 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(LocalizationKey.dailyNutritionGoals.localized) {
                    HStack {
                        Text(LocalizationKey.calories.localized)
                        Spacer()
                        TextField("2000", text: $caloriesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text(LocalizationKey.kcal.localized)
                            .foregroundColor(DesignSystem.secondaryText)
                    }
                    
                    HStack {
                        Text(LocalizationKey.protein.localized)
                        Spacer()
                        TextField("150.0", text: $proteinText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text(LocalizationKey.grams.localized)
                            .foregroundColor(DesignSystem.secondaryText)
                    }
                    
                    HStack {
                        Text(LocalizationKey.fat.localized)
                        Spacer()
                        TextField("65.0", text: $fatText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text(LocalizationKey.grams.localized)
                            .foregroundColor(DesignSystem.secondaryText)
                    }
                    
                    HStack {
                        Text(LocalizationKey.carbohydrates.localized)
                        Spacer()
                        TextField("250.0", text: $carbsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text(LocalizationKey.grams.localized)
                            .foregroundColor(DesignSystem.secondaryText)
                    }
                }
                
                Section {
                    Button(LocalizationKey.resetToDefaults.localized) {
                        let defaultGoals = NutritionGoals.standard
                        caloriesText = "\(defaultGoals.dailyCalories)"
                        proteinText = String(format: "%.1f", defaultGoals.dailyProtein)
                        fatText = String(format: "%.1f", defaultGoals.dailyFat)
                        carbsText = String(format: "%.1f", defaultGoals.dailyCarbs)
                    }
                    .foregroundColor(DesignSystem.warningOrange)
                }
            }
            .navigationTitle(LocalizationKey.editGoals.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizationKey.cancel.localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationKey.save.localized) {
                        saveGoals()
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private func saveGoals() {
        guard let calories = Int(caloriesText),
              let protein = Double(proteinText),
              let fat = Double(fatText),
              let carbs = Double(carbsText) else {
            return
        }
        
        goals = NutritionGoals(
            dailyCalories: calories,
            dailyProtein: protein,
            dailyFat: fat,
            dailyCarbs: carbs
        )
    }
}

// MARK: - Supporting Views

struct GoalRow: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(DesignSystem.primaryText)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(value)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.primaryGreen)
                
                Text(unit)
                    .foregroundColor(DesignSystem.secondaryText)
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Item.self, inMemory: true)
}