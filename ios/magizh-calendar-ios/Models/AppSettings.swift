import Foundation
import SwiftUI

// MARK: - Time Format

/// Time display format preference
enum TimeFormat: String, Codable, CaseIterable, Identifiable {
    case twelveHour = "12h"
    case twentyFourHour = "24h"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .twelveHour: return "12-hour (3:30 PM)"
        case .twentyFourHour: return "24-hour (15:30)"
        }
    }

    var dateFormatString: String {
        switch self {
        case .twelveHour: return "h:mm a"
        case .twentyFourHour: return "HH:mm"
        }
    }
}

// MARK: - Date Format

/// Date display format preference
enum DateFormat: String, Codable, CaseIterable, Identifiable {
    case full = "full"
    case medium = "medium"
    case short = "short"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .full: return "Friday, January 3, 2026"
        case .medium: return "Jan 3, 2026"
        case .short: return "1/3/26"
        }
    }

    var dateFormatString: String {
        switch self {
        case .full: return "EEEE, MMMM d, yyyy"
        case .medium: return "MMM d, yyyy"
        case .short: return "M/d/yy"
        }
    }
}

// MARK: - App Theme

/// App appearance theme preference
enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - RawRepresentable Extensions for @AppStorage

extension TimeFormat: RawRepresentable {
    init?(rawValue: String) {
        switch rawValue {
        case "12h": self = .twelveHour
        case "24h": self = .twentyFourHour
        default: return nil
        }
    }
}

extension DateFormat: RawRepresentable {
    init?(rawValue: String) {
        switch rawValue {
        case "full": self = .full
        case "medium": self = .medium
        case "short": self = .short
        default: return nil
        }
    }
}

extension AppTheme: RawRepresentable {
    init?(rawValue: String) {
        switch rawValue {
        case "system": self = .system
        case "light": self = .light
        case "dark": self = .dark
        default: return nil
        }
    }
}
