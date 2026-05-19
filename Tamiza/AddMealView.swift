//
//  AddMealView.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

struct AddMealView: View {
    let onSave: (Item) -> Void
    
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var fat = ""
    @State private var carbs = ""
    @State private var timestamp = Date()
    @State private var showingAICamera = false
    
    @Environment(\.dismiss) private var dismiss
    
    // Validation
    private var isFormValid: Bool {
        !name.isEmpty &&
        !calories.isEmpty &&
        !protein.isEmpty &&
        !fat.isEmpty &&
        !carbs.isEmpty &&
        Int(calories) != nil &&
        Double(protein) != nil &&
        Double(fat) != nil &&
        Double(carbs) != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Meal Information") {
                    HStack {
                        Text("Name")
                            .foregroundColor(.textGray)
                        Spacer()
                        TextField("Enter meal name", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Time", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                        .foregroundColor(.textGray)
                }
                
                Section("Nutrition Facts") {
                    HStack {
                        Label("Calories", systemImage: "flame.fill")
                            .foregroundColor(.primaryGreen)
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("kcal")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Protein", systemImage: "p.circle.fill")
                            .foregroundColor(.accentGreen)
                        Spacer()
                        TextField("0.0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Fat", systemImage: "f.circle.fill")
                            .foregroundColor(.warningOrange)
                        Spacer()
                        TextField("0.0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Carbs", systemImage: "c.circle.fill")
                            .foregroundColor(.primaryGreen)
                        Spacer()
                        TextField("0.0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                }
                
                if isFormValid {
                    Section("Preview") {
                        NutritionPreview(
                            calories: Int(calories) ?? 0,
                            protein: Double(protein) ?? 0.0,
                            fat: Double(fat) ?? 0.0,
                            carbs: Double(carbs) ?? 0.0
                        )
                    }
                }
                
                Section("AI Recognition") {
                    Button(action: {
                        showingAICamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(DesignSystem.primaryGreen)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Scan Food with AI")
                                    .foregroundColor(DesignSystem.primaryText)
                                    .fontWeight(.medium)
                                
                                Text("Use your camera to identify food automatically")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.secondaryText)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(DesignSystem.secondaryText)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Section("Quick Add") {
                    QuickAddButtons(
                        onQuickAdd: { quickMeal in
                            name = quickMeal.name
                            calories = String(quickMeal.calories)
                            protein = String(format: "%.1f", quickMeal.protein)
                            fat = String(format: "%.1f", quickMeal.fat)
                            carbs = String(format: "%.1f", quickMeal.carbs)
                        }
                    )
                }
            }
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMeal()
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.semibold)
                }
            }
            .tint(.primaryGreen)
            .sheet(isPresented: $showingAICamera) {
                AICameraView()
            }
        }
    }
    
    private func saveMeal() {
        guard isFormValid,
              let caloriesInt = Int(calories),
              let proteinDouble = Double(protein),
              let fatDouble = Double(fat),
              let carbsDouble = Double(carbs) else {
            return
        }
        
        let newItem = Item(
            timestamp: timestamp,
            name: name,
            calories: caloriesInt,
            protein: proteinDouble,
            fat: fatDouble,
            carbs: carbsDouble
        )
        
        onSave(newItem)
        dismiss()
    }
}

// MARK: - Supporting Views

struct NutritionPreview: View {
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    
    private var calculatedCalories: Int {
        Int((protein * 4) + (fat * 9) + (carbs * 4))
    }
    
    private var caloriesDifference: Int {
        calories - calculatedCalories
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Nutrition Summary")
                    .font(.headline)
                    .foregroundColor(.textGray)
                Spacer()
            }
            
            HStack(spacing: 20) {
                MacroPreview(title: "Protein", value: protein, unit: "g", color: .accentGreen)
                MacroPreview(title: "Fat", value: fat, unit: "g", color: .warningOrange)
                MacroPreview(title: "Carbs", value: carbs, unit: "g", color: .primaryGreen)
            }
            
            if abs(caloriesDifference) > 10 {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.warningOrange)
                    
                    Text("Calculated calories: \(calculatedCalories) kcal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct MacroPreview: View {
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

struct QuickAddButtons: View {
    let onQuickAdd: (Item) -> Void
    
    private let quickMeals = [
        Item(name: "Apple", calories: 95, protein: 0.5, fat: 0.3, carbs: 25.0),
        Item(name: "Banana", calories: 105, protein: 1.3, fat: 0.4, carbs: 27.0),
        Item(name: "Greek Yogurt", calories: 100, protein: 17.0, fat: 0.7, carbs: 6.0),
        Item(name: "Chicken Breast (100g)", calories: 231, protein: 43.5, fat: 5.0, carbs: 0.0),
        Item(name: "Brown Rice (1 cup)", calories: 216, protein: 5.0, fat: 1.8, carbs: 45.0),
        Item(name: "Almonds (28g)", calories: 164, protein: 6.0, fat: 14.0, carbs: 6.0)
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            ForEach(quickMeals, id: \.name) { meal in
                Button {
                    onQuickAdd(meal)
                } label: {
                    VStack(spacing: 4) {
                        Text(meal.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.textGray)
                            .multilineTextAlignment(.center)
                        
                        Text("\(meal.calories) kcal")
                            .font(.caption2)
                            .foregroundColor(.primaryGreen)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.lightGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    AddMealView { item in
        print("Added meal: \(item.name)")
    }
}