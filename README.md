# FoodTrackerPro

> An iOS nutrition tracker with AI-powered food recognition, HealthKit sync, iCloud backup, and a C++ performance core — built in Swift / SwiftUI.

![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0070C0?logo=swift)
![iOS](https://img.shields.io/badge/iOS-16%2B-000000?logo=apple)
![CoreML](https://img.shields.io/badge/AI-CoreML%20%2B%20Vision-5856D6?logo=apple)

---

## What It Does

FoodTrackerPro lets you log meals, track macros, and monitor body metrics — all on-device. Snap a photo of your food and the app identifies it using a **Food-101 CoreML model** (101 food categories) and auto-fills the nutrition data. Everything syncs to iCloud and integrates with Apple Health.

---

## Features

### AI Camera
- Real-time food recognition via **Food-101 CoreML + Vision** framework
- Confidence score with colour-coded indicator (green / orange / red)
- Top-3 suggestions shown instantly after capture
- Portion size picker (50 g / 100 g / 150 g / 200 g / 250 g + custom)
- Nutrition auto-filled from recognised category; adjusts to chosen portion

### Nutrition & Meals
- Daily macro dashboard (calories, protein, fat, carbs)
- Add meals manually or via AI camera
- Calendar view — browse any past day's log
- Macro goal configuration per user profile

### Body & Health
- Body weight / measurement tracking with trend charts
- **HealthKit** integration — read steps, active calories; write nutrition data
- Analytics dashboard with weekly / monthly breakdowns

### Technical
- **C++ core** (`FoodItem`, `UserProfile`) bridged to Swift via Objective-C++
- **iCloud (`CloudKit`)** sync — data available across all your devices
- **6 languages** — English, Russian, Kazakh, German, Spanish, French
- SwiftData persistence
- Fully async with `async/await` + `@MainActor`

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9 |
| UI framework | SwiftUI |
| AI / ML | CoreML · Vision · Food-101 model |
| Performance core | C++ (bridged via Objective-C++) |
| Persistence | SwiftData |
| Cloud sync | CloudKit / iCloud |
| Health | HealthKit |
| Min deployment | iOS 16 |

---

## Architecture

```
FoodTrackerPro/
  App/
    FoodTrackerProApp.swift   # entry point, environment setup
    ContentView.swift
  Views/
    MainTabView.swift         # tab bar (Today / Calendar / Analytics / Profile)
    Food/
      AICameraView.swift      # camera + Vision inference + result cards
      FoodSearchView.swift    # manual search
    Meals/
      TodayView.swift         # daily macro ring + meal list
      AddMealView.swift
    Analytics/
      AnalyticsView.swift     # charts
    BodyTracking/
      BodyTrackingView.swift
    Calendar/
      CalendarView.swift
    Profile/
      ProfileView.swift
      ProfileSetupView.swift
  Services/
    Food101RecognitionManager.swift   # CoreML inference pipeline
    HealthManager.swift               # HealthKit read/write
    iCloudManager.swift               # CloudKit sync
    LocalizationManager.swift         # runtime language switching
  Models/
    AppModel.swift            # @Observable app state
    FoodDatabaseManager.swift
    UserProfileManager.swift
  Bridge/
    FoodTrackerPro-Bridging-Header.h
    TamizaFoodItemBridge.{h,mm}       # C++ ↔ Swift bridge (Obj-C++)
    TamizaUserProfileBridge.{h,mm}
  CppCore/
    FoodItem.{hpp,cpp}        # nutrition data model in C++
    UserProfile.{hpp,cpp}     # user BMR / TDEE calculations in C++
  Resources/
    DesignSystem.swift        # design tokens (colours, fonts, spacing)
    Localizations/            # en · ru · kk · de · es · fr
```

---

## How to Run

1. **Requirements:** Xcode 15+, macOS 14+, an iPhone or iOS Simulator running iOS 16+
2. Clone the repo and open `FoodTrackerPro.xcodeproj` in Xcode
3. Select your development team in *Signing & Capabilities* (required for HealthKit + iCloud entitlements)
4. Add the `Food101.mlmodelc` CoreML model to the bundle (not committed — large binary; see `XCODE_SETUP_INSTRUCTIONS.md`)
5. Build & run on device or simulator (`⌘R`)

For HealthKit and iCloud to work you need a physical device with a valid Apple ID signed in.

---

## AI Food Recognition Pipeline

```
Camera capture (AVFoundation)
    │
    ▼
UIImage → CGImage
    │
    ▼
VNCoreMLRequest (Food101.mlmodelc)
    │ imageCropAndScaleOption: .centerCrop
    ▼
VNClassificationObservation[]
    │ filter confidence ≥ 0.30
    │ take top 5
    ▼
Food101Result { foodName · confidence · category · estimatedNutrition }
    │
    ▼
RecognitionResultCard shown in overlay
    │ user picks result + portion size
    ▼
Meal entry created, macros logged
```

101 food categories including sushi, pizza, ramen, tacos, apple pie, steak, and more.

---

## Localisation

The app switches language at runtime via `LocalizationManager` (no system restart needed). Supported: 🇬🇧 English · 🇷🇺 Russian · 🇰🇿 Kazakh · 🇩🇪 German · 🇪🇸 Spanish · 🇫🇷 French.

---

## What I Learned

- **CoreML + Vision pipeline** — wiring a `.mlmodelc` into a real-time camera overlay with async inference taught me how to keep the UI responsive while heavy ML work runs off the main thread
- **C++ ↔ Swift bridging** — using Objective-C++ as a bridge layer was initially unfamiliar; it's cleaner than it looks once you understand the `.mm` compilation boundary
- **SwiftUI concurrency** — `async/await` + `@MainActor` is the right model; publishing from background tasks without `@MainActor` causes subtle crashes
- **HealthKit permissions** — the entitlement + plist + runtime request triple-check is mandatory; any mismatch silently denies access
- **iCloud sync** — `CloudKit` requires every field to be optional during migration; building defensively from day one avoids schema pain later

---

## My Role

Sole developer — architecture, AI pipeline, C++ core, all SwiftUI screens, HealthKit integration, iCloud sync, localisation, design system.
