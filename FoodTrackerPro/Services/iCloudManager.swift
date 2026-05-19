//
//  iCloudManager.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import Foundation
import SwiftUI

class iCloudManager: ObservableObject {
    @Published var iCloudAvailable = false
    @Published var syncStatus: SyncStatus = .idle
    
    private let fileManager = FileManager.default
    private var documentsDirectory: URL?
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error(String)
        
        var localizedDescription: String {
            switch self {
            case .idle:
                return "Ready"
            case .syncing:
                return "Syncing..."
            case .success:
                return "Synced"
            case .error(let message):
                return "Error: \(message)"
            }
        }
    }
    
    // MARK: - Initialization
    
    init() {
        setupiCloudDirectory()
        checkiCloudAvailability()
    }
    
    // MARK: - Setup
    
    private func setupiCloudDirectory() {
        guard let containerURL = fileManager.url(forUbiquityContainerIdentifier: nil) else {
            print("iCloud container not available")
            return
        }
        
        documentsDirectory = containerURL.appendingPathComponent("Documents/FoodLogs")
        
        // Create directory if it doesn't exist
        do {
            try fileManager.createDirectory(
                at: documentsDirectory!,
                withIntermediateDirectories: true,
                attributes: nil
            )
            print("iCloud Documents directory created/verified: \(documentsDirectory!)")
        } catch {
            print("Failed to create iCloud Documents directory: \(error)")
        }
    }
    
    private func checkiCloudAvailability() {
        if let _ = fileManager.url(forUbiquityContainerIdentifier: nil) {
            iCloudAvailable = true
            print("iCloud is available")
        } else {
            iCloudAvailable = false
            print("iCloud is not available")
        }
    }
    
    // MARK: - Day Data Management
    
    func saveDayData(_ dayData: DayData) async {
        guard iCloudAvailable, let documentsDirectory = documentsDirectory else {
            await fallbackToLocalSave(dayData)
            return
        }
        
        await MainActor.run {
            syncStatus = .syncing
        }
        
        do {
            let fileName = dayDataFileName(for: dayData.date)
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(dayData)
            
            try data.write(to: fileURL)
            
            await MainActor.run {
                syncStatus = .success
            }
            
            print("Day data saved to iCloud: \(fileName)")
            
        } catch {
            await MainActor.run {
                syncStatus = .error(error.localizedDescription)
            }
            
            print("Failed to save day data to iCloud: \(error)")
            
            // Fallback to local storage
            await fallbackToLocalSave(dayData)
        }
    }
    
    func loadDayData(for date: Date) async -> DayData? {
        guard iCloudAvailable, let documentsDirectory = documentsDirectory else {
            return await fallbackToLocalLoad(for: date)
        }
        
        do {
            let fileName = dayDataFileName(for: date)
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            guard fileManager.fileExists(atPath: fileURL.path) else {
                // Try local fallback
                return await fallbackToLocalLoad(for: date)
            }
            
            let data = try Data(contentsOf: fileURL)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let dayData = try decoder.decode(DayData.self, from: data)
            
            print("Day data loaded from iCloud: \(fileName)")
            return dayData
            
        } catch {
            print("Failed to load day data from iCloud: \(error)")
            
            // Fallback to local storage
            return await fallbackToLocalLoad(for: date)
        }
    }
    
    func loadWeeklyData(endingOn date: Date) async -> [DayData] {
        var weeklyData: [DayData] = []
        let calendar = Calendar.current
        
        for i in 0..<7 {
            guard let dayDate = calendar.date(byAdding: .day, value: -i, to: date) else { continue }
            
            if let dayData = await loadDayData(for: dayDate) {
                weeklyData.append(dayData)
            } else {
                // Create empty day data if none exists
                weeklyData.append(DayData(date: dayDate))
            }
        }
        
        return weeklyData.reversed()
    }
    
    // MARK: - Sync Management
    
    func syncAllData() async {
        guard iCloudAvailable else {
            await MainActor.run {
                syncStatus = .error("iCloud not available")
            }
            return
        }
        
        await MainActor.run {
            syncStatus = .syncing
        }
        
        do {
            // Get all local files
            let localFiles = try getLocalDayDataFiles()
            
            // Sync each file to iCloud
            for localFile in localFiles {
                if let dayData = await loadLocalDayData(from: localFile) {
                    await saveDayData(dayData)
                }
            }
            
            await MainActor.run {
                syncStatus = .success
            }
            
        } catch {
            await MainActor.run {
                syncStatus = .error(error.localizedDescription)
            }
        }
    }
    
    func downloadFromiCloud() async {
        guard iCloudAvailable, let documentsDirectory = documentsDirectory else {
            await MainActor.run {
                syncStatus = .error("iCloud not available")
            }
            return
        }
        
        await MainActor.run {
            syncStatus = .syncing
        }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            
            for fileURL in contents {
                if fileURL.pathExtension == "json" {
                    // Trigger download by accessing the file
                    _ = try Data(contentsOf: fileURL)
                }
            }
            
            await MainActor.run {
                syncStatus = .success
            }
            
        } catch {
            await MainActor.run {
                syncStatus = .error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Local Fallback
    
    private func fallbackToLocalSave(_ dayData: DayData) async {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(dayData)
            let fileName = dayDataFileName(for: dayData.date)
            UserDefaults.standard.set(data, forKey: "local_\(fileName)")
            print("Day data saved locally: \(fileName)")
        } catch {
            print("Failed to save day data locally: \(error)")
        }
    }
    
    private func fallbackToLocalLoad(for date: Date) async -> DayData? {
        let fileName = dayDataFileName(for: date)
        
        guard let data = UserDefaults.standard.data(forKey: "local_\(fileName)") else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let dayData = try decoder.decode(DayData.self, from: data)
            print("Day data loaded locally: \(fileName)")
            return dayData
        } catch {
            print("Failed to load day data locally: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func dayDataFileName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: date)).json"
    }
    
    private func getLocalDayDataFiles() throws -> [String] {
        let keys = UserDefaults.standard.dictionaryRepresentation().keys
        return keys.filter { $0.hasPrefix("local_") && $0.hasSuffix(".json") }
    }
    
    private func loadLocalDayData(from key: String) async -> DayData? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(DayData.self, from: data)
        } catch {
            print("Failed to decode local day data: \(error)")
            return nil
        }
    }
}

// MARK: - DayData Codable Extension

extension DayData: Codable {
    enum CodingKeys: String, CodingKey {
        case id, date, meals
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let date = try container.decode(Date.self, forKey: .date)
        let meals = try container.decode([MealData].self, forKey: .meals)
        
        self.init(date: date)
        self.meals = meals
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(meals, forKey: .meals)
    }
}

// MARK: - MealData Codable Extension

extension MealData: Codable {
    enum CodingKeys: String, CodingKey {
        case id, type, timestamp, foodItems
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let typeString = try container.decode(String.self, forKey: .type)
        let timestamp = try container.decode(Date.self, forKey: .timestamp)
        let foodItems = try container.decode([FoodItemData].self, forKey: .foodItems)
        
        guard let type = MealType(rawValue: typeString) else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid meal type")
        }
        
        self.init(type: type, timestamp: timestamp)
        self.foodItems = foodItems
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(foodItems, forKey: .foodItems)
    }
}

// MARK: - MealData Initializer Extension

extension MealData {
    init(type: MealType, timestamp: Date) {
        self.type = type
        self.timestamp = timestamp
        self.foodItems = []
    }
}