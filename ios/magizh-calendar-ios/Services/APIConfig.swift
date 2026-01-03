import Foundation

/// API Configuration - Thread-safe configuration values
enum APIConfig: Sendable {
    /// Base URL for the Panchangam API
    static var baseURL: String {
        AppEnvironment.current.apiBaseURL
    }

    /// Timeout interval from environment
    static var timeoutInterval: TimeInterval {
        AppEnvironment.current.apiTimeout
    }

    /// Default location (Chennai) - compile-time constants
    static let defaultLatitude: Double = 13.0827
    static let defaultLongitude: Double = 80.2707
    static let defaultTimezone: String = "Asia/Kolkata"
}

/// API endpoint paths - simple string constants
enum APIEndpoints {
    static let daily = "/api/panchangam/daily"
    static let weekly = "/api/panchangam/weekly"
    static let health = "/api/panchangam/health"
}
