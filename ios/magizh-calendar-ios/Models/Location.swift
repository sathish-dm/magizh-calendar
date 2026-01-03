import Foundation
import CoreLocation

/// Represents a geographic location for Panchangam calculations
/// Location is critical for accurate sunrise/sunset and timing calculations
struct Location: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let city: String
    let state: String?
    let country: String
    let latitude: Double
    let longitude: Double
    let timezone: String

    init(
        id: UUID = UUID(),
        name: String? = nil,
        city: String,
        state: String? = nil,
        country: String,
        latitude: Double,
        longitude: Double,
        timezone: String
    ) {
        self.id = id
        self.name = name ?? city
        self.city = city
        self.state = state
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
    }

    /// Full display name (e.g., "Chennai, Tamil Nadu, India")
    var fullDisplayName: String {
        if let state = state {
            return "\(city), \(state), \(country)"
        }
        return "\(city), \(country)"
    }

    /// Short display name (e.g., "Chennai, TN")
    var shortDisplayName: String {
        if let state = state {
            let stateAbbr = state.prefix(2).uppercased()
            return "\(city), \(stateAbbr)"
        }
        return city
    }

    /// Display name for UI (alias for name)
    var displayName: String { name }

    /// CoreLocation coordinate
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// TimeZone object
    var timeZone: TimeZone? {
        TimeZone(identifier: timezone)
    }

    /// UTC offset string (e.g., "+05:30")
    var utcOffset: String {
        guard let tz = timeZone else { return "" }
        let seconds = tz.secondsFromGMT()
        let hours = seconds / 3600
        let minutes = abs(seconds % 3600) / 60
        return String(format: "%+03d:%02d", hours, minutes)
    }
}

// MARK: - Popular Cities

extension Location {
    /// Pre-configured popular locations for quick selection
    static let popularLocations: [Location] = [
        .chennai,
        .coimbatore,
        .madurai,
        .trichy,
        .bangalore,
        .mumbai,
        .newDelhi,
        .newYork,
        .london,
        .singapore,
        .dubai,
        .toronto,
        .sydney
    ]

    // MARK: - India

    static let chennai = Location(
        city: "Chennai",
        state: "Tamil Nadu",
        country: "India",
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: "Asia/Kolkata"
    )

    static let coimbatore = Location(
        city: "Coimbatore",
        state: "Tamil Nadu",
        country: "India",
        latitude: 11.0168,
        longitude: 76.9558,
        timezone: "Asia/Kolkata"
    )

    static let madurai = Location(
        city: "Madurai",
        state: "Tamil Nadu",
        country: "India",
        latitude: 9.9252,
        longitude: 78.1198,
        timezone: "Asia/Kolkata"
    )

    static let trichy = Location(
        name: "Trichy",
        city: "Tiruchirappalli",
        state: "Tamil Nadu",
        country: "India",
        latitude: 10.7905,
        longitude: 78.7047,
        timezone: "Asia/Kolkata"
    )

    static let bangalore = Location(
        city: "Bangalore",
        state: "Karnataka",
        country: "India",
        latitude: 12.9716,
        longitude: 77.5946,
        timezone: "Asia/Kolkata"
    )

    static let mumbai = Location(
        city: "Mumbai",
        state: "Maharashtra",
        country: "India",
        latitude: 19.0760,
        longitude: 72.8777,
        timezone: "Asia/Kolkata"
    )

    static let newDelhi = Location(
        city: "New Delhi",
        state: "Delhi",
        country: "India",
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: "Asia/Kolkata"
    )

    // MARK: - International

    static let newYork = Location(
        city: "New York",
        state: "NY",
        country: "USA",
        latitude: 40.7128,
        longitude: -74.0060,
        timezone: "America/New_York"
    )

    static let london = Location(
        city: "London",
        country: "United Kingdom",
        latitude: 51.5074,
        longitude: -0.1278,
        timezone: "Europe/London"
    )

    static let singapore = Location(
        city: "Singapore",
        country: "Singapore",
        latitude: 1.3521,
        longitude: 103.8198,
        timezone: "Asia/Singapore"
    )

    static let dubai = Location(
        city: "Dubai",
        country: "UAE",
        latitude: 25.2048,
        longitude: 55.2708,
        timezone: "Asia/Dubai"
    )

    static let toronto = Location(
        city: "Toronto",
        state: "Ontario",
        country: "Canada",
        latitude: 43.6532,
        longitude: -79.3832,
        timezone: "America/Toronto"
    )

    static let sydney = Location(
        city: "Sydney",
        state: "NSW",
        country: "Australia",
        latitude: -33.8688,
        longitude: 151.2093,
        timezone: "Australia/Sydney"
    )

    // MARK: - Sample

    static let sample = chennai
}
