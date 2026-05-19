//
//  ContentView.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var showingAddMeal = false
    @State private var selectedDate = Date()
    @State private var showingCalendar = false
    
    // Filter items for selected date
    private var todayItems: [Item] {
        let calendar = Calendar.current
        return items.filter { calendar.isDate($0.timestamp, inSameDayAs: selectedDate) }
    }
    
    // Calculate daily totals
    private var dailyTotals: (calories: Int, protein: Double, fat: Double, carbs: Double) {
        let calories = todayItems.reduce(0) { $0 + $1.calories }
        let protein = todayItems.reduce(0.0) { $0 + $1.protein }
        let fat = todayItems.reduce(0.0) { $0 + $1.fat }
        let carbs = todayItems.reduce(0.0) { $0 + $1.carbs }
        return (calories, protein, fat, carbs)
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar - Calendar or Date Selector
            VStack(spacing: 0) {
                // Header with date and calendar toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tamiza")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryGreen)
                        
                        Text(selectedDate, style: .date)
                            .font(.headline)
                            .foregroundColor(.textGray)
                    }
                    
                    Spacer()
                    
                    Button {
                        showingCalendar.toggle()
                    } label: {
                        Image(systemName: showingCalendar ? "list.bullet" : "calendar")
                            .font(.title2)
                            .foregroundColor(.primaryGreen)
                    }
                }
                .padding()
                .background(Color.primaryWhite)
                
                if showingCalendar {
                    // Calendar View
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(Color.primaryWhite)
                } else {
                    // Meal List
                    List {
                        // Daily Summary Section
                        Section {
                            DailySummaryRow(
                                calories: dailyTotals.calories,
                                protein: dailyTotals.protein,
                                fat: dailyTotals.fat,
                                carbs: dailyTotals.carbs
                            )
                        }
                        
                        // Meals Section
                        Section("Today's Meals") {
                            if todayItems.isEmpty {
                                Text("No meals logged today")
                                    .foregroundColor(.secondary)
                                    .italic()
                            } else {
                                ForEach(todayItems.sorted(by: { $0.timestamp > $1.timestamp })) { item in
                                    MealRow(item: item)
                                }
                                .onDelete(perform: deleteItems)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                
                Spacer()
            }
            .background(Color.backgroundGray)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddMeal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.primaryGreen)
                    }
                }
            }
        } detail: {
            // Detail View - Meal Details or Welcome
            if let selectedItem = todayItems.first {
                MealDetailView(item: selectedItem)
            } else {
                WelcomeView()
            }
        }
        .sheet(isPresented: $showingAddMeal) {
            AddMealView { newItem in
                addItem(newItem)
            }
        }
        .tint(.primaryGreen)
    }
    
    private func addItem(_ item: Item) {
        withAnimation {
            modelContext.insert(item)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let sortedItems = todayItems.sorted(by: { $0.timestamp > $1.timestamp })
            for index in offsets {
                modelContext.delete(sortedItems[index])
            }
        }
    }
}

// MARK: - Supporting Views

struct DailySummaryRow: View {
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Daily Total")
                    .font(.headline)
                    .foregroundColor(.textGray)
                
                Spacer()
                
                Text("\(calories) kcal")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryGreen)
            }
            
            HStack(spacing: 20) {
                MacroItem(title: "Protein", value: protein, unit: "g", color: .accentGreen)
                MacroItem(title: "Fat", value: fat, unit: "g", color: .warningOrange)
                MacroItem(title: "Carbs", value: carbs, unit: "g", color: .primaryGreen)
            }
        }
        .padding(.vertical, 8)
    }
}

struct MacroItem: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1f", value))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text("\(title) (\(unit))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MealRow: View {
    let item: Item
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.textGray)
                
                Text(item.formattedTimestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(item.calories) kcal")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryGreen)
                
                Text("P:\(String(format: "%.1f", item.protein)) F:\(String(format: "%.1f", item.fat)) C:\(String(format: "%.1f", item.carbs))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct MealDetailView: View {
    let item: Item
    
    var body: some View {
        VStack(spacing: 24) {
            // Meal Header
            VStack(spacing: 8) {
                Text(item.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textGray)
                
                Text(item.formattedTimestamp)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Nutrition Details
            VStack(spacing: 16) {
                NutritionDetailRow(title: "Calories", value: "\(item.calories)", unit: "kcal", color: .primaryGreen)
                NutritionDetailRow(title: "Protein", value: String(format: "%.1f", item.protein), unit: "g", color: .accentGreen)
                NutritionDetailRow(title: "Fat", value: String(format: "%.1f", item.fat), unit: "g", color: .warningOrange)
                NutritionDetailRow(title: "Carbohydrates", value: String(format: "%.1f", item.carbs), unit: "g", color: .primaryGreen)
            }
            .whiteCard()
            
            Spacer()
        }
        .padding()
        .background(Color.backgroundGray)
        .navigationTitle("Meal Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NutritionDetailRow: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.textGray)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 80))
                .foregroundColor(.primaryGreen)
            
            VStack(spacing: 8) {
                Text("Welcome to Tamiza")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textGray)
                
                Text("Track your meals and nutrition")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Text("Select a meal from the sidebar or add a new one to get started")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundGray)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}