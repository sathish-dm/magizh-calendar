import Foundation

/// Represents a Thithi (lunar day) in the Tamil Panchangam
/// There are 30 Thithis in a lunar month, 15 in each paksha (fortnight)
struct Thithi: Codable, Identifiable, Equatable {
    let id: UUID
    let name: ThithiName
    let paksha: Paksha
    let endTime: Date

    init(
        id: UUID = UUID(),
        name: ThithiName,
        paksha: Paksha,
        endTime: Date
    ) {
        self.id = id
        self.name = name
        self.paksha = paksha
        self.endTime = endTime
    }

    /// Formatted display name with paksha (e.g., "Shukla Panchami")
    var fullName: String {
        "\(paksha.rawValue) \(name.tamilName)"
    }

    /// Formatted end time string (device timezone)
    var endTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: endTime)
    }

    /// Formatted end time with timezone conversion based on settings
    @MainActor
    func endTimeForDisplay(locationTimezone: TimeZone) -> String {
        TimezoneConversionService.shared.formatTime(endTime, locationTimezone: locationTimezone)
    }

    /// Whether this Thithi is considered auspicious
    var isAuspicious: Bool {
        name.isGenerallyAuspicious
    }

    /// Whether this is a special observance day
    var isSpecialDay: SpecialThithiDay? {
        switch name {
        case .ekadasi:
            return .ekadasi
        case .amavasai:
            return .amavasai
        case .pournami:
            return .pournami
        case .pradosham where paksha == .krishna:
            return .pradosham
        case .chaturthi:
            return .chaturthi
        case .ashtami:
            return .ashtami
        case .sashti:
            return .sashti
        default:
            return nil
        }
    }
}

// MARK: - Paksha (Lunar Fortnight)

/// The two fortnights of the lunar month
enum Paksha: String, Codable, CaseIterable {
    case shukla = "Shukla"   // Bright/waxing fortnight
    case krishna = "Krishna" // Dark/waning fortnight

    /// Tamil name (romanized)
    var tamilName: String {
        switch self {
        case .shukla: return "Valar Pirai"   // Growing moon
        case .krishna: return "Thei Pirai"   // Waning moon
        }
    }

    /// Localized name based on current app language
    var localizedName: String {
        PanchangamStrings.shared.paksha(rawValue, for: LocalizationService.shared.currentLanguage)
    }

    /// Description
    var description: String {
        switch self {
        case .shukla: return "Waxing Moon (Bright fortnight)"
        case .krishna: return "Waning Moon (Dark fortnight)"
        }
    }
}

// MARK: - Thithi Names

/// The 15 Thithis (plus Amavasai and Pournami)
enum ThithiName: String, Codable, CaseIterable {
    case prathama = "Prathama"       // 1st
    case dvitiya = "Dvitiya"         // 2nd
    case tritiya = "Tritiya"         // 3rd
    case chaturthi = "Chaturthi"     // 4th
    case panchami = "Panchami"       // 5th
    case sashti = "Sashti"           // 6th
    case saptami = "Saptami"         // 7th
    case ashtami = "Ashtami"         // 8th
    case navami = "Navami"           // 9th
    case dasami = "Dasami"           // 10th
    case ekadasi = "Ekadasi"         // 11th
    case dvadasi = "Dvadasi"         // 12th
    case trayodasi = "Trayodasi"     // 13th (Pradosham day)
    case chaturdasi = "Chaturdasi"   // 14th
    case pournami = "Pournami"       // Full moon (15th of Shukla)
    case amavasai = "Amavasai"       // New moon (15th of Krishna)

    // Alias for Pradosham calculations
    static let pradosham = ThithiName.trayodasi

    /// Tamil name (romanized)
    var tamilName: String {
        rawValue
    }

    /// Localized name based on current app language
    var localizedName: String {
        PanchangamStrings.shared.thithi(rawValue, for: LocalizationService.shared.currentLanguage)
    }

    /// Thithi number (1-15)
    var number: Int {
        switch self {
        case .prathama: return 1
        case .dvitiya: return 2
        case .tritiya: return 3
        case .chaturthi: return 4
        case .panchami: return 5
        case .sashti: return 6
        case .saptami: return 7
        case .ashtami: return 8
        case .navami: return 9
        case .dasami: return 10
        case .ekadasi: return 11
        case .dvadasi: return 12
        case .trayodasi: return 13
        case .chaturdasi: return 14
        case .pournami, .amavasai: return 15
        }
    }

    /// Whether this Thithi is generally considered auspicious
    var isGenerallyAuspicious: Bool {
        switch self {
        case .dvitiya, .tritiya, .panchami, .saptami, .dasami, .ekadasi, .trayodasi, .pournami:
            return true
        default:
            return false
        }
    }

    /// Deity associated with this Thithi
    var deity: String {
        switch self {
        case .prathama: return "Agni"
        case .dvitiya: return "Brahma"
        case .tritiya: return "Gauri"
        case .chaturthi: return "Ganesha"
        case .panchami: return "Nagas"
        case .sashti: return "Skanda"
        case .saptami: return "Surya"
        case .ashtami: return "Shiva"
        case .navami: return "Durga"
        case .dasami: return "Yama"
        case .ekadasi: return "Vishnu"
        case .dvadasi: return "Vishnu"
        case .trayodasi: return "Kamadeva"
        case .chaturdasi: return "Shiva"
        case .pournami: return "Chandra"
        case .amavasai: return "Pitru"
        }
    }
}

// MARK: - Special Thithi Days

/// Special observance days based on Thithi
enum SpecialThithiDay: String, Codable {
    case ekadasi = "Ekadasi"
    case pradosham = "Pradosham"
    case amavasai = "Amavasai"
    case pournami = "Pournami"
    case chaturthi = "Chaturthi"
    case ashtami = "Ashtami"
    case sashti = "Sashti"

    /// Description of the observance
    var description: String {
        switch self {
        case .ekadasi:
            return "Fasting day dedicated to Lord Vishnu"
        case .pradosham:
            return "Auspicious time for Lord Shiva worship"
        case .amavasai:
            return "New moon day for ancestral rites"
        case .pournami:
            return "Full moon day, highly auspicious"
        case .chaturthi:
            return "Sacred to Lord Ganesha"
        case .ashtami:
            return "Sacred to Goddess Durga"
        case .sashti:
            return "Sacred to Lord Murugan"
        }
    }

    /// Food restrictions for this day
    var foodRestriction: FoodRestriction {
        switch self {
        case .ekadasi:
            return .strictFast
        case .pradosham, .ashtami, .chaturthi:
            return .avoidNonVeg
        case .amavasai:
            return .avoidNonVeg
        case .pournami, .sashti:
            return .none
        }
    }
}

// MARK: - Food Restriction

/// Types of food restrictions
enum FoodRestriction: String, Codable {
    case none = "None"
    case avoidNonVeg = "Avoid Non-Veg"
    case strictFast = "Strict Fasting"

    var description: String {
        switch self {
        case .none:
            return "No restrictions"
        case .avoidNonVeg:
            return "Avoid non-vegetarian food"
        case .strictFast:
            return "Fasting recommended (fruits/milk allowed)"
        }
    }
}

// MARK: - Sample Data

extension Thithi {
    /// Sample Thithi for previews
    static let sample: Thithi = {
        let calendar = Calendar.current
        let endTime = calendar.date(
            bySettingHour: 16,
            minute: 30,
            second: 0,
            of: Date()
        ) ?? Date()

        return Thithi(
            name: .panchami,
            paksha: .shukla,
            endTime: endTime
        )
    }()

    /// Ekadasi sample
    static let ekadasi: Thithi = {
        let calendar = Calendar.current
        let endTime = calendar.date(
            bySettingHour: 11,
            minute: 15,
            second: 0,
            of: Date()
        ) ?? Date()

        return Thithi(
            name: .ekadasi,
            paksha: .shukla,
            endTime: endTime
        )
    }()

    /// Amavasai sample
    static let amavasai: Thithi = {
        let calendar = Calendar.current
        let endTime = calendar.date(
            bySettingHour: 5,
            minute: 45,
            second: 0,
            of: Date().addingTimeInterval(86400)
        ) ?? Date()

        return Thithi(
            name: .amavasai,
            paksha: .krishna,
            endTime: endTime
        )
    }()
}
