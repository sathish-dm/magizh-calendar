import XCTest
@testable import magizh_calendar_ios

/// Unit tests for Location model
final class LocationTests: XCTestCase {

    // MARK: - Initialization Tests

    func testLocationInitialization() {
        let location = Location(
            city: "Chennai",
            state: "Tamil Nadu",
            country: "India",
            latitude: 13.0827,
            longitude: 80.2707,
            timezone: "Asia/Kolkata"
        )

        XCTAssertEqual(location.city, "Chennai")
        XCTAssertEqual(location.state, "Tamil Nadu")
        XCTAssertEqual(location.country, "India")
        XCTAssertEqual(location.latitude, 13.0827, accuracy: 0.0001)
        XCTAssertEqual(location.longitude, 80.2707, accuracy: 0.0001)
        XCTAssertEqual(location.timezone, "Asia/Kolkata")
    }

    func testLocationWithCustomName() {
        let location = Location(
            name: "Trichy",
            city: "Tiruchirappalli",
            state: "Tamil Nadu",
            country: "India",
            latitude: 10.7905,
            longitude: 78.7047,
            timezone: "Asia/Kolkata"
        )

        XCTAssertEqual(location.name, "Trichy")
        XCTAssertEqual(location.city, "Tiruchirappalli")
    }

    func testLocationNameDefaultsToCity() {
        let location = Location(
            city: "Chennai",
            country: "India",
            latitude: 13.0827,
            longitude: 80.2707,
            timezone: "Asia/Kolkata"
        )

        XCTAssertEqual(location.name, "Chennai")
    }

    // MARK: - Display Name Tests

    func testFullDisplayNameWithState() {
        let location = Location.chennai

        XCTAssertEqual(location.fullDisplayName, "Chennai, Tamil Nadu, India")
    }

    func testFullDisplayNameWithoutState() {
        let location = Location.london

        XCTAssertEqual(location.fullDisplayName, "London, United Kingdom")
    }

    func testShortDisplayNameWithState() {
        let location = Location.chennai

        XCTAssertEqual(location.shortDisplayName, "Chennai, TA")
    }

    func testShortDisplayNameWithoutState() {
        let location = Location.singapore

        XCTAssertEqual(location.shortDisplayName, "Singapore")
    }

    // MARK: - Coordinate Tests

    func testCoordinate() {
        let location = Location.chennai

        XCTAssertEqual(location.coordinate.latitude, 13.0827, accuracy: 0.0001)
        XCTAssertEqual(location.coordinate.longitude, 80.2707, accuracy: 0.0001)
    }

    // MARK: - Timezone Tests

    func testTimeZone() {
        let location = Location.chennai

        XCTAssertNotNil(location.timeZone)
        XCTAssertEqual(location.timeZone?.identifier, "Asia/Kolkata")
    }

    func testUTCOffset() {
        let chennai = Location.chennai
        // Chennai is UTC+5:30
        XCTAssertEqual(chennai.utcOffset, "+05:30")
    }

    func testUTCOffsetNegative() {
        let newYork = Location.newYork
        // New York is UTC-5 or UTC-4 (DST)
        let offset = newYork.utcOffset
        XCTAssertTrue(offset.starts(with: "-"), "New York should have negative UTC offset")
    }

    // MARK: - Equatable Tests

    func testLocationEquality() {
        let location1 = Location(
            id: UUID(),
            city: "Chennai",
            country: "India",
            latitude: 13.0827,
            longitude: 80.2707,
            timezone: "Asia/Kolkata"
        )

        let location2 = Location(
            id: location1.id,
            city: "Chennai",
            country: "India",
            latitude: 13.0827,
            longitude: 80.2707,
            timezone: "Asia/Kolkata"
        )

        XCTAssertEqual(location1, location2)
    }

    // MARK: - Codable Tests

    func testLocationEncodingDecoding() throws {
        let original = Location.chennai

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Location.self, from: data)

        XCTAssertEqual(decoded.city, original.city)
        XCTAssertEqual(decoded.latitude, original.latitude, accuracy: 0.0001)
        XCTAssertEqual(decoded.longitude, original.longitude, accuracy: 0.0001)
        XCTAssertEqual(decoded.timezone, original.timezone)
    }

    // MARK: - Popular Locations Tests

    func testPopularLocationsCount() {
        XCTAssertEqual(Location.popularLocations.count, 13)
    }

    func testPopularLocationsContainsChennai() {
        XCTAssertTrue(Location.popularLocations.contains(where: { $0.city == "Chennai" }))
    }

    func testAllPopularLocationsHaveValidTimezones() {
        for location in Location.popularLocations {
            XCTAssertNotNil(
                TimeZone(identifier: location.timezone),
                "Invalid timezone for \(location.city): \(location.timezone)"
            )
        }
    }

    func testAllPopularLocationsHaveValidCoordinates() {
        for location in Location.popularLocations {
            XCTAssertTrue(
                location.latitude >= -90 && location.latitude <= 90,
                "Invalid latitude for \(location.city): \(location.latitude)"
            )
            XCTAssertTrue(
                location.longitude >= -180 && location.longitude <= 180,
                "Invalid longitude for \(location.city): \(location.longitude)"
            )
        }
    }
}
