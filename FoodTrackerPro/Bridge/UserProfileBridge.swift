//
//  UserProfileBridge.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//  Swift wrapper for C++ UserProfile using Objective-C++ bridge
//

import Foundation

// Swift enums that match the Objective-C bridge enums
public enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    
    var bridgeValue: TamizaGender {
        switch self {
        case .male: return TamizaGenderMale
        case .female: return TamizaGenderFemale
        }
    }
    
    init(from bridgeValue: TamizaGender) {
        switch bridgeValue {
        case TamizaGenderMale: self = .male
        case TamizaGenderFemale: self = .female
        default: self = .male
        }
    }
}

public enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "sedentary"
    case light = "light"
    case moderate = "moderate"
    case active = "active"
    case veryActive = "very_active"
    
    var bridgeValue: TamizaActivityLevel {
        switch self {
        case .sedentary: return TamizaActivityLevelSedentary
        case .light: return TamizaActivityLevelLight
        case .moderate: return TamizaActivityLevelModerate
        case .active: return TamizaActivityLevelActive
        case .veryActive: return TamizaActivityLevelVeryActive
        }
    }
    
    init(from bridgeValue: TamizaActivityLevel) {
        switch bridgeValue {
        case TamizaActivityLevelSedentary: self = .sedentary
        case TamizaActivityLevelLight: self = .light
        case TamizaActivityLevelModerate: self = .moderate
        case TamizaActivityLevelActive: self = .active
        case TamizaActivityLevelVeryActive: self = .veryActive
        default: self = .moderate
        }
    }
}

// Swift data structure that matches the existing UserProfileData
public struct UserProfileData: Codable {
    public var name: String
    public var age: Int
    public var height: Double // cm
    public var weight: Double // kg
    public var gender: Gender
    public var activityLevel: ActivityLevel
    
    // Body measurements
    public var shoulderCircumference: Double = 0.0
    public var neckCircumference: Double = 0.0
    public var chestCircumference: Double = 0.0
    public var armCircumference: Double = 0.0
    public var thighCircumference: Double = 0.0
    public var hipCircumference: Double = 0.0
    public var calfCircumference: Double = 0.0
    public var footSize: Double = 0.0
    
    public init(name: String, age: Int, height: Double, weight: Double, gender: Gender, activityLevel: ActivityLevel) {
        self.name = name
        self.age = age
        self.height = height
        self.weight = weight
        self.gender = gender
        self.activityLevel = activityLevel
    }
}

// Swift wrapper class that uses the C++ bridge
public class UserProfileBridge {
    private let bridge: TamizaUserProfileBridge
    
    public init() {
        self.bridge = TamizaUserProfileBridge()
    }
    
    public init(userId: String, name: String) {
        self.bridge = TamizaUserProfileBridge(userId: userId, name: name)
    }
    
    public init(from profileData: UserProfileData) {
        self.bridge = TamizaUserProfileBridge()
        self.updateFromProfileData(profileData)
    }
    
    // MARK: - Properties
    
    public var userId: String {
        get { bridge.userId }
        set { bridge.userId = newValue }
    }
    
    public var name: String {
        get { bridge.name }
        set { bridge.name = newValue }
    }
    
    public var age: Int {
        get { Int(bridge.age) }
        set { bridge.age = newValue }
    }
    
    public var height: Double {
        get { bridge.height }
        set { bridge.height = newValue }
    }
    
    public var weight: Double {
        get { bridge.weight }
        set { bridge.weight = newValue }
    }
    
    public var gender: Gender {
        get { Gender(from: bridge.gender) }
        set { bridge.gender = newValue.bridgeValue }
    }
    
    public var activityLevel: ActivityLevel {
        get { ActivityLevel(from: bridge.activityLevel) }
        set { bridge.activityLevel = newValue.bridgeValue }
    }
    
    // Body measurements
    public var shoulderCircumference: Double {
        get { bridge.shoulderCircumference }
        set { bridge.shoulderCircumference = newValue }
    }
    
    public var neckCircumference: Double {
    
    public init(userId: String, name: String) {
        self.bridge = TamizaUserProfileBridge(userId: userId, name: name)
        
        // Initialize properties from bridge
        self.userId = bridge.userId
        self.name = bridge.name
        self.age = Int(bridge.age)
        self.height = bridge.height
        self.weight = bridge.weight
        self.gender = Gender(from: bridge.gender)
        self.activityLevel = ActivityLevel(from: bridge.activityLevel)
        
        // Body measurements
    }
    
    public func calculateBodyFatPercentage() -> Double {
        return bridge.calculateBodyFatPercentage()
    }
    
    // MARK: - Utility Methods
    
    public func isValid() -> Bool {
        return bridge.isValid()
    }
    
