import Foundation

/// API Configuration
enum APIConfig {
    /// Base URL for the Panchangam API (from environment)
    static var baseURL: String {
        AppEnvironment.current.apiBaseURL
    }

    /// API endpoints
    enum Endpoints {
        static let daily = "/api/panchangam/daily"
        static let weekly = "/api/panchangam/weekly"
        static let health = "/api/panchangam/health"
    }

    /// Timeout interval from environment
    static var timeoutInterval: TimeInterval {
        AppEnvironment.current.apiTimeout
    }

    /// Default location (Chennai)
    static let defaultLatitude = 13.0827
    static let defaultLongitude = 80.2707
    static let defaultTimezone = "Asia/Kolkata"
}
