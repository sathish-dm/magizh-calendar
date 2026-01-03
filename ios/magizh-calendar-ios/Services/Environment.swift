import Foundation

/// App environment configuration
/// Manages API URLs and feature flags for different environments
enum AppEnvironment: String, CaseIterable {
    case development
    case staging
    case production

    /// Current active environment
    /// Change this to switch environments
    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    /// Base URL for the API
    var apiBaseURL: String {
        switch self {
        case .development:
            return "http://localhost:8080"
        case .staging:
            return "https://staging-api.magizh.com"
        case .production:
            return "https://api.magizh.com"
        }
    }

    /// Whether to show debug information
    var showDebugInfo: Bool {
        switch self {
        case .development:
            return true
        case .staging:
            return true
        case .production:
            return false
        }
    }

    /// API timeout in seconds
    var apiTimeout: TimeInterval {
        switch self {
        case .development:
            return 30  // Longer timeout for debugging
        case .staging, .production:
            return 15
        }
    }

    /// Whether to use mock data when API fails
    var useMockDataFallback: Bool {
        return true  // Always use fallback for better UX
    }

    /// Display name for debugging
    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Environment-aware API Config

extension APIConfig {
    /// Get base URL from current environment
    static var environmentBaseURL: String {
        AppEnvironment.current.apiBaseURL
    }

    /// Get timeout from current environment
    static var environmentTimeout: TimeInterval {
        AppEnvironment.current.apiTimeout
    }
}
