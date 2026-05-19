//
//  FoodItem.hpp
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

#ifndef FoodItem_hpp
#define FoodItem_hpp

#include <string>
#include <memory>
#include <vector>

class FoodItem {
private:
    std::string id;
    std::string name;
    std::string brand;
    std::string barcode;
    std::string category;
    
    // Nutritional information per 100g
    int calories;           // kcal
    double protein;         // g
    double fat;             // g
    double carbs;           // g
    double fiber;           // g
    double sugar;           // g
    int sodium;             // mg
    
    // Serving information
    double servingSize;     // g (default 100g)
    std::string servingUnit; // "g", "ml", "piece", etc.
    
    // Metadata
    bool isUserCreated;
    std::string createdBy;
    int verificationCount;
    std::string createdAt;
    
public:
    // Constructors
    FoodItem();
    FoodItem(const std::string& id, const std::string& name);
    FoodItem(const FoodItem& other);
    FoodItem& operator=(const FoodItem& other);
    ~FoodItem() = default;
    
    // Getters
    const std::string& getId() const { return id; }
    const std::string& getName() const { return name; }
    const std::string& getBrand() const { return brand; }
    const std::string& getBarcode() const { return barcode; }
    const std::string& getCategory() const { return category; }
    
    int getCalories() const { return calories; }
    double getProtein() const { return protein; }
    double getFat() const { return fat; }
    double getCarbs() const { return carbs; }
    double getFiber() const { return fiber; }
    double getSugar() const { return sugar; }
    int getSodium() const { return sodium; }
    
    double getServingSize() const { return servingSize; }
    const std::string& getServingUnit() const { return servingUnit; }
    
    bool getIsUserCreated() const { return isUserCreated; }
    const std::string& getCreatedBy() const { return createdBy; }
    int getVerificationCount() const { return verificationCount; }
    const std::string& getCreatedAt() const { return createdAt; }
    
    // Setters
    void setId(const std::string& i) { id = i; }
    void setName(const std::string& n) { name = n; }
    void setBrand(const std::string& b) { brand = b; }
    void setBarcode(const std::string& bc) { barcode = bc; }
    void setCategory(const std::string& c) { category = c; }
    
    void setCalories(int c) { calories = c; }
    void setProtein(double p) { protein = p; }
    void setFat(double f) { fat = f; }
    void setCarbs(double c) { carbs = c; }
    void setFiber(double f) { fiber = f; }
    void setSugar(double s) { sugar = s; }
    void setSodium(int s) { sodium = s; }
    
    void setServingSize(double size) { servingSize = size; }
    void setServingUnit(const std::string& unit) { servingUnit = unit; }
    
    void setIsUserCreated(bool created) { isUserCreated = created; }
    void setCreatedBy(const std::string& creator) { createdBy = creator; }
    void setVerificationCount(int count) { verificationCount = count; }
    void setCreatedAt(const std::string& timestamp) { createdAt = timestamp; }
    
    // Nutritional calculations for specific portions
    int getCaloriesForPortion(double portionSize) const;
    double getProteinForPortion(double portionSize) const;
    double getFatForPortion(double portionSize) const;
    double getCarbsForPortion(double portionSize) const;
    double getFiberForPortion(double portionSize) const;
    double getSugarForPortion(double portionSize) const;
    int getSodiumForPortion(double portionSize) const;
    
    // Utility methods
    bool isValid() const;
    std::string getDisplayName() const;
    std::string getNutritionSummary() const;
    double getTotalMacros() const;
    
    // Search and comparison
    bool matchesQuery(const std::string& query) const;
    double calculateSimilarity(const FoodItem& other) const;
    
    // JSON serialization
    std::string toJSON() const;
    bool fromJSON(const std::string& json);
    
    // Operators
    bool operator==(const FoodItem& other) const;
    bool operator!=(const FoodItem& other) const;
    
private:
    void initializeDefaults();
    double calculatePortionMultiplier(double portionSize) const;
};

// Helper functions
std::string generateFoodId();
bool isValidNutritionalValue(double value);
std::string formatNutritionalValue(double value, const std::string& unit);

#endif /* FoodItem_hpp */