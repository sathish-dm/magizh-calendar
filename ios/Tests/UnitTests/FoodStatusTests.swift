import XCTest
@testable import magizh_calendar_ios

/// Unit tests for FoodStatus and related types
final class FoodStatusTests: XCTestCase {

    // MARK: - FoodStatus Initialization Tests

    func testFoodStatusInitialization() {
        let status = FoodStatus(type: .regular)

        XCTAssertEqual(status.type, .regular)
        XCTAssertNotNil(status.id)
    }

    func testFoodStatusWithReason() {
        let status = FoodStatus(type: .avoidNonVeg, reason: "Pradosham tomorrow")

        XCTAssertEqual(status.type, .avoidNonVeg)
        XCTAssertEqual(status.reason, "Pradosham tomorrow")
    }

    func testFoodStatusDefaultReason() {
        let status = FoodStatus(type: .strictFast)

        XCTAssertEqual(status.reason, "Ekadasi or major fasting day")
    }

    // MARK: - FoodStatusType Tests

    func testRegularStatusColor() {
        let color = FoodStatusType.regular.color
        XCTAssertNotNil(color)
    }

    func testAvoidNonVegStatusColor() {
        let color = FoodStatusType.avoidNonVeg.color
        XCTAssertNotNil(color)
    }

    func testStrictFastStatusColor() {
        let color = FoodStatusType.strictFast.color
        XCTAssertNotNil(color)
    }

    func testMultipleObservancesStatusColor() {
        let color = FoodStatusType.multipleObservances.color
        XCTAssertNotNil(color)
    }

    // MARK: - Short Message Tests

    func testRegularShortMessage() {
        let status = FoodStatus(type: .regular)
        XCTAssertEqual(status.shortMessage, "Regular Day")
    }

    func testAvoidNonVegShortMessage() {
        let status = FoodStatus(type: .avoidNonVeg)
        XCTAssertEqual(status.shortMessage, "Avoid Non-Veg")
    }

    func testStrictFastShortMessage() {
        let status = FoodStatus(type: .strictFast)
        XCTAssertEqual(status.shortMessage, "Fasting Day")
    }

    func testMultipleObservancesShortMessage() {
        let status = FoodStatus(type: .multipleObservances)
        XCTAssertEqual(status.shortMessage, "Special Day")
    }

    // MARK: - Icon Tests

    func testAllStatusTypesHaveIcons() {
        let types: [FoodStatusType] = [.regular, .avoidNonVeg, .strictFast, .multipleObservances]

        for type in types {
            XCTAssertFalse(type.iconName.isEmpty, "\(type) should have an icon")
        }
    }

    func testRegularIcon() {
        XCTAssertEqual(FoodStatusType.regular.iconName, "checkmark.circle.fill")
    }

    func testAvoidNonVegIcon() {
        XCTAssertEqual(FoodStatusType.avoidNonVeg.iconName, "leaf.fill")
    }

    func testStrictFastIcon() {
        XCTAssertEqual(FoodStatusType.strictFast.iconName, "moon.stars.fill")
    }

    // MARK: - Gradient Colors Tests

    func testAllTypesHaveGradientColors() {
        let types: [FoodStatusType] = [.regular, .avoidNonVeg, .strictFast, .multipleObservances]

        for type in types {
            XCTAssertEqual(type.gradientColors.count, 2, "\(type) should have 2 gradient colors")
        }
    }

    // MARK: - AuspiciousDay Tests

    func testAuspiciousDayInitialization() {
        let date = Date()
        let day = AuspiciousDay(
            name: "Ekadasi",
            type: .ekadasi,
            date: date,
            description: "Shukla Ekadasi"
        )

        XCTAssertEqual(day.name, "Ekadasi")
        XCTAssertEqual(day.type, .ekadasi)
        XCTAssertEqual(day.date, date)
        XCTAssertEqual(day.description, "Shukla Ekadasi")
    }

    func testAuspiciousDayDaysUntilToday() {
        let today = Date()
        let day = AuspiciousDay(name: "Test", type: .festival, date: today)

        XCTAssertEqual(day.daysUntil, 0)
        XCTAssertEqual(day.daysUntilFormatted, "Today")
    }

    func testAuspiciousDayDaysUntilTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let day = AuspiciousDay(name: "Test", type: .festival, date: tomorrow)

        XCTAssertEqual(day.daysUntil, 1)
        XCTAssertEqual(day.daysUntilFormatted, "Tomorrow")
    }

    func testAuspiciousDayDaysUntilMultiple() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let day = AuspiciousDay(name: "Test", type: .festival, date: futureDate)

        XCTAssertEqual(day.daysUntil, 5)
        XCTAssertEqual(day.daysUntilFormatted, "In 5 days")
    }

    // MARK: - AuspiciousDayType Food Restriction Tests

    func testEkadasiIsStrictFast() {
        XCTAssertEqual(AuspiciousDayType.ekadasi.foodRestriction, .strictFast)
    }

    func testNavaratriIsStrictFast() {
        XCTAssertEqual(AuspiciousDayType.navaratri.foodRestriction, .strictFast)
    }

    func testPradoshamIsAvoidNonVeg() {
        XCTAssertEqual(AuspiciousDayType.pradosham.foodRestriction, .avoidNonVeg)
    }

    func testAmavasaiIsAvoidNonVeg() {
        XCTAssertEqual(AuspiciousDayType.amavasai.foodRestriction, .avoidNonVeg)
    }

    func testPournamiIsAvoidNonVeg() {
        XCTAssertEqual(AuspiciousDayType.pournami.foodRestriction, .avoidNonVeg)
    }

    func testFestivalIsRegular() {
        XCTAssertEqual(AuspiciousDayType.festival.foodRestriction, .regular)
    }

    // MARK: - AuspiciousDayType Observance Description Tests

    func testAllTypesHaveDescriptions() {
        for type in AuspiciousDayType.allCases {
            XCTAssertFalse(
                type.observanceDescription.isEmpty,
                "\(type) should have an observance description"
            )
        }
    }

    // MARK: - Codable Tests

    func testFoodStatusEncodingDecoding() throws {
        let original = FoodStatus(type: .avoidNonVeg, reason: "Pradosham")

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(FoodStatus.self, from: data)

        XCTAssertEqual(decoded.type, original.type)
        XCTAssertEqual(decoded.reason, original.reason)
    }

    func testAuspiciousDayEncodingDecoding() throws {
        let original = AuspiciousDay(
            name: "Ekadasi",
            type: .ekadasi,
            date: Date(),
            description: "Test"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AuspiciousDay.self, from: data)

        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.type, original.type)
    }

    // MARK: - Sample Data Tests

    func testSampleRegular() {
        let sample = FoodStatus.sampleRegular
        XCTAssertEqual(sample.type, .regular)
    }

    func testSampleAvoidNonVeg() {
        let sample = FoodStatus.sampleAvoidNonVeg
        XCTAssertEqual(sample.type, .avoidNonVeg)
    }

    func testSampleFasting() {
        let sample = FoodStatus.sampleFasting
        XCTAssertEqual(sample.type, .strictFast)
    }
}
