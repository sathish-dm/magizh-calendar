import Foundation

/// Errors that can occur during API calls
enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case serverUnavailable

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
        }
    }
}

/// Service for making Panchangam API calls
actor PanchangamAPIService {

    // MARK: - Singleton

    static let shared = PanchangamAPIService()

    // MARK: - Properties

    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Initialization

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.timeoutInterval
        config.timeoutIntervalForResource = APIConfig.timeoutInterval * 2
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
    }

    // MARK: - Public API

    /// Fetch daily panchangam data
    /// - Parameters:
    ///   - date: Date to fetch panchangam for
    ///   - latitude: Location latitude
    ///   - longitude: Location longitude
    ///   - timezone: Timezone string
    /// - Returns: PanchangamAPIResponse
    func fetchDailyPanchangam(
        date: Date,
        latitude: Double = APIConfig.defaultLatitude,
        longitude: Double = APIConfig.defaultLongitude,
        timezone: String = APIConfig.defaultTimezone
    ) async throws -> PanchangamAPIResponse {
        let dateString = formatDate(date)

        var components = URLComponents(string: APIConfig.baseURL + APIConfig.Endpoints.daily)
        components?.queryItems = [
            URLQueryItem(name: "date", value: dateString),
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lng", value: String(longitude)),
            URLQueryItem(name: "timezone", value: timezone)
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        return try await performRequest(url: url)
    }

    /// Fetch weekly panchangam data
    /// - Parameters:
    ///   - startDate: Start date of the week
    ///   - latitude: Location latitude
    ///   - longitude: Location longitude
    ///   - timezone: Timezone string
    /// - Returns: Array of PanchangamAPIResponse
    func fetchWeeklyPanchangam(
        startDate: Date,
        latitude: Double = APIConfig.defaultLatitude,
        longitude: Double = APIConfig.defaultLongitude,
        timezone: String = APIConfig.defaultTimezone
    ) async throws -> [PanchangamAPIResponse] {
        let dateString = formatDate(startDate)

        var components = URLComponents(string: APIConfig.baseURL + APIConfig.Endpoints.weekly)
        components?.queryItems = [
            URLQueryItem(name: "startDate", value: dateString),
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lng", value: String(longitude)),
            URLQueryItem(name: "timezone", value: timezone)
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        return try await performRequest(url: url)
    }

    /// Check API health
    /// - Returns: True if API is available
    func checkHealth() async -> Bool {
        guard let url = URL(string: APIConfig.baseURL + APIConfig.Endpoints.health) else {
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
        let request = URLRequest(url: url)

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

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
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
    /// - Parameters:
    ///   - date: Date to fetch
    ///   - location: Location for calculations
    /// - Returns: PanchangamData domain model
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
    /// - Parameters:
    ///   - startDate: Start date of the week
    ///   - location: Location for calculations
    /// - Returns: Array of PanchangamData domain models
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
