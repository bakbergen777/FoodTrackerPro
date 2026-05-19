//
//  FoodItem.hpp
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

#ifndef FoodItem_hpp
#define FoodItem_hpp

// Objective-C++ compatibility guards
#ifdef __cplusplus

#include <string>
#include <vector>
#include <memory>
#include <chrono>
#include <iostream>

namespace TamizaCore {

// Enums
enum class FoodCategory {
    Fruits,
    Vegetables,
    Grains,
    Protein,
    Dairy,
    Fats,
    Beverages,
    Snacks,
    Desserts,
    Other
};

enum class NutrientDensity {
    Low,
    Medium,
    High,
    VeryHigh
};

// Structures
struct NutritionFacts {
    double calories_per_100g;
    double protein_per_100g;
    double fat_per_100g;
    double carbs_per_100g;
    double fiber_per_100g;
    double sugar_per_100g;
    double sodium_per_100g; // in mg
    double potassium_per_100g; // in mg
    double calcium_per_100g; // in mg
    double iron_per_100g; // in mg
    double vitamin_c_per_100g; // in mg
    double vitamin_a_per_100g; // in IU
    
    NutritionFacts() : calories_per_100g(0), protein_per_100g(0), fat_per_100g(0),
                      carbs_per_100g(0), fiber_per_100g(0), sugar_per_100g(0),
                      sodium_per_100g(0), potassium_per_100g(0), calcium_per_100g(0),
                      iron_per_100g(0), vitamin_c_per_100g(0), vitamin_a_per_100g(0) {}
    
    NutritionFacts(double calories, double protein, double fat, double carbs)
        : calories_per_100g(calories), protein_per_100g(protein), fat_per_100g(fat),
          carbs_per_100g(carbs), fiber_per_100g(0), sugar_per_100g(0),
          sodium_per_100g(0), potassium_per_100g(0), calcium_per_100g(0),
          iron_per_100g(0), vitamin_c_per_100g(0), vitamin_a_per_100g(0) {}
};

struct ServingInfo {
    std::string serving_description;
    double serving_size_grams;
    double typical_serving_size;
    
    ServingInfo() : serving_description("100g"), serving_size_grams(100.0), typical_serving_size(1.0) {}
    
    ServingInfo(const std::string& description, double size_grams, double typical_size = 1.0)
        : serving_description(description), serving_size_grams(size_grams), typical_serving_size(typical_size) {}
};

// Main FoodItem class
class FoodItem {
private:
    std::string food_id;
    std::string name;
    std::string brand;
    std::string description;
    FoodCategory category;
    NutritionFacts nutrition_facts;
    ServingInfo serving_info;
    std::vector<std::string> ingredients;
    std::vector<std::string> allergens;
    std::string barcode;
    bool is_verified;
    bool is_organic;
    bool is_gluten_free;
    bool is_vegan;
    bool is_vegetarian;
    std::chrono::system_clock::time_point created_at;
    std::chrono::system_clock::time_point updated_at;
    
    // Private helper methods
    NutrientDensity calculateNutrientDensity() const;
    double calculateHealthScore() const;
    void updateTimestamp();

public:
    // Constructors
    FoodItem();
    FoodItem(const std::string& id, const std::string& name);
    FoodItem(const std::string& id, const std::string& name, const NutritionFacts& nutrition);
    FoodItem(const std::string& id, const std::string& name, const std::string& brand,
             const NutritionFacts& nutrition, FoodCategory cat);
    
    // Destructor
    ~FoodItem();
    
    // Copy constructor and assignment operator
    FoodItem(const FoodItem& other);
    FoodItem& operator=(const FoodItem& other);
    
    // Move constructor and assignment operator
    FoodItem(FoodItem&& other) noexcept;
    FoodItem& operator=(FoodItem&& other) noexcept;
    
    // Getters
    const std::string& getFoodId() const { return food_id; }
    const std::string& getName() const { return name; }
    const std::string& getBrand() const { return brand; }
    const std::string& getDescription() const { return description; }
    FoodCategory getCategory() const { return category; }
    const NutritionFacts& getNutritionFacts() const { return nutrition_facts; }
    const ServingInfo& getServingInfo() const { return serving_info; }
    const std::vector<std::string>& getIngredients() const { return ingredients; }
    const std::vector<std::string>& getAllergens() const { return allergens; }
    const std::string& getBarcode() const { return barcode; }
    bool isVerified() const { return is_verified; }
    bool isOrganic() const { return is_organic; }
    bool isGlutenFree() const { return is_gluten_free; }
    bool isVegan() const { return is_vegan; }
    bool isVegetarian() const { return is_vegetarian; }
    std::chrono::system_clock::time_point getCreatedAt() const { return created_at; }
    std::chrono::system_clock::time_point getUpdatedAt() const { return updated_at; }
    
    // Nutrition getters (per 100g)
    double getCaloriesPer100g() const { return nutrition_facts.calories_per_100g; }
    double getProteinPer100g() const { return nutrition_facts.protein_per_100g; }
    double getFatPer100g() const { return nutrition_facts.fat_per_100g; }
    double getCarbsPer100g() const { return nutrition_facts.carbs_per_100g; }
    double getFiberPer100g() const { return nutrition_facts.fiber_per_100g; }
    double getSugarPer100g() const { return nutrition_facts.sugar_per_100g; }
    double getSodiumPer100g() const { return nutrition_facts.sodium_per_100g; }
    double getPotassiumPer100g() const { return nutrition_facts.potassium_per_100g; }
    double getCalciumPer100g() const { return nutrition_facts.calcium_per_100g; }
    double getIronPer100g() const { return nutrition_facts.iron_per_100g; }
    double getVitaminCPer100g() const { return nutrition_facts.vitamin_c_per_100g; }
    double getVitaminAPer100g() const { return nutrition_facts.vitamin_a_per_100g; }
    
    // Setters
    void setName(const std::string& new_name);
    void setBrand(const std::string& new_brand);
    void setDescription(const std::string& new_description);
    void setCategory(FoodCategory new_category);
    void setNutritionFacts(const NutritionFacts& facts);
    void setServingInfo(const ServingInfo& info);
    void setIngredients(const std::vector<std::string>& new_ingredients);
    void setAllergens(const std::vector<std::string>& new_allergens);
    void setBarcode(const std::string& new_barcode);
    void setVerified(bool verified);
    void setOrganic(bool organic);
    void setGlutenFree(bool gluten_free);
    void setVegan(bool vegan);
    void setVegetarian(bool vegetarian);
    
    // Nutrition calculation methods for specific serving sizes
    double getCaloriesForServing(double serving_size_grams) const;
    double getProteinForServing(double serving_size_grams) const;
    double getFatForServing(double serving_size_grams) const;
    double getCarbsForServing(double serving_size_grams) const;
    double getFiberForServing(double serving_size_grams) const;
    double getSugarForServing(double serving_size_grams) const;
    double getSodiumForServing(double serving_size_grams) const;
    
    // Analysis methods
    NutrientDensity getNutrientDensity() const { return calculateNutrientDensity(); }
    double getHealthScore() const { return calculateHealthScore(); }
    double getProteinPercentage() const;
    double getFatPercentage() const;
    double getCarbsPercentage() const;
    bool isHighProtein() const;
    bool isLowCarb() const;
    bool isLowFat() const;
    bool isHighFiber() const;
    
    // Search and filtering methods
    bool matchesSearchTerm(const std::string& search_term) const;
    bool hasAllergen(const std::string& allergen) const;
    bool hasIngredient(const std::string& ingredient) const;
    
    // Validation methods
    bool isValidFoodItem() const;
    std::vector<std::string> getValidationErrors() const;
    
    // Serialization methods
    std::string toJSON() const;
    bool fromJSON(const std::string& json);
    
    // Utility methods
    void addIngredient(const std::string& ingredient);
    void removeIngredient(const std::string& ingredient);
    void addAllergen(const std::string& allergen);
    void removeAllergen(const std::string& allergen);
    std::string getNutritionSummary() const;
    std::string getFormattedNutritionLabel() const;
    
    // Comparison operators
    bool operator==(const FoodItem& other) const;
    bool operator!=(const FoodItem& other) const { return !(*this == other); }
    bool operator<(const FoodItem& other) const; // For sorting by name
    
    // Stream operators
    friend std::ostream& operator<<(std::ostream& os, const FoodItem& food);
    
    // Static factory methods
    static FoodItem createFromBarcode(const std::string& barcode);
    static FoodItem createBasicFood(const std::string& name, double calories, double protein, double fat, double carbs);
    static std::vector<FoodItem> createSampleFoods();
};

// Utility functions
std::string categoryToString(FoodCategory category);
FoodCategory stringToCategory(const std::string& str);
std::string nutrientDensityToString(NutrientDensity density);
NutrientDensity stringToNutrientDensity(const std::string& str);

// Food database functions
class FoodDatabase {
private:
    std::vector<FoodItem> foods;
    
public:
    void addFood(const FoodItem& food);
    void removeFood(const std::string& food_id);
    FoodItem* findFood(const std::string& food_id);
    const FoodItem* findFood(const std::string& food_id) const;
    std::vector<FoodItem> searchFoods(const std::string& query) const;
    std::vector<FoodItem> getFoodsByCategory(FoodCategory category) const;
    std::vector<FoodItem> getFoodsByBrand(const std::string& brand) const;
    size_t size() const { return foods.size(); }
    void clear() { foods.clear(); }
    
    // Nutrition analysis
    std::vector<FoodItem> getHighProteinFoods(double min_protein_per_100g = 20.0) const;
    std::vector<FoodItem> getLowCarbFoods(double max_carbs_per_100g = 10.0) const;
    std::vector<FoodItem> getHighFiberFoods(double min_fiber_per_100g = 5.0) const;
    
    // Serialization
    std::string toJSON() const;
    bool fromJSON(const std::string& json);
};

// Constants
namespace Constants {
    constexpr double MIN_CALORIES_PER_100G = 0.0;
    constexpr double MAX_CALORIES_PER_100G = 900.0;
    constexpr double HIGH_PROTEIN_THRESHOLD = 20.0; // grams per 100g
    constexpr double LOW_CARB_THRESHOLD = 10.0; // grams per 100g
    constexpr double LOW_FAT_THRESHOLD = 3.0; // grams per 100g
    constexpr double HIGH_FIBER_THRESHOLD = 5.0; // grams per 100g
    constexpr double HIGH_SODIUM_THRESHOLD = 600.0; // mg per 100g
}

} // namespace TamizaCore

#endif // __cplusplus

#endif /* FoodItem_hpp */