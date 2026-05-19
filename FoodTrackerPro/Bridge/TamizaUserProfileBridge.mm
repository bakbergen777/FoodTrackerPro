//
//  TamizaUserProfileBridge.mm
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//  Objective-C++ implementation bridging C++ UserProfile to Swift
//

#import "TamizaUserProfileBridge.h"
#include "../../CppCore/UserProfile.hpp"
#include <memory>

@interface TamizaUserProfileBridge ()
@property (nonatomic) std::shared_ptr<UserProfile> cppUserProfile;
@end

@implementation TamizaUserProfileBridge

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _cppUserProfile = std::make_shared<UserProfile>();
    }
    return self;
}

- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)name {
    self = [super init];
    if (self) {
        std::string cppUserId = userId ? [userId UTF8String] : "";
        std::string cppName = name ? [name UTF8String] : "";
        _cppUserProfile = std::make_shared<UserProfile>(cppUserId, cppName);
    }
    return self;
}

// MARK: - Property Getters

- (NSString *)userId {
    if (!_cppUserProfile) return @"";
    return [NSString stringWithUTF8String:_cppUserProfile->getUserId().c_str()];
}

- (NSString *)name {
    if (!_cppUserProfile) return @"";
    return [NSString stringWithUTF8String:_cppUserProfile->getName().c_str()];
}

- (NSInteger)age {
    if (!_cppUserProfile) return 0;
    return _cppUserProfile->getAge();
}

- (double)height {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->getHeight();
}

- (double)weight {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->getWeight();
}

- (TamizaGender)gender {
    if (!_cppUserProfile) return TamizaGenderMale;
    Gender cppGender = _cppUserProfile->getGender();
    return (cppGender == Gender::Female) ? TamizaGenderFemale : TamizaGenderMale;
}

- (TamizaActivityLevel)activityLevel {
    if (!_cppUserProfile) return TamizaActivityLevelModerate;
    ActivityLevel cppLevel = _cppUserProfile->getActivityLevel();
    switch (cppLevel) {
        case ActivityLevel::Sedentary: return TamizaActivityLevelSedentary;
        case ActivityLevel::Light: return TamizaActivityLevelLight;
        case ActivityLevel::Moderate: return TamizaActivityLevelModerate;
        case ActivityLevel::Active: return TamizaActivityLevelActive;
        case ActivityLevel::VeryActive: return TamizaActivityLevelVeryActive;
        default: return TamizaActivityLevelModerate;
    }
}

// Body measurements getters
- (double)shoulderCircumference {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->getShoulderCircumference();
}

- (double)neckCircumference {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->getNeckCircumference();
}

- (double)chestCircumference {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->getChestCircumference();
}

- (double)armCircumference {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->getArmCircumference();
}

- (double)thighCircumference {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->getThighCircumference();
}

- (double)hipCircumference {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->getHipCircumference();
}

- (double)calfCircumference {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->getCalfCircumference();
}

- (double)footSize {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->getFootSize();
}

// MARK: - Property Setters

- (void)setUserId:(NSString *)userId {
    if (!_cppUserProfile) return;
    std::string cppUserId = userId ? [userId UTF8String] : "";
    _cppUserProfile->setUserId(cppUserId);
}

- (void)setName:(NSString *)name {
    if (!_cppUserProfile) return;
    std::string cppName = name ? [name UTF8String] : "";
    _cppUserProfile->setName(cppName);
}

- (void)setAge:(NSInteger)age {
    if (!_cppUserProfile) return;
    _cppUserProfile->setAge((int)age);
}

- (void)setHeight:(double)height {
    if (!_cppUserProfile) return;
    _cppUserProfile->setHeight(height);
}

- (void)setWeight:(double)weight {
    if (!_cppUserProfile) return;
    _cppUserProfile->setWeight(weight);
}

- (void)setGender:(TamizaGender)gender {
    if (!_cppUserProfile) return;
    Gender cppGender = (gender == TamizaGenderFemale) ? Gender::Female : Gender::Male;
    _cppUserProfile->setGender(cppGender);
}

- (void)setActivityLevel:(TamizaActivityLevel)activityLevel {
    if (!_cppUserProfile) return;
    ActivityLevel cppLevel;
    switch (activityLevel) {
        case TamizaActivityLevelSedentary: cppLevel = ActivityLevel::Sedentary; break;
        case TamizaActivityLevelLight: cppLevel = ActivityLevel::Light; break;
        case TamizaActivityLevelModerate: cppLevel = ActivityLevel::Moderate; break;
        case TamizaActivityLevelActive: cppLevel = ActivityLevel::Active; break;
        case TamizaActivityLevelVeryActive: cppLevel = ActivityLevel::VeryActive; break;
        default: cppLevel = ActivityLevel::Moderate; break;
    }
    _cppUserProfile->setActivityLevel(cppLevel);
}

// Body measurements setters
- (void)setShoulderCircumference:(double)shoulderCircumference {
    if (!_cppUserProfile) return;
    _cppUserProfile->setShoulderCircumference(shoulderCircumference);
}

- (void)setNeckCircumference:(double)neckCircumference {
    if (!_cppUserProfile) return;
    _cppUserProfile->setNeckCircumference(neckCircumference);
}

- (void)setChestCircumference:(double)chestCircumference {
    if (!_cppUserProfile) return;
    _cppUserProfile->setChestCircumference(chestCircumference);
}

- (void)setArmCircumference:(double)armCircumference {
    if (!_cppUserProfile) return;
    _cppUserProfile->setArmCircumference(armCircumference);
}

- (void)setThighCircumference:(double)thighCircumference {
    if (!_cppUserProfile) return;
    _cppUserProfile->setThighCircumference(thighCircumference);
}

- (void)setHipCircumference:(double)hipCircumference {
    if (!_cppUserProfile) return;
    _cppUserProfile->setHipCircumference(hipCircumference);
}

- (void)setCalfCircumference:(double)calfCircumference {
    if (!_cppUserProfile) return;
    _cppUserProfile->setCalfCircumference(calfCircumference);
}

- (void)setFootSize:(double)footSize {
    if (!_cppUserProfile) return;
    _cppUserProfile->setFootSize(footSize);
}

// MARK: - Health Calculations

- (double)calculateBMR {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->calculateBMR();
}

- (double)calculateTDEE {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->calculateTDEE();
}

- (double)calculateBMI {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->calculateBMI();
}

- (double)calculateBodyFatPercentage {
    if (!_cppUserProfile) return 0.0;
    return _cppUserProfile->calculateBodyFatPercentage();
}

// MARK: - Utility Methods

- (BOOL)isValid {
    if (!_cppUserProfile) return NO;
    return _cppUserProfile->isValid() ? YES : NO;
}

- (NSString *)genderString {
    if (!_cppUserProfile) return @"";
    return [NSString stringWithUTF8String:_cppUserProfile->getGenderString().c_str()];
}

- (NSString *)activityLevelString {
    if (!_cppUserProfile) return @"";
    return [NSString stringWithUTF8String:_cppUserProfile->getActivityLevelString().c_str()];
}

// MARK: - JSON Serialization

- (NSString *)toJSON {
    if (!_cppUserProfile) return @"{}";
    return [NSString stringWithUTF8String:_cppUserProfile->toJSON().c_str()];
}

- (BOOL)fromJSON:(NSString *)json {
    if (!_cppUserProfile || !json) return NO;
    std::string cppJson = [json UTF8String];
    return _cppUserProfile->fromJSON(cppJson) ? YES : NO;
}

// MARK: - Helper Methods for Enum Conversion

+ (TamizaGender)genderFromString:(NSString *)genderStr {
    if (!genderStr) return TamizaGenderMale;
    std::string cppGenderStr = [genderStr UTF8String];
    Gender cppGender = stringToGender(cppGenderStr);
    return (cppGender == Gender::Female) ? TamizaGenderFemale : TamizaGenderMale;
}

+ (NSString *)stringFromGender:(TamizaGender)gender {
    Gender cppGender = (gender == TamizaGenderFemale) ? Gender::Female : Gender::Male;
    return [NSString stringWithUTF8String:genderToString(cppGender).c_str()];
}

+ (TamizaActivityLevel)activityLevelFromString:(NSString *)levelStr {
    if (!levelStr) return TamizaActivityLevelModerate;
    std::string cppLevelStr = [levelStr UTF8String];
    ActivityLevel cppLevel = stringToActivityLevel(cppLevelStr);
    switch (cppLevel) {
        case ActivityLevel::Sedentary: return TamizaActivityLevelSedentary;
        case ActivityLevel::Light: return TamizaActivityLevelLight;
        case ActivityLevel::Moderate: return TamizaActivityLevelModerate;
        case ActivityLevel::Active: return TamizaActivityLevelActive;
        case ActivityLevel::VeryActive: return TamizaActivityLevelVeryActive;
        default: return TamizaActivityLevelModerate;
    }
}

+ (NSString *)stringFromActivityLevel:(TamizaActivityLevel)level {
    ActivityLevel cppLevel;
    switch (level) {
        case TamizaActivityLevelSedentary: cppLevel = ActivityLevel::Sedentary; break;
        case TamizaActivityLevelLight: cppLevel = ActivityLevel::Light; break;
        case TamizaActivityLevelModerate: cppLevel = ActivityLevel::Moderate; break;
        case TamizaActivityLevelActive: cppLevel = ActivityLevel::Active; break;
        case TamizaActivityLevelVeryActive: cppLevel = ActivityLevel::VeryActive; break;
        default: cppLevel = ActivityLevel::Moderate; break;
    }
    return [NSString stringWithUTF8String:activityLevelToString(cppLevel).c_str()];
}

@end