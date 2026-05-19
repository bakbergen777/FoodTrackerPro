//
//  TodayView.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var showingAddMeal = false
    @State private var selectedMealType: MealType = .breakfast
    @State private var showingFoodSearch = false
    @State private var showingAICamera = false
    @State private var calorieBalance: CalorieBalance = .zero
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Daily Summary Card
                    DailySummaryCard(balance: calorieBalance)
                    
                    // Quick Add Section
                    QuickAddSection {
                        showingFoodSearch = true
                    } onAICamera: {
                        showingAICamera = true
                    }
                    
                    // Meals Section
                    MealsSection(
                        dayData: appModel.currentDayData,
                        onAddMeal: { mealType in
                            selectedMealType = mealType
                            showingAddMeal = true
                        },
                        onEditMeal: { meal in
                            // Handle meal editing
                        }
                    )
                }
                .padding()
            }
            .background(Color.backgroundGray)
            .greenNavigationBar(title: "tab.today")
            .refreshable {
                await loadTodayData()
            }
            .task {
                await loadTodayData()
            }
        }
        .sheet(isPresented: $showingAddMeal) {
            AddMealView(mealType: selectedMealType) { meal in
                Task {
                    await appModel.addMeal(meal)
                    await updateCalorieBalance()
                }
            }
        }
        .sheet(isPresented: $showingFoodSearch) {
            FoodSearchView { food, portion in
                // Handle food selection
                let meal = createQuickMeal(with: food, portion: portion)
                Task {
                    await appModel.addMeal(meal)
                    await updateCalorieBalance()
                }
            }
        }
        .sheet(isPresented: $showingAICamera) {
            AICameraView { results in
                // Handle AI recognition results
                if let result = results.first {
                    let foodData = result.estimatedNutrition.toFoodItemData(name: result.foodName)
                    let meal = createQuickMeal(with: foodData, portion: 100)
                    Task {
                        await appModel.addMeal(meal)
                        await updateCalorieBalance()
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadTodayData() async {
        await appModel.loadDayData(for: Date())
        await updateCalorieBalance()
    }
    
    private func updateCalorieBalance() async {
        calorieBalance = await appModel.calculateDailyBalance()
    }
    
    private func createQuickMeal(with food: FoodItemData, portion: Double) -> MealData {
        let mealType = determineMealType()
        var meal = MealData(type: mealType, timestamp: Date())
        
        // Adjust food data for portion size
        let adjustedFood = adjustFoodForPortion(food, portion: portion)
        meal.foodItems = [adjustedFood]
        
        return meal
    }
    
    private func determineMealType() -> MealType {
        let hour = Calendar.current.component(.hour, from: Date())
        
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
    
    private func adjustFoodForPortion(_ food: FoodItemData, portion: Double) -> FoodItemData {
        let multiplier = portion / food.servingSize
        
        return FoodItemData(
            name: food.name,
            brand: food.brand,
            calories: Int(Double(food.calories) * multiplier),
            protein: food.protein * multiplier,
            fat: food.fat * multiplier,
            carbs: food.carbs * multiplier,
            fiber: food.fiber * multiplier,
            sugar: food.sugar * multiplier,
            sodium: Int(Double(food.sodium) * multiplier),
            servingSize: portion,
            servingUnit: food.servingUnit
        )
    }
}

// MARK: - Daily Summary Card

struct DailySummaryCard: View {
    let balance: CalorieBalance
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("analytics.calorie_balance".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textGray)
                
                Spacer()
                
                Text(balance.isDeficit ? "analytics.deficit".localized : "analytics.surplus".localized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(balance.isDeficit ? Color.successGreen : Color.warningOrange)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            // Calorie Progress Ring
            ZStack {
                GreenProgressRing(progress: min(1.0, Double(balance.consumed) / balance.tdee))
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 2) {
                    Text("\(balance.consumed)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.textGray)
                    
                    Text("health.calories".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Balance Details
            HStack(spacing: 20) {
                BalanceItem(
                    title: "analytics.consumed".localized,
                    value: "\(balance.consumed)",
                    color: .primaryGreen
                )
                
                BalanceItem(
                    title: "analytics.burned".localized,
                    value: String(format: "%.0f", balance.burned),
                    color: .warningOrange
                )
                
                BalanceItem(
                    title: "health.tdee".localized,
                    value: String(format: "%.0f", balance.tdee),
                    color: .accentGreen
                )
            }
        }
        .whiteCard()
    }
}

struct BalanceItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quick Add Section

struct QuickAddSection: View {
    let onFoodSearch: () -> Void
    let onAICamera: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Quick Add")
                    .font(.headline)
                    .foregroundColor(.textGray)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button(action: onFoodSearch) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("food.search_placeholder".localized)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button(action: onAICamera) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("ai.take_photo".localized)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(GreenButtonStyle())
            }
        }
        .whiteCard()
    }
}

// MARK: - Meals Section

struct MealsSection: View {
    let dayData: DayData?
    let onAddMeal: (MealType) -> Void
    let onEditMeal: (MealData) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(MealType.allCases, id: \.self) { mealType in
                MealCard(
                    mealType: mealType,
                    meals: mealsForType(mealType),
                    onAddMeal: { onAddMeal(mealType) },
                    onEditMeal: onEditMeal
                )
            }
        }
    }
    
    private func mealsForType(_ type: MealType) -> [MealData] {
        return dayData?.meals.filter { $0.type == type } ?? []
    }
}

struct MealCard: View {
    let mealType: MealType
    let meals: [MealData]
    let onAddMeal: () -> Void
    let onEditMeal: (MealData) -> Void
    
    private var totalCalories: Int {
        meals.reduce(0) { $0 + $1.totalCalories }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: mealType.icon)
                        .foregroundColor(.primaryGreen)
                    
                    Text(mealType.localizedTitle)
                        .font(.headline)
                        .foregroundColor(.textGray)
                }
                
                Spacer()
                
                if totalCalories > 0 {
                    Text("\(totalCalories) kcal")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryGreen)
                }
                
                Button(action: onAddMeal) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.primaryGreen)
                        .font(.title2)
                }
            }
            
            if meals.isEmpty {
                Text("No items added")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(meals) { meal in
                        MealItemRow(meal: meal) {
                            onEditMeal(meal)
                        }
                    }
                }
            }
        }
        .whiteCard()
    }
}

struct MealItemRow: View {
    let meal: MealData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if meal.foodItems.count == 1, let food = meal.foodItems.first {
                        Text(food.name)
                            .font(.body)
                            .foregroundColor(.textGray)
                        
                        Text("\(Int(food.servingSize))\(food.servingUnit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(meal.foodItems.count) items")
                            .font(.body)
                            .foregroundColor(.textGray)
                        
                        Text("Mixed meal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(meal.totalCalories) kcal")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.textGray)
                    
                    Text(meal.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TodayView()
        .environmentObject(AppModel())
        .environmentObject(LocalizationManager.shared)
}