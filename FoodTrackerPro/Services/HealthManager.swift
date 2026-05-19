//
//  HealthManager.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var isAuthorized = false
    
    // MARK: - Authorization
    
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            
            await MainActor.run {
                self.authorizationStatus = self.healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!)
                self.isAuthorized = self.authorizationStatus == .sharingAuthorized
            }
            
            print("HealthKit authorization completed. Status: \(authorizationStatus)")
        } catch {
            print("HealthKit authorization failed: \(error)")
        }
    }
    
    // MARK: - Active Energy
    
    func fetchActiveEnergy(for date: Date) async -> Double {
        guard isAuthorized,
              let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return 0.0
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: activeEnergyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    print("Error fetching active energy: \(error)")
                    continuation.resume(returning: 0.0)
                    return
                }
                
                let energy = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0.0
                continuation.resume(returning: energy)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Weekly Active Energy
    
    func fetchWeeklyActiveEnergy(endingOn date: Date) async -> [DailyEnergyData] {
        guard isAuthorized,
              let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return []
        }
        
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: date)
        let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: calendar.date(byAdding: .day, value: 1, to: endDate)!,
            options: .strictStartDate
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: activeEnergyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: startDate,
                intervalComponents: DateComponents(day: 1)
            )
            
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    print("Error fetching weekly active energy: \(error)")
                    continuation.resume(returning: [])
                    return
                }
                
                var dailyData: [DailyEnergyData] = []
                
                results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                    let energy = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0.0
                    let data = DailyEnergyData(date: statistics.startDate, activeEnergy: energy)
                    dailyData.append(data)
                }
                
                continuation.resume(returning: dailyData)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Body Measurements
    
    func fetchLatestWeight() async -> Double? {
        guard isAuthorized,
              let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    print("Error fetching weight: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let weight = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                continuation.resume(returning: weight)
            }
            
            healthStore.execute(query)
        }
    }
    
    func fetchLatestHeight() async -> Double? {
        guard isAuthorized,
              let heightType = HKQuantityType.quantityType(forIdentifier: .height) else {
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    print("Error fetching height: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let height = sample.quantity.doubleValue(for: .meterUnit(with: .centi))
                continuation.resume(returning: height)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Step Count
    
    func fetchStepCount(for date: Date) async -> Double {
        guard isAuthorized,
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 0.0
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    print("Error fetching step count: \(error)")
                    continuation.resume(returning: 0.0)
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0.0
                continuation.resume(returning: steps)
            }
            
            healthStore.execute(query)
        }
    }
}

// MARK: - Supporting Types

struct DailyEnergyData {
    let date: Date
    let activeEnergy: Double
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - HealthKit Extensions

extension HKAuthorizationStatus {
    var localizedDescription: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .sharingDenied:
            return "Denied"
        case .sharingAuthorized:
            return "Authorized"
        @unknown default:
            return "Unknown"
        }
    }
}