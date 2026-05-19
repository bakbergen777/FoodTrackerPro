//
//  AICameraView.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import AVFoundation
import UIKit

struct AICameraView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var recognitionManager = Food101RecognitionManager()
    @StateObject private var cameraManager = CameraManager()
    
    @State private var showingResults = false
    @State private var capturedImage: UIImage?
    @State private var recognitionResults: [FoodRecognitionResult] = []
    @State private var selectedResult: FoodRecognitionResult?
    @State private var servingSize: String = "100"
    @State private var showingServingSizeAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Camera Preview
                CameraPreviewView(cameraManager: cameraManager)
                    .ignoresSafeArea()
                
                // Overlay UI
                VStack {
                    // Top Bar
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .padding()
                        
                        Spacer()
                        
                        // Flash Toggle
                        Button(action: {
                            cameraManager.toggleFlash()
                        }) {
                            Image(systemName: cameraManager.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Recognition Status
                    if recognitionManager.isProcessing {
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            
                            Text("Analyzing food...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    // Bottom Controls
                    HStack(spacing: 40) {
                        // Gallery Button
                        Button(action: {
                            // Open photo library
                        }) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        // Capture Button
                        Button(action: {
                            capturePhoto()
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 2)
                                        .frame(width: 70, height: 70)
                                )
                        }
                        .disabled(recognitionManager.isProcessing)
                        
                        // Switch Camera Button
                        Button(action: {
                            cameraManager.switchCamera()
                        }) {
                            Image(systemName: "camera.rotate")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingResults) {
            FoodRecognitionResultsView(
                image: capturedImage,
                results: recognitionResults,
                onFoodSelected: { result in
                    selectedResult = result
                    showingServingSizeAlert = true
                }
            )
        }
        .alert("Serving Size", isPresented: $showingServingSizeAlert) {
            TextField("Grams", text: $servingSize)
                .keyboardType(.numberPad)
            
            Button("Add to Log") {
                addSelectedFood()
            }
            
            Button("Cancel", role: .cancel) {
                selectedResult = nil
            }
        } message: {
            if let result = selectedResult {
                Text("How many grams of \(result.displayName) did you eat?")
            }
        }
        .onAppear {
            cameraManager.requestPermission()
        }
    }
    
    private func capturePhoto() {
        cameraManager.capturePhoto { image in
            guard let image = image else { return }
            
            capturedImage = image
            
            // Recognize food in the captured image
            recognitionManager.recognizeFood(in: image) { results in
                recognitionResults = results
                if !results.isEmpty {
                    showingResults = true
                }
            }
        }
    }
    
    private func addSelectedFood() {
        guard let result = selectedResult,
              let servingSizeValue = Double(servingSize) else { return }
        
        let item = recognitionManager.createItem(from: result, servingSize: servingSizeValue)
        modelContext.insert(item)
        
        selectedResult = nil
        dismiss()
    }
}

// MARK: - Camera Manager

@Observable
class CameraManager: NSObject {
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var currentCamera: AVCaptureDevice?
    private var photoCaptureCompletion: ((UIImage?) -> Void)?
    
    var isFlashOn = false
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.startSession()
                }
            }
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        
        currentCamera = backCamera
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if captureSession?.canAddOutput(photoOutput!) == true {
                captureSession?.addOutput(photoOutput!)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.videoGravity = .resizeAspectFill
            
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.stopRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let photoOutput = photoOutput else {
            completion(nil)
            return
        }
        
        photoCaptureCompletion = completion
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
    
    func switchCamera() {
        guard let captureSession = captureSession else { return }
        
        captureSession.beginConfiguration()
        
        // Remove current input
        if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
            captureSession.removeInput(currentInput)
        }
        
        // Switch camera
        let newPosition: AVCaptureDevice.Position = currentCamera?.position == .back ? .front : .back
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
            captureSession.commitConfiguration()
            return
        }
        
        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            if captureSession.canAddInput(newInput) {
                captureSession.addInput(newInput)
                currentCamera = newCamera
            }
        } catch {
            print("Error switching camera: \(error)")
        }
        
        captureSession.commitConfiguration()
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoCaptureCompletion?(nil)
            return
        }
        
        photoCaptureCompletion?(image)
        photoCaptureCompletion = nil
    }
}

// MARK: - Camera Preview View

struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        if let previewLayer = cameraManager.previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - Food Recognition Results View

struct FoodRecognitionResultsView: View {
    let image: UIImage?
    let results: [FoodRecognitionResult]
    let onFoodSelected: (FoodRecognitionResult) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Captured Image
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                // Results Header
                VStack(spacing: 8) {
                    Text("Food Recognition Results")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.primaryText)
                    
                    Text("Tap a food item to add it to your log")
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.secondaryText)
                }
                
                // Results List
                if results.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(DesignSystem.secondaryText)
                        
                        Text("No food items recognized")
                            .font(.headline)
                            .foregroundColor(DesignSystem.primaryText)
                        
                        Text("Try taking another photo with better lighting")
                            .font(.subheadline)
                            .foregroundColor(DesignSystem.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(results, id: \.identifier) { result in
                                FoodResultRow(result: result) {
                                    onFoodSelected(result)
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("AI Recognition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Food Result Row

struct FoodResultRow: View {
    let result: FoodRecognitionResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Confidence Indicator
                VStack {
                    Circle()
                        .fill(confidenceColor)
                        .frame(width: 12, height: 12)
                    
                    Text("\(result.confidencePercentage)%")
                        .font(.caption2)
                        .foregroundColor(DesignSystem.secondaryText)
                }
                
                // Food Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.displayName)
                        .font(.headline)
                        .foregroundColor(DesignSystem.primaryText)
                    
                    if let nutrition = result.nutritionEstimate {
                        Text("\(Int(nutrition.caloriesPer100g)) kcal • P: \(String(format: "%.1f", nutrition.proteinPer100g))g • C: \(String(format: "%.1f", nutrition.carbsPer100g))g")
                            .font(.caption)
                            .foregroundColor(DesignSystem.secondaryText)
                    }
                    
                    Text("Confidence: \(result.confidencePercentage)%")
                        .font(.caption2)
                        .foregroundColor(confidenceColor)
                }
                
                Spacer()
                
                // Add Button
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(DesignSystem.primaryGreen)
            }
            .padding()
            .background(DesignSystem.cardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var confidenceColor: Color {
        if result.confidence >= 0.8 {
            return DesignSystem.successGreen
        } else if result.confidence >= 0.6 {
            return DesignSystem.warningOrange
        } else {
            return DesignSystem.errorRed
        }
    }
}

#Preview {
    AICameraView()
}