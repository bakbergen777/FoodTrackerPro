//
//  ProfileSetupView.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var name = ""
    @State private var age = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var selectedGender: Gender = .male
    @State private var selectedActivityLevel: ActivityLevel = .moderate
    @State private var currentStep = 0
    @State private var isLoading = false
    
    private let totalSteps = 3
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                    .progressViewStyle(LinearProgressViewStyle(tint: .primaryGreen))
                    .padding()
                
                // Content
                TabView(selection: $currentStep) {
                    // Step 1: Basic Info
                    basicInfoStep
                        .tag(0)
                    
                    // Step 2: Physical Info
                    physicalInfoStep
                        .tag(1)
                    
                    // Step 3: Activity Level
                    activityLevelStep
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("action.back".localized) {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    
                    Spacer()
                    
                    Button(currentStep == totalSteps - 1 ? "action.done".localized : "action.next".localized) {
                        if currentStep == totalSteps - 1 {
                            completeSetup()
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .buttonStyle(GreenButtonStyle())
                    .disabled(!isCurrentStepValid || isLoading)
                }
                .padding()
            }
            .background(Color.backgroundGray)
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Step Views
    
    private var basicInfoStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("profile.setup_title".localized)
                    .font(.largeTitle)
                    .foregroundColor(.textGray)
                    .multilineTextAlignment(.center)
                
                Text("profile.setup_subtitle".localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("profile.name".localized)
                        .font(.headline)
                        .foregroundColor(.textGray)
                    
                    TextField("profile.name".localized, text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("profile.age".localized)
                        .font(.headline)
                        .foregroundColor(.textGray)
                    
                    TextField("profile.age".localized, text: $age)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("profile.gender".localized)
                        .font(.headline)
                        .foregroundColor(.textGray)
                    
                    Picker("profile.gender".localized, selection: $selectedGender) {
                        Text("profile.gender.male".localized).tag(Gender.male)
                        Text("profile.gender.female".localized).tag(Gender.female)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .whiteCard()
        .padding()
    }
    
    private var physicalInfoStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Physical Information")
                    .font(.largeTitle)
                    .foregroundColor(.textGray)
                    .multilineTextAlignment(.center)
                
                Text("Help us calculate your BMR and TDEE accurately")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("body.height".localized)
                        .font(.headline)
                        .foregroundColor(.textGray)
                    
                    HStack {
                        TextField("body.height".localized, text: $height)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .font(.body)
                        
                        Text("cm")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("body.weight".localized)
                        .font(.headline)
                        .foregroundColor(.textGray)
                    
                    HStack {
                        TextField("body.weight".localized, text: $weight)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .font(.body)
                        
                        Text("kg")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .whiteCard()
        .padding()
    }
    
    private var activityLevelStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Activity Level")
                    .font(.largeTitle)
                    .foregroundColor(.textGray)
                    .multilineTextAlignment(.center)
                
                Text("This helps us calculate your daily calorie needs")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            VStack(spacing: 16) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    ActivityLevelCard(
                        level: level,
                        isSelected: selectedActivityLevel == level
                    ) {
                        selectedActivityLevel = level
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var isCurrentStepValid: Bool {
        switch currentStep {
        case 0:
            return !name.isEmpty && !age.isEmpty && Int(age) != nil
        case 1:
            return !height.isEmpty && !weight.isEmpty && 
                   Double(height) != nil && Double(weight) != nil
        case 2:
            return true // Activity level always has a default selection
        default:
            return false
        }
    }
    
    // MARK: - Actions
    
    private func completeSetup() {
        guard let ageInt = Int(age),
              let heightDouble = Double(height),
              let weightDouble = Double(weight) else {
            return
        }
        
        isLoading = true
        
        let profile = UserProfileData(
            name: name,
            age: ageInt,
            height: heightDouble,
            weight: weightDouble,
            gender: selectedGender,
            activityLevel: selectedActivityLevel
        )
        
        Task {
            await appModel.completeProfileSetup(profile)
            isLoading = false
        }
    }
}

// MARK: - Supporting Views

struct ActivityLevelCard: View {
    let level: ActivityLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.localizedTitle)
                        .font(.headline)
                        .foregroundColor(.textGray)
                    
                    Text(level.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primaryGreen)
                        .font(.title2)
                }
            }
            .padding()
            .background(Color.primaryWhite)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryGreen : Color.lightGray, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Types

enum Gender: CaseIterable {
    case male, female
    
    var localizedTitle: String {
        switch self {
        case .male: return "profile.gender.male".localized
        case .female: return "profile.gender.female".localized
        }
    }
}

enum ActivityLevel: CaseIterable {
    case sedentary, light, moderate, active, veryActive
    
    var localizedTitle: String {
        switch self {
        case .sedentary: return "profile.activity.sedentary".localized
        case .light: return "profile.activity.light".localized
        case .moderate: return "profile.activity.moderate".localized
        case .active: return "profile.activity.active".localized
        case .veryActive: return "profile.activity.very_active".localized
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .sedentary: return "Little or no exercise"
        case .light: return "Light exercise 1-3 days/week"
        case .moderate: return "Moderate exercise 3-5 days/week"
        case .active: return "Hard exercise 6-7 days/week"
        case .veryActive: return "Very hard exercise, physical job"
        }
    }
}

struct UserProfileData {
    let name: String
    let age: Int
    let height: Double
    let weight: Double
    let gender: Gender
    let activityLevel: ActivityLevel
}

#Preview {
    ProfileSetupView()
        .environmentObject(AppModel())
        .environmentObject(LocalizationManager.shared)
}