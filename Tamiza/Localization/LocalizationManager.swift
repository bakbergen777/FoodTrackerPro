//
//  LocalizationManager.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import Foundation
import SwiftUI

// MARK: - Supported Languages

enum SupportedLanguage: String, CaseIterable {
    case english = "en"
    case russian = "ru"
    case kazakh = "kk"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        case .kazakh: return "Қазақша"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        }
    }
    
    var nativeName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        case .kazakh: return "Қазақша"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .russian: return "🇷🇺"
        case .kazakh: return "🇰🇿"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        }
    }
}

// MARK: - Localization Keys

enum LocalizationKey: String, CaseIterable {
    // App General
    case appName = "app.name"
    case cancel = "general.cancel"
    case save = "general.save"
    case delete = "general.delete"
    case edit = "general.edit"
    case done = "general.done"
    case ok = "general.ok"
    case yes = "general.yes"
    case no = "general.no"
    case loading = "general.loading"
    case error = "general.error"
    case success = "general.success"
    
    // Navigation
    case meals = "navigation.meals"
    case analytics = "navigation.analytics"
    case profile = "navigation.profile"
    case settings = "navigation.settings"
    
    // Meals
    case addMeal = "meals.add_meal"
    case mealName = "meals.meal_name"
    case enterMealName = "meals.enter_meal_name"
    case mealInformation = "meals.meal_information"
    case nutritionFacts = "meals.nutrition_facts"
    case calories = "nutrition.calories"
    case protein = "nutrition.protein"
    case fat = "nutrition.fat"
    case carbohydrates = "nutrition.carbohydrates"
    case fiber = "nutrition.fiber"
    case sugar = "nutrition.sugar"
    case sodium = "nutrition.sodium"
    case todaysMeals = "meals.todays_meals"
    case noMealsLogged = "meals.no_meals_logged"
    case dailyTotal = "meals.daily_total"
    case quickAdd = "meals.quick_add"
    
    // AI Recognition
    case aiRecognition = "ai.recognition"
    case scanFoodWithAI = "ai.scan_food"
    case aiRecognitionDescription = "ai.recognition_description"
    case foodRecognitionResults = "ai.recognition_results"
    case noFoodRecognized = "ai.no_food_recognized"
    case tryBetterLighting = "ai.try_better_lighting"
    case confidence = "ai.confidence"
    
    // Analytics
    case dailyNutrition = "analytics.daily_nutrition"
    case weeklyTrends = "analytics.weekly_trends"
    case monthlyOverview = "analytics.monthly_overview"
    case goalProgress = "analytics.goal_progress"
    case macroBalance = "analytics.macro_balance"
    case balanced = "analytics.balanced"
    case unbalanced = "analytics.unbalanced"
    case foodInsights = "analytics.food_insights"
    case totalCalories = "analytics.total_calories"
    case averageCalories = "analytics.average_calories"
    case mostActiveWeek = "analytics.most_active_week"
    
    // Health Integration
    case appleHealth = "health.apple_health"
    case healthIntegration = "health.integration"
    case healthKitStatus = "health.kit_status"
    case autoSync = "health.auto_sync"
    case syncFrequency = "health.sync_frequency"
    case syncNow = "health.sync_now"
    case openHealthApp = "health.open_health_app"
    case dataPrivacy = "health.data_privacy"
    case privacyDescription = "health.privacy_description"
    
    // iCloud Sync
    case iCloudSync = "icloud.sync"
    case iCloudStatus = "icloud.status"
    case lastSync = "icloud.last_sync"
    case automaticSync = "icloud.automatic_sync"
    case syncConflicts = "icloud.sync_conflicts"
    case resolveConflicts = "icloud.resolve_conflicts"
    case clearCloudData = "icloud.clear_cloud_data"
    case cloudStorageUsed = "icloud.storage_used"
    
    // Settings
    case nutritionGoals = "settings.nutrition_goals"
    case dailyCaloriesGoal = "settings.daily_calories_goal"
    case proteinGoal = "settings.protein_goal"
    case fatGoal = "settings.fat_goal"
    case carbsGoal = "settings.carbs_goal"
    case editGoals = "settings.edit_goals"
    case resetToDefaults = "settings.reset_to_defaults"
    case language = "settings.language"
    case appInformation = "settings.app_information"
    case version = "settings.version"
    case build = "settings.build"
    
    // Units
    case kcal = "units.kcal"
    case grams = "units.grams"
    case milligrams = "units.milligrams"
    case liters = "units.liters"
    case milliliters = "units.milliliters"
    case percentage = "units.percentage"
    
    // Time
    case today = "time.today"
    case yesterday = "time.yesterday"
    case thisWeek = "time.this_week"
    case thisMonth = "time.this_month"
    case breakfast = "time.breakfast"
    case lunch = "time.lunch"
    case dinner = "time.dinner"
    case snack = "time.snack"
    
    // Validation
    case fieldRequired = "validation.field_required"
    case invalidValue = "validation.invalid_value"
    case valueTooLow = "validation.value_too_low"
    case valueTooHigh = "validation.value_too_high"
    case nameCannotBeEmpty = "validation.name_cannot_be_empty"
    case caloriesMustBePositive = "validation.calories_must_be_positive"
    
    // Errors
    case networkError = "error.network"
    case syncError = "error.sync"
    case healthKitError = "error.healthkit"
    case cameraError = "error.camera"
    case permissionDenied = "error.permission_denied"
    case unknownError = "error.unknown"
    
    // Performance Optimization
    case performanceOptimization = "performance_optimization"
    case performanceMetrics = "performance_metrics"
    case memoryUsage = "memory_usage"
    case optimizingPerformance = "optimizing_performance"
    case lastOptimization = "last_optimization"
    case optimizationActions = "optimization_actions"
    case clearCache = "clear_cache"
    case clearCacheDescription = "clear_cache_description"
    case optimizeDatabase = "optimize_database"
    case optimizeDatabaseDescription = "optimize_database_description"
    case cleanupTempFiles = "cleanup_temp_files"
    case cleanupTempFilesDescription = "cleanup_temp_files_description"
    case advancedOptions = "advanced_options"
    case showAdvancedOptions = "show_advanced_options"
    case autoOptimization = "auto_optimization"
    case backgroundOptimization = "background_optimization"
    case optimizationFrequency = "optimization_frequency"
    case daily = "daily"
    case performanceHistory = "performance_history"
    case memoryUsageOverTime = "memory_usage_over_time"
    case performanceChartPlaceholder = "performance_chart_placeholder"
    case optimizeNow = "optimize_now"
    
    // Additional missing keys
    case preferences = "preferences"
    case selectLanguage = "select_language"
    case healthFitness = "health_fitness"
    case syncNutritionData = "sync_nutrition_data"
    case dataSync = "data_sync"
    case icloudSync = "icloud_sync"
    case keepDataSynced = "keep_data_synced"
    case support = "support"
    case privacyPolicy = "privacy_policy"
    case termsOfService = "terms_of_service"
    case contactSupport = "contact_support"
    case dailyNutritionGoals = "daily_nutrition_goals"
}

// MARK: - Localization Manager

@Observable
class LocalizationManager: ObservableObject {
    
    // MARK: - Properties
    
    static let shared = LocalizationManager()
    
    var currentLanguage: SupportedLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selected_language")
            loadLocalizedStrings()
        }
    }
    
    private var localizedStrings: [String: String] = [:]
    
    // MARK: - Initialization
    
    private init() {
        // Get saved language or use system default
        let savedLanguage = UserDefaults.standard.string(forKey: "selected_language")
        self.currentLanguage = SupportedLanguage(rawValue: savedLanguage ?? "en") ?? .english
        loadLocalizedStrings()
    }
    
    // MARK: - Localization Methods
    
    func localizedString(for key: LocalizationKey, comment: String = "") -> String {
        return localizedString(for: key.rawValue, comment: comment)
    }
    
    func localizedString(for key: String, comment: String = "") -> String {
        // First try to get from loaded strings
        if let localizedString = localizedStrings[key] {
            return localizedString
        }
        
        // Fallback to NSLocalizedString
        let bundle = getLanguageBundle()
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: comment)
        
        // If no localization found, return the key itself
        return localizedString != key ? localizedString : key
    }
    
    func localizedString(for key: LocalizationKey, arguments: CVarArg...) -> String {
        let format = localizedString(for: key)
        return String(format: format, arguments: arguments)
    }
    
    // MARK: - Private Methods
    
    private func loadLocalizedStrings() {
        guard let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: currentLanguage.rawValue),
              let data = NSData(contentsOfFile: path) else {
            print("Could not load localization file for \(currentLanguage.rawValue)")
            return
        }
        
        do {
            let plist = try PropertyListSerialization.propertyList(from: data as Data, options: [], format: nil)
            if let dictionary = plist as? [String: String] {
                localizedStrings = dictionary
            }
        } catch {
            print("Error loading localization file: \(error)")
        }
    }
    
    private func getLanguageBundle() -> Bundle {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }
    
    // MARK: - Utility Methods
    
    func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language
    }
    
    func getAvailableLanguages() -> [SupportedLanguage] {
        return SupportedLanguage.allCases.filter { language in
            Bundle.main.path(forResource: language.rawValue, ofType: "lproj") != nil
        }
    }
    
    func isRTL() -> Bool {
        let locale = Locale(identifier: currentLanguage.rawValue)
        return Locale.characterDirection(forLanguage: currentLanguage.rawValue) == .rightToLeft
    }
    
    // MARK: - Formatting Helpers
    
    func formatCalories(_ calories: Int) -> String {
        return "\(calories) \(localizedString(for: .kcal))"
    }
    
    func formatGrams(_ grams: Double) -> String {
        return String(format: "%.1f %@", grams, localizedString(for: .grams))
    }
    
    func formatMilligrams(_ milligrams: Double) -> String {
        return String(format: "%.0f %@", milligrams, localizedString(for: .milligrams))
    }
    
    func formatPercentage(_ percentage: Double) -> String {
        return String(format: "%.0f%@", percentage * 100, localizedString(for: .percentage))
    }
    
    func formatNutritionSummary(calories: Int, protein: Double, fat: Double, carbs: Double) -> String {
        let caloriesStr = formatCalories(calories)
        let proteinStr = "\(localizedString(for: .protein)): \(formatGrams(protein))"
        let fatStr = "\(localizedString(for: .fat)): \(formatGrams(fat))"
        let carbsStr = "\(localizedString(for: .carbohydrates)): \(formatGrams(carbs))"
        
        return "\(caloriesStr), \(proteinStr), \(fatStr), \(carbsStr)"
    }
}

// MARK: - SwiftUI Integration

extension String {
    func localized(comment: String = "") -> String {
        return LocalizationManager.shared.localizedString(for: self, comment: comment)
    }
}

extension LocalizationKey {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    func localized(arguments: CVarArg...) -> String {
        return LocalizationManager.shared.localizedString(for: self, arguments: arguments)
    }
}

// MARK: - View Modifier

struct LocalizedView: ViewModifier {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, localizationManager.isRTL() ? .rightToLeft : .leftToRight)
    }
}

extension View {
    func localized() -> some View {
        modifier(LocalizedView())
    }
}

// MARK: - Language Selection View

struct LanguageSelectionView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(SupportedLanguage.allCases, id: \.self) { language in
                    Button(action: {
                        localizationManager.setLanguage(language)
                        dismiss()
                    }) {
                        HStack {
                            Text(language.flag)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(language.displayName)
                                    .foregroundColor(DesignSystem.primaryText)
                                    .fontWeight(.medium)
                                
                                Text(language.nativeName)
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.secondaryText)
                            }
                            
                            Spacer()
                            
                            if language == localizationManager.currentLanguage {
                                Image(systemName: "checkmark")
                                    .foregroundColor(DesignSystem.primaryGreen)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle(LocalizationKey.language.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationKey.done.localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LanguageSelectionView()
}