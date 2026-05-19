//
//  UserProfile.cpp
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

#include "UserProfile.hpp"
#include <cmath>
#include <stdexcept>

// MARK: - Constructors and Destructor

UserProfile::UserProfile() {
    initializeDefaults();
}

UserProfile::UserProfile(const std::string& userId, const std::string& name)
    : userId(userId), name(name) {
    initializeDefaults();
}

UserProfile::UserProfile(const UserProfile& other)
    : userId(other.userId)
    , name(other.name)
    , age(other.age)
    , height(other.height)
    , weight(other.weight)
    , gender(other.gender)
    , activityLevel(other.activityLevel)
    , shoulderCircumference(other.shoulderCircumference)
    , neckCircumference(other.neckCircumference)
    , chestCircumference(other.chestCircumference)
    , armCircumference(other.armCircumference)
    , thighCircumference(other.thighCircumference)
    , hipCircumference(other.hipCircumference)
    , calfCircumference(other.calfCircumference)
    , footSize(other.footSize) {
}

UserProfile& UserProfile::operator=(const UserProfile& other) {
    if (this != &other) {
        userId = other.userId;
        name = other.name;
        age = other.age;
        height = other.height;
        weight = other.weight;
        gender = other.gender;
        activityLevel = other.activityLevel;
        shoulderCircumference = other.shoulderCircumference;
        neckCircumference = other.neckCircumference;
        chestCircumference = other.chestCircumference;
        armCircumference = other.armCircumference;
        thighCircumference = other.thighCircumference;
        hipCircumference = other.hipCircumference;
        calfCircumference = other.calfCircumference;
        footSize = other.footSize;
    }
    return *this;
}

// MARK: - Health Calculations

double UserProfile::calculateBMR() const {
    if (!isValid()) {
        return 0.0;
    }
    
    // Mifflin-St Jeor Equation
    double baseBMR = (10.0 * weight) + (6.25 * height) - (5.0 * age);
    
    if (gender == Gender::Male) {
        return baseBMR + 5.0;
    } else {
        return baseBMR - 161.0;
    }
}

double UserProfile::calculateTDEE() const {
    double bmr = calculateBMR();
    if (bmr == 0.0) {
        return 0.0;
    }
    
    return bmr * getActivityMultiplier();
}

double UserProfile::calculateBMI() const {
    if (height <= 0 || weight <= 0) {
        return 0.0;
    }
    
    double heightInMeters = height / 100.0;
    return weight / (heightInMeters * heightInMeters);
}

double UserProfile::calculateBodyFatPercentage() const {
    // Navy Body Fat Formula using neck and waist measurements
    if (neckCircumference <= 0 || hipCircumference <= 0 || height <= 0) {
        return 0.0;
    }
    
    double bodyFat = 0.0;
    
    if (gender == Gender::Male) {
        // Male formula: 495 / (1.0324 - 0.19077 * log10(waist - neck) + 0.15456 * log10(height)) - 450
        double waist = hipCircumference; // Using hip as waist approximation
        bodyFat = 495.0 / (1.0324 - 0.19077 * log10(waist - neckCircumference) + 0.15456 * log10(height)) - 450.0;
    } else {
        // Female formula: 495 / (1.29579 - 0.35004 * log10(waist + hip - neck) + 0.22100 * log10(height)) - 450
        double waist = chestCircumference > 0 ? chestCircumference : hipCircumference * 0.8; // Approximation
        bodyFat = 495.0 / (1.29579 - 0.35004 * log10(waist + hipCircumference - neckCircumference) + 0.22100 * log10(height)) - 450.0;
    }
    
    // Clamp between reasonable values
    return std::max(3.0, std::min(50.0, bodyFat));
}

// MARK: - Utility Methods

bool UserProfile::isValid() const {
    return !name.empty() && 
           age > 0 && age < 150 &&
           height > 50 && height < 300 &&
           weight > 20 && weight < 500;
}

std::string UserProfile::getGenderString() const {
    return genderToString(gender);
}

std::string UserProfile::getActivityLevelString() const {
    return activityLevelToString(activityLevel);
}

// MARK: - JSON Serialization

std::string UserProfile::toJSON() const {
    std::string json = "{\n";
    json += "  \"userId\": \"" + userId + "\",\n";
    json += "  \"name\": \"" + name + "\",\n";
    json += "  \"age\": " + std::to_string(age) + ",\n";
    json += "  \"height\": " + std::to_string(height) + ",\n";
    json += "  \"weight\": " + std::to_string(weight) + ",\n";
    json += "  \"gender\": \"" + genderToString(gender) + "\",\n";
    json += "  \"activityLevel\": \"" + activityLevelToString(activityLevel) + "\",\n";
    
    // Body measurements
    json += "  \"bodyMeasurements\": {\n";
    json += "    \"shoulderCircumference\": " + std::to_string(shoulderCircumference) + ",\n";
    json += "    \"neckCircumference\": " + std::to_string(neckCircumference) + ",\n";
    json += "    \"chestCircumference\": " + std::to_string(chestCircumference) + ",\n";
    json += "    \"armCircumference\": " + std::to_string(armCircumference) + ",\n";
    json += "    \"thighCircumference\": " + std::to_string(thighCircumference) + ",\n";
    json += "    \"hipCircumference\": " + std::to_string(hipCircumference) + ",\n";
    json += "    \"calfCircumference\": " + std::to_string(calfCircumference) + ",\n";
    json += "    \"footSize\": " + std::to_string(footSize) + "\n";
    json += "  }\n";
    json += "}";
    
    return json;
}

bool UserProfile::fromJSON(const std::string& json) {
    // Simple JSON parsing - in a real implementation, use a proper JSON library
    // This is a basic implementation for demonstration
    return false; // Not implemented in this basic version
}

// MARK: - Private Methods

double UserProfile::getActivityMultiplier() const {
    switch (activityLevel) {
        case ActivityLevel::Sedentary:
            return 1.2;
        case ActivityLevel::Light:
            return 1.375;
        case ActivityLevel::Moderate:
            return 1.55;
        case ActivityLevel::Active:
            return 1.725;
        case ActivityLevel::VeryActive:
            return 1.9;
        default:
            return 1.55; // Default to moderate
    }
}

void UserProfile::initializeDefaults() {
    age = 0;
    height = 0.0;
    weight = 0.0;
    gender = Gender::Male;
    activityLevel = ActivityLevel::Moderate;
    
    // Initialize body measurements to 0
    shoulderCircumference = 0.0;
    neckCircumference = 0.0;
    chestCircumference = 0.0;
    armCircumference = 0.0;
    thighCircumference = 0.0;
    hipCircumference = 0.0;
    calfCircumference = 0.0;
    footSize = 0.0;
}

// MARK: - Helper Functions

Gender stringToGender(const std::string& genderStr) {
    if (genderStr == "female" || genderStr == "Female") {
        return Gender::Female;
    }
    return Gender::Male; // Default to male
}

std::string genderToString(Gender gender) {
    switch (gender) {
        case Gender::Male:
            return "male";
        case Gender::Female:
            return "female";
        default:
            return "male";
    }
}

ActivityLevel stringToActivityLevel(const std::string& levelStr) {
    if (levelStr == "sedentary") return ActivityLevel::Sedentary;
    if (levelStr == "light") return ActivityLevel::Light;
    if (levelStr == "moderate") return ActivityLevel::Moderate;
    if (levelStr == "active") return ActivityLevel::Active;
    if (levelStr == "very_active") return ActivityLevel::VeryActive;
    return ActivityLevel::Moderate; // Default
}

std::string activityLevelToString(ActivityLevel level) {
    switch (level) {
        case ActivityLevel::Sedentary:
            return "sedentary";
        case ActivityLevel::Light:
            return "light";
        case ActivityLevel::Moderate:
            return "moderate";
        case ActivityLevel::Active:
            return "active";
        case ActivityLevel::VeryActive:
            return "very_active";
        default:
            return "moderate";
    }
}