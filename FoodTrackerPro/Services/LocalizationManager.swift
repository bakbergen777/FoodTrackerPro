//
//  LocalizationManager.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: String = "en"
    
    static let shared = LocalizationManager()
    
    private init() {
        // Set initial language from user preferences or system
        if let preferredLanguage = UserDefaults.standard.string(forKey: "app_language") {
            currentLanguage = preferredLanguage
        } else {
            // Use system language if supported, otherwise default to English
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            currentLanguage = supportedLanguages.contains(systemLanguage) ? systemLanguage : "en"
        }
    }
    
    let supportedLanguages = ["en", "ru", "kk", "es", "fr", "de"]
    
    func setLanguage(_ language: String) {
        guard supportedLanguages.contains(language) else { return }
        
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: "app_language")
        
        // Update app language
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Notify observers
        objectWillChange.send()
    }
    
    func localizedString(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
    
    func languageName(for code: String) -> String {
        switch code {
        case "en": return "English"
        case "ru": return "Русский"
        case "kk": return "Қазақша"
        case "es": return "Español"
        case "fr": return "Français"
        case "de": return "Deutsch"
        default: return "English"
        }
    }
    
    func languageFlag(for code: String) -> String {
        switch code {
        case "en": return "🇺🇸"
        case "ru": return "🇷🇺"
        case "kk": return "🇰🇿"
        case "es": return "🇪🇸"
        case "fr": return "🇫🇷"
        case "de": return "🇩🇪"
        default: return "🇺🇸"
        }
    }
}

// MARK: - String Extension for Localization
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}