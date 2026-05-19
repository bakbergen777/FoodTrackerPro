//
//  TamizaFoodItemBridge.h
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//  Bridge between C++ FoodItem and Swift
//

#ifndef TamizaFoodItemBridge_h
#define TamizaFoodItemBridge_h

#import <Foundation/Foundation.h>

// Forward declarations
@class TamizaFoodItemBridge;

// Objective-C bridge class for FoodItem
@interface TamizaFoodItemBridge : NSObject

// Initialization
- (instancetype)init;
- (instancetype)initWithId:(NSString *)itemId name:(NSString *)name;

// Basic properties
@property (nonatomic, strong) NSString *itemId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *barcode;
@property (nonatomic, strong) NSString *category;

// Nutritional information per 100g
@property (nonatomic, assign) NSInteger calories;
@property (nonatomic, assign) double protein;
@property (nonatomic, assign) double fat;
@property (nonatomic, assign) double carbs;
@property (nonatomic, assign) double fiber;
@property (nonatomic, assign) double sugar;
@property (nonatomic, assign) NSInteger sodium;

// Serving information
@property (nonatomic, assign) double servingSize;
@property (nonatomic, strong) NSString *servingUnit;

// Metadata
@property (nonatomic, assign) BOOL isUserCreated;
@property (nonatomic, strong) NSString *createdBy;
@property (nonatomic, assign) NSInteger verificationCount;
@property (nonatomic, strong) NSString *createdAt;

// Nutritional calculations for specific portions
- (NSInteger)getCaloriesForPortion:(double)portionSize;
- (double)getProteinForPortion:(double)portionSize;
- (double)getFatForPortion:(double)portionSize;
- (double)getCarbsForPortion:(double)portionSize;
- (double)getFiberForPortion:(double)portionSize;
- (double)getSugarForPortion:(double)portionSize;
- (NSInteger)getSodiumForPortion:(double)portionSize;

// Utility methods
- (BOOL)isValid;
- (NSString *)getDisplayName;
- (NSString *)getNutritionSummary;
- (double)getTotalMacros;

// Search and comparison
- (BOOL)matchesQuery:(NSString *)query;
- (double)calculateSimilarity:(TamizaFoodItemBridge *)other;

// JSON serialization
- (NSString *)toJSON;
- (BOOL)fromJSON:(NSString *)json;

// Operators
- (BOOL)isEqualToFoodItem:(TamizaFoodItemBridge *)other;

// Helper methods
+ (NSString *)generateFoodId;
+ (BOOL)isValidNutritionalValue:(double)value;
+ (NSString *)formatNutritionalValue:(double)value unit:(NSString *)unit;

@end

#endif /* TamizaFoodItemBridge_h */