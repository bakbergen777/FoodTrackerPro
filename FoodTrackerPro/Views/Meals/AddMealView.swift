//
//  AddMealView.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

struct AddMealView: View {
    let mealType: MealType
    let onSave: (MealData) -> Void
    
    @State private var selectedFoods: [FoodItemData] = []
    @State private var showingFoodSearch = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                if selectedFoods.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: mealType.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.primaryGreen)
                        
                        Text("Add foods to your \(mealType.localizedTitle.lowercased())")
                            .font(.title2)
                            .foregroundColor(.textGray)
                            .multilineTextAlignment(.center)
                        
                        Button("meal.add_food".localized) {
                            showingFoodSearch = true
                        }
                        .buttonStyle(GreenButtonStyle())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(selectedFoods) { food in
                            FoodItemRow(food: food) {
                                // Handle food editing
                            }
                        }
                        .onDelete(perform: deleteFoods)
                    }
                }
            }
            .background(Color.backgroundGray)
            .navigationTitle(mealType.localizedTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("action.cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !selectedFoods.isEmpty {
                        Button("action.save".localized) {
                            saveMeal()
                        }
                    } else {
                        Button("meal.add_food".localized) {
                            showingFoodSearch = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingFoodSearch) {
            FoodSearchView { food, portion in
                let adjustedFood = adjustFoodForPortion(food, portion: portion)
                selectedFoods.append(adjustedFood)
            }
        }
    }
    
    private func deleteFoods(offsets: IndexSet) {
        selectedFoods.remove(atOffsets: offsets)
    }
    
    private func saveMeal() {
        var meal = MealData(type: mealType, timestamp: Date())
        meal.foodItems = selectedFoods
        onSave(meal)
        dismiss()
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

#Preview {
    AddMealView(mealType: .breakfast) { meal in
        print("Saved meal: \(meal)")
    }
}