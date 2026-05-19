# FoodTrackerPro - Complete Xcode Setup Instructions

This guide provides step-by-step instructions for setting up the FoodTrackerPro iOS application in Xcode.

## Prerequisites

- **Xcode 15.0 or later** (recommended: latest version)
- **macOS Ventura 13.0 or later**
- **iOS 16.0+ deployment target**
- **Apple Developer Account** (for device testing and App Store distribution)

## Project Overview

FoodTrackerPro is a SwiftUI-based iOS application with the following key features:
- C++ core engine for performance-critical calculations
- Multi-language support (English, German, Spanish, French, Kazakh, Russian)
- HealthKit integration
- Camera-based food recognition
- iCloud synchronization
- Advanced analytics and body tracking

## Step 1: Create New Xcode Project

1. **Launch Xcode**
2. **Create a new project:**
   - Select "Create a new Xcode project"
   - Choose "iOS" → "App"
   - Click "Next"

3. **Configure project settings:**
   - **Product Name:** `FoodTrackerPro`
   - **Team:** Select your Apple Developer Team
   - **Organization Identifier:** `com.yourcompany.foodtrackerpro` (replace with your identifier)
   - **Bundle Identifier:** Will auto-populate based on organization identifier
   - **Language:** Swift
   - **Interface:** SwiftUI
   - **Use Core Data:** ❌ (unchecked)
   - **Include Tests:** ✅ (checked)
   - Click "Next"

4. **Choose location:**
   - Navigate to `/Users/amirbakbergen/Documents/`
   - **Important:** Name the project folder `FoodTrackerProXcode` to avoid conflicts
   - Click "Create"

## Step 2: Configure Project Settings

### 2.1 General Settings
1. **Select the project file** in the navigator
2. **Under "Deployment Info":**
   - **Minimum Deployments:** iOS 16.0
   - **Supported Destinations:** iPhone, iPad
   - **Device Orientation:** Portrait, Landscape Left, Landscape Right
   - **Status Bar Style:** Default

### 2.2 Build Settings
1. **Select the target** → **Build Settings**
2. **Search for "C++ Language Dialect":**
   - Set to **C++17** or **C++20**
3. **Search for "C++ Standard Library":**
   - Set to **libc++**
4. **Search for "Objective-C Bridging Header":**
   - Set to `FoodTrackerPro/Bridge/FoodTrackerPro-Bridging-Header.h`

### 2.3 Capabilities
1. **Select target** → **Signing & Capabilities**
2. **Add the following capabilities:**
   - **HealthKit**
   - **iCloud** → CloudKit
   - **Background Modes** → Background processing
   - **Camera** (automatically added when using camera)

## Step 3: Import Source Files

### 3.1 Delete Default Files
1. **Delete the following auto-generated files:**
   - `ContentView.swift`
   - `FoodTrackerProApp.swift`
   - `Assets.xcassets` (we'll replace it)

### 3.2 Copy Project Structure
1. **Copy the entire `FoodTrackerPro` folder contents** from your source directory to the Xcode project:
   ```
   FoodTrackerPro/
   ├── App/
   ├── Assets.xcassets/
   ├── Bridge/
   ├── Info.plist
   ├── Models/
   ├── Preview Content/
   ├── Resources/
   ├── Services/
   └── Views/
   ```

2. **Copy the `CppCore` folder** to the project root:
   ```
   CppCore/
   ├── FoodItem.cpp
   ├── FoodItem.hpp
   ├── UserProfile.cpp
   └── UserProfile.hpp
   ```

### 3.3 Add Files to Xcode Project
1. **Right-click on the project** in the navigator
2. **Select "Add Files to 'FoodTrackerPro'"**
3. **Navigate to your copied folders** and select:
   - The entire `FoodTrackerPro` folder
   - The entire `CppCore` folder
4. **In the dialog:**
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ **Add to target: FoodTrackerPro**
   - Click "Add"

## Step 4: Configure C++ Integration

### 4.1 Add C++ Files to Build
1. **Select project** → **Build Phases**
2. **Expand "Compile Sources"**
3. **Ensure the following C++ files are listed:**
   - `CppCore/FoodItem.cpp`
   - `CppCore/UserProfile.cpp`
4. **If not present, click "+" and add them**

### 4.2 Configure Bridging Header
1. **Verify the bridging header path** in Build Settings:
   - **Objective-C Bridging Header:** `FoodTrackerPro/Bridge/FoodTrackerPro-Bridging-Header.h`

### 4.3 Add Objective-C++ Bridge Files
**Ensure these files are in your project:**
- `FoodTrackerPro/Bridge/TamizaFoodItemBridge.h`
- `FoodTrackerPro/Bridge/TamizaFoodItemBridge.mm`
- `FoodTrackerPro/Bridge/TamizaUserProfileBridge.h`
- `FoodTrackerPro/Bridge/TamizaUserProfileBridge.mm`
- `FoodTrackerPro/Bridge/UserProfileBridge.swift`

## Step 5: Configure Info.plist

### 5.1 Replace Info.plist
1. **Delete the auto-generated Info.plist**
2. **Use the provided Info.plist** from the FoodTrackerPro folder
3. **Verify the following permissions are present:**
   - `NSCameraUsageDescription`
   - `NSHealthShareUsageDescription`
   - `NSHealthUpdateUsageDescription`
   - `NSLocationWhenInUseUsageDescription`

### 5.2 Update Bundle Identifier
1. **Open Info.plist**
2. **Verify CFBundleIdentifier** matches your project settings

## Step 6: Configure Localization

### 6.1 Add Localization Files
1. **In Xcode, select the project**
2. **Go to Project** → **Info** → **Localizations**
3. **Add the following languages:**
   - English (en)
   - German (de)
   - Spanish (es)
   - French (fr)
   - Kazakh (kk)
   - Russian (ru)

### 6.2 Import Localization Resources
1. **Copy the `Resources/Localizations` folder** to your project
2. **Add each `.lproj` folder** to the Xcode project
3. **Ensure Localizable.strings files** are properly linked

## Step 7: Configure Dependencies and Frameworks

### 7.1 Add Required Frameworks
1. **Select target** → **Build Phases** → **Link Binary With Libraries**
2. **Add the following frameworks:**
   - `SwiftUI.framework`
   - `UIKit.framework`
   - `HealthKit.framework`
   - `CloudKit.framework`
   - `AVFoundation.framework` (for camera)
   - `Vision.framework` (for AI recognition)
   - `CoreML.framework` (for AI recognition)
   - `CoreLocation.framework`

### 7.2 Add Swift Package Dependencies (if needed)
1. **File** → **Add Package Dependencies**
2. **Add any required packages** (check the Swift files for import statements)

## Step 8: Build Configuration

### 8.1 Resolve Build Issues
1. **Build the project** (⌘+B)
2. **Common issues and solutions:**

   **Missing C++ Standard Library:**
   - Build Settings → C++ Standard Library → libc++

   **Bridging Header Not Found:**
   - Build Settings → Objective-C Bridging Header → Verify path

   **Missing Framework:**
   - Add missing frameworks in Build Phases

   **Localization Issues:**
   - Ensure all .lproj folders are properly added to target

### 8.2 Configure Schemes
1. **Edit Scheme** (Product → Scheme → Edit Scheme)
2. **Run** → **Options**:
   - **Language:** System Language
   - **Region:** System Region

## Step 9: Test the Setup

### 9.1 Build and Run
1. **Select a simulator** (iPhone 15 Pro recommended)
2. **Build and run** (⌘+R)
3. **Verify the app launches** without crashes

### 9.2 Test Key Features
1. **Profile Setup:** Verify the initial setup screen appears
2. **Navigation:** Test tab navigation
3. **Camera:** Test camera permissions (on device)
4. **HealthKit:** Test health permissions (on device)

## Step 10: Device Testing

### 10.1 Configure for Device Testing
1. **Connect your iOS device**
2. **Select your device** as the run destination
3. **Ensure your Apple ID** is added to Xcode preferences
4. **Trust the developer certificate** on your device

### 10.2 Test on Device
1. **Build and run on device**
2. **Test camera functionality**
3. **Test HealthKit integration**
4. **Verify all permissions work correctly**

## Troubleshooting

### Common Build Errors

**Error: "No such file or directory"**
- **Solution:** Verify all files are properly added to the target
- Check Build Phases → Compile Sources

**Error: "Use of undeclared identifier"**
- **Solution:** Check bridging header configuration
- Verify C++ files are compiled as Objective-C++

**Error: "Module not found"**
- **Solution:** Add missing frameworks
- Check import statements in Swift files

**Error: "Localization not working"**
- **Solution:** Verify .lproj folders are added to target
- Check LocalizationManager implementation

### Performance Optimization

1. **Enable compiler optimizations** for Release builds
2. **Configure proper memory management** for C++ objects
3. **Test on older devices** to ensure performance

## Final Checklist

- [ ] Project builds without errors
- [ ] App launches successfully
- [ ] All tabs navigate properly
- [ ] Camera permissions work
- [ ] HealthKit permissions work
- [ ] Localization works for all languages
- [ ] C++ bridge functions correctly
- [ ] iCloud sync is configured
- [ ] App works on both simulator and device

## Additional Resources

- **Apple Developer Documentation:** https://developer.apple.com/documentation/
- **SwiftUI Documentation:** https://developer.apple.com/documentation/swiftui
- **HealthKit Documentation:** https://developer.apple.com/documentation/healthkit
- **CloudKit Documentation:** https://developer.apple.com/documentation/cloudkit

## Support

If you encounter issues during setup:
1. **Check the build log** for specific error messages
2. **Verify all file paths** are correct
3. **Ensure all dependencies** are properly configured
4. **Test on a clean project** if issues persist

---

**Note:** This setup guide assumes you have the complete FoodTrackerPro source code. Make sure all source files are present before beginning the setup process.