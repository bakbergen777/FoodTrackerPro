//
//  UserProfile.cpp
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

#include "UserProfile.hpp"
#include "FoodItem.hpp"
#include <algorithm>
#include <cmath>
#include <sstream>
#include <iomanip>

namespace TamizaCore {

// UserProfile Implementation

// Constructors
UserProfile::UserProfile() 
    : user_id(""), name(""), email(""), fitness_goal(Goal::MaintainWeight),
      created_at(std::chrono::system_clock::now()), updated_at(std::chrono::system_clock::now()) {
}

UserProfile::UserProfile(const std::string& id, const std::string& name, const std::string& email)
    : user_id(id), name(name), email(email), fitness_goal(Goal::MaintainWeight),
      created_at(std::chrono::system_clock::now()), updated_at(std::chrono::system_clock::now()) {
}

UserProfile::UserProfile(const std::string& id, const std::string& name, const std::string& email,
                        const PhysicalStats& stats, Goal goal)
    : user_id(id), name(name), email(email), physical_stats(stats), fitness_goal(goal),
      created_at(std::chrono::system_clock::now()), updated_at(std::chrono::system_clock::now()) {
    nutrition_goals = calculateRecommendedGoals();
}

// Destructor
UserProfile::~UserProfile() = default;

// Copy constructor
UserProfile::UserProfile(const UserProfile& other)
    : user_id(other.user_id), name(other.name), email(other.email),
      physical_stats(other.physical_stats), nutrition_goals(other.nutrition_goals),
      fitness_goal(other.fitness_goal), daily_progress_history(other.daily_progress_history),
      created_at(other.created_at), updated_at(other.updated_at) {
}

// Copy assignment operator
UserProfile& UserProfile::operator=(const UserProfile& other) {
    if (this != &other) {
        user_id = other.user_id;
        name = other.name;
        email = other.email;
        physical_stats = other.physical_stats;
        nutrition_goals = other.nutrition_goals;
        fitness_goal = other.fitness_goal;
        daily_progress_history = other.daily_progress_history;
        created_at = other.created_at;
        updated_at = other.updated_at;
    }
    return *this;
}

// Move constructor
UserProfile::UserProfile(UserProfile&& other) noexcept
    : user_id(std::move(other.user_id)), name(std::move(other.name)), email(std::move(other.email)),
      physical_stats(std::move(other.physical_stats)), nutrition_goals(std::move(other.nutrition_goals)),
      fitness_goal(other.fitness_goal), daily_progress_history(std::move(other.daily_progress_history)),
      created_at(other.created_at), updated_at(other.updated_at) {
}

// Move assignment operator
UserProfile& UserProfile::operator=(UserProfile&& other) noexcept {
    if (this != &other) {
        user_id = std::move(other.user_id);
        name = std::move(other.name);
        email = std::move(other.email);
        physical_stats = std::move(other.physical_stats);
        nutrition_goals = std::move(other.nutrition_goals);
        fitness_goal = other.fitness_goal;
        daily_progress_history = std::move(other.daily_progress_history);
        created_at = other.created_at;
        updated_at = other.updated_at;
    }
    return *this;
}

// Setters
void UserProfile::setName(const std::string& new_name) {
    name = new_name;
    updateTimestamp();
}

void UserProfile::setEmail(const std::string& new_email) {
    email = new_email;
    updateTimestamp();
}

void UserProfile::setPhysicalStats(const PhysicalStats& stats) {
    physical_stats = stats;
    nutrition_goals = calculateRecommendedGoals(); // Recalculate goals based on new stats
    updateTimestamp();
}

void UserProfile::setNutritionGoals(const NutritionGoals& goals) {
    nutrition_goals = goals;
    updateTimestamp();
}

void UserProfile::setFitnessGoal(Goal goal) {
    fitness_goal = goal;
    nutrition_goals = calculateRecommendedGoals(); // Recalculate goals based on new fitness goal
    updateTimestamp();
}

// Private helper methods
double UserProfile::calculateBMR() const {
    // Mifflin-St Jeor Equation
    double bmr = 10.0 * physical_stats.weight_kg + 6.25 * physical_stats.height_cm - 5.0 * physical_stats.age;
    
    if (physical_stats.gender == Gender::Male) {
        bmr += 5.0;
    } else if (physical_stats.gender == Gender::Female) {
        bmr -= 161.0;
    } else {
        bmr -= 78.0; // Average for other genders
    }
    
    return std::max(bmr, Constants::MIN_CALORIES);
}

double UserProfile::calculateTDEE() const {
    double bmr = calculateBMR();
    double activity_multiplier = 1.2; // Sedentary default
    
    switch (physical_stats.activity_level) {
        case ActivityLevel::Sedentary:
            activity_multiplier = 1.2;
            break;
        case ActivityLevel::LightlyActive:
            activity_multiplier = 1.375;
            break;
        case ActivityLevel::ModeratelyActive:
            activity_multiplier = 1.55;
            break;
        case ActivityLevel::VeryActive:
            activity_multiplier = 1.725;
            break;
        case ActivityLevel::ExtraActive:
            activity_multiplier = 1.9;
            break;
    }
    
    return bmr * activity_multiplier;
}

NutritionGoals UserProfile::calculateRecommendedGoals() const {
    double tdee = calculateTDEE();
    double target_calories = tdee;
    
    // Adjust calories based on fitness goal
    switch (fitness_goal) {
        case Goal::LoseWeight:
            target_calories = tdee * 0.8; // 20% deficit
            break;
        case Goal::GainWeight:
        case Goal::BuildMuscle:
            target_calories = tdee * 1.15; // 15% surplus
            break;
        case Goal::MaintainWeight:
        default:
            target_calories = tdee;
            break;
    }
    
    // Ensure calories are within reasonable bounds
    target_calories = std::clamp(target_calories, Constants::MIN_CALORIES, Constants::MAX_CALORIES);
    
    // Calculate macronutrients
    double protein_g = physical_stats.weight_kg * 2.0; // 2g per kg body weight
    double fat_g = target_calories * 0.25 / 9.0; // 25% of calories from fat
    double carbs_g = (target_calories - (protein_g * 4.0) - (fat_g * 9.0)) / 4.0; // Remaining calories from carbs
    
    // Adjust for muscle building goal
    if (fitness_goal == Goal::BuildMuscle) {
        protein_g = physical_stats.weight_kg * 2.5; // Higher protein for muscle building
    }
    
    return NutritionGoals(target_calories, protein_g, fat_g, carbs_g);
}

void UserProfile::updateTimestamp() {
    updated_at = std::chrono::system_clock::now();
}

// Nutrition calculation methods
double UserProfile::getBMI() const {
    double height_m = physical_stats.height_cm / 100.0;
    return physical_stats.weight_kg / (height_m * height_m);
}

std::string UserProfile::getBMICategory() const {
    double bmi = getBMI();
    
    if (bmi < 18.5) {
        return "Underweight";
    } else if (bmi < 25.0) {
        return "Normal weight";
    } else if (bmi < 30.0) {
        return "Overweight";
    } else {
        return "Obese";
    }
}

// Progress tracking methods
void UserProfile::addDailyProgress(const DailyProgress& progress) {
    // Remove existing progress for the same date
    auto it = std::remove_if(daily_progress_history.begin(), daily_progress_history.end(),
        [&progress](const DailyProgress& existing) {
            auto progress_time = std::chrono::system_clock::to_time_t(progress.date);
            auto existing_time = std::chrono::system_clock::to_time_t(existing.date);
            
            std::tm progress_tm = *std::localtime(&progress_time);
            std::tm existing_tm = *std::localtime(&existing_time);
            
            return progress_tm.tm_year == existing_tm.tm_year &&
                   progress_tm.tm_mon == existing_tm.tm_mon &&
                   progress_tm.tm_mday == existing_tm.tm_mday;
        });
    
    daily_progress_history.erase(it, daily_progress_history.end());
    daily_progress_history.push_back(progress);
    
    // Sort by date
    std::sort(daily_progress_history.begin(), daily_progress_history.end(),
        [](const DailyProgress& a, const DailyProgress& b) {
            return a.date < b.date;
        });
    
    updateTimestamp();
}

DailyProgress* UserProfile::getTodaysProgress() {
    auto now = std::chrono::system_clock::now();
    return getProgressForDate(now);
}

const DailyProgress* UserProfile::getTodaysProgress() const {
    auto now = std::chrono::system_clock::now();
    return getProgressForDate(now);
}

DailyProgress* UserProfile::getProgressForDate(const std::chrono::system_clock::time_point& date) {
    auto target_time = std::chrono::system_clock::to_time_t(date);
    std::tm target_tm = *std::localtime(&target_time);
    
    auto it = std::find_if(daily_progress_history.begin(), daily_progress_history.end(),
        [&target_tm](const DailyProgress& progress) {
            auto progress_time = std::chrono::system_clock::to_time_t(progress.date);
            std::tm progress_tm = *std::localtime(&progress_time);
            
            return progress_tm.tm_year == target_tm.tm_year &&
                   progress_tm.tm_mon == target_tm.tm_mon &&
                   progress_tm.tm_mday == target_tm.tm_mday;
        });
    
    if (it != daily_progress_history.end()) {
        return &(*it);
    }
    
    // Create new progress entry for this date
    DailyProgress new_progress;
    new_progress.date = date;
    daily_progress_history.push_back(new_progress);
    
    // Sort by date
    std::sort(daily_progress_history.begin(), daily_progress_history.end(),
        [](const DailyProgress& a, const DailyProgress& b) {
            return a.date < b.date;
        });
    
    return getProgressForDate(date); // Recursive call to get the newly added progress
}

const DailyProgress* UserProfile::getProgressForDate(const std::chrono::system_clock::time_point& date) const {
    auto target_time = std::chrono::system_clock::to_time_t(date);
    std::tm target_tm = *std::localtime(&target_time);
    
    auto it = std::find_if(daily_progress_history.begin(), daily_progress_history.end(),
        [&target_tm](const DailyProgress& progress) {
            auto progress_time = std::chrono::system_clock::to_time_t(progress.date);
            std::tm progress_tm = *std::localtime(&progress_time);
            
            return progress_tm.tm_year == target_tm.tm_year &&
                   progress_tm.tm_mon == target_tm.tm_mon &&
                   progress_tm.tm_mday == target_tm.tm_mday;
        });
    
    return (it != daily_progress_history.end()) ? &(*it) : nullptr;
}

// Food logging methods
void UserProfile::logFood(const FoodItem& food, double serving_size) {
    auto now = std::chrono::system_clock::now();
    logFood(food, now, serving_size);
}

void UserProfile::logFood(const FoodItem& food, const std::chrono::system_clock::time_point& date, double serving_size) {
    DailyProgress* progress = getProgressForDate(date);
    if (progress) {
        progress->consumed_calories += food.getCaloriesPer100g() * serving_size;
        progress->consumed_protein_g += food.getProteinPer100g() * serving_size;
        progress->consumed_fat_g += food.getFatPer100g() * serving_size;
        progress->consumed_carbs_g += food.getCarbsPer100g() * serving_size;
        progress->consumed_fiber_g += food.getFiberPer100g() * serving_size;
        progress->consumed_sugar_g += food.getSugarPer100g() * serving_size;
        progress->consumed_sodium_mg += food.getSodiumPer100g() * serving_size;
        progress->meals_logged++;
        
        updateTimestamp();
    }
}

// Analytics methods
double UserProfile::getAverageCaloriesLastWeek() const {
    auto now = std::chrono::system_clock::now();
    auto week_ago = now - std::chrono::hours(24 * 7);
    
    double total_calories = 0.0;
    int days_count = 0;
    
    for (const auto& progress : daily_progress_history) {
        if (progress.date >= week_ago && progress.date <= now) {
            total_calories += progress.consumed_calories;
            days_count++;
        }
    }
    
    return days_count > 0 ? total_calories / days_count : 0.0;
}

double UserProfile::getAverageCaloriesLastMonth() const {
    auto now = std::chrono::system_clock::now();
    auto month_ago = now - std::chrono::hours(24 * 30);
    
    double total_calories = 0.0;
    int days_count = 0;
    
    for (const auto& progress : daily_progress_history) {
        if (progress.date >= month_ago && progress.date <= now) {
            total_calories += progress.consumed_calories;
            days_count++;
        }
    }
    
    return days_count > 0 ? total_calories / days_count : 0.0;
}

std::vector<double> UserProfile::getWeeklyCaloriesTrend() const {
    std::vector<double> trend;
    auto now = std::chrono::system_clock::now();
    
    for (int i = 6; i >= 0; i--) {
        auto day = now - std::chrono::hours(24 * i);
        const DailyProgress* progress = getProgressForDate(day);
        trend.push_back(progress ? progress->consumed_calories : 0.0);
    }
    
    return trend;
}

std::vector<double> UserProfile::getMonthlyCaloriesTrend() const {
    std::vector<double> trend;
    auto now = std::chrono::system_clock::now();
    
    for (int i = 29; i >= 0; i--) {
        auto day = now - std::chrono::hours(24 * i);
        const DailyProgress* progress = getProgressForDate(day);
        trend.push_back(progress ? progress->consumed_calories : 0.0);
    }
    
    return trend;
}

// Goal progress methods
double UserProfile::getCalorieGoalProgress() const {
    const DailyProgress* today = getTodaysProgress();
    if (!today) return 0.0;
    
    return today->consumed_calories / nutrition_goals.daily_calories;
}

double UserProfile::getProteinGoalProgress() const {
    const DailyProgress* today = getTodaysProgress();
    if (!today) return 0.0;
    
    return today->consumed_protein_g / nutrition_goals.daily_protein_g;
}

double UserProfile::getFatGoalProgress() const {
    const DailyProgress* today = getTodaysProgress();
    if (!today) return 0.0;
    
    return today->consumed_fat_g / nutrition_goals.daily_fat_g;
}

double UserProfile::getCarbsGoalProgress() const {
    const DailyProgress* today = getTodaysProgress();
    if (!today) return 0.0;
    
    return today->consumed_carbs_g / nutrition_goals.daily_carbs_g;
}

double UserProfile::getOverallGoalProgress() const {
    double calorie_progress = getCalorieGoalProgress();
    double protein_progress = getProteinGoalProgress();
    double fat_progress = getFatGoalProgress();
    double carbs_progress = getCarbsGoalProgress();
    
    return (calorie_progress + protein_progress + fat_progress + carbs_progress) / 4.0;
}

// Validation methods
bool UserProfile::isValidProfile() const {
    return getValidationErrors().empty();
}

std::vector<std::string> UserProfile::getValidationErrors() const {
    std::vector<std::string> errors;
    
    if (user_id.empty()) {
        errors.push_back("User ID cannot be empty");
    }
    
    if (name.empty()) {
        errors.push_back("Name cannot be empty");
    }
    
    if (email.empty()) {
        errors.push_back("Email cannot be empty");
    }
    
    if (physical_stats.height_cm < Constants::MIN_HEIGHT_CM || physical_stats.height_cm > Constants::MAX_HEIGHT_CM) {
        errors.push_back("Height must be between " + std::to_string(Constants::MIN_HEIGHT_CM) + 
                        " and " + std::to_string(Constants::MAX_HEIGHT_CM) + " cm");
    }
    
    if (physical_stats.weight_kg < Constants::MIN_WEIGHT_KG || physical_stats.weight_kg > Constants::MAX_WEIGHT_KG) {
        errors.push_back("Weight must be between " + std::to_string(Constants::MIN_WEIGHT_KG) + 
                        " and " + std::to_string(Constants::MAX_WEIGHT_KG) + " kg");
    }
    
    if (physical_stats.age < Constants::MIN_AGE || physical_stats.age > Constants::MAX_AGE) {
        errors.push_back("Age must be between " + std::to_string(Constants::MIN_AGE) + 
                        " and " + std::to_string(Constants::MAX_AGE) + " years");
    }
    
    if (nutrition_goals.daily_calories < Constants::MIN_CALORIES || nutrition_goals.daily_calories > Constants::MAX_CALORIES) {
        errors.push_back("Daily calories must be between " + std::to_string(Constants::MIN_CALORIES) + 
                        " and " + std::to_string(Constants::MAX_CALORIES));
    }
    
    return errors;
}

// Serialization methods
std::string UserProfile::toJSON() const {
    std::ostringstream json;
    json << std::fixed << std::setprecision(2);
    
    json << "{\n";
    json << "  \"user_id\": \"" << user_id << "\",\n";
    json << "  \"name\": \"" << name << "\",\n";
    json << "  \"email\": \"" << email << "\",\n";
    json << "  \"physical_stats\": {\n";
    json << "    \"height_cm\": " << physical_stats.height_cm << ",\n";
    json << "    \"weight_kg\": " << physical_stats.weight_kg << ",\n";
    json << "    \"age\": " << physical_stats.age << ",\n";
    json << "    \"gender\": \"" << genderToString(physical_stats.gender) << "\",\n";
    json << "    \"activity_level\": \"" << activityLevelToString(physical_stats.activity_level) << "\"\n";
    json << "  },\n";
    json << "  \"nutrition_goals\": {\n";
    json << "    \"daily_calories\": " << nutrition_goals.daily_calories << ",\n";
    json << "    \"daily_protein_g\": " << nutrition_goals.daily_protein_g << ",\n";
    json << "    \"daily_fat_g\": " << nutrition_goals.daily_fat_g << ",\n";
    json << "    \"daily_carbs_g\": " << nutrition_goals.daily_carbs_g << "\n";
    json << "  },\n";
    json << "  \"fitness_goal\": \"" << goalToString(fitness_goal) << "\"\n";
    json << "}";
    
    return json.str();
}

bool UserProfile::fromJSON(const std::string& json) {
    // Simple JSON parsing - in a real implementation, use a proper JSON library
    // This is a basic implementation for demonstration
    return false; // Not implemented in this basic version
}

// Utility methods
void UserProfile::resetDailyProgress() {
    DailyProgress* today = getTodaysProgress();
    if (today) {
        *today = DailyProgress();
        today->date = std::chrono::system_clock::now();
        updateTimestamp();
    }
}

void UserProfile::clearProgressHistory() {
    daily_progress_history.clear();
    updateTimestamp();
}

// Comparison operators
bool UserProfile::operator==(const UserProfile& other) const {
    return user_id == other.user_id &&
           name == other.name &&
           email == other.email;
}

// Stream operators
std::ostream& operator<<(std::ostream& os, const UserProfile& profile) {
    os << "UserProfile{" 
       << "id: " << profile.user_id 
       << ", name: " << profile.name 
       << ", email: " << profile.email 
       << ", BMI: " << std::fixed << std::setprecision(1) << profile.getBMI()
       << ", goal: " << goalToString(profile.fitness_goal)
       << "}";
    return os;
}

// Utility functions
std::string genderToString(Gender gender) {
    switch (gender) {
        case Gender::Male: return "Male";
        case Gender::Female: return "Female";
        case Gender::Other: return "Other";
        default: return "Unknown";
    }
}

Gender stringToGender(const std::string& str) {
    if (str == "Male") return Gender::Male;
    if (str == "Female") return Gender::Female;
    return Gender::Other;
}

std::string activityLevelToString(ActivityLevel level) {
    switch (level) {
        case ActivityLevel::Sedentary: return "Sedentary";
        case ActivityLevel::LightlyActive: return "LightlyActive";
        case ActivityLevel::ModeratelyActive: return "ModeratelyActive";
        case ActivityLevel::VeryActive: return "VeryActive";
        case ActivityLevel::ExtraActive: return "ExtraActive";
        default: return "Unknown";
    }
}

ActivityLevel stringToActivityLevel(const std::string& str) {
    if (str == "Sedentary") return ActivityLevel::Sedentary;
    if (str == "LightlyActive") return ActivityLevel::LightlyActive;
    if (str == "ModeratelyActive") return ActivityLevel::ModeratelyActive;
    if (str == "VeryActive") return ActivityLevel::VeryActive;
    if (str == "ExtraActive") return ActivityLevel::ExtraActive;
    return ActivityLevel::ModeratelyActive;
}

std::string goalToString(Goal goal) {
    switch (goal) {
        case Goal::MaintainWeight: return "MaintainWeight";
        case Goal::LoseWeight: return "LoseWeight";
        case Goal::GainWeight: return "GainWeight";
        case Goal::BuildMuscle: return "BuildMuscle";
        default: return "Unknown";
    }
}

Goal stringToGoal(const std::string& str) {
    if (str == "MaintainWeight") return Goal::MaintainWeight;
    if (str == "LoseWeight") return Goal::LoseWeight;
    if (str == "GainWeight") return Goal::GainWeight;
    if (str == "BuildMuscle") return Goal::BuildMuscle;
    return Goal::MaintainWeight;
}

} // namespace TamizaCore