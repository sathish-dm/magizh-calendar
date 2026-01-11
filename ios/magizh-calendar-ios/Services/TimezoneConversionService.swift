import Foundation

/// Service for converting and formatting times between timezones
@MainActor
final class TimezoneConversionService {

    // MARK: - Singleton

    static let shared = TimezoneConversionService()

    private let settings = SettingsService.shared

    private init() {}

    // MARK: - Timezone Helpers

    /// Returns the display timezone based on current settings
    func displayTimezone(for locationTimezone: TimeZone) -> TimeZone {
        switch settings.timezoneDisplayMode {
        case .original:
            return locationTimezone
        case .device:
            return TimeZone.current
        }
    }

    /// Formats a time for display, respecting the current timezone display mode
    func formatTime(
        _ date: Date,
        locationTimezone: TimeZone,
        timeFormat: TimeFormat? = nil
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = (timeFormat ?? settings.timeFormat).dateFormatString
        formatter.timeZone = displayTimezone(for: locationTimezone)
        return formatter.string(from: date)
    }

    /// Formats a time range for display
    func formatTimeRange(
        start: Date,
        end: Date,
        locationTimezone: TimeZone
    ) -> String {
        let startFormatted = formatTime(start, locationTimezone: locationTimezone)
        let endFormatted = formatTime(end, locationTimezone: locationTimezone)
        return "\(startFormatted) - \(endFormatted)"
    }

    /// Returns the timezone abbreviation for display (e.g., "IST", "GMT", "PST")
    func timezoneAbbreviation(for locationTimezone: TimeZone) -> String {
        let tz = displayTimezone(for: locationTimezone)
        return tz.abbreviation() ?? tz.identifier
    }

    /// Returns whether times are being shown in a different timezone than the location
    func isShowingConvertedTimezone(locationTimezone: TimeZone) -> Bool {
        guard settings.timezoneDisplayMode == .device else { return false }
        return locationTimezone.identifier != TimeZone.current.identifier
    }

    /// Returns a description of which timezone times are displayed in
    func timezoneDisplayDescription(locationTimezone: TimeZone) -> String? {
        guard isShowingConvertedTimezone(locationTimezone: locationTimezone) else {
            return nil
        }
        let deviceAbbr = TimeZone.current.abbreviation() ?? "Local"
        return "Times in \(deviceAbbr)"
    }
}
