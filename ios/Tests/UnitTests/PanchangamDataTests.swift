import XCTest
@testable import magizh_calendar_ios

/// Unit tests for PanchangamData and related models
final class PanchangamDataTests: XCTestCase {

    // MARK: - Properties

    private var calendar: Calendar!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
    }

    // MARK: - Sample Data Tests

    func testSamplePanchangamData() {
        let sample = PanchangamData.sample

        XCTAssertNotNil(sample.date)
        XCTAssertNotNil(sample.tamilDate)
        XCTAssertNotNil(sample.location)
        XCTAssertNotNil(sample.nakshatram)
        XCTAssertNotNil(sample.thithi)
        XCTAssertNotNil(sample.yogam)
        XCTAssertNotNil(sample.karanam)
        XCTAssertNotNil(sample.sunrise)
        XCTAssertNotNil(sample.sunset)
        XCTAssertNotNil(sample.rahukaalam)
        XCTAssertNotNil(sample.yamagandam)
        XCTAssertNotNil(sample.foodStatus)
    }

    // MARK: - Nakshatram Tests

    func testNakshatramNames() {
        // Verify all 27 nakshatrams are available
        XCTAssertEqual(NakshatramName.allCases.count, 27)
    }

    func testNakshatramTamilNames() {
        for nakshatram in NakshatramName.allCases {
            XCTAssertFalse(nakshatram.tamilName.isEmpty, "\(nakshatram) should have Tamil name")
        }
    }

    func testNakshatramDefaultLords() {
        for nakshatram in NakshatramName.allCases {
            XCTAssertFalse(nakshatram.defaultLord.isEmpty, "\(nakshatram) should have a default lord")
        }
    }

    func testNakshatramInitialization() {
        let endTime = Date().addingTimeInterval(3600 * 5) // 5 hours from now
        let nakshatram = Nakshatram(name: .ashwini, endTime: endTime)

        XCTAssertEqual(nakshatram.name, .ashwini)
        XCTAssertEqual(nakshatram.endTime, endTime)
    }

    // MARK: - Thithi Tests

    func testThithiNames() {
        // 14 numbered thithis + pournami + amavasai = 16 total
        XCTAssertEqual(ThithiName.allCases.count, 16)
    }

    func testThithiPaksha() {
        XCTAssertEqual(Paksha.allCases.count, 2)
        XCTAssertEqual(Paksha.shukla.rawValue, "Shukla")
        XCTAssertEqual(Paksha.krishna.rawValue, "Krishna")
    }

    func testThithiTamilNames() {
        for thithi in ThithiName.allCases {
            XCTAssertFalse(thithi.tamilName.isEmpty, "\(thithi) should have Tamil name")
        }
    }

    func testThithiInitialization() {
        let endTime = Date().addingTimeInterval(3600 * 8)
        let thithi = Thithi(name: .panchami, paksha: .shukla, endTime: endTime)

        XCTAssertEqual(thithi.name, .panchami)
        XCTAssertEqual(thithi.paksha, .shukla)
        XCTAssertEqual(thithi.endTime, endTime)
    }

    // MARK: - Yogam Tests

    func testYogamNames() {
        // 27 yogams
        XCTAssertEqual(YogamName.allCases.count, 27)
    }

    func testYogamTypes() {
        // Test that all three types exist and have proper labels
        XCTAssertEqual(YogamType.auspicious.label, "AUSPICIOUS")
        XCTAssertEqual(YogamType.inauspicious.label, "AVOID")
        XCTAssertEqual(YogamType.neutral.label, "NEUTRAL")
    }

    func testYogamTypeColors() {
        // Test that all types have colors
        XCTAssertNotNil(YogamType.auspicious.color)
        XCTAssertNotNil(YogamType.inauspicious.color)
        XCTAssertNotNil(YogamType.neutral.color)
    }

    func testYogamIsActive() {
        let now = Date()
        let start = now.addingTimeInterval(-3600) // 1 hour ago
        let end = now.addingTimeInterval(3600) // 1 hour from now

        let activeYogam = Yogam(name: .siddhi, startTime: start, endTime: end)
        XCTAssertTrue(activeYogam.isActive())

        let pastEnd = now.addingTimeInterval(-1800) // 30 min ago
        let inactiveYogam = Yogam(name: .siddhi, startTime: start, endTime: pastEnd)
        XCTAssertFalse(inactiveYogam.isActive())
    }

    // MARK: - Karanam Tests

    func testKaranamNames() {
        // 11 karanams
        XCTAssertEqual(KaranamName.allCases.count, 11)
    }

    func testKaranamTamilNames() {
        for karanam in KaranamName.allCases {
            XCTAssertFalse(karanam.tamilName.isEmpty, "\(karanam) should have Tamil name")
        }
    }

    func testKaranamInitialization() {
        let endTime = Date().addingTimeInterval(3600 * 3)
        let karanam = Karanam(name: .bava, endTime: endTime)

        XCTAssertEqual(karanam.name, .bava)
        XCTAssertEqual(karanam.endTime, endTime)
    }

    // MARK: - Tamil Date Tests

    func testTamilMonths() {
        // 12 Tamil months
        XCTAssertEqual(TamilMonth.allCases.count, 12)
    }

    func testTamilMonthTamilNames() {
        for month in TamilMonth.allCases {
            XCTAssertFalse(month.tamilName.isEmpty, "\(month) should have Tamil name")
        }
    }

    func testVaaram() {
        // 7 days of the week
        XCTAssertEqual(Vaaram.allCases.count, 7)
    }

    func testVaaramTamilNames() {
        for day in Vaaram.allCases {
            XCTAssertFalse(day.tamilName.isEmpty, "\(day) should have Tamil name")
        }
    }

    func testTamilDateShortFormatted() {
        let tamilDate = TamilDate(
            day: 15,
            month: .thai,
            year: TamilYear(name: "Krodhana", cycleNumber: 38),
            weekday: .nyayiru
        )

        let formatted = tamilDate.shortFormatted
        XCTAssertTrue(formatted.contains("15"))
        XCTAssertTrue(formatted.contains("Thai") || formatted.contains("தை"))
    }

    // MARK: - Vaaram Tests

    func testVaaramDeities() {
        // Each day has an associated deity/planet
        XCTAssertTrue(Vaaram.nyayiru.deity.contains("Sun"))
        XCTAssertTrue(Vaaram.thingal.deity.contains("Moon"))
        XCTAssertTrue(Vaaram.chevvai.deity.contains("Mars"))
        XCTAssertTrue(Vaaram.budhan.deity.contains("Mercury"))
        XCTAssertTrue(Vaaram.viyazhan.deity.contains("Jupiter"))
        XCTAssertTrue(Vaaram.velli.deity.contains("Venus"))
        XCTAssertTrue(Vaaram.sani.deity.contains("Saturn"))
    }

    func testVaaramEnglishNames() {
        XCTAssertEqual(Vaaram.nyayiru.englishName, "Sunday")
        XCTAssertEqual(Vaaram.thingal.englishName, "Monday")
        XCTAssertEqual(Vaaram.chevvai.englishName, "Tuesday")
        XCTAssertEqual(Vaaram.budhan.englishName, "Wednesday")
        XCTAssertEqual(Vaaram.viyazhan.englishName, "Thursday")
        XCTAssertEqual(Vaaram.velli.englishName, "Friday")
        XCTAssertEqual(Vaaram.sani.englishName, "Saturday")
    }

    // MARK: - Formatted Properties Tests

    func testSunriseFormatted() {
        let sample = PanchangamData.sample
        XCTAssertFalse(sample.sunriseFormatted.isEmpty)
    }

    func testSunsetFormatted() {
        let sample = PanchangamData.sample
        XCTAssertFalse(sample.sunsetFormatted.isEmpty)
    }

    func testDayLengthFormatted() {
        let sample = PanchangamData.sample
        let dayLength = sample.dayLengthFormatted
        XCTAssertTrue(dayLength.contains("h") || dayLength.contains(":"))
    }

    // MARK: - Codable Tests

    func testNakshatramEncodingDecoding() throws {
        let original = Nakshatram(name: .rohini, endTime: Date())

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Nakshatram.self, from: data)

        XCTAssertEqual(decoded.name, original.name)
    }

    func testThithiEncodingDecoding() throws {
        let original = Thithi(name: .ekadasi, paksha: .shukla, endTime: Date())

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Thithi.self, from: data)

        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.paksha, original.paksha)
    }

    func testYogamEncodingDecoding() throws {
        let now = Date()
        let original = Yogam(
            name: .siddhi,
            startTime: now,
            endTime: now.addingTimeInterval(3600)
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Yogam.self, from: data)

        XCTAssertEqual(decoded.name, original.name)
    }
}
