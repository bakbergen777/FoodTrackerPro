//
//  FoodDatabaseManager.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import Foundation
import SwiftUI

@MainActor
class FoodDatabaseManager: ObservableObject {
    @Published var searchResults: [FoodItemData] = []
    @Published var recentFoods: [FoodItemData] = []
    @Published var favoriteFoods: [FoodItemData] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient()
    private let localCache = LocalStorageManager()
    
    // MARK: - Initialization
    
    init() {
        loadRecentFoods()
        loadFavoriteFoods()
    }
    
    // MARK: - Food Search
    
    func searchFoods(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        do {
            // Search local cache first for instant results
            let localResults = await searchLocalCache(query: query)
            searchResults = localResults
            
            // Then search remote database
            let remoteResults = try await apiClient.searchFoods(query: query)
            let combinedResults = combineAndDeduplicateResults(
                local: localResults,
                remote: remoteResults
            )
            
            searchResults = combinedResults
            
            // Update local cache with new results
            await updateLocalCache(with: remoteResults)
            
        } catch {
            errorMessage = "Failed to search foods: \(error.localizedDescription)"
            print("Food search error: \(error)")
        }
        
        isSearching = false
    }
    
    func searchByBarcode(_ barcode: String) async -> FoodItemData? {
        do {
            return try await apiClient.searchByBarcode(barcode)
        } catch {
            errorMessage = "Failed to search by barcode: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Custom Food Management
    
    func addCustomFood(_ food: FoodItemData) async -> Bool {
        do {
            // Add to remote database
            let createdFood = try await apiClient.createFood(food)
            
            // Update local cache
            await localCache.addFood(createdFood)
            
            // Add to recent foods
            await addToRecentFoods(createdFood)
            
            return true
        } catch {
            errorMessage = "Failed to add custom food: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Recent Foods
    
    func addToRecentFoods(_ food: FoodItemData) async {
        // Remove if already exists
        recentFoods.removeAll { $0.id == food.id }
        
        // Add to beginning
        recentFoods.insert(food, at: 0)
        
        // Keep only last 20 items
        if recentFoods.count > 20 {
            recentFoods = Array(recentFoods.prefix(20))
        }
        
        // Save to local storage
        await localCache.saveRecentFoods(recentFoods)
    }
    
    private func loadRecentFoods() {
        Task {
            recentFoods = await localCache.loadRecentFoods()
        }
    }
    
    // MARK: - Favorite Foods
    
    func toggleFavorite(_ food: FoodItemData) async {
        if favoriteFoods.contains(where: { $0.id == food.id }) {
            // Remove from favorites
            favoriteFoods.removeAll { $0.id == food.id }
        } else {
            // Add to favorites
            favoriteFoods.append(food)
        }
        
        // Save to local storage
        await localCache.saveFavoriteFoods(favoriteFoods)
        
        // Sync with remote if needed
        do {
            try await apiClient.updateFavorites(favoriteFoods.map { $0.id })
        } catch {
            print("Failed to sync favorites: \(error)")
        }
    }
    
    func isFavorite(_ food: FoodItemData) -> Bool {
        return favoriteFoods.contains { $0.id == food.id }
    }
    
    private func loadFavoriteFoods() {
        Task {
            favoriteFoods = await localCache.loadFavoriteFoods()
        }
    }
    
    // MARK: - Private Methods
    
    private func searchLocalCache(query: String) async -> [FoodItemData] {
        return await localCache.searchFoods(query: query)
    }
    
    private func updateLocalCache(with foods: [FoodItemData]) async {
        await localCache.cacheFoods(foods)
    }
    
    private func combineAndDeduplicateResults(local: [FoodItemData], remote: [FoodItemData]) -> [FoodItemData] {
        var combined = local
        
        for remoteFood in remote {
            if !combined.contains(where: { $0.name.lowercased() == remoteFood.name.lowercased() }) {
                combined.append(remoteFood)
            }
        }
        
        return combined
    }
}

// MARK: - API Client

class APIClient {
    private let baseURL = "https://api.tamiza.app/v1"
    private let session = URLSession.shared
    
    func searchFoods(query: String) async throws -> [FoodItemData] {
        // Simulate API call with mock data for now
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        
        return mockFoodData.filter { food in
            food.name.lowercased().contains(query.lowercased())
        }
    }
    
    func searchByBarcode(_ barcode: String) async throws -> FoodItemData? {
        // Simulate barcode search
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
        
        return mockFoodData.first { $0.name.contains("Banana") } // Mock result
    }
    
    func createFood(_ food: FoodItemData) async throws -> FoodItemData {
        // Simulate food creation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 second delay
        
        return food
    }
    
    func updateFavorites(_ foodIds: [UUID]) async throws {
        // Simulate favorites sync
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
    }
    
    // Mock data for development
    private let mockFoodData: [FoodItemData] = [
        FoodItemData(
            name: "Apple",
            brand: nil,
            calories: 52,
            protein: 0.3,
            fat: 0.2,
            carbs: 14.0,
            fiber: 2.4,
            sugar: 10.4,
            sodium: 1,
            servingSize: 100,
            servingUnit: "g"
        ),
        FoodItemData(
            name: "Banana",
            brand: nil,
            calories: 89,
            protein: 1.1,
            fat: 0.3,
            carbs: 23.0,
            fiber: 2.6,
            sugar: 12.2,
            sodium: 1,
            servingSize: 100,
            servingUnit: "g"
        ),
        FoodItemData(
            name: "Chicken Breast",
            brand: nil,
            calories: 165,
            protein: 31.0,
            fat: 3.6,
            carbs: 0.0,
            fiber: 0.0,
            sugar: 0.0,
            sodium: 74,
            servingSize: 100,
            servingUnit: "g"
        ),
        FoodItemData(
            name: "Brown Rice",
            brand: nil,
            calories: 111,
            protein: 2.6,
            fat: 0.9,
            carbs: 23.0,
            fiber: 1.8,
            sugar: 0.4,
            sodium: 5,
            servingSize: 100,
            servingUnit: "g"
        ),
        FoodItemData(
            name: "Greek Yogurt",
            brand: "Chobani",
            calories: 59,
            protein: 10.0,
            fat: 0.4,
            carbs: 3.6,
            fiber: 0.0,
            sugar: 3.2,
            sodium: 36,
            servingSize: 100,
            servingUnit: "g"
        )
    ]
}

// MARK: - Local Storage Manager

class LocalStorageManager {
    private let userDefaults = UserDefaults.standard
    private let recentFoodsKey = "recent_foods"
    private let favoriteFoodsKey = "favorite_foods"
    private let cachedFoodsKey = "cached_foods"
    
    func saveRecentFoods(_ foods: [FoodItemData]) async {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(foods)
            userDefaults.set(data, forKey: recentFoodsKey)
        } catch {
            print("Failed to save recent foods: \(error)")
        }
    }
    
    func loadRecentFoods() async -> [FoodItemData] {
        guard let data = userDefaults.data(forKey: recentFoodsKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([FoodItemData].self, from: data)
        } catch {
            print("Failed to load recent foods: \(error)")
            return []
        }
    }
    
    func saveFavoriteFoods(_ foods: [FoodItemData]) async {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(foods)
            userDefaults.set(data, forKey: favoriteFoodsKey)
        } catch {
            print("Failed to save favorite foods: \(error)")
        }
    }
    
    func loadFavoriteFoods() async -> [FoodItemData] {
        guard let data = userDefaults.data(forKey: favoriteFoodsKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([FoodItemData].self, from: data)
        } catch {
            print("Failed to load favorite foods: \(error)")
            return []
        }
    }
    
    func cacheFoods(_ foods: [FoodItemData]) async {
        // Implementation for caching search results
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(foods)
            userDefaults.set(data, forKey: cachedFoodsKey)
        } catch {
            print("Failed to cache foods: \(error)")
        }
    }
    
    func searchFoods(query: String) async -> [FoodItemData] {
        guard let data = userDefaults.data(forKey: cachedFoodsKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        do {
            let cachedFoods = try decoder.decode([FoodItemData].self, from: data)
            return cachedFoods.filter { food in
                food.name.lowercased().contains(query.lowercased())
            }
        } catch {
            print("Failed to search cached foods: \(error)")
            return []
        }
    }
    
    func addFood(_ food: FoodItemData) async {
        // Add single food to cache
        var cachedFoods = await loadCachedFoods()
        cachedFoods.append(food)
        await cacheFoods(cachedFoods)
    }
    
    private func loadCachedFoods() async -> [FoodItemData] {
        guard let data = userDefaults.data(forKey: cachedFoodsKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([FoodItemData].self, from: data)
        } catch {
            print("Failed to load cached foods: \(error)")
            return []
        }
    }
}

// MARK: - FoodItemData Codable Extension

extension FoodItemData: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, brand, calories, protein, fat, carbs, fiber, sugar, sodium, servingSize, servingUnit
    }
}