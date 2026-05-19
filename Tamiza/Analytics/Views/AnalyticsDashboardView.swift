//
//  AnalyticsDashboardView.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import SwiftData

struct AnalyticsDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var analyticsManager = AnalyticsManager()
    
    @State private var selectedDate = Date()
    @State private var selectedTimeframe: TimeFrame = .daily
    @State private var nutritionGoals = NutritionGoals.standard
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header with date picker and timeframe selector
                    headerSection
                    
                    // Main content based on selected timeframe
                    switch selectedTimeframe {
                    case .daily:
                        dailyAnalyticsSection
                    case .weekly:
                        weeklyAnalyticsSection
                    case .monthly:
                        monthlyAnalyticsSection
                    }
                    
                    // Food insights section
                    foodInsightsSection
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                analyticsManager.modelContext = modelContext
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Date Picker
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: selectedTimeframe == .monthly ? [.date] : [.date]
            )
            .datePickerStyle(.compact)
            .padding()
            .background(DesignSystem.cardBackground)
            .cornerRadius(12)
            
            // Timeframe Selector
            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                    Text(timeframe.displayName)
                        .tag(timeframe)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Daily Analytics Section
    
    private var dailyAnalyticsSection: some View {
        let dailySummary = analyticsManager.getDailySummary(for: selectedDate)
        let goalProgress = analyticsManager.getGoalProgress(for: selectedDate, goals: nutritionGoals)
        
        return VStack(spacing: 16) {
            // Daily summary cards
            dailySummaryCards(dailySummary)
            
            // Goal progress chart
            GoalProgressChart(goalProgress: goalProgress)
            
            // Daily nutrition chart
            DailyNutritionChart(dailySummary: dailySummary, goals: nutritionGoals)
            
            // Macro balance pie chart
            MacroBalancePieChart(macroBalance: dailySummary.macroBalance)
            
            // Meal distribution
            mealDistributionView(dailySummary)
        }
    }
    
    // MARK: - Weekly Analytics Section
    
    private var weeklyAnalyticsSection: some View {
        let weeklyTrends = analyticsManager.getWeeklyTrends(for: selectedDate)
        
        return VStack(spacing: 16) {
            // Weekly summary cards
            weeklySummaryCards(weeklyTrends)
            
            // Weekly trends chart
            WeeklyTrendsChart(weeklyTrends: weeklyTrends)
            
            // Weekly insights
            weeklyInsightsView(weeklyTrends)
        }
    }
    
    // MARK: - Monthly Analytics Section
    
    private var monthlyAnalyticsSection: some View {
        let monthlyOverview = analyticsManager.getMonthlyOverview(for: selectedDate)
        
        return VStack(spacing: 16) {
            // Monthly summary cards
            monthlySummaryCards(monthlyOverview)
            
            // Monthly overview chart
            MonthlyOverviewChart(monthlyOverview: monthlyOverview)
            
            // Monthly insights
            monthlyInsightsView(monthlyOverview)
        }
    }
    
    // MARK: - Food Insights Section
    
    private var foodInsightsSection: some View {
        let foodInsights = analyticsManager.getMostConsumedFoods()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Food Insights")
                .font(.headline)
                .foregroundColor(DesignSystem.primaryText)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(foodInsights.enumerated()), id: \.offset) { index, insight in
                    FoodInsightRow(insight: insight, rank: index + 1)
                }
            }
            .padding()
            .background(DesignSystem.cardBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Supporting Views
    
    private func dailySummaryCards(_ summary: DailySummary) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            SummaryCard(
                title: "Total Calories",
                value: "\(summary.totalCalories)",
                subtitle: "kcal",
                color: DesignSystem.primaryGreen,
                icon: "flame.fill"
            )
            
            SummaryCard(
                title: "Meals",
                value: "\(summary.mealCount)",
                subtitle: "today",
                color: DesignSystem.accentBlue,
                icon: "fork.knife"
            )
            
            SummaryCard(
                title: "Protein",
                value: String(format: "%.1f", summary.totalProtein),
                subtitle: "grams",
                color: DesignSystem.accentBlue,
                icon: "p.circle.fill"
            )
            
            SummaryCard(
                title: "Balance",
                value: summary.macroBalance.isBalanced ? "Good" : "Poor",
                subtitle: "macros",
                color: summary.macroBalance.isBalanced ? DesignSystem.successGreen : DesignSystem.warningOrange,
                icon: summary.macroBalance.isBalanced ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
            )
        }
    }
    
    private func weeklySummaryCards(_ trends: WeeklyTrends) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            SummaryCard(
                title: "Avg Calories",
                value: "\(trends.averageCalories)",
                subtitle: "per day",
                color: DesignSystem.primaryGreen,
                icon: "chart.line.uptrend.xyaxis"
            )
            
            SummaryCard(
                title: "Total Meals",
                value: "\(trends.totalMeals)",
                subtitle: "this week",
                color: DesignSystem.accentBlue,
                icon: "calendar.badge.plus"
            )
            
            SummaryCard(
                title: "Trend",
                value: trends.caloriesTrend == .increasing ? "Up" : trends.caloriesTrend == .decreasing ? "Down" : "Stable",
                subtitle: "calories",
                color: trends.caloriesTrend.color,
                icon: trends.caloriesTrend.icon
            )
            
            SummaryCard(
                title: "Consistency",
                value: trends.dailyData.filter { $0.mealCount > 0 }.count >= 5 ? "Good" : "Poor",
                subtitle: "tracking",
                color: trends.dailyData.filter { $0.mealCount > 0 }.count >= 5 ? DesignSystem.successGreen : DesignSystem.warningOrange,
                icon: "target"
            )
        }
    }
    
    private func monthlySummaryCards(_ overview: MonthlyOverview) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            SummaryCard(
                title: "Total Calories",
                value: "\(overview.totalCalories)",
                subtitle: "this month",
                color: DesignSystem.primaryGreen,
                icon: "sum"
            )
            
            SummaryCard(
                title: "Daily Average",
                value: "\(overview.averageDailyCalories)",
                subtitle: "calories",
                color: DesignSystem.accentBlue,
.fill"
            )
            
            SummaryCard(
                title: "Total Meals",
                value: "\(overview.totalMeals)",
                subtitle: "logged",
                color: DesignSystem.warningOrange,
                icon: "list.bullet"
            )
            
            SummaryCard(
                title: "Most Active",
                value: "Week \(overview.mostActiveWeek)",
                subtitle: "of month",
                color: DesignSystem.successGreen,
                icon: "star.fill"
            )
        }
    }
    
    private func mealDistributionView(_ summary: DailySummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Meal Distribution")
                .font(.headline)
                .foregroundColor(DesignSystem.primaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                MealTimeCard(
                    mealTime: .breakfast,
                    count: summary.breakfastItems,
                    color: DesignSystem.accentBlue
                )
                
                MealTimeCard(
                    mealTime: .lunch,
                    count: summary.lunchItems,
                    color: DesignSystem.primaryGreen
                )
                
                MealTimeCard(
                    mealTime: .dinner,
                    count: summary.dinnerItems,
                    color: DesignSystem.warningOrange
                )
                
                MealTimeCard(
                    mealTime: .snack,
                    count: summary.snackItems,
                    color: DesignSystem.errorRed
                )
            }
        }
        .padding()
        .background(DesignSystem.cardBackground)
        .cornerRadius(12)
    }
    
    private func weeklyInsightsView(_ trends: WeeklyTrends) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Insights")
                .font(.headline)
                .foregroundColor(DesignSystem.primaryText)
            
            VStack(alignment: .leading, spacing: 12) {
                InsightRow(
                    icon: "calendar.badge.checkmark",
                    title: "Active Days",
                    value: "\(trends.dailyData.filter { $0.mealCount > 0 }.count) of 7",
                    color: DesignSystem.successGreen
                )
                
                InsightRow(
                    icon: "arrow.up.arrow.down",
                    title: "Calorie Range",
                    value: "\(trends.dailyData.map { $0.calories }.min() ?? 0) - \(trends.dailyData.map { $0.calories }.max() ?? 0)",
                    color: DesignSystem.accentBlue
                )
                
                InsightRow(
                    icon: "target",
                    title: "Most Active Day",
                    value: trends.dailyData.max(by: { $0.mealCount < $1.mealCount })?.date.formatted(.dateTime.weekday(.wide)) ?? "None",
                    color: DesignSystem.primaryGreen
                )
            }
        }
        .padding()
        .background(DesignSystem.cardBackground)
        .cornerRadius(12)
    }
    
    private func monthlyInsightsView(_ overview: MonthlyOverview) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Insights")
                .font(.headline)
                .foregroundColor(DesignSystem.primaryText)
            
            VStack(alignment: .leading, spacing: 12) {
                InsightRow(
                    icon: "calendar.badge.plus",
                    title: "Active Weeks",
                    value: "\(overview.weeklyData.count) weeks",
                    color: DesignSystem.successGreen
                )
                
                InsightRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Peak Week",
                    value: "Week \(overview.mostActiveWeek)",
                    color: DesignSystem.primaryGreen
                )
                
                InsightRow(
                    icon: "sum",
                    title: "Monthly Goal",
                    value: overview.totalCalories >= 60000 ? "Achieved" : "In Progress",
                    color: overview.totalCalories >= 60000 ? DesignSystem.successGreen : DesignSystem.warningOrange
                )
            }
        }
        .padding()
        .background(DesignSystem.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.primaryText)
            
            Text(title)
                .font(.caption)
                .foregroundColor(DesignSystem.secondaryText)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(DesignSystem.secondaryText)
        }
        .padding()
        .background(DesignSystem.cardBackground)
        .cornerRadius(12)
    }
}

struct MealTimeCard: View {
    let mealTime: MealTime
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: mealTime.icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.primaryText)
            
            Text(mealTime.displayName)
                .font(.caption)
                .foregroundColor(DesignSystem.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(DesignSystem.surfaceBackground)
        .cornerRadius(8)
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.primaryText)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(DesignSystem.secondaryText)
            }
            
            Spacer()
        }
    }
}

struct FoodInsightRow: View {
    let insight: FoodInsight
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            Text("\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(rank <= 3 ? DesignSystem.primaryGreen : DesignSystem.secondaryText)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(insight.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.primaryText)
                
                Text("\(insight.count) times • \(insight.averageCalories) avg kcal")
                    .font(.caption)
                    .foregroundColor(DesignSystem.secondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(insight.totalCalories)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.primaryText)
                
                Text("total kcal")
                    .font(.caption2)
                    .foregroundColor(DesignSystem.secondaryText)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Enums

enum TimeFrame: CaseIterable {
    case daily, weekly, monthly
    
    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }
}
                icon: "chart.bar