import Foundation

/// Represents a date in the Tamil calendar system
/// Tamil calendar is a solar calendar with 12 months starting from Chithirai (mid-April)
struct TamilDate: Codable, Identifiable, Equatable {
    let id: UUID
    let day: Int
    let month: TamilMonth
    let year: TamilYear
    let weekday: Vaaram

    init(
        id: UUID = UUID(),
        day: Int,
        month: TamilMonth,
        year: TamilYear,
        weekday: Vaaram
    ) {
        self.id = id
        self.day = day
        self.month = month
        self.year = year
        self.weekday = weekday
    }

    /// Formatted Tamil date string (e.g., "Thai 16, Visuvaavasu")
    var formatted: String {
        "\(month.tamilName) \(day), \(year.name)"
    }

    /// Short format (e.g., "Thai 16")
    var shortFormatted: String {
        "\(month.tamilName) \(day)"
    }

    /// Localized short format (e.g., "தை 16" in Tamil or "Thai 16" in English)
    var localizedFormatted: String {
        "\(month.localizedName) \(day)"
    }
}

// MARK: - Tamil Month

/// The 12 months of the Tamil calendar
enum TamilMonth: String, Codable, CaseIterable {
    case chithirai = "Chithirai"
    case vaikasi = "Vaikasi"
    case aani = "Aani"
    case aadi = "Aadi"
    case aavani = "Aavani"
    case purattasi = "Purattasi"
    case aippasi = "Aippasi"
    case karthigai = "Karthigai"
    case margazhi = "Margazhi"
    case thai = "Thai"
    case maasi = "Maasi"
    case panguni = "Panguni"

    /// Tamil name of the month (romanized)
    var tamilName: String {
        rawValue
    }

    /// Localized name based on current app language
    var localizedName: String {
        CalendarStrings.shared.month(rawValue, for: LocalizationService.shared.currentLanguage)
    }

    /// Month number (1-12, starting from Chithirai)
    var monthNumber: Int {
        switch self {
        case .chithirai: return 1
        case .vaikasi: return 2
        case .aani: return 3
        case .aadi: return 4
        case .aavani: return 5
        case .purattasi: return 6
        case .aippasi: return 7
        case .karthigai: return 8
        case .margazhi: return 9
        case .thai: return 10
        case .maasi: return 11
        case .panguni: return 12
        }
    }

    /// Approximate Gregorian month mapping
    var gregorianEquivalent: String {
        switch self {
        case .chithirai: return "Apr-May"
        case .vaikasi: return "May-Jun"
        case .aani: return "Jun-Jul"
        case .aadi: return "Jul-Aug"
        case .aavani: return "Aug-Sep"
        case .purattasi: return "Sep-Oct"
        case .aippasi: return "Oct-Nov"
        case .karthigai: return "Nov-Dec"
        case .margazhi: return "Dec-Jan"
        case .thai: return "Jan-Feb"
        case .maasi: return "Feb-Mar"
        case .panguni: return "Mar-Apr"
        }
    }
}

// MARK: - Tamil Year

/// Tamil year in the 60-year cycle (Prabhava to Akshaya)
struct TamilYear: Codable, Equatable {
    let name: String
    let cycleNumber: Int // 1-60 in the 60-year cycle

    init(name: String, cycleNumber: Int) {
        self.name = name
        self.cycleNumber = cycleNumber
    }
}

// MARK: - Vaaram (Day of Week)

/// Days of the week in Tamil
enum Vaaram: String, Codable, CaseIterable {
    case nyayiru = "Nyayiru"      // Sunday
    case thingal = "Thingal"      // Monday
    case chevvai = "Chevvai"      // Tuesday
    case budhan = "Budhan"        // Wednesday
    case viyazhan = "Viyazhan"    // Thursday
    case velli = "Velli"          // Friday
    case sani = "Sani"            // Saturday

    /// Tamil name (romanized)
    var tamilName: String {
        rawValue
    }

    /// Localized name based on current app language
    var localizedName: String {
        CalendarStrings.shared.weekday(rawValue, for: LocalizationService.shared.currentLanguage)
    }

    /// English equivalent
    var englishName: String {
        switch self {
        case .nyayiru: return "Sunday"
        case .thingal: return "Monday"
        case .chevvai: return "Tuesday"
        case .budhan: return "Wednesday"
        case .viyazhan: return "Thursday"
        case .velli: return "Friday"
        case .sani: return "Saturday"
        }
    }

    /// Short form (e.g., "Sun", "Mon")
    var shortEnglish: String {
        String(englishName.prefix(3))
    }

    /// Associated planet/deity
    var deity: String {
        switch self {
        case .nyayiru: return "Surya (Sun)"
        case .thingal: return "Chandra (Moon)"
        case .chevvai: return "Mangal (Mars)"
        case .budhan: return "Budha (Mercury)"
        case .viyazhan: return "Guru (Jupiter)"
        case .velli: return "Shukra (Venus)"
        case .sani: return "Shani (Saturn)"
        }
    }
}

// MARK: - Sample Data

extension TamilDate {
    /// Sample Tamil date for previews and testing
    static let sample = TamilDate(
        day: 19,
        month: .margazhi,
        year: TamilYear(name: "Krodhana", cycleNumber: 38),
        weekday: .velli
    )

    /// Another sample for variety in previews
    static let sample2 = TamilDate(
        day: 1,
        month: .thai,
        year: TamilYear(name: "Krodhana", cycleNumber: 38),
        weekday: .viyazhan
    )
}
