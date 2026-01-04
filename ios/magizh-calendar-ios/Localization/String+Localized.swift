import SwiftUI

/// Environment key for tracking app language changes
struct AppLanguageKey: EnvironmentKey {
    static let defaultValue: AppLanguage = .english
}

extension EnvironmentValues {
    var appLanguage: AppLanguage {
        get { self[AppLanguageKey.self] }
        set { self[AppLanguageKey.self] = newValue }
    }
}

/// Convenience extension for creating localized Text views
extension View {
    /// Apply app language to environment
    func appLanguage(_ language: AppLanguage) -> some View {
        environment(\.appLanguage, language)
    }
}
