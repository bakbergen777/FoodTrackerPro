//
//  UserProfile.hpp
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

#ifndef UserProfile_hpp
#define UserProfile_hpp

// Objective-C++ compatibility guards
#ifdef __cplusplus

#include <string>
#include <vector>
#include <memory>
#include <chrono>
#include <iostream>

namespace TamizaCore {

// Forward declarations
class FoodItem;
class NutritionGoals;

// Enums
enum class Gender {
    Male,
    Female,
    Other
};

enum class ActivityLevel {
    Sedentary,      // Little to no exercise
    LightlyActive,  // Light exercise 1-3 days/week
    ModeratelyActive, // Moderate exercise 3-5 days/week
    VeryActive,     // Hard exercise 6-7 days/week
    ExtraActive     // Very hard exercise, physical job
};

enum class Goal {
    MaintainWeight,
    LoseWeight,
    GainWeight,
    BuildMuscle
};

// Structures
struct PhysicalStats {
    double height_cm;
    double weight_kg;
    int age;
    Gender gender;
    ActivityLevel activity_level;
    
    PhysicalStats() : height_cm(170.0), weight_kg(70.0), age(25), 
                     gender(Gender::Other), activity_level(ActivityLevel::ModeratelyActive) {}
    
    PhysicalStats(double height, double weight, int age_years, Gender g, ActivityLevel activity)
        : height_cm(height), weight_kg(weight), age(age_years), gender(g), activity_level(activity) {}
};

struct NutritionGoals {
    double daily_calories;
    double daily_protein_g;
    double daily_fat_g;
    double daily_carbs_g;
    double daily_fiber_g;
    double daily_sugar_g;
    double daily_sodium_mg;
    
    NutritionGoals() : daily_calories(2000), daily_protein_g(150), daily_fat_g(65),
                      daily_carbs_g(250), daily_fiber_g(25), daily_sugar_g(50), daily_sodium_mg(2300) {}
    
    NutritionGoals(double calories, double protein, double fat, double carbs)
        : daily_calories(calories), daily_protein_g(protein), daily_fat_g(fat), daily_carbs_g(carbs),
          daily_fiber_g(25), daily_sugar_g(50), daily_sodium_mg(2300) {}
};

struct DailyProgress {
    std::chrono::system_clock::time_point date;
    double consumed_calories;
    double consumed_protein_g;
    double consumed_fat_g;
    double consumed_carbs_g;
    double consumed_fiber_g;
    double consumed_sugar_g;
    double consumed_sodium_mg;
    int meals_logged;
    
    DailyProgress() : date(std::chrono::system_clock::now()), consumed_calories(0),
                     consumed_protein_g(0), consumed_fat_g(0), consumed_carbs_g(0),
                     consumed_fiber_g(0), consumed_sugar_g(0), consumed_sodium_mg(0), meals_logged(0) {}
};

// Main UserProfile class
class UserProfile {
private:
    std::string user_id;
    std::string name;
    std::string email;
    PhysicalStats physical_stats;
    NutritionGoals nutrition_goals;
    Goal fitness_goal;
    std::vector<DailyProgress> daily_progress_history;
    std::chrono::system_clock::time_point created_at;
    std::chrono::system_clock::time_point updated_at;
    
    // Private helper methods
    double calculateBMR() const;
    double calculateTDEE() const;
    NutritionGoals calculateRecommendedGoals() const;
    void updateTimestamp();

public:
    // Constructors
    UserProfile();
    UserProfile(const std::string& id, const std::string& name, const std::string& email);
    UserProfile(const std::string& id, const std::string& name, const std::string& email,
               const PhysicalStats& stats, Goal goal);
    
    // Destructor
    ~UserProfile();
    
    // Copy constructor and assignment operator
    UserProfile(const UserProfile& other);
    UserProfile& operator=(const UserProfile& other);
    
    // Move constructor and assignment operator
    UserProfile(UserProfile&& other) noexcept;
    UserProfile& operator=(UserProfile&& other) noexcept;
    
    // Getters
    const std::string& getUserId() const { return user_id; }
    const std::string& getName() const { return name; }
    const std::string& getEmail() const { return email; }
    const PhysicalStats& getPhysicalStats() const { return physical_stats; }
    const NutritionGoals& getNutritionGoals() const { return nutrition_goals; }
    Goal getFitnessGoal() const { return fitness_goal; }
    const std::vector<DailyProgress>& getDailyProgressHistory() const { return daily_progress_history; }
    std::chrono::system_clock::time_point getCreatedAt() const { return created_at; }
    std::chrono::system_clock::time_point getUpdatedAt() const { return updated_at; }
    
    // Setters
    void setName(const std::string& new_name);
    void setEmail(const std::string& new_email);
    void setPhysicalStats(const PhysicalStats& stats);
    void setNutritionGoals(const NutritionGoals& goals);
    void setFitnessGoal(Goal goal);
    
    // Nutrition calculation methods
    double getBMR() const { return calculateBMR(); }
    double getTDEE() const { return calculateTDEE(); }
    double getBMI() const;
    std::string getBMICategory() const;
    NutritionGoals getRecommendedGoals() const { return calculateRecommendedGoals(); }
    
    // Progress tracking methods
    void addDailyProgress(const DailyProgress& progress);
    DailyProgress* getTodaysProgress();
    const DailyProgress* getTodaysProgress() const;
    DailyProgress* getProgressForDate(const std::chrono::system_clock::time_point& date);
    const DailyProgress* getProgressForDate(const std::chrono::system_clock::time_point& date) const;
    
    // Food logging methods
    void logFood(const FoodItem& food, double serving_size = 1.0);
    void logFood(const FoodItem& food, const std::chrono::system_clock::time_point& date, double serving_size = 1.0);
    
    // Analytics methods
    double getAverageCaloriesLastWeek() const;
    double getAverageCaloriesLastMonth() const;
    std::vector<double> getWeeklyCaloriesTrend() const;
    std::vector<double> getMonthlyCaloriesTrend() const;
    
    // Goal progress methods
    double getCalorieGoalProgress() const;
    double getProteinGoalProgress() const;
    double getFatGoalProgress() const;
    double getCarbsGoalProgress() const;
    double getOverallGoalProgress() const;
    
    // Validation methods
    bool isValidProfile() const;
    std::vector<std::string> getValidationErrors() const;
    
    // Serialization methods
    std::string toJSON() const;
    bool fromJSON(const std::string& json);
    
    // Utility methods
    void resetDailyProgress();
    void clearProgressHistory();
    size_t getProgressHistorySize() const { return daily_progress_history.size(); }
    
    // Comparison operators
    bool operator==(const UserProfile& other) const;
    bool operator!=(const UserProfile& other) const { return !(*this == other); }
    
    // Stream operators
    friend std::ostream& operator<<(std::ostream& os, const UserProfile& profile);
};

// Utility functions
std::string genderToString(Gender gender);
Gender stringToGender(const std::string& str);
std::string activityLevelToString(ActivityLevel level);
ActivityLevel stringToActivityLevel(const std::string& str);
std::string goalToString(Goal goal);
Goal stringToGoal(const std::string& str);

// Constants
namespace Constants {
    constexpr double MIN_HEIGHT_CM = 100.0;
    constexpr double MAX_HEIGHT_CM = 250.0;
    constexpr double MIN_WEIGHT_KG = 30.0;
    constexpr double MAX_WEIGHT_KG = 300.0;
    constexpr int MIN_AGE = 13;
    constexpr int MAX_AGE = 120;
    constexpr double MIN_CALORIES = 800.0;
    constexpr double MAX_CALORIES = 5000.0;
}

} // namespace TamizaCore

#endif // __cplusplus

#endif /* UserProfile_hpp */