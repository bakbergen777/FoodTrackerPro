//
//  FoodSearchView.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

struct FoodSearchView: View {
    let onFoodSelected: (FoodItemData, Double) -> Void
    
    @StateObject private var foodDatabase = FoodDatabaseManager()
    @State private var searchText = ""
    @State private var selectedPortion: Double = 100
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                SearchBar(text: $searchText, placeholder: "food.search_placeholder".localized)
                    .onChange(of: searchText) { _, newValue in
                        Task {
                            await foodDatabase.searchFoods(query: newValue)
                        }
                    }
                
                // Results list
                List {
                    if searchText.isEmpty {
                        if !foodDatabase.recentFoods.isEmpty {
                            Section("food.recent_foods".localized) {
                                ForEach(foodDatabase.recentFoods) { food in
                                    FoodItemRow(food: food) {
                                        onFoodSelected(food, selectedPortion)
                                        dismiss()
                                    }
                                }
                            }
                        }
                    } else {
                        Section("food.search_results".localized) {
                            ForEach(foodDatabase.searchResults) { food in
                                FoodItemRow(food: food) {
                                    onFoodSelected(food, selectedPortion)
                                    dismiss()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("action.cancel".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

struct FoodItemRow: View {
    let food: FoodItemData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.body)
                        .foregroundColor(.textGray)
                    
                    if let brand = food.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text("\(food.calories) kcal")
                    .font(.caption)
                    .foregroundColor(.primaryGreen)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    FoodSearchView { food, portion in
        print("Selected: \(food.name), \(portion)g")
    }
}