//
//  FoodItem.cpp
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

#include "FoodItem.hpp"
#include <algorithm>
#include <cmath>
#include <sstream>
#include <iomanip>
#include <cctype>

namespace TamizaCore {

// FoodItem Implementation

// Constructors
FoodItem::FoodItem() 
    : food_id(""), name(""), brand(""), description(""), category(FoodCategory::Other),
      is_verified(false), is_organic(false), is_gluten_free(false), is_vegan(false), is_vegetarian(false),
      created_at(std::chrono::system_clock::now()), updated_at(std::chrono::system_clock::now()) {
}

FoodItem::FoodItem(const std::string& id, const std::string& name)
    : food_id(id), name(name), brand(""), description(""), category(FoodCategory::Other),
      is_verified(false), is_organic(false), is_gluten_free(false), is_vegan(false), is_vegetarian(false),
      created_at(std::chrono::system_clock::now()), updated_at(std::chrono::system_clock::now()) {
}

FoodItem::FoodItem(const std::string& id, const std::string& name, const NutritionFacts& nutrition)
    : food_id(id), name(name), brand(""), description(""), category(FoodCategory::Other),
      nutrition_facts(nutrition), is_verified(false), is_organic(false), is_gluten_free(false), 
      is_vegan(false), is_vegetarian(false),
      created_at(std::chrono::system_clock::now()), updated_at(std::chrono::system_clock::now()) {
}

FoodItem::FoodItem(const std::string& id, const std::string& name, const std::string& brand,
                   const NutritionFacts& nutrition, FoodCategory cat)
    : food_id(id), name(name), brand(brand), description(""), category(cat),
      nutrition_facts(nutrition), is_verified(false), is_organic(false), is_gluten_free(false), 
      is_vegan(false), is_vegetarian(false),
      created_at(std::chrono::system_clock::now()), updated_at(std::chrono::system_clock::now()) {
}

// Destructor
FoodItem::~FoodItem() = default;

// Copy constructor
FoodItem::FoodItem(const FoodItem& other)
    : food_id(other.food_id), name(other.name), brand(other.brand), description(other.description),
      category(other.category), nutrition_facts(other.nutrition_facts), serving_info(other.serving_info),
      ingredients(other.ingredients), allergens(other.allergens), barcode(other.barcode),
      is_verified(other.is_verified), is_organic(other.is_organic), is_gluten_free(other.is_gluten_free),
      is_vegan(other.is_vegan), is_vegetarian(other.is_vegetarian),
      created_at(other.created_at), updated_at(other.updated_at) {
}

// Copy assignment operator
FoodItem& FoodItem::operator=(const FoodItem& other) {
    if (this != &other) {
        food_id = other.food_id;
        name = other.name;
        brand = other.brand;
        description = other.description;
        category = other.category;
        nutrition_facts = other.nutrition_facts;
        serving_info = other.serving_info;
        ingredients = other.ingredients;
        allergens = other.allergens;
        barcode = other.barcode;
        is_verified = other.is_verified;
        is_organic = other.is_organic;
        is_gluten_free = other.is_gluten_free;
        is_vegan = other.is_vegan;
        is_vegetarian = other.is_vegetarian;
        created_at = other.created_at;
        updated_at = other.updated_at;
    }
    return *this;
}

// Move constructor
FoodItem::FoodItem(FoodItem&& other) noexcept
    : food_id(std::move(other.food_id)), name(std::move(other.name)), brand(std::move(other.brand)),
      description(std::move(other.description)), category(other.category),
      nutrition_facts(std::move(other.nutrition_facts)), serving_info(std::move(other.serving_info)),
      ingredients(std::move(other.ingredients)), allergens(std::move(other.allergens)),
      barcode(std::move(other.barcode)), is_verified(other.is_verified), is_organic(other.is_organic),
      is_gluten_free(other.is_gluten_free), is_vegan(other.is_vegan), is_vegetarian(other.is_vegetarian),
      created_at(other.created_at), updated_at(other.updated_at) {
}

// Move assignment operator
FoodItem& FoodItem::operator=(FoodItem&& other) noexcept {
    if (this != &other) {
        food_id = std::move(other.food_id);
        name = std::move(other.name);
        brand = std::move(other.brand);
        description = std::move(other.description);
        category = other.category;
        nutrition_facts = std::move(other.nutrition_facts);
        serving_info = std::move(other.serving_info);
        ingredients = std::move(other.ingredients);
        allergens = std::move(other.allergens);
        barcode = std::move(other.barcode);
        is_verified = other.is_verified;
        is_organic = other.is_organic;
        is_gluten_free = other.is_gluten_free;
        is_vegan = other.is_vegan;
        is_vegetarian = other.is_vegetarian;
        created_at = other.created_at;
        updated_at = other.updated_at;
    }
    return *this;
}

// Setters
void FoodItem::setName(const std::string& new_name) {
    name = new_name;
    updateTimestamp();
}

void FoodItem::setBrand(const std::string& new_brand) {
    brand = new_brand;
    updateTimestamp();
}

void FoodItem::setDescription(const std::string& new_description) {
    description = new_description;
    updateTimestamp();
}

void FoodItem::setCategory(FoodCategory new_category) {
    category = new_category;
    updateTimestamp();
}

void FoodItem::setNutritionFacts(const NutritionFacts& facts) {
    nutrition_facts = facts;
    updateTimestamp();
}

void FoodItem::setServingInfo(const ServingInfo& info) {
    serving_info = info;
    updateTimestamp();
}

void FoodItem::setIngredients(const std::vector<std::string>& new_ingredients) {
    ingredients = new_ingredients;
    updateTimestamp();
}

void FoodItem::setAllergens(const std::vector<std::string>& new_allergens) {
    allergens = new_allergens;
    updateTimestamp();
}

void FoodItem::setBarcode(const std::string& new_barcode) {
    barcode = new_barcode;
    updateTimestamp();
}

void FoodItem::setVerified(bool verified) {
    is_verified = verified;
    updateTimestamp();
}

void FoodItem::setOrganic(bool organic) {
    is_organic = organic;
    updateTimestamp();
}

void FoodItem::setGlutenFree(bool gluten_free) {
    is_gluten_free = gluten_free;
    updateTimestamp();
}

void FoodItem::setVegan(bool vegan) {
    is_vegan = vegan;
    if (vegan) {
        is_vegetarian = true; // Vegan implies vegetarian
    }
    updateTimestamp();
}

void FoodItem::setVegetarian(bool vegetarian) {
    is_vegetarian = vegetarian;
    if (!vegetarian) {
        is_vegan = false; // Not vegetarian implies not vegan
    }
    updateTimestamp();
}

// Private helper methods
NutrientDensity FoodItem::calculateNutrientDensity() const {
    if (nutrition_facts.calories_per_100g == 0) return NutrientDensity::Low;
    
    // Calculate nutrient density score based on protein, fiber, vitamins, and minerals
    double score = 0.0;
    
    // Protein contribution (0-30 points)
    score += std::min(30.0, nutrition_facts.protein_per_100g * 1.5);
    
    // Fiber contribution (0-25 points)
    score += std::min(25.0, nutrition_facts.fiber_per_100g * 5.0);
    
    // Vitamin C contribution (0-20 points)
    score += std::min(20.0, nutrition_facts.vitamin_c_per_100g * 0.2);
    
    // Iron contribution (0-15 points)
    score += std::min(15.0, nutrition_facts.iron_per_100g * 10.0);
    
    // Calcium contribution (0-10 points)
    score += std::min(10.0, nutrition_facts.calcium_per_100g * 0.01);
    
    // Penalty for high calories
    if (nutrition_facts.calories_per_100g > 400) {
        score *= 0.8;
    }
    
    // Penalty for high sodium
    if (nutrition_facts.sodium_per_100g > Constants::HIGH_SODIUM_THRESHOLD) {
        score *= 0.9;
    }
    
    if (score >= 80) return NutrientDensity::VeryHigh;
    if (score >= 60) return NutrientDensity::High;
    if (score >= 30) return NutrientDensity::Medium;
    return NutrientDensity::Low;
}

double FoodItem::calculateHealthScore() const {
    double score = 50.0; // Base score
    
    // Positive factors
    if (nutrition_facts.protein_per_100g > Constants::HIGH_PROTEIN_THRESHOLD) score += 15;
    if (nutrition_facts.fiber_per_100g > Constants::HIGH_FIBER_THRESHOLD) score += 15;
    if (nutrition_facts.vitamin_c_per_100g > 10) score += 10;
    if (nutrition_facts.iron_per_100g > 2) score += 10;
    if (is_organic) score += 5;
    if (is_vegan) score += 5;
    if (is_gluten_free && hasAllergen("gluten")) score += 5; // Only if actually needed
    
    // Negative factors
    if (nutrition_facts.sodium_per_100g > Constants::HIGH_SODIUM_THRESHOLD) score -= 15;
    if (nutrition_facts.sugar_per_100g > 20) score -= 10;
    if (nutrition_facts.calories_per_100g > 500) score -= 10;
    if (nutrition_facts.fat_per_100g > 30) score -= 5;
    
    // Category bonuses/penalties
    switch (category) {
        case FoodCategory::Fruits:
        case FoodCategory::Vegetables:
            score += 10;
            break;
        case FoodCategory::Snacks:
        case FoodCategory::Desserts:
            score -= 10;
            break;
        default:
            break;
    }
    
    return std::min(100.0, std::max(0.0, score));
}

void FoodItem::updateTimestamp() {
    updated_at = std::chrono::system_clock::now();
}

// Nutrition calculation methods for specific serving sizes
double FoodItem::getCaloriesForServing(double serving_size_grams) const {
    return (nutrition_facts.calories_per_100g * serving_size_grams) / 100.0;
}

double FoodItem::getProteinForServing(double serving_size_grams) const {
    return (nutrition_facts.protein_per_100g * serving_size_grams) / 100.0;
}

double FoodItem::getFatForServing(double serving_size_grams) const {
    return (nutrition_facts.fat_per_100g * serving_size_grams) / 100.0;
}

double FoodItem::getCarbsForServing(double serving_size_grams) const {
    return (nutrition_facts.carbs_per_100g * serving_size_grams) / 100.0;
}

double FoodItem::getFiberForServing(double serving_size_grams) const {
    return (nutrition_facts.fiber_per_100g * serving_size_grams) / 100.0;
}

double FoodItem::getSugarForServing(double serving_size_grams) const {
    return (nutrition_facts.sugar_per_100g * serving_size_grams) / 100.0;
}

double FoodItem::getSodiumForServing(double serving_size_grams) const {
    return (nutrition_facts.sodium_per_100g * serving_size_grams) / 100.0;
}

// Analysis methods
double FoodItem::getProteinPercentage() const {
    if (nutrition_facts.calories_per_100g == 0) return 0.0;
    return (nutrition_facts.protein_per_100g * 4.0) / nutrition_facts.calories_per_100g * 100.0;
}

double FoodItem::getFatPercentage() const {
    if (nutrition_facts.calories_per_100g == 0) return 0.0;
    return (nutrition_facts.fat_per_100g * 9.0) / nutrition_facts.calories_per_100g * 100.0;
}

double FoodItem::getCarbsPercentage() const {
    if (nutrition_facts.calories_per_100g == 0) return 0.0;
    return (nutrition_facts.carbs_per_100g * 4.0) / nutrition_facts.calories_per_100g * 100.0;
}

bool FoodItem::isHighProtein() const {
    return nutrition_facts.protein_per_100g >= Constants::HIGH_PROTEIN_THRESHOLD;
}

bool FoodItem::isLowCarb() const {
    return nutrition_facts.carbs_per_100g <= Constants::LOW_CARB_THRESHOLD;
}

bool FoodItem::isLowFat() const {
    return nutrition_facts.fat_per_100g <= Constants::LOW_FAT_THRESHOLD;
}

bool FoodItem::isHighFiber() const {
    return nutrition_facts.fiber_per_100g >= Constants::HIGH_FIBER_THRESHOLD;
}

// Search and filtering methods
bool FoodItem::matchesSearchTerm(const std::string& search_term) const {
    std::string lower_search = search_term;
    std::transform(lower_search.begin(), lower_search.end(), lower_search.begin(), ::tolower);
    
    std::string lower_name = name;
    std::transform(lower_name.begin(), lower_name.end(), lower_name.begin(), ::tolower);
    
    std::string lower_brand = brand;
    std::transform(lower_brand.begin(), lower_brand.end(), lower_brand.begin(), ::tolower);
    
    std::string lower_description = description;
    std::transform(lower_description.begin(), lower_description.end(), lower_description.begin(), ::tolower);
    
    return lower_name.find(lower_search) != std::string::npos ||
           lower_brand.find(lower_search) != std::string::npos ||
           lower_description.find(lower_search) != std::string::npos;
}

bool FoodItem::hasAllergen(const std::string& allergen) const {
    return std::find(allergens.begin(), allergens.end(), allergen) != allergens.end();
}

bool FoodItem::hasIngredient(const std::string& ingredient) const {
    return std::find(ingredients.begin(), ingredients.end(), ingredient) != ingredients.end();
}

// Validation methods
bool FoodItem::isValidFoodItem() const {
    return getValidationErrors().empty();
}

std::vector<std::string> FoodItem::getValidationErrors() const {
    std::vector<std::string> errors;
    
    if (food_id.empty()) {
        errors.push_back("Food ID cannot be empty");
    }
    
    if (name.empty()) {
        errors.push_back("Name cannot be empty");
    }
    
    if (nutrition_facts.calories_per_100g < Constants::MIN_CALORIES_PER_100G || 
        nutrition_facts.calories_per_100g > Constants::MAX_CALORIES_PER_100G) {
        errors.push_back("Calories per 100g must be between " + 
                        std::to_string(Constants::MIN_CALORIES_PER_100G) + 
                        " and " + std::to_string(Constants::MAX_CALORIES_PER_100G));
    }
    
    if (nutrition_facts.protein_per_100g < 0 || nutrition_facts.protein_per_100g > 100) {
        errors.push_back("Protein per 100g must be between 0 and 100 grams");
    }
    
    if (nutrition_facts.fat_per_100g < 0 || nutrition_facts.fat_per_100g > 100) {
        errors.push_back("Fat per 100g must be between 0 and 100 grams");
    }
    
    if (nutrition_facts.carbs_per_100g < 0 || nutrition_facts.carbs_per_100g > 100) {
        errors.push_back("Carbs per 100g must be between 0 and 100 grams");
    }
    
    // Check if macronutrients add up reasonably
    double total_macro_calories = (nutrition_facts.protein_per_100g * 4) + 
                                 (nutrition_facts.fat_per_100g * 9) + 
                                 (nutrition_facts.carbs_per_100g * 4);
    
    if (std::abs(total_macro_calories - nutrition_facts.calories_per_100g) > 50) {
        errors.push_back("Macronutrient calories don't match total calories");
    }
    
    return errors;
}

// Serialization methods
std::string FoodItem::toJSON() const {
    std::ostringstream json;
    json << std::fixed << std::setprecision(2);
    
    json << "{\n";
    json << "  \"food_id\": \"" << food_id << "\",\n";
    json << "  \"name\": \"" << name << "\",\n";
    json << "  \"brand\": \"" << brand << "\",\n";
    json << "  \"description\": \"" << description << "\",\n";
    json << "  \"category\": \"" << categoryToString(category) << "\",\n";
    json << "  \"nutrition_facts\": {\n";
    json << "    \"calories_per_100g\": " << nutrition_facts.calories_per_100g << ",\n";
    json << "    \"protein_per_100g\": " << nutrition_facts.protein_per_100g << ",\n";
    json << "    \"fat_per_100g\": " << nutrition_facts.fat_per_100g << ",\n";
    json << "    \"carbs_per_100g\": " << nutrition_facts.carbs_per_100g << ",\n";
    json << "    \"fiber_per_100g\": " << nutrition_facts.fiber_per_100g << ",\n";
    json << "    \"sugar_per_100g\": " << nutrition_facts.sugar_per_100g << ",\n";
    json << "    \"sodium_per_100g\": " << nutrition_facts.sodium_per_100g << "\n";
    json << "  },\n";
    json << "  \"is_verified\": " << (is_verified ? "true" : "false") << ",\n";
    json << "  \"is_organic\": " << (is_organic ? "true" : "false") << ",\n";
    json << "  \"is_vegan\": " << (is_vegan ? "true" : "false") << ",\n";
    json << "  \"is_vegetarian\": " << (is_vegetarian ? "true" : "false") << "\n";
    json << "}";
    
    return json.str();
}

bool FoodItem::fromJSON(const std::string& json) {
    // Simple JSON parsing - in a real implementation, use a proper JSON library
    // This is a basic implementation for demonstration
    return false; // Not implemented in this basic version
}

// Utility methods
void FoodItem::addIngredient(const std::string& ingredient) {
    if (std::find(ingredients.begin(), ingredients.end(), ingredient) == ingredients.end()) {
        ingredients.push_back(ingredient);
        updateTimestamp();
    }
}

void FoodItem::removeIngredient(const std::string& ingredient) {
    auto it = std::find(ingredients.begin(), ingredients.end(), ingredient);
    if (it != ingredients.end()) {
        ingredients.erase(it);
        updateTimestamp();
    }
}

void FoodItem::addAllergen(const std::string& allergen) {
    if (std::find(allergens.begin(), allergens.end(), allergen) == allergens.end()) {
        allergens.push_back(allergen);
        updateTimestamp();
    }
}

void FoodItem::removeAllergen(const std::string& allergen) {
    auto it = std::find(allergens.begin(), allergens.end(), allergen);
    if (it != allergens.end()) {
        allergens.erase(it);
        updateTimestamp();
    }
}

std::string FoodItem::getNutritionSummary() const {
    std::ostringstream summary;
    summary << std::fixed << std::setprecision(1);
    summary << nutrition_facts.calories_per_100g << " kcal, ";
    summary << "P: " << nutrition_facts.protein_per_100g << "g, ";
    summary << "F: " << nutrition_facts.fat_per_100g << "g, ";
    summary << "C: " << nutrition_facts.carbs_per_100g << "g";
    return summary.str();
}

std::string FoodItem::getFormattedNutritionLabel() const {
    std::ostringstream label;
    label << std::fixed << std::setprecision(1);
    
    label << "Nutrition Facts (per 100g)\n";
    label << "========================\n";
    label << "Calories: " << nutrition_facts.calories_per_100g << " kcal\n";
    label << "Protein: " << nutrition_facts.protein_per_100g << "g\n";
    label << "Fat: " << nutrition_facts.fat_per_100g << "g\n";
    label << "Carbohydrates: " << nutrition_facts.carbs_per_100g << "g\n";
    label << "  Fiber: " << nutrition_facts.fiber_per_100g << "g\n";
    label << "  Sugar: " << nutrition_facts.sugar_per_100g << "g\n";
    label << "Sodium: " << nutrition_facts.sodium_per_100g << "mg\n";
    
    if (nutrition_facts.vitamin_c_per_100g > 0) {
        label << "Vitamin C: " << nutrition_facts.vitamin_c_per_100g << "mg\n";
    }
    
    if (nutrition_facts.iron_per_100g > 0) {
        label << "Iron: " << nutrition_facts.iron_per_100g << "mg\n";
    }
    
    return label.str();
}

// Comparison operators
bool FoodItem::operator==(const FoodItem& other) const {
    return food_id == other.food_id;
}

bool FoodItem::operator<(const FoodItem& other) const {
    return name < other.name;
}

// Stream operators
std::ostream& operator<<(std::ostream& os, const FoodItem& food) {
    os << "FoodItem{" 
       << "id: " << food.food_id 
       << ", name: " << food.name 
       << ", brand: " << food.brand
       << ", calories: " << std::fixed << std::setprecision(1) << food.nutrition_facts.calories_per_100g << "/100g"
       << ", category: " << categoryToString(food.category)
       << "}";
    return os;
}

// Static factory methods
FoodItem FoodItem::createFromBarcode(const std::string& barcode) {
    FoodItem food;
    food.barcode = barcode;
    food.food_id = "barcode_" + barcode;
    food.name = "Unknown Food";
    return food;
}

FoodItem FoodItem::createBasicFood(const std::string& name, double calories, double protein, double fat, double carbs) {
    FoodItem food;
    food.food_id = "basic_" + name;
    food.name = name;
    food.nutrition_facts = NutritionFacts(calories, protein, fat, carbs);
    return food;
}

std::vector<FoodItem> FoodItem::createSampleFoods() {
    std::vector<FoodItem> foods;
    
    // Sample foods with realistic nutrition data
    foods.push_back(createBasicFood("Chicken Breast", 231, 43.5, 5.0, 0.0));
    foods.push_back(createBasicFood("Brown Rice", 362, 7.2, 2.3, 72.9));
    foods.push_back(createBasicFood("Broccoli", 34, 2.8, 0.4, 7.0));
    foods.push_back(createBasicFood("Salmon", 206, 22.1, 12.4, 0.0));
    foods.push_back(createBasicFood("Apple", 52, 0.3, 0.2, 13.8));
    
    // Set categories
    foods[0].setCategory(FoodCategory::Protein);
    foods[1].setCategory(FoodCategory::Grains);
    foods[2].setCategory(FoodCategory::Vegetables);
    foods[3].setCategory(FoodCategory::Protein);
    foods[4].setCategory(FoodCategory::Fruits);
    
    return foods;
}

// Utility functions
std::string categoryToString(FoodCategory category) {
    switch (category) {
        case FoodCategory::Fruits: return "Fruits";
        case FoodCategory::Vegetables: return "Vegetables";
        case FoodCategory::Grains: return "Grains";
        case FoodCategory::Protein: return "Protein";
        case FoodCategory::Dairy: return "Dairy";
        case FoodCategory::Fats: return "Fats";
        case FoodCategory::Beverages: return "Beverages";
        case FoodCategory::Snacks: return "Snacks";
        case FoodCategory::Desserts: return "Desserts";
        case FoodCategory::Other: return "Other";
        default: return "Unknown";
    }
}

FoodCategory stringToCategory(const std::string& str) {
    if (str == "Fruits") return FoodCategory::Fruits;
    if (str == "Vegetables") return FoodCategory::Vegetables;
    if (str == "Grains") return FoodCategory::Grains;
    if (str == "Protein") return FoodCategory::Protein;
    if (str == "Dairy") return FoodCategory::Dairy;
    if (str == "Fats") return FoodCategory::Fats;
    if (str == "Beverages") return FoodCategory::Beverages;
    if (str == "Snacks") return FoodCategory::Snacks;
    if (str == "Desserts") return FoodCategory::Desserts;
    return FoodCategory::Other;
}

std::string nutrientDensityToString(NutrientDensity density) {
    switch (density) {
        case NutrientDensity::Low: return "Low";
        case NutrientDensity::Medium: return "Medium";
        case NutrientDensity::High: return "High";
        case NutrientDensity::VeryHigh: return "VeryHigh";
        default: return "Unknown";
    }
}

NutrientDensity stringToNutrientDensity(const std::string& str) {
    if (str == "Low") return NutrientDensity::Low;
    if (str == "Medium") return NutrientDensity::Medium;
    if (str == "High") return NutrientDensity::High;
    if (str == "VeryHigh") return NutrientDensity::VeryHigh;
    return NutrientDensity::Low;
}

// FoodDatabase Implementation
void FoodDatabase::addFood(const FoodItem& food) {
    // Remove existing food with same ID
    removeFood(food.getFoodId());
    foods.push_back(food);
}

void FoodDatabase::removeFood(const std::string& food_id) {
    foods.erase(std::remove_if(foods.begin(), foods.end(),
        [&food_id](const FoodItem& food) {
            return food.getFoodId() == food_id;
        }), foods.end());
}

FoodItem* FoodDatabase::findFood(const std::string& food_id) {
    auto it = std::find_if(foods.begin(), foods.end(),
        [&food_id](const FoodItem& food) {
            return food.getFoodId() == food_id;
        });
    return (it != foods.end()) ? &(*it) : nullptr;
}

const FoodItem* FoodDatabase::findFood(const std::string& food_id) const {
    auto it = std::find_if(foods.begin(), foods.end(),
        [&food_id](const FoodItem& food) {
            return food.getFoodId() == food_id;
        });
    return (it != foods.end()) ? &(*it) : nullptr;
}

std::vector<FoodItem> FoodDatabase::searchFoods(const std::string& query) const {
    std::vector<FoodItem> results;
    std::copy_if(foods.begin(), foods.end(), std::back_inserter(results),
        [&query](const FoodItem& food) {
            return food.matchesSearchTerm(query);
        });
    return results;
}

std::vector<FoodItem> FoodDatabase::getFoodsByCategory(FoodCategory category) const {
    std::vector<FoodItem> results;
    std::copy_if(foods.begin(), foods.end(), std::back_inserter(results),
        [category](const FoodItem& food) {
            return food.getCategory() == category;
        });
    return results;
}

std::vector<FoodItem> FoodDatabase::getFoodsByBrand(const std::string& brand) const {
    std::vector<FoodItem> results;
    std::copy_if(foods.begin(), foods.end(), std::back_inserter(results),
        [&brand](const FoodItem& food) {
            return food.getBrand() == brand;
        });
    return results;
}

std::vector<FoodItem> FoodDatabase::getHighProteinFoods(double min_protein_per_100g) const {
    std::vector<FoodItem> results;
    std::copy_if(foods.begin(), foods.end(), std::back_inserter(results),
        [min_protein_per_100g](const FoodItem& food) {
            return food.getProteinPer100g() >= min_protein_per_100g;
        });
    return results;
}

std::vector<FoodItem> FoodDatabase::getLowCarbFoods(double max_carbs_per_100g) const {
    std::vector<FoodItem> results;
    std::copy_if(foods.begin(), foods.end(), std::back_inserter(results),
        [max_carbs_per_100g](const FoodItem& food) {
            return food.getCarbsPer100g() <= max_carbs_per_100g;
        });
    return results;
}

std::vector<FoodItem> FoodDatabase::getHighFiberFoods(double min_fiber_per_100g) const {
    std::vector<FoodItem> results;
    std::copy_if(foods.begin(), foods.end(), std::back_inserter(results),
        [min_fiber_per_100g](const FoodItem& food) {
            return food.getFiberPer100g() >= min_fiber_per_100g;
        });
    return results;
}

std::string FoodDatabase::toJSON() const {
    std::ostringstream json;
    json << "{\n";
    json << "  \"foods\": [\n";
    
    for (size_t i = 0; i < foods.size(); ++i) {
        json << "    " << foods[i].toJSON();
        if (i < foods.size() - 1) {
            json << ",";
        }
        json << "\n";
    }
    
    json << "  ]\n";
    json << "}";
    return json.str();
}

bool FoodDatabase::fromJSON(const std::string& json) {
    // Simple JSON parsing - in a real implementation, use a proper JSON library
    // This is a basic implementation for demonstration
    return false; // Not implemented in this basic version
}

} // namespace TamizaCore