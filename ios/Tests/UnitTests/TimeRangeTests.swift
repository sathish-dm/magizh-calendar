import XCTest
@testable import magizh_calendar_ios

/// Unit tests for TimeRange model
final class TimeRangeTests: XCTestCase {

    // MARK: - Properties

    private var calendar: Calendar!
    private var baseDate: Date!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
        baseDate = Date()
    }

    // MARK: - Initialization Tests

    func testTimeRangeInitialization() {
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!

        let timeRange = TimeRange(startTime: start, endTime: end, type: .nallaNeram)

        XCTAssertEqual(timeRange.startTime, start)
        XCTAssertEqual(timeRange.endTime, end)
        XCTAssertEqual(timeRange.type, .nallaNeram)
    }

    func testTimeRangeWithoutType() {
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: baseDate)!

        let timeRange = TimeRange(startTime: start, endTime: end)

        XCTAssertNil(timeRange.type)
    }

    // MARK: - Duration Tests

    func testDuration() {
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!

        let timeRange = TimeRange(startTime: start, endTime: end)

        XCTAssertEqual(timeRange.duration, 5400, accuracy: 1) // 90 minutes in seconds
    }

    func testDurationMinutes() {
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!

        let timeRange = TimeRange(startTime: start, endTime: end)

        XCTAssertEqual(timeRange.durationMinutes, 90)
    }

    func testDurationFormattedHoursAndMinutes() {
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!

        let timeRange = TimeRange(startTime: start, endTime: end)

        XCTAssertEqual(timeRange.durationFormatted, "1h 30m")
    }

    func testDurationFormattedMinutesOnly() {
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 9, minute: 45, second: 0, of: baseDate)!

        let timeRange = TimeRange(startTime: start, endTime: end)

        XCTAssertEqual(timeRange.durationFormatted, "45m")
    }

    // MARK: - Contains Tests

    func testContainsTimeInRange() {
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!
        let middle = calendar.date(bySettingHour: 9, minute: 45, second: 0, of: baseDate)!

        let timeRange = TimeRange(startTime: start, endTime: end)

        XCTAssertTrue(timeRange.contains(middle))
    }

    func testContainsStartTime() {
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!

        let timeRange = TimeRange(startTime: start, endTime: end)

        XCTAssertTrue(timeRange.contains(start))
    }

    func testContainsEndTime() {
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!

        let timeRange = TimeRange(startTime: start, endTime: end)

        XCTAssertTrue(timeRange.contains(end))
    }

    func testDoesNotContainTimeOutOfRange() {
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!
        let outside = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: baseDate)!

        let timeRange = TimeRange(startTime: start, endTime: end)

        XCTAssertFalse(timeRange.contains(outside))
    }

    func testDoesNotContainTimeBefore() {
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!
        let before = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: baseDate)!

        let timeRange = TimeRange(startTime: start, endTime: end)

        XCTAssertFalse(timeRange.contains(before))
    }

    // MARK: - Time Range Type Tests

    func testNallaNeramIsAuspicious() {
        XCTAssertTrue(TimeRangeType.nallaNeram.isAuspicious)
    }

    func testAbhijitMuhurtamIsAuspicious() {
        XCTAssertTrue(TimeRangeType.abhijitMuhurtam.isAuspicious)
    }

    func testBrahmaMuhurtamIsAuspicious() {
        XCTAssertTrue(TimeRangeType.brahmaMuhurtam.isAuspicious)
    }

    func testRahukaalamIsNotAuspicious() {
        XCTAssertFalse(TimeRangeType.rahukaalam.isAuspicious)
    }

    func testYamagandamIsNotAuspicious() {
        XCTAssertFalse(TimeRangeType.yamagandam.isAuspicious)
    }

    func testKuligaiIsNotAuspicious() {
        XCTAssertFalse(TimeRangeType.kuligai.isAuspicious)
    }

    // MARK: - Tamil Name Tests

    func testRahukaalamTamilName() {
        XCTAssertEqual(TimeRangeType.rahukaalam.tamilName, "Raagu Kaalam")
    }

    func testYamagandamTamilName() {
        XCTAssertEqual(TimeRangeType.yamagandam.tamilName, "Ema Gandam")
    }

    func testNallaNeramTamilName() {
        XCTAssertEqual(TimeRangeType.nallaNeram.tamilName, "Nalla Neram")
    }

    // MARK: - Icon Tests

    func testAllTypesHaveIcons() {
        let types: [TimeRangeType] = [
            .nallaNeram, .rahukaalam, .yamagandam,
            .kuligai, .abhijitMuhurtam, .brahmaMuhurtam
        ]

        for type in types {
            XCTAssertFalse(type.iconName.isEmpty, "\(type) should have an icon")
        }
    }

    // MARK: - Codable Tests

    func testTimeRangeEncodingDecoding() throws {
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!
        let original = TimeRange(startTime: start, endTime: end, type: .rahukaalam)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TimeRange.self, from: data)

        XCTAssertEqual(decoded.startTime, original.startTime)
        XCTAssertEqual(decoded.endTime, original.endTime)
        XCTAssertEqual(decoded.type, original.type)
    }

    // MARK: - Equatable Tests

    func testTimeRangeEquality() {
        let id = UUID()
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!

        let range1 = TimeRange(id: id, startTime: start, endTime: end, type: .nallaNeram)
        let range2 = TimeRange(id: id, startTime: start, endTime: end, type: .nallaNeram)

        XCTAssertEqual(range1, range2)
    }
}
