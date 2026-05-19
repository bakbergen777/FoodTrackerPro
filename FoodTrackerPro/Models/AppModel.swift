//
//  AppModel.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import Foundation

@MainActor
class AppModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedDate = Date()
    @Published var currentDayData: DayData?
    @Published var userProfile: UserProfileData?
    @Published var isFirstLaunch = true
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Managers
    private let healthManager = HealthManager()
    private let profileManager = UserProfileManager()
    private let foodDatabase = FoodDatabaseManager()
    private let iCloudManager = iCloudManager()
    
    // MARK: - Initialization
    
    init() {
        checkFirstLaunch()
        setupObservers()
    }
    
    // MARK: - App Lifecycle
    
    func initializeApp() async {
        isLoading = true
        
        do {
            // Load user profile
            await loadUserProfile()
            
            // Load today's data
            await loadDayData(for: selectedDate)
            
            // Request health permissions if profile exists
            if userProfile != nil {
                await healthManager.requestAuthorization()
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Profile Management
    
    func completeProfileSetup(_ profile: UserProfileData) async {
        isLoading = true
        
        do {
            // Save profile
            await profileManager.createUserProfile(profile)
            userProfile = profile
            isFirstLaunch = false
            
            // Save first launch flag
            UserDefaults.standard.set(false, forKey: "isFirstLaunch")
            
            // Request health permissions
            await healthManager.requestAuthorization()
            
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateUserProfile(_ profile: UserProfileData) async {
        isLoading = true
        
        do {
            await profileManager.updateUserProfile(profile)
            userProfile = profile
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Day Data Management
    
    func loadDayData(for date: Date) async {
        do {
            currentDayData = await iCloudManager.loadDayData(for: date)
            if currentDayData == nil {
                currentDayData = DayData(date: date)
            }
        } catch {
            errorMessage = "Failed to load day data: \(error.localizedDescription)"
            currentDayData = DayData(date: date)
        }
    }
    
    func saveDayData() async {
        guard let dayData = currentDayData else { return }
        
        do {
            await iCloudManager.saveDayData(dayData)
        } catch {
            errorMessage = "Failed to save day data: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Meal Management
    
    func addMeal(_ meal: MealData) async {
        guard var dayData = currentDayData else { return }
        
        dayData.meals.append(meal)
        currentDayData = dayData
        
        await saveDayData()
    }
    
    func updateMeal(_ meal: MealData) async {
        guard var dayData = currentDayData else { return }
        
        if let index = dayData.meals.firstIndex(where: { $0.id == meal.id }) {
            dayData.meals[index] = meal
            currentDayData = dayData
            await saveDayData()
        }
    }
    
    func deleteMeal(_ meal: MealData) async {
        guard var dayData = currentDayData else { return }
        
        dayData.meals.removeAll { $0.id == meal.id }
        currentDayData = dayData
        
        await saveDayData()
    }
    
    // MARK: - Calorie Balance Calculations
    
    func calculateDailyBalance() async -> CalorieBalance {
        guard let profile = userProfile,
              let dayData = currentDayData else {
            return CalorieBalance.zero
        }
        
        let activeEnergy = await healthManager.fetchActiveEnergy(for: selectedDate)
        let bmr = calculateBMR(for: profile)
        let tdee = calculateTDEE(for: profile)
        let consumed = dayData.totalCalories
        
        return CalorieBalance(
            consumed: consumed,
            burned: activeEnergy,
            bmr: bmr,
            tdee: tdee
        )
    }
    
    func calculateWeeklyData() async -> [DayAnalytics] {
        var weeklyData: [DayAnalytics] = []
        let calendar = Calendar.current
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: selectedDate) else { continue }
            
            let dayData = await iCloudManager.loadDayData(for: date) ?? DayData(date: date)
            let activeEnergy = await healthManager.fetchActiveEnergy(for: date)
            
            let analytics = DayAnalytics(
                date: date,
                consumed: dayData.totalCalories,
                burned: activeEnergy,
                protein: dayData.totalProtein,
                fat: dayData.totalFat,
                carbs: dayData.totalCarbs
            )
            
            weeklyData.append(analytics)
        }
        
        return weeklyData.reversed()
    }
    
    // MARK: - Health Calculations
    
    private func calculateBMR(for profile: UserProfileData) -> Double {
        // Mifflin-St Jeor Equation
        let baseBMR = (10.0 * profile.weight) + (6.25 * profile.height) - (5.0 * Double(profile.age))
        
        switch profile.gender {
        case .male:
            return baseBMR + 5.0
        case .female:
            return baseBMR - 161.0
        }
    }
    
    private func calculateTDEE(for profile: UserProfileData) -> Double {
        let bmr = calculateBMR(for: profile)
        let multiplier = profile.activityLevel.multiplier
        return bmr * multiplier
    }
    
    // MARK: - Private Methods
    
    private func checkFirstLaunch() {
        isFirstLaunch = !UserDefaults.standard.bool(forKey: "isFirstLaunch")
    }
    
    private func loadUserProfile() async {
        userProfile = await profileManager.loadUserProfile()
    }
    
    private func setupObservers() {
        // Set up date change observer
        NotificationCenter.default.addObserver(
            forName: .NSCalendarDayChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.loadDayData(for: Date())
            }
        }
    }
}

// MARK: - Supporting Data Types

struct DayData {
    let id = UUID()
    let date: Date
    var meals: [MealData] = []
    
    var totalCalories: Int {
        meals.reduce(0) { $0 + $1.totalCalories }
    }
    
    var totalProtein: Double {
        meals.reduce(0) { $0 + $1.totalProtein }
    }
    
    var totalFat: Double {
        meals.reduce(0) { $0 + $1.totalFat }
    }
    
    var totalCarbs: Double {
        meals.reduce(0) { $0 + $1.totalCarbs }
    }
}

struct MealData: Identifiable {
    let id = UUID()
    let type: MealType
    let timestamp: Date
    var foodItems: [FoodItemData] = []
    
    var totalCalories: Int {
        foodItems.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        foodItems.reduce(0) { $0 + $1.protein }
    }
    
    var totalFat: Double {
        foodItems.reduce(0) { $0 + $1.fat }
    }
    
    var totalCarbs: Double {
        foodItems.reduce(0) { $0 + $1.carbs }
    }
}

enum MealType: String, CaseIterable {
    case breakfast, lunch, dinner, snack
    
    var localizedTitle: String {
        switch self {
        case .breakfast: return "meal.breakfast".localized
        case .lunch: return "meal.lunch".localized
        case .dinner: return "meal.dinner".localized
        case .snack: return "meal.snack".localized
        }
    }
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "sunset.fill"
        case .snack: return "leaf.fill"
        }
    }
}

struct FoodItemData: Identifiable {
    let id = UUID()
    let name: String
    let brand: String?
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    let fiber: Double
    let sugar: Double
    let sodium: Int
    let servingSize: Double
    let servingUnit: String
}

struct CalorieBalance {
    let consumed: Int
    let burned: Double
    let bmr: Double
    let tdee: Double
    
    var netBalance: Double {
        return Double(consumed) - burned
    }
    
    var tdeeBalance: Double {
        return Double(consumed) - tdee
    }
    
    var isDeficit: Bool {
        return tdeeBalance < 0
    }
    
    static let zero = CalorieBalance(consumed: 0, burned: 0, bmr: 0, tdee: 0)
}

struct DayAnalytics {
    let date: Date
    let consumed: Int
    let burned: Double
    let protein: Double
    let fat: Double
    let carbs: Double
}

// MARK: - Extensions

extension ActivityLevel {
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
}