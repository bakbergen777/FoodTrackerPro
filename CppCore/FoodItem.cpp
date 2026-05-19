//
//  FoodItem.cpp
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

#include "FoodItem.hpp"
#include <algorithm>
#include <sstream>
#include <iomanip>
#include <ctime>
#include <random>

// MARK: - Constructors and Destructor

FoodItem::FoodItem() {
    initializeDefaults();
}

FoodItem::FoodItem(const std::string& id, const std::string& name)
    : id(id), name(name) {
    initializeDefaults();
}

FoodItem::FoodItem(const FoodItem& other)
    : id(other.id)
    , name(other.name)
    , brand(other.brand)
    , barcode(other.barcode)
    , category(other.category)
    , calories(other.calories)
    , protein(other.protein)
    , fat(other.fat)
    , carbs(other.carbs)
    , fiber(other.fiber)
    , sugar(other.sugar)
    , sodium(other.sodium)
    , servingSize(other.servingSize)
    , servingUnit(other.servingUnit)
    , isUserCreated(other.isUserCreated)
    , createdBy(other.createdBy)
    , verificationCount(other.verificationCount)
    , createdAt(other.createdAt) {
}

FoodItem& FoodItem::operator=(const FoodItem& other) {
    if (this != &other) {
        id = other.id;
        name = other.name;
        brand = other.brand;
        barcode = other.barcode;
        category = other.category;
        calories = other.calories;
        protein = other.protein;
        fat = other.fat;
        carbs = other.carbs;
        fiber = other.fiber;
        sugar = other.sugar;
        sodium = other.sodium;
        servingSize = other.servingSize;
        servingUnit = other.servingUnit;
        isUserCreated = other.isUserCreated;
        createdBy = other.createdBy;
        verificationCount = other.verificationCount;
        createdAt = other.createdAt;
    }
    return *this;
}

// MARK: - Nutritional Calculations

int FoodItem::getCaloriesForPortion(double portionSize) const {
    return static_cast<int>(calories * calculatePortionMultiplier(portionSize));
}

double FoodItem::getProteinForPortion(double portionSize) const {
    return protein * calculatePortionMultiplier(portionSize);
}

double FoodItem::getFatForPortion(double portionSize) const {
    return fat * calculatePortionMultiplier(portionSize);
}

double FoodItem::getCarbsForPortion(double portionSize) const {
    return carbs * calculatePortionMultiplier(portionSize);
}

double FoodItem::getFiberForPortion(double portionSize) const {
    return fiber * calculatePortionMultiplier(portionSize);
}

double FoodItem::getSugarForPortion(double portionSize) const {
    return sugar * calculatePortionMultiplier(portionSize);
}

int FoodItem::getSodiumForPortion(double portionSize) const {
    return static_cast<int>(sodium * calculatePortionMultiplier(portionSize));
}

// MARK: - Utility Methods

bool FoodItem::isValid() const {
    return !name.empty() && 
           calories >= 0 && 
           protein >= 0 && 
           fat >= 0 && 
           carbs >= 0 &&
           servingSize > 0;
}

std::string FoodItem::getDisplayName() const {
    if (brand.empty()) {
        return name;
    }
    return brand + " " + name;
}

std::string FoodItem::getNutritionSummary() const {
    std::ostringstream oss;
    oss << std::fixed << std::setprecision(1);
    oss << calories << " kcal, ";
    oss << protein << "g protein, ";
    oss << fat << "g fat, ";
    oss << carbs << "g carbs";
    return oss.str();
}

double FoodItem::getTotalMacros() const {
    return protein + fat + carbs;
}

// MARK: - Search and Comparison

bool FoodItem::matchesQuery(const std::string& query) const {
    if (query.empty()) {
        return true;
    }
    
    std::string lowerQuery = query;
    std::transform(lowerQuery.begin(), lowerQuery.end(), lowerQuery.begin(), ::tolower);
    
    std::string lowerName = name;
    std::transform(lowerName.begin(), lowerName.end(), lowerName.begin(), ::tolower);
    
    std::string lowerBrand = brand;
    std::transform(lowerBrand.begin(), lowerBrand.end(), lowerBrand.begin(), ::tolower);
    
    std::string lowerCategory = category;
    std::transform(lowerCategory.begin(), lowerCategory.end(), lowerCategory.begin(), ::tolower);
    
    return lowerName.find(lowerQuery) != std::string::npos ||
           lowerBrand.find(lowerQuery) != std::string::npos ||
           lowerCategory.find(lowerQuery) != std::string::npos ||
           barcode == query;
}

double FoodItem::calculateSimilarity(const FoodItem& other) const {
    double similarity = 0.0;
    
    // Name similarity (40% weight)
    if (name == other.name) {
        similarity += 0.4;
    } else if (name.find(other.name) != std::string::npos || 
               other.name.find(name) != std::string::npos) {
        similarity += 0.2;
    }
    
    // Brand similarity (20% weight)
    if (brand == other.brand) {
        similarity += 0.2;
    }
    
    // Category similarity (20% weight)
    if (category == other.category) {
        similarity += 0.2;
    }
    
    // Nutritional similarity (20% weight)
    double nutritionalSimilarity = 0.0;
    if (calories > 0 && other.calories > 0) {
        nutritionalSimilarity += 1.0 - std::abs(calories - other.calories) / static_cast<double>(std::max(calories, other.calories));
    }
    similarity += nutritionalSimilarity * 0.2;
    
    return std::min(1.0, similarity);
}

// MARK: - JSON Serialization

std::string FoodItem::toJSON() const {
    std::string json = "{\n";
    json += "  \"id\": \"" + id + "\",\n";
    json += "  \"name\": \"" + name + "\",\n";
    json += "  \"brand\": \"" + brand + "\",\n";
    json += "  \"barcode\": \"" + barcode + "\",\n";
    json += "  \"category\": \"" + category + "\",\n";
    
    json += "  \"nutrition\": {\n";
    json += "    \"calories\": " + std::to_string(calories) + ",\n";
    json += "    \"protein\": " + std::to_string(protein) + ",\n";
    json += "    \"fat\": " + std::to_string(fat) + ",\n";
    json += "    \"carbs\": " + std::to_string(carbs) + ",\n";
    json += "    \"fiber\": " + std::to_string(fiber) + ",\n";
    json += "    \"sugar\": " + std::to_string(sugar) + ",\n";
    json += "    \"sodium\": " + std::to_string(sodium) + "\n";
    json += "  },\n";
    
    json += "  \"serving\": {\n";
    json += "    \"size\": " + std::to_string(servingSize) + ",\n";
    json += "    \"unit\": \"" + servingUnit + "\"\n";
    json += "  },\n";
    
    json += "  \"metadata\": {\n";
    json += "    \"isUserCreated\": " + std::string(isUserCreated ? "true" : "false") + ",\n";
    json += "    \"createdBy\": \"" + createdBy + "\",\n";
    json += "    \"verificationCount\": " + std::to_string(verificationCount) + ",\n";
    json += "    \"createdAt\": \"" + createdAt + "\"\n";
    json += "  }\n";
    json += "}";
    
    return json;
}

bool FoodItem::fromJSON(const std::string& json) {
    // Simple JSON parsing - in a real implementation, use a proper JSON library
    // This is a basic implementation for demonstration
    return false; // Not implemented in this basic version
}

// MARK: - Operators

bool FoodItem::operator==(const FoodItem& other) const {
    return id == other.id || 
           (name == other.name && brand == other.brand && barcode == other.barcode);
}

bool FoodItem::operator!=(const FoodItem& other) const {
    return !(*this == other);
}

// MARK: - Private Methods

void FoodItem::initializeDefaults() {
    if (id.empty()) {
        id = generateFoodId();
    }
    
    calories = 0;
    protein = 0.0;
    fat = 0.0;
    carbs = 0.0;
    fiber = 0.0;
    sugar = 0.0;
    sodium = 0;
    
    servingSize = 100.0;
    servingUnit = "g";
    
    isUserCreated = false;
    verificationCount = 0;
    
    // Set current timestamp
    auto now = std::time(nullptr);
    auto tm = *std::localtime(&now);
    std::ostringstream oss;
    oss << std::put_time(&tm, "%Y-%m-%d %H:%M:%S");
    createdAt = oss.str();
}

double FoodItem::calculatePortionMultiplier(double portionSize) const {
    if (servingSize <= 0) {
        return portionSize / 100.0; // Default to per 100g
    }
    return portionSize / servingSize;
}

// MARK: - Helper Functions

std::string generateFoodId() {
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_int_distribution<> dis(100000, 999999);
    
    auto now = std::time(nullptr);
    return "food_" + std::to_string(now) + "_" + std::to_string(dis(gen));
}

bool isValidNutritionalValue(double value) {
    return value >= 0.0 && value <= 1000.0; // Reasonable range for nutritional values
}

std::string formatNutritionalValue(double value, const std::string& unit) {
    std::ostringstream oss;
    oss << std::fixed << std::setprecision(1) << value << unit;
    return oss.str();
}