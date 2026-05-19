//
//  TamizaFoodItemBridge.mm
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//  Objective-C++ implementation bridging C++ FoodItem to Swift
//

#import "TamizaFoodItemBridge.h"
#include "../../CppCore/FoodItem.hpp"
#include <memory>

@interface TamizaFoodItemBridge ()
@property (nonatomic) std::shared_ptr<FoodItem> cppFoodItem;
@end

@implementation TamizaFoodItemBridge

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _cppFoodItem = std::make_shared<FoodItem>();
    }
    return self;
}

- (instancetype)initWithId:(NSString *)itemId name:(NSString *)name {
    self = [super init];
    if (self) {
        std::string cppId = itemId ? [itemId UTF8String] : "";
        std::string cppName = name ? [name UTF8String] : "";
        _cppFoodItem = std::make_shared<FoodItem>(cppId, cppName);
    }
    return self;
}

// MARK: - Property Getters

- (NSString *)itemId {
    if (!_cppFoodItem) return @"";
    return [NSString stringWithUTF8String:_cppFoodItem->getId().c_str()];
}

- (NSString *)name {
    if (!_cppFoodItem) return @"";
    return [NSString stringWithUTF8String:_cppFoodItem->getName().c_str()];
}

- (NSString *)brand {
    if (!_cppFoodItem) return @"";
    return [NSString stringWithUTF8String:_cppFoodItem->getBrand().c_str()];
}

- (NSString *)barcode {
    if (!_cppFoodItem) return @"";
    return [NSString stringWithUTF8String:_cppFoodItem->getBarcode().c_str()];
}

- (NSString *)category {
    if (!_cppFoodItem) return @"";
    return [NSString stringWithUTF8String:_cppFoodItem->getCategory().c_str()];
}

- (NSInteger)calories {
    if (!_cppFoodItem) return 0;
    return _cppFoodItem->getCalories();
}

- (double)protein {
    if (!_cppFoodItem) return 0.0;
    return _cppFoodItem->getProtein();
}

- (double)fat {
    if (!_cppFoodItem) return 0.0;
    return _cppFoodItem->getFat();
}

- (double)carbs {
    if (!_cppFoodItem) return 0.0;
    return _cppFoodItem->getCarbs();
}

- (double)fiber {
    if (!_cppFoodItem) return 0.0;
    return _cppFoodItem->getFiber();
}

- (double)sugar {
    if (!_cppFoodItem) return 0.0;
    return _cppFoodItem->getSugar();
}

- (NSInteger)sodium {
    if (!_cppFoodItem) return 0;
    return _cppFoodItem->getSodium();
}

- (double)servingSize {
    if (!_cppFoodItem) return 0.0;
    return _cppFoodItem->getServingSize();
}

- (NSString *)servingUnit {
    if (!_cppFoodItem) return @"";
    return [NSString stringWithUTF8String:_cppFoodItem->getServingUnit().c_str()];
}

- (BOOL)isUserCreated {
    if (!_cppFoodItem) return NO;
    return _cppFoodItem->getIsUserCreated() ? YES : NO;
}

- (NSString *)createdBy {
    if (!_cppFoodItem) return @"";
    return [NSString stringWithUTF8String:_cppFoodItem->getCreatedBy().c_str()];
}

- (NSInteger)verificationCount {
    if (!_cppFoodItem) return 0;
    return _cppFoodItem->getVerificationCount();
}

- (NSString *)createdAt {
    if (!_cppFoodItem) return @"";
    return [NSString stringWithUTF8String:_cppFoodItem->getCreatedAt().c_str()];
}

// MARK: - Property Setters

- (void)setItemId:(NSString *)itemId {
    if (!_cppFoodItem) return;
    std::string cppId = itemId ? [itemId UTF8String] : "";
    _cppFoodItem->setId(cppId);
}

- (void)setName:(NSString *)name {
    if (!_cppFoodItem) return;
    std::string cppName = name ? [name UTF8String] : "";
    _cppFoodItem->setName(cppName);
}

- (void)setBrand:(NSString *)brand {
    if (!_cppFoodItem) return;
    std::string cppBrand = brand ? [brand UTF8String] : "";
    _cppFoodItem->setBrand(cppBrand);
}

- (void)setBarcode:(NSString *)barcode {
    if (!_cppFoodItem) return;
    std::string cppBarcode = barcode ? [barcode UTF8String] : "";
    _cppFoodItem->setBarcode(cppBarcode);
}

- (void)setCategory:(NSString *)category {
    if (!_cppFoodItem) return;
    std::string cppCategory = category ? [category UTF8String] : "";
    _cppFoodItem->setCategory(cppCategory);
}

- (void)setCalories:(NSInteger)calories {
    if (!_cppFoodItem) return;
    _cppFoodItem->setCalories((int)calories);
}

- (void)setProtein:(double)protein {
    if (!_cppFoodItem) return;
    _cppFoodItem->setProtein(protein);
}

- (void)setFat:(double)fat {
    if (!_cppFoodItem) return;
    _cppFoodItem->setFat(fat);
}

- (void)setCarbs:(double)carbs {
    if (!_cppFoodItem) return;
    _cppFoodItem->setCarbs(carbs);
}

- (void)setFiber:(double)fiber {
    if (!_cppFoodItem) return;
    _cppFoodItem->setFiber(fiber);
}

- (void)setSugar:(double)sugar {
    if (!_cppFoodItem) return;
    _cppFoodItem->setSugar(sugar);
}

- (void)setSodium:(NSInteger)sodium {
    if (!_cppFoodItem) return;
    _cppFoodItem->setSodium((int)sodium);
}

- (void)setServingSize:(double)servingSize {
    if (!_cppFoodItem) return;
    _cppFoodItem->setServingSize(servingSize);
}

- (void)setServingUnit:(NSString *)servingUnit {
    if (!_cppFoodItem) return;
    std::string cppUnit = servingUnit ? [servingUnit UTF8String] : "";
    _cppFoodItem->setServingUnit(cppUnit);
}

- (void)setIsUserCreated:(BOOL)isUserCreated {
    if (!_cppFoodItem) return;
    _cppFoodItem->setIsUserCreated(isUserCreated ? true : false);
}

- (void)setCreatedBy:(NSString *)createdBy {
    if (!_cppFoodItem) return;
    std::string cppCreatedBy = createdBy ? [createdBy UTF8String] : "";
    _cppFoodItem->setCreatedBy(cppCreatedBy);
}

- (void)setVerificationCount:(NSInteger)verificationCount {
    if (!_cppFoodItem) return;
    _cppFoodItem->setVerificationCount((int)verificationCount);
}

- (void)setCreatedAt:(NSString *)createdAt {
    if (!_cppFoodItem) return;
    std::string cppCreatedAt = createdAt ? [createdAt UTF8String] : "";
    _cppFoodItem->setCreatedAt(cppCreatedAt);
}

// MARK: - Nutritional Calculations

- (NSInteger)getCaloriesForPortion:(double)portionSize {
    if (!_cppFoodItem) return 0;
    return _cppFoodItem->getCaloriesForPortion(portionSize);
}

- (double)getProteinForPortion:(double)portionSize {
    if (!_cppFoodItem) return 0.0;
    return _cppFoodItem->getProteinForPortion(portionSize);
}

- (double)getFatForPortion:(double)portionSize {
    if (!_cppFoodItem) return 0.0;
    return _cppFoodItem->getFatForPortion(portionSize);
}

- (double)getCarbsForPortion:(double)portionSize {
    if (!_cppFoodItem) return 0.0;
    return _cppFoodItem->getCarbsForPortion(portionSize);
}

- (double)getFiberForPortion:(double)portionSize {
    if (!_cppFoodItem) return 0.0;
    return _cppFoodItem->getFiberForPortion(portionSize);
}

- (double)getSugarForPortion:(double)portionSize {
    if (!_cppFoodItem) return 0.0;
    return _cppFoodItem->getSugarForPortion(portionSize);
}

- (NSInteger)getSodiumForPortion:(double)portionSize {
    if (!_cppFoodItem) return 0;
    return _cppFoodItem->getSodiumForPortion(portionSize);
}

// MARK: - Utility Methods

- (BOOL)isValid {
    if (!_cppFoodItem) return NO;
    return _cppFoodItem->isValid() ? YES : NO;
}

- (NSString *)getDisplayName {
    if (!_cppFoodItem) return @"";
    return [NSString stringWithUTF8String:_cppFoodItem->getDisplayName().c_str()];
}

- (NSString *)getNutritionSummary {
    if (!_cppFoodItem) return @"";
    return [NSString stringWithUTF8String:_cppFoodItem->getNutritionSummary().c_str()];
}

- (double)getTotalMacros {
    if (!_cppFoodItem) return 0.0;
    return _cppFoodItem->getTotalMacros();
}

// MARK: - Search and Comparison

- (BOOL)matchesQuery:(NSString *)query {
    if (!_cppFoodItem || !query) return NO;
    std::string cppQuery = [query UTF8String];
    return _cppFoodItem->matchesQuery(cppQuery) ? YES : NO;
}

- (double)calculateSimilarity:(TamizaFoodItemBridge *)other {
    if (!_cppFoodItem || !other || !other.cppFoodItem) return 0.0;
    return _cppFoodItem->calculateSimilarity(*other.cppFoodItem);
}

// MARK: - JSON Serialization

- (NSString *)toJSON {
    if (!_cppFoodItem) return @"{}";
    return [NSString stringWithUTF8String:_cppFoodItem->toJSON().c_str()];
}

- (BOOL)fromJSON:(NSString *)json {
    if (!_cppFoodItem || !json) return NO;
    std::string cppJson = [json UTF8String];
    return _cppFoodItem->fromJSON(cppJson) ? YES : NO;
}

// MARK: - Operators

- (BOOL)isEqualToFoodItem:(TamizaFoodItemBridge *)other {
    if (!_cppFoodItem || !other || !other.cppFoodItem) return NO;
    return (*_cppFoodItem == *other.cppFoodItem) ? YES : NO;
}

// MARK: - Helper Methods

+ (NSString *)generateFoodId {
    return [NSString stringWithUTF8String:generateFoodId().c_str()];
}

+ (BOOL)isValidNutritionalValue:(double)value {
    return isValidNutritionalValue(value) ? YES : NO;
}

+ (NSString *)formatNutritionalValue:(double)value unit:(NSString *)unit {
    std::string cppUnit = unit ? [unit UTF8String] : "";
    return [NSString stringWithUTF8String:formatNutritionalValue(value, cppUnit).c_str()];
}

@end