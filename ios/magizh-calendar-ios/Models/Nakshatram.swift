import Foundation

/// Represents a Nakshatram (lunar mansion/star) in the Tamil Panchangam
/// There are 27 Nakshatrams in the zodiac, each spanning 13°20' of the ecliptic
struct Nakshatram: Codable, Identifiable, Equatable {
    let id: UUID
    let name: NakshatramName
    let endTime: Date
    let lordPlanet: String

    init(
        id: UUID = UUID(),
        name: NakshatramName,
        endTime: Date,
        lordPlanet: String? = nil
    ) {
        self.id = id
        self.name = name
        self.endTime = endTime
        self.lordPlanet = lordPlanet ?? name.defaultLord
    }

    /// Formatted end time string
    var endTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: endTime)
    }
}

// MARK: - Nakshatram Names

/// The 27 Nakshatrams of Hindu astrology
enum NakshatramName: String, Codable, CaseIterable {
    case ashwini = "Ashwini"
    case bharani = "Bharani"
    case krithigai = "Krithigai"
    case rohini = "Rohini"
    case mrigashirisham = "Mrigashirisham"
    case thiruvathirai = "Thiruvathirai"
    case punarpoosam = "Punarpoosam"
    case poosam = "Poosam"
    case ayilyam = "Ayilyam"
    case magam = "Magam"
    case pooram = "Pooram"
    case uthiram = "Uthiram"
    case hastham = "Hastham"
    case chithirai = "Chithirai"
    case swathi = "Swathi"
    case visagam = "Visagam"
    case anusham = "Anusham"
    case kettai = "Kettai"
    case moolam = "Moolam"
    case pooradam = "Pooradam"
    case uthiradam = "Uthiradam"
    case thiruvonam = "Thiruvonam"
    case avittam = "Avittam"
    case sathayam = "Sathayam"
    case poorattathi = "Poorattathi"
    case uthirattathi = "Uthirattathi"
    case revathi = "Revathi"

    /// Tamil name of the Nakshatram (romanized)
    var tamilName: String {
        rawValue
    }

    /// Localized name based on current app language
    var localizedName: String {
        PanchangamStrings.shared.nakshatram(rawValue, for: LocalizationService.shared.currentLanguage)
    }

    /// Position in the 27-star cycle (1-27)
    var position: Int {
        (Self.allCases.firstIndex(of: self) ?? 0) + 1
    }

    /// Ruling planet/lord of the Nakshatram
    var defaultLord: String {
        switch self {
        case .ashwini, .magam, .moolam:
            return "Ketu"
        case .bharani, .pooram, .pooradam:
            return "Venus"
        case .krithigai, .uthiram, .uthiradam:
            return "Sun"
        case .rohini, .hastham, .thiruvonam:
            return "Moon"
        case .mrigashirisham, .chithirai, .avittam:
            return "Mars"
        case .thiruvathirai, .swathi, .sathayam:
            return "Rahu"
        case .punarpoosam, .visagam, .poorattathi:
            return "Jupiter"
        case .poosam, .anusham, .uthirattathi:
            return "Saturn"
        case .ayilyam, .kettai, .revathi:
            return "Mercury"
        }
    }

    /// General nature/quality of the Nakshatram
    var nature: NakshatramNature {
        switch self {
        case .ashwini, .punarpoosam, .hastham, .anusham, .moolam, .revathi:
            return .light
        case .bharani, .magam, .pooram, .pooradam, .poorattathi:
            return .fierce
        case .krithigai, .visagam:
            return .mixed
        case .rohini, .uthiram, .uthiradam, .uthirattathi:
            return .fixed
        case .mrigashirisham, .chithirai, .thiruvonam, .avittam, .sathayam:
            return .movable
        case .thiruvathirai, .ayilyam, .kettai, .swathi:
            return .sharp
        case .poosam:
            return .soft
        }
    }
}

// MARK: - Nakshatram Nature

/// The nature/quality classification of Nakshatrams
enum NakshatramNature: String, Codable {
    case light = "Light/Swift"
    case fierce = "Fierce/Severe"
    case mixed = "Mixed/Dual"
    case fixed = "Fixed/Permanent"
    case movable = "Movable/Temporary"
    case sharp = "Sharp/Dreadful"
    case soft = "Soft/Tender"

    /// Activities suited for this nature
    var suitableActivities: String {
        switch self {
        case .light:
            return "Travel, learning, sports, healing"
        case .fierce:
            return "Competitive activities, surgery, demolition"
        case .mixed:
            return "Routine work, daily activities"
        case .fixed:
            return "Foundation laying, long-term commitments"
        case .movable:
            return "Travel, vehicle purchase, new ventures"
        case .sharp:
            return "Confrontation, filing complaints, separation"
        case .soft:
            return "Arts, music, romance, friendships"
        }
    }
}

// MARK: - Sample Data

extension Nakshatram {
    /// Sample Nakshatram for previews
    static let sample: Nakshatram = {
        let calendar = Calendar.current
        let endTime = calendar.date(
            bySettingHour: 14,
            minute: 45,
            second: 0,
            of: Date()
        ) ?? Date()

        return Nakshatram(
            name: .rohini,
            endTime: endTime
        )
    }()

    /// Another sample for variety
    static let sample2: Nakshatram = {
        let calendar = Calendar.current
        let endTime = calendar.date(
            bySettingHour: 22,
            minute: 30,
            second: 0,
            of: Date()
        ) ?? Date()

        return Nakshatram(
            name: .thiruvathirai,
            endTime: endTime
        )
    }()
}
