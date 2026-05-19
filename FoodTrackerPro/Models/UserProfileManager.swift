//
//  UserProfileManager.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import Foundation

class UserProfileManager {
    private let userDefaults = UserDefaults.standard
    private let profileKey = "user_profile"
    
    // MARK: - Profile Management
    
    func createUserProfile(_ profile: UserProfileData) async {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(profile)
            userDefaults.set(data, forKey: profileKey)
        } catch {
            print("Failed to save user profile: \(error)")
        }
    }
    
    func loadUserProfile() async -> UserProfileData? {
        guard let data = userDefaults.data(forKey: profileKey) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(UserProfileData.self, from: data)
        } catch {
            print("Failed to load user profile: \(error)")
            return nil
        }
    }
    
    func updateUserProfile(_ profile: UserProfileData) async {
        await createUserProfile(profile)
    }
    
    func deleteUserProfile() async {
        userDefaults.removeObject(forKey: profileKey)
    }
}

// MARK: - UserProfileData Codable Extension

extension UserProfileData: Codable {
    enum CodingKeys: String, CodingKey {
        case name, age, height, weight, gender, activityLevel
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)
        height = try container.decode(Double.self, forKey: .height)
        weight = try container.decode(Double.self, forKey: .weight)
        
        let genderString = try container.decode(String.self, forKey: .gender)
        gender = Gender(rawValue: genderString) ?? .male
        
        let activityString = try container.decode(String.self, forKey: .activityLevel)
        activityLevel = ActivityLevel(rawValue: activityString) ?? .moderate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(age, forKey: .age)
        try container.encode(height, forKey: .height)
        try container.encode(weight, forKey: .weight)
        try container.encode(gender.rawValue, forKey: .gender)
        try container.encode(activityLevel.rawValue, forKey: .activityLevel)
    }
}

// MARK: - Enum Extensions

extension Gender: Codable {
    var rawValue: String {
        switch self {
        case .male: return "male"
        case .female: return "female"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue {
        case "male": self = .male
        case "female": self = .female
        default: return nil
        }
    }
}

extension ActivityLevel: Codable {
    var rawValue: String {
        switch self {
        case .sedentary: return "sedentary"
        case .light: return "light"
        case .moderate: return "moderate"
        case .active: return "active"
        case .veryActive: return "very_active"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue {
        case "sedentary": self = .sedentary
        case "light": self = .light
        case "moderate": self = .moderate
        case "active": self = .active
        case "very_active": self = .veryActive
        default: return nil
        }
    }
}