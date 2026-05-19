//
//  Food101RecognitionManager.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import Foundation
import CoreML
import Vision
import UIKit
import SwiftUI

// MARK: - Food Recognition Models

struct FoodRecognitionResult {
    let identifier: String
    let displayName: String
    let confidence: Float
    let nutritionEstimate: NutritionEstimate?
    
    var confidencePercentage: Int {
        return Int(confidence * 100)
    }
    
    var isHighConfidence: Bool {
        return confidence >= 0.7
    }
}

struct NutritionEstimate {
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let fatPer100g: Double
    let carbsPer100g: Double
    let fiberPer100g: Double
    let sugarPer100g: Double
    let sodiumPer100g: Double
    
    init(calories: Double, protein: Double, fat: Double, carbs: Double, 
         fiber: Double = 0, sugar: Double = 0, sodium: Double = 0) {
        self.caloriesPer100g = calories
        self.proteinPer100g = protein
        self.fatPer100g = fat
        self.carbsPer100g = carbs
        self.fiberPer100g = fiber
        self.sugarPer100g = sugar
        self.sodiumPer100g = sodium
    }
}

// MARK: - Food Recognition Manager

@Observable
class Food101RecognitionManager: NSObject {
    
    // MARK: - Properties
    
    private var model: VNCoreMLModel?
    private var isModelLoaded = false
    
    @Published var isProcessing = false
    @Published var lastError: Error?
    @Published var recognitionResults: [FoodRecognitionResult] = []
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        loadModel()
    }
    
    // MARK: - Model Loading
    
    private func loadModel() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                // In a real implementation, you would load the actual Food-101 CoreML model
                // For this demo, we'll simulate the model loading
                self?.simulateModelLoading()
            } catch {
                DispatchQueue.main.async {
                    self?.lastError = error
                    print("Failed to load Food-101 model: \(error)")
                }
            }
        }
    }
    
    private func simulateModelLoading() {
        // Simulate model loading delay
        Thread.sleep(forTimeInterval: 1.0)
        
        DispatchQueue.main.async { [weak self] in
            self?.isModelLoaded = true
            print("Food-101 model loaded successfully (simulated)")
        }
    }
    
    // MARK: - Food Recognition
    
    func recognizeFood(in image: UIImage, completion: @escaping ([FoodRecognitionResult]) -> Void) {
        guard isModelLoaded else {
            completion([])
            return
        }
        
        isProcessing = true
        recognitionResults = []
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // In a real implementation, this would use the actual CoreML model
            let results = self?.simulateFoodRecognition(for: image) ?? []
            
            DispatchQueue.main.async {
                self?.isProcessing = false
                self?.recognitionResults = results
                completion(results)
            }
        }
    }
    
    private func simulateFoodRecognition(for image: UIImage) -> [FoodRecognitionResult] {
        // Simulate processing delay
        Thread.sleep(forTimeInterval: 2.0)
        
        // Return simulated results based on common foods
        let simulatedResults = [
            FoodRecognitionResult(
                identifier: "grilled_chicken",
                displayName: "Grilled Chicken",
                confidence: 0.89,
                nutritionEstimate: NutritionEstimate(calories: 231, protein: 43.5, fat: 5.0, carbs: 0.0)
            ),
            FoodRecognitionResult(
                identifier: "caesar_salad",
                displayName: "Caesar Salad",
                confidence: 0.76,
                nutritionEstimate: NutritionEstimate(calories: 158, protein: 8.4, fat: 13.2, carbs: 6.8, fiber: 3.2)
            ),
            FoodRecognitionResult(
                identifier: "apple",
                displayName: "Apple",
                confidence: 0.65,
                nutritionEstimate: NutritionEstimate(calories: 52, protein: 0.3, fat: 0.2, carbs: 13.8, fiber: 2.4, sugar: 10.4)
            )
        ]
        
        // Return top 3 results sorted by confidence
        return Array(simulatedResults.sorted { $0.confidence > $1.confidence }.prefix(3))
    }
    
    // MARK: - Real CoreML Implementation (Template)
    
    private func performRealFoodRecognition(for image: UIImage, completion: @escaping ([FoodRecognitionResult]) -> Void) {
        guard let model = model else {
            completion([])
            return
        }
        
        guard let ciImage = CIImage(image: image) else {
            completion([])
            return
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.lastError = error
                }
                completion([])
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                completion([])
                return
            }
            
            let foodResults = results.prefix(5).compactMap { observation -> FoodRecognitionResult? in
                let nutrition = self?.getNutritionEstimate(for: observation.identifier)
                return FoodRecognitionResult(
                    identifier: observation.identifier,
                    displayName: self?.formatFoodName(observation.identifier) ?? observation.identifier,
                    confidence: observation.confidence,
                    nutritionEstimate: nutrition
                )
            }
            
            completion(Array(foodResults))
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            DispatchQueue.main.async {
                self.lastError = error
            }
            completion([])
        }
    }
    
    // MARK: - Nutrition Database
    
    private func getNutritionEstimate(for foodIdentifier: String) -> NutritionEstimate? {
        // This would typically query a nutrition database
        // For now, we'll return estimates for common foods
        
        let nutritionDatabase: [String: NutritionEstimate] = [
            "apple": NutritionEstimate(calories: 52, protein: 0.3, fat: 0.2, carbs: 13.8, fiber: 2.4, sugar: 10.4),
            "banana": NutritionEstimate(calories: 89, protein: 1.1, fat: 0.3, carbs: 22.8, fiber: 2.6, sugar: 12.2),
            "orange": NutritionEstimate(calories: 47, protein: 0.9, fat: 0.1, carbs: 11.8, fiber: 2.4, sugar: 9.4),
            "grilled_chicken": NutritionEstimate(calories: 231, protein: 43.5, fat: 5.0, carbs: 0.0),
            "salmon": NutritionEstimate(calories: 206, protein: 22.1, fat: 12.4, carbs: 0.0),
            "broccoli": NutritionEstimate(calories: 34, protein: 2.8, fat: 0.4, carbs: 7.0, fiber: 2.6, sugar: 1.5),
            "brown_rice": NutritionEstimate(calories: 362, protein: 7.2, fat: 2.3, carbs: 72.9, fiber: 3.4),
            "caesar_salad": NutritionEstimate(calories: 158, protein: 8.4, fat: 13.2, carbs: 6.8, fiber: 3.2),
            "pizza": NutritionEstimate(calories: 266, protein: 11.0, fat: 10.4, carbs: 33.0, fiber: 2.3, sodium: 598),
            "hamburger": NutritionEstimate(calories: 295, protein: 17.0, fat: 14.0, carbs: 28.0, fiber: 2.0, sodium: 497)
        ]
        
        return nutritionDatabase[foodIdentifier.lowercased()]
    }
    
    private func formatFoodName(_ identifier: String) -> String {
        return identifier
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
    
    // MARK: - Batch Processing
    
    func recognizeMultipleFoods(in images: [UIImage], completion: @escaping ([String: [FoodRecognitionResult]]) -> Void) {
        guard isModelLoaded else {
            completion([:])
            return
        }
        
        isProcessing = true
        var results: [String: [FoodRecognitionResult]] = [:]
        let group = DispatchGroup()
        
        for (index, image) in images.enumerated() {
            group.enter()
            recognizeFood(in: image) { foodResults in
                results["image_\(index)"] = foodResults
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isProcessing = false
            completion(results)
        }
    }
    
    // MARK: - Confidence Filtering
    
    func getHighConfidenceResults(from results: [FoodRecognitionResult], minimumConfidence: Float = 0.7) -> [FoodRecognitionResult] {
        return results.filter { $0.confidence >= minimumConfidence }
    }
    
    func getBestResult(from results: [FoodRecognitionResult]) -> FoodRecognitionResult? {
        return results.max { $0.confidence < $1.confidence }
    }
    
    // MARK: - Utility Methods
    
    func clearResults() {
        recognitionResults = []
        lastError = nil
    }
    
    var modelStatus: String {
        if isProcessing {
            return "Processing..."
        } else if isModelLoaded {
            return "Ready"
        } else {
            return "Loading model..."
        }
    }
    
    // MARK: - Error Handling
    
    enum RecognitionError: LocalizedError {
        case modelNotLoaded
        case invalidImage
        case processingFailed
        case noResults
        
        var errorDescription: String? {
            switch self {
            case .modelNotLoaded:
                return "Food recognition model is not loaded"
            case .invalidImage:
                return "Invalid image provided"
            case .processingFailed:
                return "Failed to process image"
            case .noResults:
                return "No food items recognized in image"
            }
        }
    }
}

// MARK: - Extensions

extension Food101RecognitionManager {
    
    // Convert recognition result to Item for SwiftData
    func createItem(from result: FoodRecognitionResult, servingSize: Double = 100.0) -> Item {
        let item = Item()
        item.name = result.displayName
        item.timestamp = Date()
        
        if let nutrition = result.nutritionEstimate {
            let multiplier = servingSize / 100.0
            item.calories = Int(nutrition.caloriesPer100g * multiplier)
            item.protein = nutrition.proteinPer100g * multiplier
            item.fat = nutrition.fatPer100g * multiplier
            item.carbs = nutrition.carbsPer100g * multiplier
        }
        
        return item
    }
    
    // Batch create items
    func createItems(from results: [FoodRecognitionResult], servingSize: Double = 100.0) -> [Item] {
        return results.map { createItem(from: $0, servingSize: servingSize) }
    }
}

// MARK: - Sample Data for Testing

extension Food101RecognitionManager {
    
    static func createSampleResults() -> [FoodRecognitionResult] {
        return [
            FoodRecognitionResult(
                identifier: "grilled_chicken",
                displayName: "Grilled Chicken Breast",
                confidence: 0.92,
                nutritionEstimate: NutritionEstimate(calories: 231, protein: 43.5, fat: 5.0, carbs: 0.0)
            ),
            FoodRecognitionResult(
                identifier: "quinoa_salad",
                displayName: "Quinoa Salad",
                confidence: 0.84,
                nutritionEstimate: NutritionEstimate(calories: 172, protein: 6.1, fat: 2.8, carbs: 31.6, fiber: 3.6)
            ),
            FoodRecognitionResult(
                identifier: "avocado",
                displayName: "Avocado",
                confidence: 0.78,
                nutritionEstimate: NutritionEstimate(calories: 160, protein: 2.0, fat: 14.7, carbs: 8.5, fiber: 6.7)
            )
        ]
    }
}