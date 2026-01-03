import Foundation
import SwiftUI

/// Represents a Yogam in the Tamil Panchangam
/// Yogam is calculated from the combined longitudes of Sun and Moon
/// There are 27 Yogams, each with auspicious or inauspicious qualities
struct Yogam: Codable, Identifiable, Equatable {
    let id: UUID
    let name: YogamName
    let type: YogamType
    let startTime: Date
    let endTime: Date
    let description: String?

    init(
        id: UUID = UUID(),
        name: YogamName,
        type: YogamType? = nil,
        startTime: Date,
        endTime: Date,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type ?? name.defaultType
        self.startTime = startTime
        self.endTime = endTime
        self.description = description ?? name.defaultDescription
    }

    /// Duration of the Yogam
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    /// Formatted time range string
    var timeRangeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }

    /// Whether currently active
    func isActive(at date: Date = Date()) -> Bool {
        date >= startTime && date <= endTime
    }

    /// Color for UI representation
    var color: Color {
        type.color
    }
}

// MARK: - Yogam Type

/// Classification of Yogam quality
enum YogamType: String, Codable {
    case auspicious = "Auspicious"
    case inauspicious = "Inauspicious"
    case neutral = "Neutral"

    /// Display label
    var label: String {
        switch self {
        case .auspicious: return "AUSPICIOUS"
        case .inauspicious: return "AVOID"
        case .neutral: return "NEUTRAL"
        }
    }

    /// Color for UI
    var color: Color {
        switch self {
        case .auspicious: return .green
        case .inauspicious: return .red
        case .neutral: return .orange
        }
    }

    /// Icon name
    var iconName: String {
        switch self {
        case .auspicious: return "checkmark.seal.fill"
        case .inauspicious: return "xmark.seal.fill"
        case .neutral: return "minus.circle.fill"
        }
    }

    /// Recommendation text
    var recommendation: String {
        switch self {
        case .auspicious:
            return "Excellent for new ventures, important decisions, and auspicious activities"
        case .inauspicious:
            return "Avoid starting important work or making major decisions"
        case .neutral:
            return "Suitable for routine activities, moderate for new ventures"
        }
    }
}

// MARK: - Yogam Names

/// The 27 Yogams of Hindu astrology
enum YogamName: String, Codable, CaseIterable {
    case vishkumbham = "Vishkumbham"
    case priti = "Priti"
    case ayushman = "Ayushman"
    case saubhagya = "Saubhagya"
    case sobhanam = "Sobhanam"
    case atiganda = "Atiganda"
    case sukarma = "Sukarma"
    case dhriti = "Dhriti"
    case soola = "Soola"
    case ganda = "Ganda"
    case vriddhi = "Vriddhi"
    case dhruva = "Dhruva"
    case vyagatha = "Vyagatha"
    case harshana = "Harshana"
    case vajra = "Vajra"
    case siddhi = "Siddhi"
    case vyatipata = "Vyatipata"
    case variyan = "Variyan"
    case parigha = "Parigha"
    case siva = "Siva"
    case siddha = "Siddha"
    case sadhya = "Sadhya"
    case subha = "Subha"
    case sukla = "Sukla"
    case brahma = "Brahma"
    case indra = "Indra"
    case vaidhriti = "Vaidhriti"

    /// Tamil/Sanskrit name
    var tamilName: String {
        rawValue
    }

    /// Position in the 27-yogam cycle (1-27)
    var position: Int {
        (Self.allCases.firstIndex(of: self) ?? 0) + 1
    }

    /// Default type/quality of this Yogam
    var defaultType: YogamType {
        switch self {
        // Highly Auspicious
        case .priti, .ayushman, .saubhagya, .sobhanam, .sukarma,
             .dhriti, .vriddhi, .dhruva, .harshana, .siddhi,
             .variyan, .siva, .siddha, .sadhya, .subha, .sukla,
             .brahma, .indra:
            return .auspicious

        // Inauspicious
        case .vishkumbham, .atiganda, .soola, .ganda, .vyagatha,
             .vajra, .vyatipata, .parigha, .vaidhriti:
            return .inauspicious
        }
    }

    /// Default description for this Yogam
    var defaultDescription: String {
        switch self {
        case .vishkumbham:
            return "Obstacle-creating Yogam, avoid new beginnings"
        case .priti:
            return "Love and affection Yogam, excellent for relationships"
        case .ayushman:
            return "Long life Yogam, good for health matters"
        case .saubhagya:
            return "Good fortune Yogam, highly auspicious"
        case .sobhanam:
            return "Brightness Yogam, good for all activities"
        case .atiganda:
            return "Danger Yogam, exercise caution"
        case .sukarma:
            return "Good deeds Yogam, excellent for virtuous activities"
        case .dhriti:
            return "Steadfastness Yogam, good for commitments"
        case .soola:
            return "Thorn/Pain Yogam, avoid medical procedures"
        case .ganda:
            return "Danger Yogam, proceed with caution"
        case .vriddhi:
            return "Growth Yogam, excellent for expansion"
        case .dhruva:
            return "Stable Yogam, good for permanent works"
        case .vyagatha:
            return "Killing Yogam, avoid important activities"
        case .harshana:
            return "Joy Yogam, excellent for celebrations"
        case .vajra:
            return "Diamond/Hard Yogam, mixed results"
        case .siddhi:
            return "Accomplishment Yogam, excellent for success"
        case .vyatipata:
            return "Calamity Yogam, avoid all important work"
        case .variyan:
            return "Comfort Yogam, good for relaxation"
        case .parigha:
            return "Obstruction Yogam, face obstacles"
        case .siva:
            return "Auspicious Yogam, excellent for all activities"
        case .siddha:
            return "Perfection Yogam, accomplishment assured"
        case .sadhya:
            return "Achievable Yogam, goals can be reached"
        case .subha:
            return "Auspicious Yogam, good for ceremonies"
        case .sukla:
            return "Bright Yogam, clarity and success"
        case .brahma:
            return "Creator Yogam, excellent for new ventures"
        case .indra:
            return "King Yogam, authority and success"
        case .vaidhriti:
            return "Great Calamity Yogam, avoid all important activities"
        }
    }
}

// MARK: - Sample Data

extension Yogam {
    /// Auspicious Yogam sample
    static let sampleAuspicious: Yogam = {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(
            bySettingHour: 8,
            minute: 30,
            second: 0,
            of: now
        ) ?? now
        let endTime = calendar.date(
            bySettingHour: 14,
            minute: 15,
            second: 0,
            of: now
        ) ?? now

        return Yogam(
            name: .siddhi,
            startTime: startTime,
            endTime: endTime
        )
    }()

    /// Inauspicious Yogam sample
    static let sampleInauspicious: Yogam = {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(
            bySettingHour: 6,
            minute: 0,
            second: 0,
            of: now
        ) ?? now
        let endTime = calendar.date(
            bySettingHour: 12,
            minute: 45,
            second: 0,
            of: now
        ) ?? now

        return Yogam(
            name: .vyatipata,
            startTime: startTime,
            endTime: endTime
        )
    }()

    /// Default sample (auspicious)
    static let sample = sampleAuspicious
}
