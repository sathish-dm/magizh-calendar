import Foundation

/// Represents a time range with start and end times
/// Used for Nalla Neram, Rahukaalam, Yamagandam, etc.
struct TimeRange: Codable, Identifiable, Equatable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let type: TimeRangeType?

    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date,
        type: TimeRangeType? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.type = type
    }

    /// Duration of the time range
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    /// Duration in minutes
    var durationMinutes: Int {
        Int(duration / 60)
    }

    /// Duration formatted as hours and minutes
    var durationFormatted: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    /// Formatted time range string (e.g., "9:00 AM - 10:30 AM")
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }

    /// Short format (e.g., "9:00 - 10:30")
    var shortFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }

    /// Formatted time range with timezone conversion based on settings
    @MainActor
    func formattedForDisplay(locationTimezone: TimeZone) -> String {
        TimezoneConversionService.shared.formatTimeRange(
            start: startTime,
            end: endTime,
            locationTimezone: locationTimezone
        )
    }

    /// Check if a given time falls within this range
    func contains(_ date: Date) -> Bool {
        date >= startTime && date <= endTime
    }

    /// Check if currently active
    var isCurrentlyActive: Bool {
        contains(Date())
    }

    /// Time remaining if currently active
    var timeRemaining: TimeInterval? {
        let now = Date()
        guard contains(now) else { return nil }
        return endTime.timeIntervalSince(now)
    }

    /// Time remaining formatted
    var timeRemainingFormatted: String? {
        guard let remaining = timeRemaining else { return nil }
        let minutes = Int(remaining / 60)
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m remaining"
        }
        return "\(mins)m remaining"
    }
}

// MARK: - Time Range Type

/// Types of special time periods in Panchangam
enum TimeRangeType: String, Codable {
    case nallaNeram = "Nalla Neram"
    case rahukaalam = "Rahukaalam"
    case yamagandam = "Yamagandam"
    case kuligai = "Kuligai"
    case gowriNallaNeram = "Gowri Nalla Neram"
    case abhijitMuhurtam = "Abhijit Muhurtam"
    case brahmaMuhurtam = "Brahma Muhurtam"

    /// Tamil name
    var tamilName: String {
        switch self {
        case .nallaNeram: return "Nalla Neram"
        case .rahukaalam: return "Raagu Kaalam"
        case .yamagandam: return "Ema Gandam"
        case .kuligai: return "Kuligai"
        case .gowriNallaNeram: return "கௌரி நல்ல நேரம்"
        case .abhijitMuhurtam: return "Abhijit Muhurtam"
        case .brahmaMuhurtam: return "Brahma Muhurtam"
        }
    }

    /// Description
    var description: String {
        switch self {
        case .nallaNeram:
            return "Auspicious time for important activities"
        case .rahukaalam:
            return "Inauspicious period ruled by Rahu - avoid new beginnings"
        case .yamagandam:
            return "Inauspicious period ruled by Yama - avoid travel"
        case .kuligai:
            return "Inauspicious period - avoid important work"
        case .gowriNallaNeram:
            return "Auspicious time per Gowri Panchangam calculation"
        case .abhijitMuhurtam:
            return "Most auspicious time of the day (midday)"
        case .brahmaMuhurtam:
            return "Divine time before sunrise for spiritual practice"
        }
    }

    /// Whether this is an auspicious time
    var isAuspicious: Bool {
        switch self {
        case .nallaNeram, .gowriNallaNeram, .abhijitMuhurtam, .brahmaMuhurtam:
            return true
        case .rahukaalam, .yamagandam, .kuligai:
            return false
        }
    }

    /// Icon name for UI
    var iconName: String {
        switch self {
        case .nallaNeram: return "star.fill"
        case .rahukaalam: return "moon.fill"
        case .yamagandam: return "exclamationmark.triangle.fill"
        case .kuligai: return "xmark.circle.fill"
        case .gowriNallaNeram: return "star.circle.fill"
        case .abhijitMuhurtam: return "sun.max.fill"
        case .brahmaMuhurtam: return "sunrise.fill"
        }
    }
}

// MARK: - Sample Data

extension TimeRange {
    /// Sample Nalla Neram
    static let sampleNallaNeram: TimeRange = {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(bySettingHour: 9, minute: 15, second: 0, of: now) ?? now
        let end = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now) ?? now

        return TimeRange(startTime: start, endTime: end, type: .nallaNeram)
    }()

    /// Sample Rahukaalam
    static let sampleRahukaalam: TimeRange = {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(bySettingHour: 13, minute: 30, second: 0, of: now) ?? now
        let end = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: now) ?? now

        return TimeRange(startTime: start, endTime: end, type: .rahukaalam)
    }()

    /// Sample Yamagandam
    static let sampleYamagandam: TimeRange = {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(bySettingHour: 7, minute: 30, second: 0, of: now) ?? now
        let end = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now

        return TimeRange(startTime: start, endTime: end, type: .yamagandam)
    }()

    /// Default sample
    static let sample = sampleNallaNeram
}
