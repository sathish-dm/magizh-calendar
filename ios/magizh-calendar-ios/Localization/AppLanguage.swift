import Foundation
import SwiftUI

/// Supported languages in the app
enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case english = "en"
    case tamil = "ta"

    var id: String { rawValue }

    /// Display name in the language itself
    var displayName: String {
        switch self {
        case .english: return "English"
        case .tamil: return "தமிழ்"
        }
    }

    /// Display name in English (for accessibility)
    var englishDisplayName: String {
        switch self {
        case .english: return "English"
        case .tamil: return "Tamil"
        }
    }

    /// Font design to use for this language
    /// Tamil uses default system font for proper rendering
    var preferredFontDesign: Font.Design {
        switch self {
        case .english: return .rounded
        case .tamil: return .default
        }
    }
}
