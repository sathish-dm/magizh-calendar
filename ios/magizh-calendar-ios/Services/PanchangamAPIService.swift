import Foundation

/// Errors that can occur during API calls
enum APIError: Error, LocalizedError, Sendable {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case serverUnavailable
    case unauthorized
    case rateLimited
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "Server error (HTTP \(statusCode))"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .serverUnavailable:
            return "Server is unavailable. Please try again later."
        case .unauthorized:
            return "Authentication failed. Please restart the app."
        case .rateLimited:
            return "Too many requests. Please wait a moment."
        case .missingAPIKey:
            return "API key not configured."
        }
    }
}

/// Configuration constants for the API service
private enum ServiceConfig: Sendable {
    #if DEBUG
    static nonisolated let baseURL = "http://localhost:8080"
    static nonisolated let timeout: TimeInterval = 30
    #else
    static nonisolated let baseURL = "https://api.magizh.com"
    static nonisolated let timeout: TimeInterval = 15
    #endif

    static nonisolated let dailyEndpoint = "/api/panchangam/daily"
    static nonisolated let weeklyEndpoint = "/api/panchangam/weekly"
    static nonisolated let healthEndpoint = "/api/panchangam/health"

    static nonisolated let defaultLatitude = 13.0827
    static nonisolated let defaultLongitude = 80.2707
    static nonisolated let defaultTimezone = "Asia/Kolkata"
}

/// Service for making Panchangam API calls
actor PanchangamAPIService {

    // MARK: - Singleton

    static let shared = PanchangamAPIService()

    // MARK: - Properties

    private let session: URLSession
    private let decoder: JSONDecoder
    private var cachedAPIKey: String?

    // MARK: - Initialization

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = ServiceConfig.timeout
        config.timeoutIntervalForResource = ServiceConfig.timeout * 2
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    // MARK: - Public API

    /// Fetch daily panchangam data
    func fetchDailyPanchangam(
        date: Date,
        latitude: Double? = nil,
        longitude: Double? = nil,
        timezone: String? = nil
    ) async throws -> PanchangamAPIResponse {
        let lat = latitude ?? ServiceConfig.defaultLatitude
        let lng = longitude ?? ServiceConfig.defaultLongitude
        let tz = timezone ?? ServiceConfig.defaultTimezone
        let dateString = formatDate(date)

        var components = URLComponents(string: ServiceConfig.baseURL + ServiceConfig.dailyEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "date", value: dateString),
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lng", value: String(lng)),
            URLQueryItem(name: "timezone", value: tz)
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        return try await performRequest(url: url)
    }

    /// Fetch weekly panchangam data
    func fetchWeeklyPanchangam(
        startDate: Date,
        latitude: Double? = nil,
        longitude: Double? = nil,
        timezone: String? = nil
    ) async throws -> [PanchangamAPIResponse] {
        let lat = latitude ?? ServiceConfig.defaultLatitude
        let lng = longitude ?? ServiceConfig.defaultLongitude
        let tz = timezone ?? ServiceConfig.defaultTimezone
        let dateString = formatDate(startDate)

        var components = URLComponents(string: ServiceConfig.baseURL + ServiceConfig.weeklyEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "startDate", value: dateString),
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lng", value: String(lng)),
            URLQueryItem(name: "timezone", value: tz)
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        return try await performRequest(url: url)
    }

    /// Check API health
    func checkHealth() async -> Bool {
        guard let url = URL(string: ServiceConfig.baseURL + ServiceConfig.healthEndpoint) else {
            return false
        }

        do {
            let (_, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }

    // MARK: - Private Methods

    private func performRequest<T: Decodable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)

        // Add authentication headers
        try await addAuthenticationHeaders(to: &request)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            if error.code == .notConnectedToInternet ||
               error.code == .cannotConnectToHost ||
               error.code == .timedOut {
                throw APIError.serverUnavailable
            }
            throw APIError.networkError(error)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Handle auth-specific error codes
        switch httpResponse.statusCode {
        case 200...299:
            break // Success, continue
        case 401:
            throw APIError.unauthorized
        case 429:
            throw APIError.rateLimited
        default:
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    /// Add authentication headers to request
    private func addAuthenticationHeaders(to request: inout URLRequest) async throws {
        // Get cached key or fetch from APICredentials
        if cachedAPIKey == nil {
            cachedAPIKey = await APICredentials.getAPIKey()
        }

        guard let apiKey = cachedAPIKey else {
            #if DEBUG
            // Allow requests without API key in debug mode for flexibility
            return
            #else
            throw APIError.missingAPIKey
            #endif
        }

        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue(APICredentials.clientType, forHTTPHeaderField: "X-Client-Type")
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Convenience Extension

extension PanchangamAPIService {
    /// Fetch daily panchangam and convert to domain model
    func fetchDailyPanchangamModel(
        date: Date,
        location: Location
    ) async throws -> PanchangamData {
        let response = try await fetchDailyPanchangam(
            date: date,
            latitude: location.latitude,
            longitude: location.longitude,
            timezone: location.timezone
        )

        guard let model = await response.toDomainModel(location: location) else {
            throw APIError.invalidResponse
        }

        return model
    }

    /// Fetch weekly panchangam and convert to domain models
    func fetchWeeklyPanchangamModels(
        startDate: Date,
        location: Location
    ) async throws -> [PanchangamData] {
        let responses = try await fetchWeeklyPanchangam(
            startDate: startDate,
            latitude: location.latitude,
            longitude: location.longitude,
            timezone: location.timezone
        )

        var models: [PanchangamData] = []
        for response in responses {
            if let model = await response.toDomainModel(location: location) {
                models.append(model)
            }
        }
        return models
    }
}
