//
//  NutritionCharts.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import Charts

// MARK: - Daily Nutrition Chart

struct DailyNutritionChart: View {
    let dailySummary: DailySummary
    let goals: NutritionGoals
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Nutrition")
                .font(.headline)
                .foregroundColor(DesignSystem.primaryText)
            
            Chart {
                // Actual values
                BarMark(
                    x: .value("Nutrient", "Calories"),
                    y: .value("Amount", Double(dailySummary.totalCalories))
                )
                .foregroundStyle(DesignSystem.primaryGreen)
                .opacity(0.8)
                
                BarMark(
                    x: .value("Nutrient", "Protein"),
                    y: .value("Amount", dailySummary.totalProtein * 4) // Convert to calories
                )
                .foregroundStyle(DesignSystem.accentBlue)
                .opacity(0.8)
                
                BarMark(
                    x: .value("Nutrient", "Fat"),
                    y: .value("Amount", dailySummary.totalFat * 9) // Convert to calories
                )
                .foregroundStyle(DesignSystem.warningOrange)
                .opacity(0.8)
                
                BarMark(
                    x: .value("Nutrient", "Carbs"),
                    y: .value("Amount", dailySummary.totalCarbs * 4) // Convert to calories
                )
                .foregroundStyle(DesignSystem.errorRed)
                .opacity(0.8)
                
                // Goal lines
                RuleMark(y: .value("Goal", Double(goals.dailyCalories)))
                    .foregroundStyle(DesignSystem.secondaryText)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Double.self) {
                            Text("\(Int(intValue))")
                                .font(.caption)
                                .foregroundColor(DesignSystem.secondaryText)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let stringValue = value.as(String.self) {
                            Text(stringValue)
                                .font(.caption)
                                .foregroundColor(DesignSystem.secondaryText)
                        }
                    }
                }
            }
        }
        .padding()
        .background(DesignSystem.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Weekly Trends Chart

struct WeeklyTrendsChart: View {
    let weeklyTrends: WeeklyTrends
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Trends")
                    .font(.headline)
                    .foregroundColor(DesignSystem.primaryText)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: weeklyTrends.caloriesTrend.icon)
                        .foregroundColor(weeklyTrends.caloriesTrend.color)
                    Text("\(weeklyTrends.averageCalories) avg")
                        .font(.caption)
                        .foregroundColor(DesignSystem.secondaryText)
                }
            }
            
            Chart(weeklyTrends.dailyData, id: \.date) { dayData in
                LineMark(
                    x: .value("Day", dayData.date, unit: .day),
                    y: .value("Calories", dayData.calories)
                )
                .foregroundStyle(DesignSystem.primaryGreen)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                AreaMark(
                    x: .value("Day", dayData.date, unit: .day),
                    y: .value("Calories", dayData.calories)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignSystem.primaryGreen.opacity(0.3), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                PointMark(
                    x: .value("Day", dayData.date, unit: .day),
                    y: .value("Calories", dayData.calories)
                )
                .foregroundStyle(DesignSystem.primaryGreen)
                .symbolSize(50)
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.caption)
                                .foregroundColor(DesignSystem.secondaryText)
                        }
                    }
                }
            }
        }
        .padding()
        .background(DesignSystem.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Macro Balance Pie Chart

struct MacroBalancePieChart: View {
    let macroBalance: MacroBalance
    
    private var chartData: [MacroData] {
        [
            MacroData(name: "Protein", percentage: macroBalance.proteinPercentage, color: DesignSystem.accentBlue),
            MacroData(name: "Fat", percentage: macroBalance.fatPercentage, color: DesignSystem.warningOrange),
            MacroData(name: "Carbs", percentage: macroBalance.carbsPercentage, color: DesignSystem.primaryGreen)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Macro Balance")
                    .font(.headline)
                    .foregroundColor(DesignSystem.primaryText)
                
                Spacer()
                
                if macroBalance.isBalanced {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DesignSystem.successGreen)
                        Text("Balanced")
                            .font(.caption)
                            .foregroundColor(DesignSystem.successGreen)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(DesignSystem.warningOrange)
                        Text("Unbalanced")
                            .font(.caption)
                            .foregroundColor(DesignSystem.warningOrange)
                    }
                }
            }
            
            HStack(spacing: 20) {
                // Pie Chart
                Chart(chartData, id: \.name) { data in
                    SectorMark(
                        angle: .value("Percentage", data.percentage),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(data.color)
                    .opacity(0.8)
                }
                .frame(width: 120, height: 120)
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(chartData, id: \.name) { data in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(data.color)
                                .frame(width: 12, height: 12)
                            
                            Text(data.name)
                                .font(.caption)
                                .foregroundColor(DesignSystem.primaryText)
                            
                            Spacer()
                            
                            Text("\(Int(data.percentage * 100))%")
                                .font(.caption)
                                .foregroundColor(DesignSystem.secondaryText)
                        }
                    }
                }
            }
        }
        .padding()
        .background(DesignSystem.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Goal Progress Chart

struct GoalProgressChart: View {
    let goalProgress: GoalProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Goal Progress")
                    .font(.headline)
                    .foregroundColor(DesignSystem.primaryText)
                
                Spacer()
                
                Text("\(Int(goalProgress.overallProgress * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(goalProgress.isOnTrack ? DesignSystem.successGreen : DesignSystem.warningOrange)
            }
            
            VStack(spacing: 12) {
                GoalProgressBar(
                    title: "Calories",
                    progress: goalProgress.caloriesProgress,
                    actual: "\(goalProgress.actual.dailyCalories)",
                    goal: "\(goalProgress.goals.dailyCalories)",
                    color: DesignSystem.primaryGreen
                )
                
                GoalProgressBar(
                    title: "Protein",
                    progress: goalProgress.proteinProgress,
                    actual: String(format: "%.1fg", goalProgress.actual.dailyProtein),
                    goal: String(format: "%.1fg", goalProgress.goals.dailyProtein),
                    color: DesignSystem.accentBlue
                )
                
                GoalProgressBar(
                    title: "Fat",
                    progress: goalProgress.fatProgress,
                    actual: String(format: "%.1fg", goalProgress.actual.dailyFat),
                    goal: String(format: "%.1fg", goalProgress.goals.dailyFat),
                    color: DesignSystem.warningOrange
                )
                
                GoalProgressBar(
                    title: "Carbs",
                    progress: goalProgress.carbsProgress,
                    actual: String(format: "%.1fg", goalProgress.actual.dailyCarbs),
                    goal: String(format: "%.1fg", goalProgress.goals.dailyCarbs),
                    color: DesignSystem.errorRed
                )
            }
        }
        .padding()
        .background(DesignSystem.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Monthly Overview Chart

struct MonthlyOverviewChart: View {
    let monthlyOverview: MonthlyOverview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Overview")
                .font(.headline)
                .foregroundColor(DesignSystem.primaryText)
            
            Chart(monthlyOverview.weeklyData, id: \.week) { weekData in
                BarMark(
                    x: .value("Week", "Week \(weekData.week)"),
                    y: .value("Calories", weekData.calories)
                )
                .foregroundStyle(
                    weekData.week == monthlyOverview.mostActiveWeek ?
                    DesignSystem.primaryGreen : DesignSystem.primaryGreen.opacity(0.6)
                )
                .cornerRadius(4)
            }
            .frame(height: 160)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.caption)
                                .foregroundColor(DesignSystem.secondaryText)
                        }
                    }
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Calories")
                        .font(.caption)
                        .foregroundColor(DesignSystem.secondaryText)
                    Text("\(monthlyOverview.totalCalories)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.primaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Daily Average")
                        .font(.caption)
                        .foregroundColor(DesignSystem.secondaryText)
                    Text("\(monthlyOverview.averageDailyCalories)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.primaryText)
                }
            }
        }
        .padding()
        .background(DesignSystem.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct GoalProgressBar: View {
    let title: String
    let progress: Double
    let actual: String
    let goal: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(DesignSystem.primaryText)
                
                Spacer()
                
                Text("\(actual) / \(goal)")
                    .font(.caption)
                    .foregroundColor(DesignSystem.secondaryText)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(DesignSystem.surfaceBackground)
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * min(progress, 1.0), height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Data Models

struct MacroData {
    let name: String
    let percentage: Double
    let color: Color
}