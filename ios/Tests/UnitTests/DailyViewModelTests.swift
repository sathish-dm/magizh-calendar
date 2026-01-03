import XCTest
@testable import magizh_calendar_ios

/// Unit tests for DailyViewModel
@MainActor
final class DailyViewModelTests: XCTestCase {

    // MARK: - Properties

    private var sut: DailyViewModel!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = DailyViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        XCTAssertFalse(sut.hasError)
        XCTAssertNil(sut.errorMessage)
    }

    func testInitialLocation() {
        // Should load from settings
        XCTAssertNotNil(sut.currentLocation)
    }

    // MARK: - Date Navigation Tests

    func testSelectedDayNumber() {
        let dayNumber = sut.selectedDayNumber
        let calendar = Calendar.current
        let expectedDay = calendar.component(.day, from: sut.selectedDate)

        XCTAssertEqual(dayNumber, expectedDay)
    }

    func testSelectedDateFormatted() {
        let formatted = sut.selectedDateFormatted
        XCTAssertFalse(formatted.isEmpty)
        // Should contain day name and month
        XCTAssertTrue(formatted.contains(","))
    }

    func testGoToNextDay() {
        let originalDate = sut.selectedDate
        sut.goToNextDay()

        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: originalDate, to: sut.selectedDate).day

        XCTAssertEqual(daysDifference, 1)
    }

    func testGoToPreviousDay() {
        let originalDate = sut.selectedDate
        sut.goToPreviousDay()

        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: sut.selectedDate, to: originalDate).day

        XCTAssertEqual(daysDifference, 1)
    }

    func testGoToToday() {
        // First go to a different day
        sut.goToNextDay()
        sut.goToNextDay()

        // Then go to today
        sut.goToToday()

        XCTAssertTrue(sut.isToday)
    }

    func testGoToSpecificDate() {
        let calendar = Calendar.current
        let targetDate = calendar.date(byAdding: .day, value: 10, to: Date())!

        sut.goToDate(targetDate)

        XCTAssertEqual(
            calendar.startOfDay(for: sut.selectedDate),
            calendar.startOfDay(for: targetDate)
        )
    }

    func testIsToday() {
        sut.goToToday()
        XCTAssertTrue(sut.isToday)

        sut.goToNextDay()
        XCTAssertFalse(sut.isToday)
    }

    // MARK: - Location Tests

    func testUpdateLocation() {
        let newLocation = Location.bangalore
        sut.updateLocation(newLocation)

        XCTAssertEqual(sut.currentLocation.city, "Bangalore")
    }

    // MARK: - Data State Tests

    func testHasData() {
        // Initially may or may not have data depending on loading
        // After loading mock data, should have data
        sut.loadPanchangamData()

        // Give it time to load
        let expectation = XCTestExpectation(description: "Data loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        // Should have data (either from API or mock fallback)
        XCTAssertTrue(sut.hasData || sut.isLoading)
    }

    func testClearError() {
        sut.clearError()
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.hasError)
    }

    // MARK: - Preview Helper Tests

    func testPreviewHelper() {
        let preview = DailyViewModel.preview

        XCTAssertNotNil(preview.panchangamData)
        XCTAssertFalse(preview.isLoading)
    }

    func testPreviewLoadingHelper() {
        let preview = DailyViewModel.previewLoading

        XCTAssertTrue(preview.isLoading)
    }

    func testPreviewErrorHelper() {
        let preview = DailyViewModel.previewError

        XCTAssertNotNil(preview.errorMessage)
        XCTAssertTrue(preview.hasError)
        XCTAssertFalse(preview.isLoading)
    }

    // MARK: - Yogam Status Tests

    func testYogamStatusTextWhenNoData() {
        // Create fresh view model
        let vm = DailyViewModel()

        // If panchangam data is nil, yogamStatusText should be nil
        if vm.panchangamData == nil {
            XCTAssertNil(vm.yogamStatusText)
        }
    }

    // MARK: - Retry Tests

    func testRetry() {
        // Should not crash and should trigger data reload
        sut.retry()

        // Verify loading state is updated
        XCTAssertTrue(sut.isLoading || sut.hasData)
    }
}
