//
//  HealthKitManager.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import Foundation
import HealthKit
import SwiftUI

// MARK: - HealthKit Data Types

enum HealthKitError: LocalizedError {
    case notAvailable
    case permissionDenied
    case dataNotFound
    case writeFailed
    case readFailed
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .permissionDenied:
            return "Permission to access HealthKit was denied"
        case .dataNotFound:
            return "No health data found"
        case .writeFailed:
            return "Failed to write data to HealthKit"
        case .readFailed:
            return "Failed to read data from HealthKit"
        }
    }
}

struct HealthKitNutritionData {
    let date: Date
    let calories: Double?
    let protein: Double?
    let fat: Double?
    let carbs: Double?
    let fiber: Double?
    let sugar: Double?
    let sodium: Double?
    let water: Double?
    
    init(date: Date, calories: Double? = nil, protein: Double? = nil, fat: Double? = nil,
         carbs: Double? = nil, fiber: Double? = nil, sugar: Double? = nil,
         sodium: Double? = nil, water: Double? = nil) {
        self.date = date
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.water = water
    }
}

// MARK: - HealthKit Manager

@Observable
class HealthKitManager: NSObject {
    
    // MARK: - Properties
    
    private let healthStore = HKHealthStore()
    
    var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    var authorizationStatus: HKAuthorizationStatus = .notDetermined
    var lastError: Error?
    var isProcessing = false
    
    // MARK: - HealthKit Data Types
    
    private let nutritionTypes: Set<HKSampleType> = [
        HKQuantityType(.dietaryEnergyConsumed),
        HKQuantityType(.dietaryProtein),
        HKQuantityType(.dietaryFatTotal),
        HKQuantityType(.dietaryCarbohydrates),
        HKQuantityType(.dietaryFiber),
        HKQuantityType(.dietarySugar),
        HKQuantityType(.dietarySodium),
        HKQuantityType(.dietaryWater)
    ]
    
    private let bodyMeasurementTypes: Set<HKSampleType> = [
        HKQuantityType(.bodyMass),
        HKQuantityType(.height),
        HKQuantityType(.bodyMassIndex),
        HKQuantityType(.bodyFatPercentage),
        HKQuantityType(.leanBodyMass)
    ]
    
    private let workoutTypes: Set<HKSampleType> = [
        HKWorkoutType.workoutType()
    ]
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        let allTypes = nutritionTypes.union(bodyMeasurementTypes).union(workoutTypes)
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { [weak self] success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.lastError = error
                        continuation.resume(throwing: error)
                    } else if success {
                        self?.authorizationStatus = .sharingAuthorized
                        continuation.resume()
                    } else {
                        let error = HealthKitError.permissionDenied
                        self?.lastError = error
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    func checkAuthorizationStatus() {
        guard isHealthKitAvailable else {
            authorizationStatus = .notDetermined
            return
        }
        
        // Check status for dietary energy (representative of nutrition data)
        let status = healthStore.authorizationStatus(for: HKQuantityType(.dietaryEnergyConsumed))
        authorizationStatus = status
    }
    
    // MARK: - Writing Nutrition Data
    
    func writeNutritionData(_ data: HealthKitNutritionData) async throws {
        guard authorizationStatus == .sharingAuthorized else {
            throw HealthKitError.permissionDenied
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        var samples: [HKQuantitySample] = []
        
        // Create samples for each nutrition component
        if let calories = data.calories {
            let sample = createNutritionSample(
                type: HKQuantityType(.dietaryEnergyConsumed),
                quantity: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
                date: data.date
            )
            samples.append(sample)
        }
        
        if let protein = data.protein {
            let sample = createNutritionSample(
                type: HKQuantityType(.dietaryProtein),
                quantity: HKQuantity(unit: .gram(), doubleValue: protein),
                date: data.date
            )
            samples.append(sample)
        }
        
        if let fat = data.fat {
            let sample = createNutritionSample(
                type: HKQuantityType(.dietaryFatTotal),
                quantity: HKQuantity(unit: .gram(), doubleValue: fat),
                date: data.date
            )
            samples.append(sample)
        }
        
        if let carbs = data.carbs {
            let sample = createNutritionSample(
                type: HKQuantityType(.dietaryCarbohydrates),
                quantity: HKQuantity(unit: .gram(), doubleValue: carbs),
                date: data.date
            )
            samples.append(sample)
        }
        
        if let fiber = data.fiber {
            let sample = createNutritionSample(
                type: HKQuantityType(.dietaryFiber),
                quantity: HKQuantity(unit: .gram(), doubleValue: fiber),
                date: data.date
            )
            samples.append(sample)
        }
        
        if let sugar = data.sugar {
            let sample = createNutritionSample(
                type: HKQuantityType(.dietarySugar),
                quantity: HKQuantity(unit: .gram(), doubleValue: sugar),
                date: data.date
            )
            samples.append(sample)
        }
        
        if let sodium = data.sodium {
            let sample = createNutritionSample(
                type: HKQuantityType(.dietarySodium),
                quantity: HKQuantity(unit: .gram(), doubleValue: sodium / 1000.0), // Convert mg to g
                date: data.date
            )
            samples.append(sample)
        }
        
        if let water = data.water {
            let sample = createNutritionSample(
                type: HKQuantityType(.dietaryWater),
                quantity: HKQuantity(unit: .liter(), doubleValue: water / 1000.0), // Convert ml to L
                date: data.date
            )
            samples.append(sample)
        }
        
        // Save all samples
        try await saveSamples(samples)
    }
    
    private func createNutritionSample(type: HKQuantityType, quantity: HKQuantity, date: Date) -> HKQuantitySample {
        let metadata: [String: Any] = [
            HKMetadataKeyFoodType: "Tamiza App Entry",
            HKMetadataKeyWasUserEntered: true
        ]
        
        return HKQuantitySample(
            type: type,
            quantity: quantity,
            start: date,
            end: date,
            metadata: metadata
        )
    }
    
    private func saveSamples(_ samples: [HKQuantitySample]) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.save(samples) { [weak self] success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.lastError = error
                        continuation.resume(throwing: HealthKitError.writeFailed)
                    } else if success {
                        continuation.resume()
                    } else {
                        let error = HealthKitError.writeFailed
                        self?.lastError = error
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    // MARK: - Reading Nutrition Data
    
    func readNutritionData(for date: Date) async throws -> HealthKitNutritionData {
        guard authorizationStatus == .sharingAuthorized else {
            throw HealthKitError.permissionDenied
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        // Read all nutrition data concurrently
        async let calories = readQuantityData(type: HKQuantityType(.dietaryEnergyConsumed), 
                                            unit: .kilocalorie(), 
                                            start: startOfDay, 
                                            end: endOfDay)
        async let protein = readQuantityData(type: HKQuantityType(.dietaryProtein), 
                                           unit: .gram(), 
                                           start: startOfDay, 
                                           end: endOfDay)
        async let fat = readQuantityData(type: HKQuantityType(.dietaryFatTotal), 
                                       unit: .gram(), 
                                       start: startOfDay, 
                                       end: endOfDay)
        async let carbs = readQuantityData(type: HKQuantityType(.dietaryCarbohydrates), 
                                         unit: .gram(), 
                                         start: startOfDay, 
                                         end: endOfDay)
        async let fiber = readQuantityData(type: HKQuantityType(.dietaryFiber), 
                                         unit: .gram(), 
                                         start: startOfDay, 
                                         end: endOfDay)
        async let sugar = readQuantityData(type: HKQuantityType(.dietarySugar), 
                                         unit: .gram(), 
                                         start: startOfDay, 
                                         end: endOfDay)
        async let sodium = readQuantityData(type: HKQuantityType(.dietarySodium), 
                                          unit: .gram(), 
                                          start: startOfDay, 
                                          end: endOfDay)
        async let water = readQuantityData(type: HKQuantityType(.dietaryWater), 
                                         unit: .liter(), 
                                         start: startOfDay, 
                                         end: endOfDay)
        
        return try await HealthKitNutritionData(
            date: date,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            fiber: fiber,
            sugar: sugar,
            sodium: sodium != nil ? sodium! * 1000 : nil, // Convert g to mg
            water: water != nil ? water! * 1000 : nil // Convert L to ml
        )
    }
    
    private func readQuantityData(type: HKQuantityType, unit: HKUnit, start: Date, end: Date) async throws -> Double? {
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { [weak self] _, result, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.lastError = error
                        continuation.resume(throwing: HealthKitError.readFailed)
                    } else if let sum = result?.sumQuantity() {
                        let value = sum.doubleValue(for: unit)
                        continuation.resume(returning: value > 0 ? value : nil)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Body Measurements
    
    func writeBodyWeight(_ weight: Double, date: Date = Date()) async throws {
        guard authorizationStatus == .sharingAuthorized else {
            throw HealthKitError.permissionDenied
        }
        
        let weightSample = HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: weight),
            start: date,
            end: date,
            metadata: [HKMetadataKeyWasUserEntered: true]
        )
        
        try await saveSamples([weightSample])
    }
    
    func readLatestBodyWeight() async throws -> Double? {
        guard authorizationStatus == .sharingAuthorized else {
            throw HealthKitError.permissionDenied
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(
                sampleType: HKQuantityType(.bodyMass),
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { [weak self] _, samples, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.lastError = error
                        continuation.resume(throwing: HealthKitError.readFailed)
                    } else if let sample = samples?.first as? HKQuantitySample {
                        let weight = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                        continuation.resume(returning: weight)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Convenience Methods
    
    func syncMealToHealthKit(_ item: Item) async throws {
        let nutritionData = HealthKitNutritionData(
            date: item.timestamp,
            calories: Double(item.calories),
            protein: item.protein,
            fat: item.fat,
            carbs: item.carbs
        )
        
        try await writeNutritionData(nutritionData)
    }
    
    func syncDailyNutritionToHealthKit(_ items: [Item], date: Date) async throws {
        let totalCalories = items.reduce(0) { $0 + $1.calories }
        let totalProtein = items.reduce(0.0) { $0 + $1.protein }
        let totalFat = items.reduce(0.0) { $0 + $1.fat }
        let totalCarbs = items.reduce(0.0) { $0 + $1.carbs }
        
        let nutritionData = HealthKitNutritionData(
            date: date,
            calories: Double(totalCalories),
            protein: totalProtein,
            fat: totalFat,
            carbs: totalCarbs
        )
        
        try await writeNutritionData(nutritionData)
    }
    
    // MARK: - Settings and Preferences
    
    var isAutoSyncEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "healthkit_auto_sync_enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "healthkit_auto_sync_enabled")
        }
    }
    
    var syncFrequency: SyncFrequency {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: "healthkit_sync_frequency")
            return SyncFrequency(rawValue: rawValue) ?? .daily
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "healthkit_sync_frequency")
        }
    }
    
    // MARK: - Background Sync
    
    func performBackgroundSync() async {
        guard isAutoSyncEnabled && authorizationStatus == .sharingAuthorized else {
            return
        }
        
        // This would typically sync recent data based on sync frequency
        // Implementation would depend on your app's data storage
        print("Performing background HealthKit sync...")
    }
}

// MARK: - Supporting Types

enum SyncFrequency: Int, CaseIterable {
    case realtime = 0
    case daily = 1
    case weekly = 2
    
    var displayName: String {
        switch self {
        case .realtime: return "Real-time"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        }
    }
    
    var description: String {
        switch self {
        case .realtime: return "Sync immediately after each meal"
        case .daily: return "Sync once per day"
        case .weekly: return "Sync once per week"
        }
    }
}

// MARK: - Extensions

extension HealthKitManager {
    
    func openHealthApp() {
        if let url = URL(string: "x-apple-health://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    var authorizationStatusDescription: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Not determined"
        case .sharingDenied:
            return "Access denied"
        case .sharingAuthorized:
            return "Authorized"
        @unknown default:
            return "Unknown"
        }
    }
}

// MARK: - Sample Data

extension HealthKitManager {
    
    static func createSampleNutritionData() -> HealthKitNutritionData {
        return HealthKitNutritionData(
            date: Date(),
            calories: 2000,
            protein: 150,
            fat: 65,
            carbs: 250,
            fiber: 25,
            sugar: 50,
            sodium: 2300,
            water: 2000
        )
    }
}