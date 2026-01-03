import XCTest
@testable import magizh_calendar_ios

/// Unit tests for SettingsService
final class SettingsServiceTests: XCTestCase {

    // MARK: - Properties

    private var sut: SettingsService!
    private let testDefaults = UserDefaults(suiteName: "TestDefaults")!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // Clear test defaults before each test
        testDefaults.removePersistentDomain(forName: "TestDefaults")
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: "TestDefaults")
        super.tearDown()
    }

    // MARK: - Singleton Tests

    func testSharedInstance() {
        let instance1 = SettingsService.shared
        let instance2 = SettingsService.shared

        XCTAssertTrue(instance1 === instance2, "Should return the same instance")
    }

    // MARK: - Default Values Tests

    func testDefaultTimeFormat() {
        let settings = SettingsService.shared
        // Default should be 12-hour format
        XCTAssertEqual(settings.timeFormat, .twelveHour)
    }

    func testDefaultDateFormat() {
        let settings = SettingsService.shared
        XCTAssertEqual(settings.dateFormat, .full)
    }

    func testDefaultTheme() {
        let settings = SettingsService.shared
        XCTAssertEqual(settings.theme, .system)
    }

    // MARK: - Time Format Tests

    func testTimeFormatDisplayNames() {
        XCTAssertEqual(TimeFormat.twelveHour.displayName, "12-hour (3:30 PM)")
        XCTAssertEqual(TimeFormat.twentyFourHour.displayName, "24-hour (15:30)")
    }

    func testTimeFormatDateFormatStrings() {
        XCTAssertEqual(TimeFormat.twelveHour.dateFormatString, "h:mm a")
        XCTAssertEqual(TimeFormat.twentyFourHour.dateFormatString, "HH:mm")
    }

    // MARK: - Date Format Tests

    func testDateFormatDisplayNames() {
        XCTAssertFalse(DateFormat.short.displayName.isEmpty)
        XCTAssertFalse(DateFormat.medium.displayName.isEmpty)
        XCTAssertFalse(DateFormat.full.displayName.isEmpty)
    }

    // MARK: - Theme Tests

    func testAppThemeDisplayNames() {
        XCTAssertEqual(AppTheme.system.displayName, "System")
        XCTAssertEqual(AppTheme.light.displayName, "Light")
        XCTAssertEqual(AppTheme.dark.displayName, "Dark")
    }

    // MARK: - Vegetarian Preference Tests

    func testVegetarianPreferenceDefault() {
        let settings = SettingsService.shared
        // After reset, isVegetarian should be false
        settings.resetToDefaults()
        XCTAssertFalse(settings.isVegetarian)
    }

    func testVegetarianPreferenceToggle() {
        let settings = SettingsService.shared
        let original = settings.isVegetarian

        settings.isVegetarian = !original
        XCTAssertNotEqual(settings.isVegetarian, original)

        // Reset back
        settings.isVegetarian = original
    }

    // MARK: - Location Tests

    func testDefaultLocation() {
        let settings = SettingsService.shared
        settings.resetToDefaults()

        XCTAssertEqual(settings.defaultLocation.city, "Chennai")
    }

    // MARK: - Favorite Locations Tests

    func testAddFavorite() {
        let settings = SettingsService.shared
        settings.resetToDefaults()

        let location = Location.bangalore
        settings.addFavorite(location)

        XCTAssertTrue(settings.favoriteLocations.contains(where: { $0.city == "Bangalore" }))

        // Cleanup
        settings.removeFavorite(location)
    }

    func testRemoveFavorite() {
        let settings = SettingsService.shared
        settings.resetToDefaults()

        let location = Location.mumbai
        settings.addFavorite(location)
        settings.removeFavorite(location)

        XCTAssertFalse(settings.favoriteLocations.contains(where: { $0.city == "Mumbai" }))
    }

    func testIsFavorite() {
        let settings = SettingsService.shared
        settings.resetToDefaults()

        let location = Location.coimbatore
        XCTAssertFalse(settings.isFavorite(location))

        settings.addFavorite(location)
        XCTAssertTrue(settings.isFavorite(location))

        // Cleanup
        settings.removeFavorite(location)
    }

    func testToggleFavorite() {
        let settings = SettingsService.shared
        settings.resetToDefaults()

        let location = Location.madurai
        XCTAssertFalse(settings.isFavorite(location))

        settings.toggleFavorite(location)
        XCTAssertTrue(settings.isFavorite(location))

        settings.toggleFavorite(location)
        XCTAssertFalse(settings.isFavorite(location))
    }

    func testAddFavoriteDuplicate() {
        let settings = SettingsService.shared
        settings.resetToDefaults()

        let location = Location.singapore
        settings.addFavorite(location)
        let countAfterFirst = settings.favoriteLocations.count

        settings.addFavorite(location) // Add again
        let countAfterSecond = settings.favoriteLocations.count

        XCTAssertEqual(countAfterFirst, countAfterSecond, "Should not add duplicate")

        // Cleanup
        settings.removeFavorite(location)
    }

    // MARK: - Formatting Helper Tests

    func testFormatTime12Hour() {
        let settings = SettingsService.shared
        settings.timeFormat = .twelveHour

        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: 14, minute: 30, second: 0, of: Date())!

        let formatted = settings.formatTime(date)
        XCTAssertTrue(formatted.contains("PM") || formatted.contains("pm"))
    }

    func testFormatTime24Hour() {
        let settings = SettingsService.shared
        settings.timeFormat = .twentyFourHour

        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: 14, minute: 30, second: 0, of: Date())!

        let formatted = settings.formatTime(date)
        XCTAssertTrue(formatted.contains("14:30"))
    }

    func testFormatTimeRange() {
        let settings = SettingsService.shared
        let calendar = Calendar.current
        let now = Date()

        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now)!

        let formatted = settings.formatTimeRange(start: start, end: end)
        XCTAssertTrue(formatted.contains(" - "))
    }

    // MARK: - Reset Tests

    func testResetToDefaults() {
        let settings = SettingsService.shared

        // Change some settings
        settings.timeFormat = .twentyFourHour
        settings.theme = .dark
        settings.isVegetarian = true
        settings.addFavorite(Location.newYork)

        // Reset
        settings.resetToDefaults()

        // Verify defaults
        XCTAssertEqual(settings.timeFormat, .twelveHour)
        XCTAssertEqual(settings.theme, .system)
        XCTAssertFalse(settings.isVegetarian)
        XCTAssertTrue(settings.favoriteLocations.isEmpty)
        XCTAssertEqual(settings.defaultLocation.city, "Chennai")
    }
}
