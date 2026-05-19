//
//  AnalyticsManager.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import Foundation
import SwiftData
import SwiftUI

/// Analytics manager for nutrition data insights
@Observable
class AnalyticsManager {
    
    // MARK: - Properties
    
    private var modelContext: ModelContext?
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    // MARK: - Daily Analytics
    
    /// Get daily nutrition summary for a specific date
    func getDailySummary(for date: Date) -> DailySummary {
        guard let context = modelContext else {
            return DailySummary.empty
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        let predicate = #Predicate<Item> { item in
            item.timestamp >= startOfDay && item.timestamp < endOfDay
        }
        
        let descriptor = FetchDescriptor<Item>(predicate: predicate)
        
        do {
            let items = try context.fetch(descriptor)
            return calculateDailySummary(from: items, date: date)
        } catch {
            print("Failed to fetch items for daily summary: \(error)")
            return DailySummary.empty
        }
    }
    
    /// Get weekly nutrition trends
    func getWeeklyTrends(for date: Date) -> WeeklyTrends {
        guard let context = modelContext else {
            return WeeklyTrends.empty
        }
        
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? date
        
        let predicate = #Predicate<Item> { item in
            item.timestamp >= weekStart && item.timestamp < weekEnd
        }
        
        let descriptor = FetchDescriptor<Item>(predicate: predicate)
        
        do {
            let items = try context.fetch(descriptor)
            return calculateWeeklyTrends(from: items, weekStart: weekStart)
        } catch {
            print("Failed to fetch items for weekly trends: \(error)")
            return WeeklyTrends.empty
        }
    }
    
    /// Get monthly nutrition overview
    func getMonthlyOverview(for date: Date) -> MonthlyOverview {
        guard let context = modelContext else {
            return MonthlyOverview.empty
        }
        
        let calendar = Calendar.current
        let monthStart = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? date
        
        let predicate = #Predicate<Item> { item in
            item.timestamp >= monthStart && item.timestamp < monthEnd
        }
        
        let descriptor = FetchDescriptor<Item>(predicate: predicate)
        
        do {
            let items = try context.fetch(descriptor)
            return calculateMonthlyOverview(from: items, monthStart: monthStart)
        } catch {
            print("Failed to fetch items for monthly overview: \(error)")
            return MonthlyOverview.empty
        }
    }
    
    // MARK: - Nutrition Goals
    
    /// Get nutrition goal progress for a specific date
    func getGoalProgress(for date: Date, goals: NutritionGoals) -> GoalProgress {
        let dailySummary = getDailySummary(for: date)
        
        return GoalProgress(
            caloriesProgress: min(1.0, Double(dailySummary.totalCalories) / Double(goals.dailyCalories)),
            proteinProgress: min(1.0, dailySummary.totalProtein / goals.dailyProtein),
            fatProgress: min(1.0, dailySummary.totalFat / goals.dailyFat),
            carbsProgress: min(1.0, dailySummary.totalCarbs / goals.dailyCarbs),
            goals: goals,
            actual: NutritionGoals(
                dailyCalories: dailySummary.totalCalories,
                dailyProtein: dailySummary.totalProtein,
                dailyFat: dailySummary.totalFat,
                dailyCarbs: dailySummary.totalCarbs
            )
        )
    }
    
    // MARK: - Food Insights
    
    /// Get most consumed foods
    func getMostConsumedFoods(limit: Int = 10) -> [FoodInsight] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<Item>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            let items = try context.fetch(descriptor)
            let foodCounts = Dictionary(grouping: items, by: { $0.name.lowercased() })
            
            return foodCounts.map { name, items in
                FoodInsight(
                    name: items.first?.name ?? name,
                    count: items.count,
                    totalCalories: items.reduce(0) { $0 + $1.calories },
                    averageCalories: items.isEmpty ? 0 : items.reduce(0) { $0 + $1.calories } / items.count,
                    lastConsumed: items.max(by: { $0.timestamp < $1.timestamp })?.timestamp ?? Date()
                )
            }
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { $0 }
        } catch {
            print("Failed to fetch food insights: \(error)")
            return []
        }
    }
    
    // MARK: - Private Calculation Methods
    
    private func calculateDailySummary(from items: [Item], date: Date) -> DailySummary {
        let totalCalories = items.reduce(0) { $0 + $1.calories }
        let totalProtein = items.reduce(0.0) { $0 + $1.protein }
        let totalFat = items.reduce(0.0) { $0 + $1.fat }
        let totalCarbs = items.reduce(0.0) { $0 + $1.carbs }
        
        let mealsByTime = Dictionary(grouping: items) { item in
            getMealTime(for: item.timestamp)
        }
        
        return DailySummary(
            date: date,
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalFat: totalFat,
            totalCarbs: totalCarbs,
            mealCount: items.count,
            breakfastItems: mealsByTime[.breakfast]?.count ?? 0,
            lunchItems: mealsByTime[.lunch]?.count ?? 0,
            dinnerItems: mealsByTime[.dinner]?.count ?? 0,
            snackItems: mealsByTime[.snack]?.count ?? 0,
            macroBalance: MacroBalance(
                proteinPercentage: totalProtein * 4 / max(1, Double(totalCalories)),
                fatPercentage: totalFat * 9 / max(1, Double(totalCalories)),
                carbsPercentage: totalCarbs * 4 / max(1, Double(totalCalories))
            )
        )
    }
    
    private func calculateWeeklyTrends(from items: [Item], weekStart: Date) -> WeeklyTrends {
        let calendar = Calendar.current
        var dailyData: [DailyData] = []
        
        for i in 0..<7 {
            let day = calendar.date(byAdding: .day, value: i, to: weekStart) ?? weekStart
            let dayItems = items.filter { calendar.isDate($0.timestamp, inSameDayAs: day) }
            
            dailyData.append(DailyData(
                date: day,
                calories: dayItems.reduce(0) { $0 + $1.calories },
                protein: dayItems.reduce(0.0) { $0 + $1.protein },
                fat: dayItems.reduce(0.0) { $0 + $1.fat },
                carbs: dayItems.reduce(0.0) { $0 + $1.carbs },
                mealCount: dayItems.count
            ))
        }
        
        let totalCalories = dailyData.reduce(0) { $0 + $1.calories }
        let averageCalories = totalCalories / max(1, dailyData.count)
        
        return WeeklyTrends(
            weekStart: weekStart,
            dailyData: dailyData,
            averageCalories: averageCalories,
            totalMeals: dailyData.reduce(0) { $0 + $1.mealCount },
            caloriesTrend: calculateTrend(dailyData.map { Double($0.calories) })
        )
    }
    
    private func calculateMonthlyOverview(from items: [Item], monthStart: Date) -> MonthlyOverview {
        let calendar = Calendar.current
        let monthRange = calendar.range(of: .day, in: .month, for: monthStart) ?? 1..<32
        var weeklyData: [WeeklyData] = []
        
        // Group by weeks
        let weekGroups = Dictionary(grouping: items) { item in
            calendar.component(.weekOfMonth, from: item.timestamp)
        }
        
        for week in 1...5 {
            let weekItems = weekGroups[week] ?? []
            if !weekItems.isEmpty {
                weeklyData.append(WeeklyData(
                    week: week,
                    calories: weekItems.reduce(0) { $0 + $1.calories },
                    protein: weekItems.reduce(0.0) { $0 + $1.protein },
                    fat: weekItems.reduce(0.0) { $0 + $1.fat },
                    carbs: weekItems.reduce(0.0) { $0 + $1.carbs },
                    mealCount: weekItems.count
                ))
            }
        }
        
        let totalCalories = items.reduce(0) { $0 + $1.calories }
        let daysInMonth = monthRange.count
        
        return MonthlyOverview(
            month: monthStart,
            weeklyData: weeklyData,
            totalCalories: totalCalories,
            averageDailyCalories: totalCalories / max(1, daysInMonth),
            totalMeals: items.count,
            mostActiveWeek: weeklyData.max(by: { $0.mealCount < $1.mealCount })?.week ?? 1
        )
    }
    
    private func getMealTime(for date: Date) -> MealTime {
        let hour = Calendar.current.component(.hour, from: date)
        
        switch hour {
        case 5..<11:
            return .breakfast
        case 11..<16:
            return .lunch
        case 16..<22:
            return .dinner
        default:
            return .snack
        }
    }
    
    private func calculateTrend(_ values: [Double]) -> TrendDirection {
        guard values.count >= 2 else { return .stable }
        
        let firstHalf = values.prefix(values.count / 2)
        let secondHalf = values.suffix(values.count / 2)
        
        let firstAverage = firstHalf.reduce(0, +) / Double(firstHalf.count)
        let secondAverage = secondHalf.reduce(0, +) / Double(secondHalf.count)
        
        let difference = secondAverage - firstAverage
        let threshold = firstAverage * 0.1 // 10% threshold
        
        if difference > threshold {
            return .increasing
        } else if difference < -threshold {
            return .decreasing
        } else {
            return .stable
        }
    }
}

// MARK: - Data Models

struct DailySummary {
    let date: Date
    let totalCalories: Int
    let totalProtein: Double
    let totalFat: Double
    let totalCarbs: Double
    let mealCount: Int
    let breakfastItems: Int
    let lunchItems: Int
    let dinnerItems: Int
    let snackItems: Int
    let macroBalance: MacroBalance
    
    static let empty = DailySummary(
        date: Date(),
        totalCalories: 0,
        totalProtein: 0,
        totalFat: 0,
        totalCarbs: 0,
        mealCount: 0,
        breakfastItems: 0,
        lunchItems: 0,
        dinnerItems: 0,
        snackItems: 0,
        macroBalance: MacroBalance(proteinPercentage: 0, fatPercentage: 0, carbsPercentage: 0)
    )
}

struct MacroBalance {
    let proteinPercentage: Double
    let fatPercentage: Double
    let carbsPercentage: Double
    
    var isBalanced: Bool {
        let proteinRange = 0.15...0.35
        let fatRange = 0.20...0.35
        let carbsRange = 0.45...0.65
        
        return proteinRange.contains(proteinPercentage) &&
               fatRange.contains(fatPercentage) &&
               carbsRange.contains(carbsPercentage)
    }
}

struct WeeklyTrends {
    let weekStart: Date
    let dailyData: [DailyData]
    let averageCalories: Int
    let totalMeals: Int
    let caloriesTrend: TrendDirection
    
    static let empty = WeeklyTrends(
        weekStart: Date(),
        dailyData: [],
        averageCalories: 0,
        totalMeals: 0,
        caloriesTrend: .stable
    )
}

struct DailyData {
    let date: Date
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    let mealCount: Int
}

struct MonthlyOverview {
    let month: Date
    let weeklyData: [WeeklyData]
    let totalCalories: Int
    let averageDailyCalories: Int
    let totalMeals: Int
    let mostActiveWeek: Int
    
    static let empty = MonthlyOverview(
        month: Date(),
        weeklyData: [],
        totalCalories: 0,
        averageDailyCalories: 0,
        totalMeals: 0,
        mostActiveWeek: 1
    )
}

struct WeeklyData {
    let week: Int
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    let mealCount: Int
}

struct GoalProgress {
    let caloriesProgress: Double
    let proteinProgress: Double
    let fatProgress: Double
    let carbsProgress: Double
    let goals: NutritionGoals
    let actual: NutritionGoals
    
    var overallProgress: Double {
        (caloriesProgress + proteinProgress + fatProgress + carbsProgress) / 4.0
    }
    
    var isOnTrack: Bool {
        overallProgress >= 0.8 && overallProgress <= 1.2
    }
}

struct NutritionGoals {
    let dailyCalories: Int
    let dailyProtein: Double
    let dailyFat: Double
    let dailyCarbs: Double
    
    static let standard = NutritionGoals(
        dailyCalories: 2000,
        dailyProtein: 150.0,
        dailyFat: 65.0,
        dailyCarbs: 250.0
    )
}

struct FoodInsight {
    let name: String
    let count: Int
    let totalCalories: Int
    let averageCalories: Int
    let lastConsumed: Date
}

enum MealTime: CaseIterable {
    case breakfast, lunch, dinner, snack
    
    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        }
    }
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "sunset.fill"
        case .snack: return "moon.stars.fill"
        }
    }
}

enum TrendDirection {
    case increasing, decreasing, stable
    
    var icon: String {
        switch self {
        case .increasing: return "arrow.up.right"
        case .decreasing: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    var color: Color {
        switch self {
        case .increasing: return .green
        case .decreasing: return .red
        case .stable: return .blue
        }
    }
}