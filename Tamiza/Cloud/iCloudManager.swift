//
//  iCloudManager.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import Foundation
import CloudKit
import SwiftUI

// MARK: - iCloud Data Models

struct CloudMealRecord {
    let recordID: CKRecord.ID?
    let name: String
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    let timestamp: Date
    let deviceID: String
    let lastModified: Date
    
    init(from item: Item, deviceID: String) {
        self.recordID = nil
        self.name = item.name
        self.calories = item.calories
        self.protein = item.protein
        self.fat = item.fat
        self.carbs = item.carbs
        self.timestamp = item.timestamp
        self.deviceID = deviceID
        self.lastModified = Date()
    }
    
    init(from record: CKRecord) {
        self.recordID = record.recordID
        self.name = record["name"] as? String ?? ""
        self.calories = record["calories"] as? Int ?? 0
        self.protein = record["protein"] as? Double ?? 0.0
        self.fat = record["fat"] as? Double ?? 0.0
        self.carbs = record["carbs"] as? Double ?? 0.0
        self.timestamp = record["timestamp"] as? Date ?? Date()
        self.deviceID = record["deviceID"] as? String ?? ""
        self.lastModified = record.modificationDate ?? Date()
    }
    
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "MealRecord", recordID: recordID ?? CKRecord.ID())
        record["name"] = name
        record["calories"] = calories
        record["protein"] = protein
        record["fat"] = fat
        record["carbs"] = carbs
        record["timestamp"] = timestamp
        record["deviceID"] = deviceID
        record["lastModified"] = lastModified
        return record
    }
    
    func toItem() -> Item {
        let item = Item()
        item.name = name
        item.calories = calories
        item.protein = protein
        item.fat = fat
        item.carbs = carbs
        item.timestamp = timestamp
        return item
    }
}

// MARK: - iCloud Sync Status

enum iCloudSyncStatus {
    case notConfigured
    case available
    case syncing
    case error(Error)
    case noAccount
    case restricted
    
    var displayText: String {
        switch self {
        case .notConfigured:
            return "Not configured"
        case .available:
            return "Available"
        case .syncing:
            return "Syncing..."
        case .error(let error):
            return "Error: \(error.localizedDescription)"
        case .noAccount:
            return "No iCloud account"
        case .restricted:
            return "iCloud restricted"
        }
    }
    
    var isAvailable: Bool {
        switch self {
        case .available, .syncing:
            return true
        default:
            return false
        }
    }
}

// MARK: - iCloud Manager

@Observable
class iCloudManager: NSObject {
    
    // MARK: - Properties
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    
    var syncStatus: iCloudSyncStatus = .notConfigured
    var lastSyncDate: Date?
    var isAutoSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "icloud_auto_sync_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "icloud_auto_sync_enabled") }
    }
    
    var syncConflicts: [SyncConflict] = []
    
    // MARK: - Initialization
    
    override init() {
        self.container = CKContainer.default()
        self.privateDatabase = container.privateCloudDatabase
        super.init()
        
        checkiCloudStatus()
        setupNotifications()
    }
    
    // MARK: - iCloud Status
    
    func checkiCloudStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.syncStatus = .error(error)
                    return
                }
                
                switch status {
                case .available:
                    self?.syncStatus = .available
                case .noAccount:
                    self?.syncStatus = .noAccount
                case .restricted:
                    self?.syncStatus = .restricted
                case .couldNotDetermine:
                    self?.syncStatus = .notConfigured
                case .temporarilyUnavailable:
                    self?.syncStatus = .error(iCloudError.temporarilyUnavailable)
                @unknown default:
                    self?.syncStatus = .notConfigured
                }
            }
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudAccountChanged),
            name: .CKAccountChanged,
            object: nil
        )
    }
    
    @objc private func iCloudAccountChanged() {
        checkiCloudStatus()
    }
    
    // MARK: - Sync Operations
    
    func syncMealToCloud(_ item: Item) async throws {
        guard syncStatus.isAvailable else {
            throw iCloudError.notAvailable
        }
        
        let cloudRecord = CloudMealRecord(from: item, deviceID: deviceID)
        let record = cloudRecord.toCKRecord()
        
        do {
            _ = try await privateDatabase.save(record)
            print("Successfully synced meal to iCloud: \(item.name)")
        } catch {
            print("Failed to sync meal to iCloud: \(error)")
            throw error
        }
    }
    
    func syncAllMealsToCloud(_ items: [Item]) async throws {
        guard syncStatus.isAvailable else {
            throw iCloudError.notAvailable
        }
        
        syncStatus = .syncing
        
        do {
            let records = items.map { item in
                CloudMealRecord(from: item, deviceID: deviceID).toCKRecord()
            }
            
            // Batch save records
            let batchSize = 100 // CloudKit limit
            for batch in records.chunked(into: batchSize) {
                let operation = CKModifyRecordsOperation(recordsToSave: batch)
                operation.savePolicy = .changedKeys
                operation.qualityOfService = .userInitiated
                
                try await withCheckedThrowingContinuation { continuation in
                    operation.modifyRecordsResultBlock = { result in
                        switch result {
                        case .success:
                            continuation.resume()
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                    
                    privateDatabase.add(operation)
                }
            }
            
            lastSyncDate = Date()
            syncStatus = .available
            print("Successfully synced \(items.count) meals to iCloud")
            
        } catch {
            syncStatus = .error(error)
            throw error
        }
    }
    
    func fetchMealsFromCloud(since date: Date? = nil) async throws -> [CloudMealRecord] {
        guard syncStatus.isAvailable else {
            throw iCloudError.notAvailable
        }
        
        syncStatus = .syncing
        
        do {
            var predicate: NSPredicate
            
            if let date = date {
                predicate = NSPredicate(format: "lastModified > %@", date as NSDate)
            } else {
                predicate = NSPredicate(value: true)
            }
            
            let query = CKQuery(recordType: "MealRecord", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            
            let (matchResults, _) = try await privateDatabase.records(matching: query)
            
            var cloudRecords: [CloudMealRecord] = []
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    cloudRecords.append(CloudMealRecord(from: record))
                case .failure(let error):
                    print("Failed to fetch record: \(error)")
                }
            }
            
            syncStatus = .available
            return cloudRecords
            
        } catch {
            syncStatus = .error(error)
            throw error
        }
    }
    
    func performFullSync(localItems: [Item]) async throws -> SyncResult {
        guard syncStatus.isAvailable else {
            throw iCloudError.notAvailable
        }
        
        syncStatus = .syncing
        
        do {
            // Fetch all cloud records
            let cloudRecords = try await fetchMealsFromCloud()
            
            // Compare and resolve conflicts
            let syncResult = resolveSyncConflicts(localItems: localItems, cloudRecords: cloudRecords)
            
            // Upload new local items
            if !syncResult.itemsToUpload.isEmpty {
                try await syncAllMealsToCloud(syncResult.itemsToUpload)
            }
            
            lastSyncDate = Date()
            syncStatus = .available
            
            return syncResult
            
        } catch {
            syncStatus = .error(error)
            throw error
        }
    }
    
    // MARK: - Conflict Resolution
    
    private func resolveSyncConflicts(localItems: [Item], cloudRecords: [CloudMealRecord]) -> SyncResult {
        var itemsToUpload: [Item] = []
        var itemsToDownload: [CloudMealRecord] = []
        var conflicts: [SyncConflict] = []
        
        // Create lookup dictionaries
        let localItemsDict = Dictionary(grouping: localItems) { item in
            "\(item.name)_\(item.timestamp.timeIntervalSince1970)"
        }
        
        let cloudRecordsDict = Dictionary(grouping: cloudRecords) { record in
            "\(record.name)_\(record.timestamp.timeIntervalSince1970)"
        }
        
        // Find items to upload (local only)
        for item in localItems {
            let key = "\(item.name)_\(item.timestamp.timeIntervalSince1970)"
            if cloudRecordsDict[key] == nil {
                itemsToUpload.append(item)
            }
        }
        
        // Find items to download (cloud only)
        for record in cloudRecords {
            let key = "\(record.name)_\(record.timestamp.timeIntervalSince1970)"
            if localItemsDict[key] == nil {
                itemsToDownload.append(record)
            }
        }
        
        // Find conflicts (same item, different data)
        for record in cloudRecords {
            let key = "\(record.name)_\(record.timestamp.timeIntervalSince1970)"
            if let localItems = localItemsDict[key], let localItem = localItems.first {
                if !areItemsEqual(localItem, record) {
                    let conflict = SyncConflict(
                        localItem: localItem,
                        cloudRecord: record,
                        conflictType: .dataConflict
                    )
                    conflicts.append(conflict)
                }
            }
        }
        
        self.syncConflicts = conflicts
        
        return SyncResult(
            itemsToUpload: itemsToUpload,
            itemsToDownload: itemsToDownload,
            conflicts: conflicts
        )
    }
    
    private func areItemsEqual(_ item: Item, _ record: CloudMealRecord) -> Bool {
        return item.name == record.name &&
               item.calories == record.calories &&
               abs(item.protein - record.protein) < 0.01 &&
               abs(item.fat - record.fat) < 0.01 &&
               abs(item.carbs - record.carbs) < 0.01
    }
    
    // MARK: - Automatic Sync
    
    func enableAutomaticSync() {
        isAutoSyncEnabled = true
        
        // Set up background sync if needed
        scheduleBackgroundSync()
    }
    
    func disableAutomaticSync() {
        isAutoSyncEnabled = false
        cancelBackgroundSync()
    }
    
    private func scheduleBackgroundSync() {
        // Implementation would depend on your app's background processing setup
        print("Scheduling background sync...")
    }
    
    private func cancelBackgroundSync() {
        // Cancel any scheduled background sync
        print("Cancelling background sync...")
    }
    
    // MARK: - Utility Methods
    
    func clearCloudData() async throws {
        guard syncStatus.isAvailable else {
            throw iCloudError.notAvailable
        }
        
        let query = CKQuery(recordType: "MealRecord", predicate: NSPredicate(value: true))
        let (matchResults, _) = try await privateDatabase.records(matching: query)
        
        let recordIDs = matchResults.compactMap { (_, result) -> CKRecord.ID? in
            switch result {
            case .success(let record):
                return record.recordID
            case .failure:
                return nil
            }
        }
        
        if !recordIDs.isEmpty {
            let operation = CKModifyRecordsOperation(recordIDsToDelete: recordIDs)
            
            try await withCheckedThrowingContinuation { continuation in
                operation.modifyRecordsResultBlock = { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                
                privateDatabase.add(operation)
            }
        }
    }
    
    var cloudStorageUsage: String {
        // This would require additional CloudKit queries to calculate storage usage
        return "Calculating..."
    }
}

// MARK: - Supporting Types

struct SyncResult {
    let itemsToUpload: [Item]
    let itemsToDownload: [CloudMealRecord]
    let conflicts: [SyncConflict]
    
    var hasConflicts: Bool {
        return !conflicts.isEmpty
    }
    
    var summary: String {
        return "Upload: \(itemsToUpload.count), Download: \(itemsToDownload.count), Conflicts: \(conflicts.count)"
    }
}

struct SyncConflict {
    let localItem: Item
    let cloudRecord: CloudMealRecord
    let conflictType: ConflictType
    
    enum ConflictType {
        case dataConflict
        case timestampConflict
        case deletionConflict
    }
}

enum iCloudError: LocalizedError {
    case notAvailable
    case temporarilyUnavailable
    case quotaExceeded
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "iCloud is not available"
        case .temporarilyUnavailable:
            return "iCloud is temporarily unavailable"
        case .quotaExceeded:
            return "iCloud storage quota exceeded"
        case .networkUnavailable:
            return "Network connection unavailable"
        }
    }
}

// MARK: - Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

extension iCloudManager {
    
    var statusIcon: String {
        switch syncStatus {
        case .available:
            return "icloud.fill"
        case .syncing:
            return "icloud.and.arrow.up"
        case .error:
            return "icloud.slash.fill"
        case .noAccount, .restricted:
            return "icloud.slash"
        case .notConfigured:
            return "icloud"
        }
    }
    
    var statusColor: Color {
        switch syncStatus {
        case .available:
            return .blue
        case .syncing:
            return .orange
        case .error, .noAccount, .restricted:
            return .red
        case .notConfigured:
            return .gray
        }
    }
}