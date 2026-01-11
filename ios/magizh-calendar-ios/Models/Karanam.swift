import Foundation

/// Represents a Karanam in the Tamil Panchangam
/// Karanam is half of a Thithi - there are 11 Karanams, with 7 repeating
/// and 4 fixed ones occurring only once per lunar month
struct Karanam: Codable, Identifiable, Equatable {
    let id: UUID
    let name: KaranamName
    let endTime: Date

    init(
        id: UUID = UUID(),
        name: KaranamName,
        endTime: Date
    ) {
        self.id = id
        self.name = name
        self.endTime = endTime
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

    /// Whether this Karanam is auspicious
    var isAuspicious: Bool {
        name.isAuspicious
    }
}

// MARK: - Karanam Names

/// The 11 Karanams of Hindu astrology
enum KaranamName: String, Codable, CaseIterable {
    // Repeating Karanams (Chara - movable, occur 8 times each per month)
    case bava = "Bava"
    case balava = "Balava"
    case kaulava = "Kaulava"
    case taitila = "Taitila"
    case gara = "Gara"
    case vanija = "Vanija"
    case vishti = "Vishti"       // Also called Bhadra - inauspicious

    // Fixed Karanams (Sthira - occur only once per month)
    case sakuni = "Sakuni"       // Second half of Krishna Chaturdasi
    case chatushpada = "Chatushpada"  // First half of Amavasai
    case naga = "Naga"           // Second half of Amavasai
    case kimstughna = "Kimstughna"    // First half of Shukla Prathama

    /// Tamil/Sanskrit name (romanized)
    var tamilName: String {
        rawValue
    }

    /// Localized name based on current app language
    var localizedName: String {
        PanchangamStrings.shared.karanam(rawValue, for: LocalizationService.shared.currentLanguage)
    }

    /// Whether this is a fixed (Sthira) or movable (Chara) Karanam
    var isFixed: Bool {
        switch self {
        case .sakuni, .chatushpada, .naga, .kimstughna:
            return true
        default:
            return false
        }
    }

    /// Whether this Karanam is generally auspicious
    var isAuspicious: Bool {
        switch self {
        case .vishti, .sakuni:  // Vishti (Bhadra) is always inauspicious
            return false
        default:
            return true
        }
    }

    /// Ruling deity
    var deity: String {
        switch self {
        case .bava: return "Indra"
        case .balava: return "Brahma"
        case .kaulava: return "Mitra"
        case .taitila: return "Aryama"
        case .gara: return "Prithvi"
        case .vanija: return "Lakshmi"
        case .vishti: return "Yama"
        case .sakuni: return "Garuda"
        case .chatushpada: return "Rishabha"
        case .naga: return "Serpent"
        case .kimstughna: return "Marut"
        }
    }

    /// Suitable activities for this Karanam
    var suitableFor: String {
        switch self {
        case .bava:
            return "Starting new projects, business ventures"
        case .balava:
            return "Worship, spiritual activities, celebrations"
        case .kaulava:
            return "Friendships, social gatherings, relationships"
        case .taitila:
            return "Government work, authority matters"
        case .gara:
            return "Agriculture, planting, construction"
        case .vanija:
            return "Business, trade, financial matters"
        case .vishti:
            return "Avoid important activities (Bhadra Karanam)"
        case .sakuni:
            return "Medicine, healing, curing diseases"
        case .chatushpada:
            return "Animal husbandry, vehicle matters"
        case .naga:
            return "Permanent works, long-term commitments"
        case .kimstughna:
            return "Destroying enemies, competitive activities"
        }
    }
}

// MARK: - Sample Data

extension Karanam {
    /// Sample Karanam for previews
    static let sample: Karanam = {
        let calendar = Calendar.current
        let endTime = calendar.date(
            bySettingHour: 10,
            minute: 15,
            second: 0,
            of: Date()
        ) ?? Date()

        return Karanam(
            name: .bava,
            endTime: endTime
        )
    }()

    /// Inauspicious sample (Vishti/Bhadra)
    static let sampleInauspicious: Karanam = {
        let calendar = Calendar.current
        let endTime = calendar.date(
            bySettingHour: 18,
            minute: 30,
            second: 0,
            of: Date()
        ) ?? Date()

        return Karanam(
            name: .vishti,
            endTime: endTime
        )
    }()
}
