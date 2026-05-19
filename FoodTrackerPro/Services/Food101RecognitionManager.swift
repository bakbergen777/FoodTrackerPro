//
//  Food101RecognitionManager.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import CoreML
import Vision
import UIKit

class Food101RecognitionManager: ObservableObject {
    @Published var recognitionResults: [Food101Result] = []
    @Published var isProcessing = false
    @Published var confidence: Double = 0.0
    
    private var food101Model: VNCoreMLModel?
    private let confidenceThreshold: Double = 0.3
    
    // Food-101 categories mapping
    private let food101Categories = [
        "apple_pie", "baby_back_ribs", "baklava", "beef_carpaccio", "beef_tartare",
        "beet_salad", "beignets", "bibimbap", "bread_pudding", "breakfast_burrito",
        "bruschetta", "caesar_salad", "cannoli", "caprese_salad", "carrot_cake",
        "ceviche", "cheese_plate", "cheesecake", "chicken_curry", "chicken_quesadilla",
        "chicken_wings", "chocolate_cake", "chocolate_mousse", "churros", "clam_chowder",
        "club_sandwich", "crab_cakes", "creme_brulee", "croque_madame", "cup_cakes",
        "deviled_eggs", "donuts", "dumplings", "edamame", "eggs_benedict",
        "escargots", "falafel", "filet_mignon", "fish_and_chips", "foie_gras",
        "french_fries", "french_onion_soup", "french_toast", "fried_calamari", "fried_rice",
        "frozen_yogurt", "garlic_bread", "gnocchi", "greek_salad", "grilled_cheese_sandwich",
        "grilled_salmon", "guacamole", "gyoza", "hamburger", "hot_and_sour_soup",
        "hot_dog", "huevos_rancheros", "hummus", "ice_cream", "lasagna",
        "lobster_bisque", "lobster_roll_sandwich", "macaroni_and_cheese", "macarons", "miso_soup",
        "mussels", "nachos", "omelette", "onion_rings", "oysters",
        "pad_thai", "paella", "pancakes", "panna_cotta", "peking_duck",
        "pho", "pizza", "pork_chop", "poutine", "prime_rib",
        "pulled_pork_sandwich", "ramen", "ravioli", "red_velvet_cake", "risotto",
        "samosa", "sashimi", "scallops", "seaweed_salad", "shrimp_and_grits",
        "spaghetti_bolognese", "spaghetti_carbonara", "spring_rolls", "steak", "strawberry_shortcake",
        "sushi", "tacos", "takoyaki", "tiramisu", "tuna_tartare", "waffles"
    ]
    
    init() {
        loadFood101Model()
    }
    
    // MARK: - Model Loading
    
    private func loadFood101Model() {
        guard let modelURL = Bundle.main.url(forResource: "Food101", withExtension: "mlmodelc") else {
            print("Food-101 model not found in bundle")
            return
        }
        
        do {
            let model = try MLModel(contentsOf: modelURL)
            food101Model = try VNCoreMLModel(for: model)
            print("Food-101 model loaded successfully")
        } catch {
            print("Error loading Food-101 model: \(error)")
        }
    }
    
    // MARK: - Food Recognition
    
    func recognizeFood(in image: UIImage) async -> [Food101Result] {
        guard let cgImage = image.cgImage,
              let model = food101Model else {
            return []
        }
        
        await MainActor.run {
            isProcessing = true
        }
        
        return await withCheckedContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                guard let self = self else {
                    continuation.resume(returning: [])
                    return
                }
                
                if let error = error {
                    print("Food-101 recognition error: \(error)")
                    continuation.resume(returning: [])
                    return
                }
                
                let results = self.processFood101Results(request.results)
                
                Task { @MainActor in
                    self.recognitionResults = results
                    self.isProcessing = false
                    self.confidence = results.first?.confidence ?? 0.0
                }
                
                continuation.resume(returning: results)
            }
            
            request.imageCropAndScaleOption = .centerCrop
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform Food-101 recognition: \(error)")
                continuation.resume(returning: [])
            }
        }
    }
    
    // MARK: - Results Processing
    
    private func processFood101Results(_ results: [VNObservation]?) -> [Food101Result] {
        guard let results = results as? [VNClassificationObservation] else { return [] }
        
        return results
            .filter { $0.confidence >= Float(confidenceThreshold) }
            .prefix(5)
            .map { observation in
                Food101Result(
                    foodName: formatFoodName(observation.identifier),
                    originalIdentifier: observation.identifier,
                    confidence: Double(observation.confidence),
                    category: categorizeFoodName(observation.identifier),
                    estimatedNutrition: estimateNutrition(for: observation.identifier)
                )
            }
    }
    
    private func formatFoodName(_ identifier: String) -> String {
        // Convert "chicken_curry" to "Chicken Curry"
        return identifier
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
    
    private func categorizeFoodName(_ identifier: String) -> String {
        let desserts = ["apple_pie", "baklava", "bread_pudding", "cannoli", "carrot_cake", 
                       "cheesecake", "chocolate_cake", "chocolate_mousse", "churros", "creme_brulee", 
                       "cup_cakes", "donuts", "frozen_yogurt", "ice_cream", "macarons", 
                       "panna_cotta", "red_velvet_cake", "strawberry_shortcake", "tiramisu", "waffles"]
        
        let mains = ["beef_carpaccio", "beef_tartare", "bibimbap", "chicken_curry", "chicken_quesadilla",
                    "chicken_wings", "filet_mignon", "fish_and_chips", "grilled_salmon", "hamburger",
                    "lasagna", "pad_thai", "paella", "peking_duck", "pizza", "pork_chop",
                    "prime_rib", "ramen", "ravioli", "risotto", "spaghetti_bolognese",
                    "spaghetti_carbonara", "steak", "sushi", "tacos"]
        
        let appetizers = ["bruschetta", "caprese_salad", "deviled_eggs", "edamame", "escargots",
                         "falafel", "fried_calamari", "garlic_bread", "guacamole", "gyoza",
                         "hummus", "nachos", "oysters", "samosa", "spring_rolls"]
        
        if desserts.contains(identifier) {
            return "desserts"
        } else if mains.contains(identifier) {
            return "main_dishes"
        } else if appetizers.contains(identifier) {
            return "appetizers"
        } else {
            return "other"
        }
    }
    
    private func estimateNutrition(for identifier: String) -> EstimatedNutrition {
        // Basic nutrition estimation based on food type
        // In a real app, this would be more sophisticated
        switch identifier {
        case let id where id.contains("cake") || id.contains("pie") || id.contains("chocolate"):
            return EstimatedNutrition(calories: 350, protein: 4.0, fat: 15.0, carbs: 50.0)
        case let id where id.contains("salad"):
            return EstimatedNutrition(calories: 150, protein: 8.0, fat: 10.0, carbs: 12.0)
        case let id where id.contains("chicken"):
            return EstimatedNutrition(calories: 250, protein: 25.0, fat: 12.0, carbs: 5.0)
        case let id where id.contains("fish") || id.contains("salmon"):
            return EstimatedNutrition(calories: 200, protein: 22.0, fat: 10.0, carbs: 2.0)
        case let id where id.contains("pasta") || id.contains("spaghetti"):
            return EstimatedNutrition(calories: 300, protein: 12.0, fat: 8.0, carbs: 45.0)
        case let id where id.contains("rice"):
            return EstimatedNutrition(calories: 280, protein: 6.0, fat: 4.0, carbs: 55.0)
        default:
            return EstimatedNutrition(calories: 200, protein: 10.0, fat: 8.0, carbs: 25.0)
        }
    }
}

// MARK: - Supporting Types

struct Food101Result: Identifiable {
    let id = UUID()
    let foodName: String
    let originalIdentifier: String
    let confidence: Double
    let category: String
    let estimatedNutrition: EstimatedNutrition
    
    var isHighConfidence: Bool {
        return confidence >= 0.7
    }
    
    var confidencePercentage: Int {
        return Int(confidence * 100)
    }
    
    var confidenceColor: Color {
        switch confidence {
        case 0.8...:
            return .successGreen
        case 0.6..<0.8:
            return .warningOrange
        default:
            return .errorRed
        }
    }
}

struct EstimatedNutrition {
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    
    func toFoodItemData(name: String, servingSize: Double = 100.0) -> FoodItemData {
        return FoodItemData(
            name: name,
            brand: nil,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            fiber: 2.0, // Default estimate
            sugar: carbs * 0.3, // Rough estimate
            sodium: 200, // Default estimate
            servingSize: servingSize,
            servingUnit: "g"
        )
    }
}

// MARK: - Camera Manager

class CameraManager: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isShowingCamera = false
    
    private var captureCompletion: ((UIImage?) -> Void)?
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        captureCompletion = completion
        isShowingCamera = true
    }
    
    func switchCamera() {
        // Implementation for switching between front/back camera
        // This would be handled by the camera view
    }
}

// MARK: - Camera Preview View

struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        // Add camera preview layer here
        // This is a simplified version - full implementation would use AVCaptureSession
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update camera preview if needed
    }
}