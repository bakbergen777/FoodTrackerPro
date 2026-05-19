//
//  TamizaUserProfileBridge.h
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//  Bridge between C++ UserProfile and Swift
//

#ifndef TamizaUserProfileBridge_h
#define TamizaUserProfileBridge_h

#import <Foundation/Foundation.h>

// Forward declarations
@class TamizaUserProfileBridge;

// Enum mappings for Swift compatibility
typedef NS_ENUM(NSInteger, TamizaGender) {
    TamizaGenderMale = 0,
    TamizaGenderFemale = 1
};

typedef NS_ENUM(NSInteger, TamizaActivityLevel) {
    TamizaActivityLevelSedentary = 0,
    TamizaActivityLevelLight = 1,
    TamizaActivityLevelModerate = 2,
    TamizaActivityLevelActive = 3,
    TamizaActivityLevelVeryActive = 4
};

// Objective-C bridge class
@interface TamizaUserProfileBridge : NSObject

// Initialization
- (instancetype)init;
- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)name;

// Basic properties
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) double height;
@property (nonatomic, assign) double weight;
@property (nonatomic, assign) TamizaGender gender;
@property (nonatomic, assign) TamizaActivityLevel activityLevel;

// Body measurements
@property (nonatomic, assign) double shoulderCircumference;
@property (nonatomic, assign) double neckCircumference;
@property (nonatomic, assign) double chestCircumference;
@property (nonatomic, assign) double armCircumference;
@property (nonatomic, assign) double thighCircumference;
@property (nonatomic, assign) double hipCircumference;
@property (nonatomic, assign) double calfCircumference;
@property (nonatomic, assign) double footSize;

// Health calculations
- (double)calculateBMR;
- (double)calculateTDEE;
- (double)calculateBMI;
- (double)calculateBodyFatPercentage;

// Utility methods
- (BOOL)isValid;
- (NSString *)genderString;
- (NSString *)activityLevelString;

// JSON serialization
- (NSString *)toJSON;
- (BOOL)fromJSON:(NSString *)json;

// Helper methods for enum conversion
+ (TamizaGender)genderFromString:(NSString *)genderStr;
+ (NSString *)stringFromGender:(TamizaGender)gender;
+ (TamizaActivityLevel)activityLevelFromString:(NSString *)levelStr;
+ (NSString *)stringFromActivityLevel:(TamizaActivityLevel)level;

@end

#endif /* TamizaUserProfileBridge_h */