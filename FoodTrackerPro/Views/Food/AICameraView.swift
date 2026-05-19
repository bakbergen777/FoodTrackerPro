//
//  AICameraView.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import AVFoundation

struct AICameraView: View {
    @StateObject private var food101Manager = Food101RecognitionManager()
    @StateObject private var cameraManager = CameraManager()
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var capturedImage: UIImage?
    @State private var showingResults = false
    @State private var selectedResult: Food101Result?
    @State private var showingPortionSelector = false
    
    @Environment(\.dismiss) private var dismiss
    
    let onFoodRecognized: ([Food101Result]) -> Void
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(cameraManager: cameraManager)
                .ignoresSafeArea()
            
            // Overlay UI
            VStack {
                // Top bar
                topBar
                
                Spacer()
                
                // Recognition results
                if !food101Manager.recognitionResults.isEmpty {
                    recognitionResultsView
                }
                
                // Camera controls
                cameraControls
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingPortionSelector) {
            if let result = selectedResult {
                PortionSelectorView(
                    foodResult: result,
                    onConfirm: { finalResult in
                        onFoodRecognized([finalResult])
                        dismiss()
                    }
                )
            }
        }
    }
    
    // MARK: - View Components
    
    private var topBar: some View {
        HStack {
            Button("action.cancel".localized) {
                dismiss()
            }
            .font(.bodyBold)
            .foregroundColor(.primaryGreen)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.primaryWhite.opacity(0.9))
            .clipShape(Capsule())
            
            Spacer()
            
            if food101Manager.isProcessing {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.primaryGreen)
                    Text("ai.recognizing".localized)
                        .font(.callout)
                        .foregroundColor(.primaryGreen)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.primaryWhite.opacity(0.9))
                .clipShape(Capsule())
            }
        }
        .padding()
    }
    
    private var recognitionResultsView: some View {
        VStack(spacing: 12) {
            ForEach(food101Manager.recognitionResults.prefix(3)) { result in
                RecognitionResultCard(result: result) {
                    selectedResult = result
                    showingPortionSelector = true
                }
            }
        }
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: food101Manager.recognitionResults)
    }
    
    private var cameraControls: some View {
        HStack(spacing: 60) {
            // Switch camera button
            Button {
                cameraManager.switchCamera()
            } label: {
                Image(systemName: "camera.rotate")
                    .font(.title2)
                    .foregroundColor(.primaryGreen)
                    .padding(16)
                    .background(Color.primaryWhite.opacity(0.9))
                    .clipShape(Circle())
            }
            
            // Capture button
            Button {
                captureAndRecognize()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.primaryWhite)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .fill(food101Manager.isProcessing ? Color.lightGray : Color.primaryGreen)
                        .frame(width: 60, height: 60)
                    
                    if food101Manager.isProcessing {
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
            .disabled(food101Manager.isProcessing)
            .scaleEffect(food101Manager.isProcessing ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: food101Manager.isProcessing)
            
            // Gallery button
            Button {
                // TODO: Implement gallery access
            } label: {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(.primaryGreen)
                    .padding(16)
                    .background(Color.primaryWhite.opacity(0.9))
                    .clipShape(Circle())
            }
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Actions
    
    private func captureAndRecognize() {
        cameraManager.capturePhoto { image in
            guard let image = image else { return }
            
            capturedImage = image
            
            Task {
                let results = await food101Manager.recognizeFood(in: image)
                if !results.isEmpty {
                    showingResults = true
                }
            }
        }
    }
}

// MARK: - Recognition Result Card

struct RecognitionResultCard: View {
    let result: Food101Result
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Confidence indicator
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .stroke(Color.lightGray, lineWidth: 3)
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .trim(from: 0, to: result.confidence)
                            .stroke(result.confidenceColor, lineWidth: 3)
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(result.confidencePercentage)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(result.confidenceColor)
                    }
                    
                    Text("%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Food info
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.foodName)
                        .font(.headline)
                        .foregroundColor(.textGray)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 16) {
                        NutritionBadge(
                            value: "\(result.estimatedNutrition.calories)",
                            unit: "kcal",
                            color: .primaryGreen
                        )
                        
                        NutritionBadge(
                            value: String(format: "%.1f", result.estimatedNutrition.protein),
                            unit: "g protein",
                            color: .accentGreen
                        )
                    }
                }
                
                Spacer()
                
                // Select button
                VStack(spacing: 8) {
                    Button("ai.select_food".localized) {
                        onSelect()
                    }
                    .buttonStyle(GreenButtonStyle())
                    
                    if result.isHighConfidence {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.successGreen)
                                .font(.caption)
                            
                            Text("High Confidence")
                                .font(.caption2)
                                .foregroundColor(.successGreen)
                        }
                    }
                }
            }
            .padding()
            .background(Color.primaryWhite.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NutritionBadge: View {
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Portion Selector View

struct PortionSelectorView: View {
    let foodResult: Food101Result
    let onConfirm: (Food101Result) -> Void
    
    @State private var selectedPortion: Double = 100
    @State private var customPortion: String = "100"
    
    @Environment(\.dismiss) private var dismiss
    
    private let commonPortions: [Double] = [50, 100, 150, 200, 250]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Food info header
                VStack(spacing: 12) {
                    Text(foodResult.foodName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textGray)
                    
                    HStack(spacing: 20) {
                        NutritionInfo(
                            title: "health.calories".localized,
                            value: "\(Int(Double(foodResult.estimatedNutrition.calories) * selectedPortion / 100))",
                            unit: "kcal"
                        )
                        
                        NutritionInfo(
                            title: "health.protein".localized,
                            value: String(format: "%.1f", foodResult.estimatedNutrition.protein * selectedPortion / 100),
                            unit: "g"
                        )
                        
                        NutritionInfo(
                            title: "health.carbs".localized,
                            value: String(format: "%.1f", foodResult.estimatedNutrition.carbs * selectedPortion / 100),
                            unit: "g"
                        )
                    }
                }
                .whiteCard()
                
                // Portion selection
                VStack(spacing: 16) {
                    Text("food.serving_size".localized)
                        .font(.headline)
                        .foregroundColor(.textGray)
                    
                    // Common portions
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(commonPortions, id: \.self) { portion in
                            PortionButton(
                                portion: portion,
                                isSelected: selectedPortion == portion
                            ) {
                                selectedPortion = portion
                                customPortion = String(Int(portion))
                            }
                        }
                    }
                    
                    // Custom portion input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Amount")
                            .font(.subheadline)
                            .foregroundColor(.textGray)
                        
                        HStack {
                            TextField("Amount", text: $customPortion)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .onChange(of: customPortion) { _, newValue in
                                    if let value = Double(newValue) {
                                        selectedPortion = value
                                    }
                                }
                            
                            Text("g")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .whiteCard()
                
                Spacer()
                
                // Confirm button
                Button("action.add".localized) {
                    var adjustedResult = foodResult
                    // Adjust nutrition values for selected portion
                    let multiplier = selectedPortion / 100.0
                    adjustedResult.estimatedNutrition = EstimatedNutrition(
                        calories: Int(Double(foodResult.estimatedNutrition.calories) * multiplier),
                        protein: foodResult.estimatedNutrition.protein * multiplier,
                        fat: foodResult.estimatedNutrition.fat * multiplier,
                        carbs: foodResult.estimatedNutrition.carbs * multiplier
                    )
                    
                    onConfirm(adjustedResult)
                }
                .buttonStyle(GreenButtonStyle())
                .padding(.horizontal)
            }
            .padding()
            .background(Color.backgroundGray)
            .navigationTitle("Portion Size")
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

struct NutritionInfo: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.textGray)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct PortionButton: View {
    let portion: Double
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(Int(portion))")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("g")
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .textGray)
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.primaryGreen : Color.lightGray)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AICameraView { results in
        print("Recognized: \(results)")
    }
    .environmentObject(LocalizationManager.shared)
}