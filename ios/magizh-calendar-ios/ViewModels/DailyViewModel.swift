import Foundation
import Combine

/// Manages state and business logic for the daily panchangam view
/// Follows MVVM pattern with @MainActor for thread-safe UI updates
@MainActor
class DailyViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Current panchangam data for the selected date
    @Published private(set) var panchangamData: PanchangamData?

    /// Loading state for async operations
    @Published private(set) var isLoading = false

    /// Error message for display (nil if no error)
    @Published private(set) var errorMessage: String?

    /// Currently selected date
    @Published var selectedDate: Date = Date()

    /// Current user location
    @Published var currentLocation: Location = .chennai

    /// Whether using fallback mock data (API unavailable)
    @Published private(set) var isUsingMockData = false

    /// API service for network calls
    private let apiService = PanchangamAPIService.shared

    // MARK: - Computed Properties

    /// Whether data is successfully loaded
    var hasData: Bool {
        panchangamData != nil
    }

    /// Whether an error occurred
    var hasError: Bool {
        errorMessage != nil
    }

    /// Formatted selected date for display
    var selectedDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: selectedDate)
    }

    /// Day number of selected date
    var selectedDayNumber: Int {
        Calendar.current.component(.day, from: selectedDate)
    }

    /// Whether the selected date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    /// Current active yogam status text
    var yogamStatusText: String? {
        guard let yogam = panchangamData?.yogam else { return nil }

        if yogam.isActive() {
            let remaining = yogam.endTime.timeIntervalSince(Date())
            let hours = Int(remaining / 3600)
            let minutes = Int((remaining.truncatingRemainder(dividingBy: 3600)) / 60)

            if hours > 0 {
                return "\(hours)h \(minutes)m remaining"
            } else if minutes > 0 {
                return "\(minutes) minutes remaining"
            } else {
                return "Ending soon"
            }
        }
        return nil
    }

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        // Load data when date or location changes
        setupBindings()

        // Load initial data
        loadPanchangamData()
    }

    // MARK: - Public Methods

    /// Load panchangam data for the current selected date and location
    func loadPanchangamData() {
        isLoading = true
        errorMessage = nil
        isUsingMockData = false

        Task {
            do {
                // Try to fetch from API
                let data = try await apiService.fetchDailyPanchangamModel(
                    date: selectedDate,
                    location: currentLocation
                )

                self.panchangamData = data
                self.isLoading = false
                self.isUsingMockData = false
            } catch let error as APIError {
                // API failed, fall back to mock data
                print("API Error: \(error.localizedDescription)")
                await loadMockDataFallback()
            } catch {
                // Other errors, try mock data
                print("Error: \(error.localizedDescription)")
                await loadMockDataFallback()
            }
        }
    }

    /// Load mock data as fallback when API is unavailable
    private func loadMockDataFallback() async {
        // Small delay for UX consistency
        try? await Task.sleep(nanoseconds: 200_000_000)

        let data = createMockData(for: selectedDate, location: currentLocation)
        self.panchangamData = data
        self.isLoading = false
        self.isUsingMockData = true
    }

    /// Navigate to the next day
    func goToNextDay() {
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = nextDay
        }
    }

    /// Navigate to the previous day
    func goToPreviousDay() {
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = previousDay
        }
    }

    /// Navigate to today
    func goToToday() {
        selectedDate = Date()
    }

    /// Navigate to a specific date
    func goToDate(_ date: Date) {
        selectedDate = date
    }

    /// Update the current location
    func updateLocation(_ location: Location) {
        currentLocation = location
    }

    /// Retry loading after an error
    func retry() {
        loadPanchangamData()
    }

    /// Clear any error message
    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private Methods

    /// Set up Combine bindings for reactive updates
    private func setupBindings() {
        // Reload data when selected date changes
        $selectedDate
            .dropFirst() // Skip initial value (we load manually in init)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadPanchangamData()
            }
            .store(in: &cancellables)

        // Reload data when location changes
        $currentLocation
            .dropFirst()
            .sink { [weak self] _ in
                self?.loadPanchangamData()
            }
            .store(in: &cancellables)
    }

    /// Create mock panchangam data for a given date and location
    /// TODO: Replace with API call in Phase 2
    private func createMockData(for date: Date, location: Location) -> PanchangamData {
        let calendar = Calendar.current

        // Determine Tamil date based on Gregorian date
        // This is simplified - real implementation needs proper conversion
        let tamilDate = createTamilDate(for: date)

        // Create time-based data for the given date
        let sunrise = calendar.date(bySettingHour: 6, minute: 42, second: 0, of: date) ?? date
        let sunset = calendar.date(bySettingHour: 17, minute: 54, second: 0, of: date) ?? date

        // Nalla Neram times
        let nallaNeram1Start = calendar.date(bySettingHour: 9, minute: 15, second: 0, of: date) ?? date
        let nallaNeram1End = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: date) ?? date
        let nallaNeram2Start = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: date) ?? date
        let nallaNeram2End = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: date) ?? date

        // Rahukaalam (varies by day of week)
        let rahuTimes = getRahukalamTimes(for: date)
        let rahuStart = calendar.date(bySettingHour: rahuTimes.startHour, minute: rahuTimes.startMinute, second: 0, of: date) ?? date
        let rahuEnd = calendar.date(bySettingHour: rahuTimes.endHour, minute: rahuTimes.endMinute, second: 0, of: date) ?? date

        // Yamagandam
        let yamaStart = calendar.date(bySettingHour: 7, minute: 30, second: 0, of: date) ?? date
        let yamaEnd = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: date) ?? date

        // Kuligai
        let kuligaiStart = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: date) ?? date
        let kuligaiEnd = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date) ?? date

        // Create Yogam with times for the specific date
        let yogamStart = calendar.date(bySettingHour: 8, minute: 30, second: 0, of: date) ?? date
        let yogamEnd = calendar.date(bySettingHour: 14, minute: 15, second: 0, of: date) ?? date

        // Rotate through different yogams based on day
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let yogamIndex = dayOfYear % YogamName.allCases.count
        let yogamName = YogamName.allCases[yogamIndex]

        let yogam = Yogam(
            name: yogamName,
            startTime: yogamStart,
            endTime: yogamEnd
        )

        // Determine food status based on thithi (simplified)
        let dayComponent = calendar.component(.day, from: date)
        let isEkadasiDay = (dayComponent % 15) == 11
        let isPradoshamDay = (dayComponent % 15) == 13

        let foodStatus: FoodStatus
        let nextAuspiciousDay: AuspiciousDay?

        if isEkadasiDay {
            foodStatus = .sampleFasting
            nextAuspiciousDay = nil
        } else if isPradoshamDay {
            foodStatus = .sampleAvoidNonVeg
            nextAuspiciousDay = nil
        } else {
            foodStatus = .sampleRegular
            // Calculate next auspicious day
            let daysUntilEkadasi = (11 - (dayComponent % 15) + 15) % 15
            if daysUntilEkadasi == 0 {
                nextAuspiciousDay = nil
            } else if daysUntilEkadasi <= 3 {
                nextAuspiciousDay = .sampleEkadasi
            } else {
                nextAuspiciousDay = .samplePradosham
            }
        }

        // Create Nakshatram for the date
        let nakshatramEnd = calendar.date(bySettingHour: 14, minute: 45, second: 0, of: date) ?? date
        let nakshatram = Nakshatram(
            name: .rohini,
            endTime: nakshatramEnd
        )

        // Create Thithi
        let thithiEnd = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: date) ?? date
        let thithi = Thithi(
            name: .panchami,
            paksha: .shukla,
            endTime: thithiEnd
        )

        // Create Karanam
        let karanamEnd = calendar.date(bySettingHour: 10, minute: 15, second: 0, of: date) ?? date
        let karanam = Karanam(
            name: .bava,
            endTime: karanamEnd
        )

        return PanchangamData(
            date: date,
            tamilDate: tamilDate,
            location: location,
            nakshatram: nakshatram,
            thithi: thithi,
            yogam: yogam,
            karanam: karanam,
            sunrise: sunrise,
            sunset: sunset,
            nallaNeram: [
                TimeRange(startTime: nallaNeram1Start, endTime: nallaNeram1End, type: .nallaNeram),
                TimeRange(startTime: nallaNeram2Start, endTime: nallaNeram2End, type: .nallaNeram)
            ],
            rahukaalam: TimeRange(startTime: rahuStart, endTime: rahuEnd, type: .rahukaalam),
            yamagandam: TimeRange(startTime: yamaStart, endTime: yamaEnd, type: .yamagandam),
            kuligai: TimeRange(startTime: kuligaiStart, endTime: kuligaiEnd, type: .kuligai),
            foodStatus: foodStatus,
            nextAuspiciousDay: nextAuspiciousDay
        )
    }

    /// Create a Tamil date for a given Gregorian date (simplified conversion)
    private func createTamilDate(for date: Date) -> TamilDate {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let weekdayNumber = calendar.component(.weekday, from: date)

        // Map Gregorian month to Tamil month (simplified)
        let tamilMonth: TamilMonth
        switch month {
        case 1: tamilMonth = day < 14 ? .margazhi : .thai
        case 2: tamilMonth = day < 13 ? .thai : .maasi
        case 3: tamilMonth = day < 14 ? .maasi : .panguni
        case 4: tamilMonth = day < 14 ? .panguni : .chithirai
        case 5: tamilMonth = day < 15 ? .chithirai : .vaikasi
        case 6: tamilMonth = day < 15 ? .vaikasi : .aani
        case 7: tamilMonth = day < 17 ? .aani : .aadi
        case 8: tamilMonth = day < 17 ? .aadi : .aavani
        case 9: tamilMonth = day < 17 ? .aavani : .purattasi
        case 10: tamilMonth = day < 17 ? .purattasi : .aippasi
        case 11: tamilMonth = day < 16 ? .aippasi : .karthigai
        case 12: tamilMonth = day < 16 ? .karthigai : .margazhi
        default: tamilMonth = .thai
        }

        // Calculate approximate Tamil day
        let tamilDay = ((day - 14 + 30) % 30) + 1

        // Map weekday
        let weekdays: [Vaaram] = [.nyayiru, .thingal, .chevvai, .budhan, .viyazhan, .velli, .sani]
        let weekday = weekdays[weekdayNumber - 1]

        return TamilDate(
            day: tamilDay,
            month: tamilMonth,
            year: TamilYear(name: "Krodhana", cycleNumber: 38),
            weekday: weekday
        )
    }

    /// Get Rahukaalam times based on day of week
    /// Times vary by weekday in traditional calculations
    private func getRahukalamTimes(for date: Date) -> (startHour: Int, startMinute: Int, endHour: Int, endMinute: Int) {
        let weekday = Calendar.current.component(.weekday, from: date)

        // Traditional Rahukaalam periods (simplified, assuming standard day length)
        switch weekday {
        case 1: return (16, 30, 18, 0)   // Sunday
        case 2: return (7, 30, 9, 0)     // Monday
        case 3: return (15, 0, 16, 30)   // Tuesday
        case 4: return (12, 0, 13, 30)   // Wednesday
        case 5: return (13, 30, 15, 0)   // Thursday
        case 6: return (10, 30, 12, 0)   // Friday
        case 7: return (9, 0, 10, 30)    // Saturday
        default: return (13, 30, 15, 0)
        }
    }
}

// MARK: - Preview Helper

extension DailyViewModel {
    /// Creates a ViewModel with pre-loaded sample data for SwiftUI previews
    static var preview: DailyViewModel {
        let viewModel = DailyViewModel()
        viewModel.panchangamData = .sample
        viewModel.isLoading = false
        return viewModel
    }

    /// Creates a ViewModel in loading state for previews
    static var previewLoading: DailyViewModel {
        let viewModel = DailyViewModel()
        viewModel.isLoading = true
        return viewModel
    }

    /// Creates a ViewModel with error state for previews
    static var previewError: DailyViewModel {
        let viewModel = DailyViewModel()
        viewModel.errorMessage = "Failed to load panchangam data. Please check your connection."
        viewModel.isLoading = false
        return viewModel
    }
}
