import Foundation
import SwiftUI

/// Main Panchangam data model representing a single day's complete panchangam
/// Contains the five angams (Nakshatram, Thithi, Yogam, Karanam, Vaaram) plus
/// timing information and food status
struct PanchangamData: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let tamilDate: TamilDate
    let location: Location

    // MARK: - Five Angams (Pancha Angam)

    /// Nakshatram (lunar mansion/star)
    let nakshatram: Nakshatram

    /// Thithi (lunar day)
    let thithi: Thithi

    /// Yogam (yoga of sun and moon)
    let yogam: Yogam

    /// Karanam (half of thithi)
    let karanam: Karanam

    /// Vaaram (day of week) - accessed via tamilDate.weekday

    // MARK: - Timings

    /// Sunrise time
    let sunrise: Date

    /// Sunset time
    let sunset: Date

    /// Nalla Neram (auspicious times)
    let nallaNeram: [TimeRange]

    /// Rahukaalam (inauspicious period)
    let rahukaalam: TimeRange

    /// Yamagandam (inauspicious period)
    let yamagandam: TimeRange

    /// Kuligai (inauspicious period)
    let kuligai: TimeRange?

    // MARK: - Derived/Food Status

    /// Food status for the day
    let foodStatus: FoodStatus

    /// Next auspicious day (if any upcoming)
    let nextAuspiciousDay: AuspiciousDay?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        date: Date,
        tamilDate: TamilDate,
        location: Location,
        nakshatram: Nakshatram,
        thithi: Thithi,
        yogam: Yogam,
        karanam: Karanam,
        sunrise: Date,
        sunset: Date,
        nallaNeram: [TimeRange],
        rahukaalam: TimeRange,
        yamagandam: TimeRange,
        kuligai: TimeRange? = nil,
        foodStatus: FoodStatus,
        nextAuspiciousDay: AuspiciousDay? = nil
    ) {
        self.id = id
        self.date = date
        self.tamilDate = tamilDate
        self.location = location
        self.nakshatram = nakshatram
        self.thithi = thithi
        self.yogam = yogam
        self.karanam = karanam
        self.sunrise = sunrise
        self.sunset = sunset
        self.nallaNeram = nallaNeram
        self.rahukaalam = rahukaalam
        self.yamagandam = yamagandam
        self.kuligai = kuligai
        self.foodStatus = foodStatus
        self.nextAuspiciousDay = nextAuspiciousDay
    }

    // MARK: - Computed Properties

    /// Day of week from Tamil date
    var vaaram: Vaaram {
        tamilDate.weekday
    }

    /// Whether today is generally auspicious based on yogam
    var isAuspiciousDay: Bool {
        yogam.type == .auspicious
    }

    /// Whether the current yogam is active right now
    var isYogamCurrentlyActive: Bool {
        yogam.isActive()
    }

    /// Formatted sunrise time
    var sunriseFormatted: String {
        formatTime(sunrise)
    }

    /// Formatted sunset time
    var sunsetFormatted: String {
        formatTime(sunset)
    }

    /// Day length (sunrise to sunset)
    var dayLength: TimeInterval {
        sunset.timeIntervalSince(sunrise)
    }

    /// Day length formatted
    var dayLengthFormatted: String {
        let hours = Int(dayLength / 3600)
        let minutes = Int((dayLength.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }

    /// Current active timing period (if any)
    var currentActiveTiming: TimeRange? {
        let now = Date()

        // Check Rahukaalam first
        if rahukaalam.contains(now) {
            return rahukaalam
        }

        // Check Yamagandam
        if yamagandam.contains(now) {
            return yamagandam
        }

        // Check Kuligai
        if let kuligai = kuligai, kuligai.contains(now) {
            return kuligai
        }

        // Check Nalla Neram
        for nallaNeram in nallaNeram where nallaNeram.contains(now) {
            return nallaNeram
        }

        return nil
    }

    /// Whether we're currently in an auspicious time
    var isCurrentlyAuspicious: Bool {
        guard let activeTiming = currentActiveTiming else { return false }
        return activeTiming.type?.isAuspicious ?? false
    }

    /// Whether we're currently in an inauspicious time
    var isCurrentlyInauspicious: Bool {
        guard let activeTiming = currentActiveTiming else { return false }
        return !(activeTiming.type?.isAuspicious ?? true)
    }

    /// Formatted date for display
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }

    /// Short date format
    var shortDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    /// Day number
    var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }

    // MARK: - Helper Methods

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - CodingKeys

extension PanchangamData {
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case tamilDate = "tamil_date"
        case location
        case nakshatram
        case thithi
        case yogam
        case karanam
        case sunrise
        case sunset
        case nallaNeram = "nalla_neram"
        case rahukaalam
        case yamagandam
        case kuligai
        case foodStatus = "food_status"
        case nextAuspiciousDay = "next_auspicious_day"
    }
}

// MARK: - Sample Data

extension PanchangamData {
    /// Comprehensive sample data for previews and testing
    static let sample: PanchangamData = {
        let calendar = Calendar.current
        let now = Date()

        // Tamil Date
        let tamilDate = TamilDate.sample

        // Times
        let sunrise = calendar.date(bySettingHour: 6, minute: 42, second: 0, of: now) ?? now
        let sunset = calendar.date(bySettingHour: 17, minute: 54, second: 0, of: now) ?? now

        // Nalla Neram times
        let nallaNeram1Start = calendar.date(bySettingHour: 9, minute: 15, second: 0, of: now) ?? now
        let nallaNeram1End = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now) ?? now
        let nallaNeram2Start = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: now) ?? now
        let nallaNeram2End = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: now) ?? now

        // Rahukaalam
        let rahuStart = calendar.date(bySettingHour: 13, minute: 30, second: 0, of: now) ?? now
        let rahuEnd = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: now) ?? now

        // Yamagandam
        let yamaStart = calendar.date(bySettingHour: 7, minute: 30, second: 0, of: now) ?? now
        let yamaEnd = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now

        // Kuligai
        let kuligaiStart = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now) ?? now
        let kuligaiEnd = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now) ?? now

        return PanchangamData(
            date: now,
            tamilDate: tamilDate,
            location: .chennai,
            nakshatram: .sample,
            thithi: .sample,
            yogam: .sampleAuspicious,
            karanam: .sample,
            sunrise: sunrise,
            sunset: sunset,
            nallaNeram: [
                TimeRange(startTime: nallaNeram1Start, endTime: nallaNeram1End, type: .nallaNeram),
                TimeRange(startTime: nallaNeram2Start, endTime: nallaNeram2End, type: .nallaNeram)
            ],
            rahukaalam: TimeRange(startTime: rahuStart, endTime: rahuEnd, type: .rahukaalam),
            yamagandam: TimeRange(startTime: yamaStart, endTime: yamaEnd, type: .yamagandam),
            kuligai: TimeRange(startTime: kuligaiStart, endTime: kuligaiEnd, type: .kuligai),
            foodStatus: .sampleRegular,
            nextAuspiciousDay: .sampleEkadasi
        )
    }()

    /// Sample with inauspicious yogam
    static let sampleInauspicious: PanchangamData = {
        var data = sample
        return PanchangamData(
            date: data.date,
            tamilDate: data.tamilDate,
            location: data.location,
            nakshatram: data.nakshatram,
            thithi: data.thithi,
            yogam: .sampleInauspicious,
            karanam: data.karanam,
            sunrise: data.sunrise,
            sunset: data.sunset,
            nallaNeram: data.nallaNeram,
            rahukaalam: data.rahukaalam,
            yamagandam: data.yamagandam,
            kuligai: data.kuligai,
            foodStatus: .sampleAvoidNonVeg,
            nextAuspiciousDay: data.nextAuspiciousDay
        )
    }()

    /// Sample for Ekadasi day
    static let sampleEkadasi: PanchangamData = {
        var data = sample
        return PanchangamData(
            date: data.date,
            tamilDate: data.tamilDate,
            location: data.location,
            nakshatram: data.nakshatram,
            thithi: .ekadasi,
            yogam: .sampleAuspicious,
            karanam: data.karanam,
            sunrise: data.sunrise,
            sunset: data.sunset,
            nallaNeram: data.nallaNeram,
            rahukaalam: data.rahukaalam,
            yamagandam: data.yamagandam,
            kuligai: data.kuligai,
            foodStatus: .sampleFasting,
            nextAuspiciousDay: nil
        )
    }()
}
