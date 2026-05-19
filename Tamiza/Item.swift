//
//  Item.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var name: String
    var calories: Int
    var protein: Double
    var fat: Double
    var carbs: Double
    
    init(timestamp: Date = Date(), name: String = "", calories: Int = 0, protein: Double = 0.0, fat: Double = 0.0, carbs: Double = 0.0) {
        self.timestamp = timestamp
        self.name = name
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
    }
    
    // Computed properties for convenience
    var totalMacros: Double {
        return protein + fat + carbs
    }
    
    var proteinCalories: Double {
        return protein * 4.0 // 4 calories per gram of protein
    }
    
    var fatCalories: Double {
        return fat * 9.0 // 9 calories per gram of fat
    }
    
    var carbCalories: Double {
        return carbs * 4.0 // 4 calories per gram of carbs
    }
    
    // Validation
    var isValid: Bool {
        return !name.isEmpty && calories > 0
    }
    
    // Formatted display strings
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var nutritionSummary: String {
        return "\(calories) kcal • P: \(String(format: "%.1f", protein))g • F: \(String(format: "%.1f", fat))g • C: \(String(format: "%.1f", carbs))g"
    }
}

// MARK: - Sample Data Extension
extension Item {
    static var sampleData: [Item] {
        return [
            Item(
                timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
                name: "Grilled Chicken Breast",
                calories: 231,
                protein: 43.5,
                fat: 5.0,
                carbs: 0.0
            ),
            Item(
                timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
                name: "Brown Rice",
                calories: 216,
                protein: 5.0,
                fat: 1.8,
                carbs: 45.0
            ),
            Item(
                timestamp: Date().addingTimeInterval(-10800), // 3 hours ago
                name: "Greek Yogurt",
                calories: 100,
                protein: 17.0,
                fat: 0.7,
                carbs: 6.0
            ),
            Item(
                timestamp: Date().addingTimeInterval(-14400), // 4 hours ago
                name: "Banana",
                calories: 105,
                protein: 1.3,
                fat: 0.4,
                carbs: 27.0
            ),
            Item(
                timestamp: Date().addingTimeInterval(-18000), // 5 hours ago
                name: "Almonds (28g)",
                calories: 164,
                protein: 6.0,
                fat: 14.0,
                carbs: 6.0
            )
        ]
    }
}