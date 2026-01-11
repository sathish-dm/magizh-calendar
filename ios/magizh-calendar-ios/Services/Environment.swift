import Foundation

/// App environment configuration
/// All properties are nonisolated for safe concurrent access
enum AppEnvironment: String, CaseIterable, Sendable {
    case development
    case staging
    case production

    /// Current active environment - compile-time constant
    static let current: AppEnvironment = {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }()

    /// Base URL for the API
    var apiBaseURL: String {
        switch self {
        case .development:
            return "http://localhost:8080"
        case .staging:
            return "https://staging.api.magizh.me"
        case .production:
            return "https://api.magizh.me"
        }
    }

    /// Whether to show debug information
    var showDebugInfo: Bool {
        switch self {
        case .development, .staging:
            return true
        case .production:
            return false
        }
    }

    /// API timeout in seconds
    var apiTimeout: TimeInterval {
        switch self {
        case .development:
            return 30
        case .staging, .production:
            return 15
        }
    }

    /// Whether to use mock data when API fails
    var useMockDataFallback: Bool {
        true
    }

    /// Display name for debugging
    var displayName: String {
        rawValue.capitalized
    }
}
