import Foundation
import SwiftUI
import Combine

/// Centralized service for app localization with reactive updates
@MainActor
final class LocalizationService: ObservableObject {

    // MARK: - Singleton

    static let shared = LocalizationService()

    // MARK: - Published Properties

    @Published private(set) var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: Keys.language)
        }
    }

    // MARK: - Storage Keys

    private enum Keys {
        static let language = "appLanguage"
    }

    // MARK: - Initialization

    private init() {
        if let rawValue = UserDefaults.standard.string(forKey: Keys.language),
           let language = AppLanguage(rawValue: rawValue) {
            self.currentLanguage = language
        } else {
            // Default to English
            self.currentLanguage = .english
        }
    }

    // MARK: - Public Methods

    /// Change the app language
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }

    /// Toggle between English and Tamil
    func toggleLanguage() {
        currentLanguage = currentLanguage == .english ? .tamil : .english
    }

    /// Get localized string for a key
    func string(_ key: LocalizedStringKey) -> String {
        UIStrings.shared.get(key, for: currentLanguage)
    }

    /// Check if current language is Tamil
    var isTamil: Bool {
        currentLanguage == .tamil
    }

    /// Check if current language is English
    var isEnglish: Bool {
        currentLanguage == .english
    }
}
