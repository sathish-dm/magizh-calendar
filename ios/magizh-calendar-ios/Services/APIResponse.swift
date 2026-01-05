import Foundation

/// API Response models that match the Spring Boot backend JSON structure
/// These are separate from the app's domain models to handle API-specific formats
/// All models are Sendable for safe use across actor boundaries

// MARK: - Main Response

struct PanchangamAPIResponse: Codable, Sendable {
    let date: String  // "2026-01-03"
    let tamilDate: TamilDateAPI
    let nakshatram: NakshatramAPI
    let thithi: ThithiAPI
    let yogam: YogamAPI
    let karanam: KaranamAPI
    let timings: TimingsAPI
    let foodStatus: FoodStatusAPI
}

// MARK: - Tamil Date

struct TamilDateAPI: Codable, Sendable {
    let month: String
    let day: Int
    let year: String
    let weekday: String
}

// MARK: - Nakshatram

struct NakshatramAPI: Codable, Sendable {
    let name: String
    let endTime: String  // ISO datetime
    let lord: String
}

// MARK: - Thithi

struct ThithiAPI: Codable, Sendable {
    let name: String
    let paksha: String  // "SHUKLA" or "KRISHNA"
    let endTime: String
}

// MARK: - Yogam

struct YogamAPI: Codable, Sendable {
    let name: String
    let type: String  // "AUSPICIOUS", "INAUSPICIOUS", "NEUTRAL"
    let startTime: String
    let endTime: String
}

// MARK: - Karanam

struct KaranamAPI: Codable, Sendable {
    let name: String
    let endTime: String
}

// MARK: - Timings

struct TimingsAPI: Codable, Sendable {
    let sunrise: String
    let sunset: String
    let nallaNeram: [TimeRangeAPI]
    let rahukaalam: TimeRangeAPI
    let yamagandam: TimeRangeAPI
    let kuligai: TimeRangeAPI?
    let gowriNallaNeram: [TimeRangeAPI]?
}

struct TimeRangeAPI: Codable, Sendable {
    let startTime: String
    let endTime: String
    let type: String  // "NALLA_NERAM", "RAHUKAALAM", etc.
}

// MARK: - Food Status

struct FoodStatusAPI: Codable, Sendable {
    let type: String  // "REGULAR", "FASTING", "AVOID_NON_VEG"
    let message: String
    let nextAuspicious: NextAuspiciousAPI?
}

struct NextAuspiciousAPI: Codable, Sendable {
    let name: String
    let date: String
    let daysAway: Int
}

// MARK: - API Response to Domain Model Conversion

extension PanchangamAPIResponse {
    /// Convert API response to domain model
    @MainActor
    func toDomainModel(location: Location) -> PanchangamData? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        guard let gregorianDate = dateFormatter.date(from: date) else {
            return nil
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]

        // Parse Tamil Date
        let tamilDateModel = TamilDate(
            day: tamilDate.day,
            month: parseTamilMonth(tamilDate.month),
            year: TamilYear(name: tamilDate.year, cycleNumber: 38),
            weekday: parseVaaram(tamilDate.weekday)
        )

        // Parse Nakshatram
        let nakshatramEndTime = isoFormatter.date(from: nakshatram.endTime) ?? gregorianDate
        let nakshatramModel = Nakshatram(
            name: parseNakshatramName(nakshatram.name),
            endTime: nakshatramEndTime
        )

        // Parse Thithi
        let thithiEndTime = isoFormatter.date(from: thithi.endTime) ?? gregorianDate
        let thithiModel = Thithi(
            name: parseThithiName(thithi.name),
            paksha: thithi.paksha == "SHUKLA" ? .shukla : .krishna,
            endTime: thithiEndTime
        )

        // Parse Yogam
        let yogamStartTime = isoFormatter.date(from: yogam.startTime) ?? gregorianDate
        let yogamEndTime = isoFormatter.date(from: yogam.endTime) ?? gregorianDate
        let yogamModel = Yogam(
            name: parseYogamName(yogam.name),
            type: parseYogamType(yogam.type),
            startTime: yogamStartTime,
            endTime: yogamEndTime
        )

        // Parse Karanam
        let karanamEndTime = isoFormatter.date(from: karanam.endTime) ?? gregorianDate
        let karanamModel = Karanam(
            name: parseKaranamName(karanam.name),
            endTime: karanamEndTime
        )

        // Parse Timings
        let sunrise = isoFormatter.date(from: timings.sunrise) ?? gregorianDate
        let sunset = isoFormatter.date(from: timings.sunset) ?? gregorianDate

        let nallaNeramRanges = timings.nallaNeram.compactMap { range -> TimeRange? in
            guard let start = isoFormatter.date(from: range.startTime),
                  let end = isoFormatter.date(from: range.endTime) else { return nil }
            return TimeRange(startTime: start, endTime: end, type: .nallaNeram)
        }

        guard let rahuStart = isoFormatter.date(from: timings.rahukaalam.startTime),
              let rahuEnd = isoFormatter.date(from: timings.rahukaalam.endTime),
              let yamaStart = isoFormatter.date(from: timings.yamagandam.startTime),
              let yamaEnd = isoFormatter.date(from: timings.yamagandam.endTime) else {
            return nil
        }

        let rahukaalamRange = TimeRange(startTime: rahuStart, endTime: rahuEnd, type: .rahukaalam)
        let yamagandamRange = TimeRange(startTime: yamaStart, endTime: yamaEnd, type: .yamagandam)

        var kuligaiRange: TimeRange?
        if let kuligai = timings.kuligai,
           let kuligaiStart = isoFormatter.date(from: kuligai.startTime),
           let kuligaiEnd = isoFormatter.date(from: kuligai.endTime) {
            kuligaiRange = TimeRange(startTime: kuligaiStart, endTime: kuligaiEnd, type: .kuligai)
        }

        // Parse Gowri Nalla Neram
        var gowriNallaNeramRanges: [TimeRange] = []
        if let gowriRanges = timings.gowriNallaNeram {
            gowriNallaNeramRanges = gowriRanges.compactMap { range -> TimeRange? in
                guard let start = isoFormatter.date(from: range.startTime),
                      let end = isoFormatter.date(from: range.endTime) else { return nil }
                return TimeRange(startTime: start, endTime: end, type: .gowriNallaNeram)
            }
        }

        // Parse Food Status
        let foodStatusModel = parseFoodStatus(foodStatus, currentDate: gregorianDate)

        // Parse Next Auspicious Day
        var nextAuspiciousDay: AuspiciousDay?
        if let next = foodStatus.nextAuspicious {
            nextAuspiciousDay = AuspiciousDay(
                name: next.name,
                type: parseAuspiciousDayType(next.name),
                date: gregorianDate.addingTimeInterval(Double(next.daysAway) * 86400)
            )
        }

        return PanchangamData(
            date: gregorianDate,
            tamilDate: tamilDateModel,
            location: location,
            nakshatram: nakshatramModel,
            thithi: thithiModel,
            yogam: yogamModel,
            karanam: karanamModel,
            sunrise: sunrise,
            sunset: sunset,
            nallaNeram: nallaNeramRanges,
            rahukaalam: rahukaalamRange,
            yamagandam: yamagandamRange,
            kuligai: kuligaiRange,
            gowriNallaNeram: gowriNallaNeramRanges,
            foodStatus: foodStatusModel,
            nextAuspiciousDay: nextAuspiciousDay
        )
    }

    // MARK: - Private Parsing Helpers

    private func parseTamilMonth(_ name: String) -> TamilMonth {
        TamilMonth.allCases.first { $0.rawValue.lowercased() == name.lowercased() } ?? .thai
    }

    private func parseVaaram(_ name: String) -> Vaaram {
        Vaaram.allCases.first { $0.rawValue.lowercased() == name.lowercased() } ?? .nyayiru
    }

    private func parseNakshatramName(_ name: String) -> NakshatramName {
        NakshatramName.allCases.first { $0.rawValue.lowercased() == name.lowercased() } ?? .rohini
    }

    private func parseThithiName(_ name: String) -> ThithiName {
        ThithiName.allCases.first { $0.rawValue.lowercased() == name.lowercased() } ?? .panchami
    }

    private func parseYogamName(_ name: String) -> YogamName {
        YogamName.allCases.first { $0.rawValue.lowercased() == name.lowercased() } ?? .siddhi
    }

    private func parseYogamType(_ type: String) -> YogamType {
        switch type.uppercased() {
        case "AUSPICIOUS": return .auspicious
        case "INAUSPICIOUS": return .inauspicious
        default: return .neutral
        }
    }

    private func parseKaranamName(_ name: String) -> KaranamName {
        KaranamName.allCases.first { $0.rawValue.lowercased() == name.lowercased() } ?? .bava
    }

    private func parseFoodStatus(_ api: FoodStatusAPI, currentDate: Date) -> FoodStatus {
        let type: FoodStatusType
        switch api.type.uppercased() {
        case "FASTING": type = .strictFast
        case "AVOID_NON_VEG": type = .avoidNonVeg
        default: type = .regular
        }

        var nextAuspicious: AuspiciousDay?
        if let next = api.nextAuspicious {
            nextAuspicious = AuspiciousDay(
                name: next.name,
                type: parseAuspiciousDayType(next.name),
                date: currentDate.addingTimeInterval(Double(next.daysAway) * 86400)
            )
        }

        return FoodStatus(
            type: type,
            date: currentDate,
            reason: api.message,
            nextAuspiciousDay: nextAuspicious
        )
    }

    private func parseAuspiciousDayType(_ name: String) -> AuspiciousDayType {
        AuspiciousDayType.allCases.first { $0.rawValue.lowercased() == name.lowercased() } ?? .ekadasi
    }
}
