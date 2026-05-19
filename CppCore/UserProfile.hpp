//
//  UserProfile.hpp
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

#ifndef UserProfile_hpp
#define UserProfile_hpp

#include <string>
#include <memory>
#include <vector>
#include <chrono>
#include <iostream>

enum class Gender {
    Male,
    Female
};

enum class ActivityLevel {
    Sedentary,      // 1.2
    Light,          // 1.375
    Moderate,       // 1.55
    Active,         // 1.725
    VeryActive      // 1.9
};

class UserProfile {
private:
    std::string userId;
    std::string name;
    int age;
    double height;          // cm
    double weight;          // kg
    Gender gender;
    ActivityLevel activityLevel;
    
    // Body measurements
    double shoulderCircumference;   // cm
    double neckCircumference;       // cm
    double chestCircumference;      // cm
    double armCircumference;        // cm
    double thighCircumference;      // cm
    double hipCircumference;        // cm
    double calfCircumference;       // cm
    double footSize;                // cm
    
public:
    // Constructors
    UserProfile();
    UserProfile(const std::string& userId, const std::string& name);
    UserProfile(const UserProfile& other);
    UserProfile& operator=(const UserProfile& other);
    ~UserProfile() = default;
    
    // Getters
    const std::string& getUserId() const { return userId; }
    const std::string& getName() const { return name; }
    int getAge() const { return age; }
    double getHeight() const { return height; }
    double getWeight() const { return weight; }
    Gender getGender() const { return gender; }
    ActivityLevel getActivityLevel() const { return activityLevel; }
    
    // Body measurements getters
    double getShoulderCircumference() const { return shoulderCircumference; }
    double getNeckCircumference() const { return neckCircumference; }
    double getChestCircumference() const { return chestCircumference; }
    double getArmCircumference() const { return armCircumference; }
    double getThighCircumference() const { return thighCircumference; }
    double getHipCircumference() const { return hipCircumference; }
    double getCalfCircumference() const { return calfCircumference; }
    double getFootSize() const { return footSize; }
    
    // Setters
    void setUserId(const std::string& id) { userId = id; }
    void setName(const std::string& n) { name = n; }
    void setAge(int a) { age = a; }
    void setHeight(double h) { height = h; }
    void setWeight(double w) { weight = w; }
    void setGender(Gender g) { gender = g; }
    void setActivityLevel(ActivityLevel level) { activityLevel = level; }
    
    // Body measurements setters
    void setShoulderCircumference(double value) { shoulderCircumference = value; }
    void setNeckCircumference(double value) { neckCircumference = value; }
    void setChestCircumference(double value) { chestCircumference = value; }
    void setArmCircumference(double value) { armCircumference = value; }
    void setThighCircumference(double value) { thighCircumference = value; }
    void setHipCircumference(double value) { hipCircumference = value; }
    void setCalfCircumference(double value) { calfCircumference = value; }
    void setFootSize(double value) { footSize = value; }
    
    // Health calculations
    double calculateBMR() const;
    double calculateTDEE() const;
    double calculateBMI() const;
    double calculateBodyFatPercentage() const;
    
    // Utility methods
    bool isValid() const;
    std::string getGenderString() const;
    std::string getActivityLevelString() const;
    
    // JSON serialization
    std::string toJSON() const;
    bool fromJSON(const std::string& json);
    
private:
    double getActivityMultiplier() const;
    void initializeDefaults();
};

// Helper functions for enum conversions
Gender stringToGender(const std::string& genderStr);
std::string genderToString(Gender gender);
ActivityLevel stringToActivityLevel(const std::string& levelStr);
std::string activityLevelToString(ActivityLevel level);

#endif /* UserProfile_hpp */