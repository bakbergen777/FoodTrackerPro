// Test file to verify C++ IntelliSense is working correctly
// This file should have proper IntelliSense support

#include "CppCore/FoodItem.hpp"
#include <iostream>
#include <vector>

int main() {
    // Test C++ IntelliSense - these should have proper autocomplete and error checking
    FoodItem apple("001", "Apple");
    apple.setCalories(52);
    apple.setProtein(0.3);
    apple.setCarbs(14.0);
    
    // This should show IntelliSense suggestions
    std::vector<FoodItem> foods;
    foods.push_back(apple);
    
    // Test method calls - IntelliSense should work here
    std::cout << "Food: " << apple.getName() << std::endl;
    std::cout << "Calories: " << apple.getCalories() << std::endl;
    
    return 0;
}