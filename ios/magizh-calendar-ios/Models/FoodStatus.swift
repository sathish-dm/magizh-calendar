import Foundation
import SwiftUI

/// Represents the food status for a day based on auspicious observances
/// This is a key differentiating feature - smart food planning alerts
struct FoodStatus: Codable, Identifiable, Equatable {
    let id: UUID
    let type: FoodStatusType
    let date: Date
    let reason: String?
    let nextAuspiciousDay: AuspiciousDay?

    init(
        id: UUID = UUID(),
        type: FoodStatusType,
        date: Date = Date(),
        reason: String? = nil,
        nextAuspiciousDay: AuspiciousDay? = nil
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.reason = reason ?? type.defaultReason
        self.nextAuspiciousDay = nextAuspiciousDay
    }

    /// Message for notifications
    var notificationMessage: String {
        switch type {
        case .regular:
            if let next = nextAuspiciousDay {
                return "Regular day. Next observance: \(next.name) on \(next.dateFormatted)"
            }
            return "Regular day - no restrictions"
        case .avoidNonVeg:
            return "Tomorrow is \(reason ?? "an auspicious day") - avoid cooking/storing non-veg tonight"
        case .strictFast:
            return "Today is \(reason ?? "a fasting day") - fasting recommended"
        case .multipleObservances:
            return "Multiple observances today - \(reason ?? "check details")"
        }
    }

    /// Short status message
    var shortMessage: String {
        switch type {
        case .regular:
            return "Regular Day"
        case .avoidNonVeg:
            return "Avoid Non-Veg"
        case .strictFast:
            return "Fasting Day"
        case .multipleObservances:
            return "Special Day"
        }
    }

    /// Color for UI
    var color: Color {
        type.color
    }

    /// Icon name
    var iconName: String {
        type.iconName
    }
}

// MARK: - Food Status Type

/// Types of food status based on observances
enum FoodStatusType: String, Codable {
    case regular = "Regular"
    case avoidNonVeg = "Avoid Non-Veg"
    case strictFast = "Strict Fast"
    case multipleObservances = "Multiple Observances"

    /// Default reason for this status
    var defaultReason: String {
        switch self {
        case .regular:
            return "No special observances"
        case .avoidNonVeg:
            return "Auspicious day observance"
        case .strictFast:
            return "Ekadasi or major fasting day"
        case .multipleObservances:
            return "Multiple auspicious observances"
        }
    }

    /// UI color
    var color: Color {
        switch self {
        case .regular:
            return .green
        case .avoidNonVeg:
            return .orange
        case .strictFast:
            return .red
        case .multipleObservances:
            return .purple
        }
    }

    /// Icon name
    var iconName: String {
        switch self {
        case .regular:
            return "checkmark.circle.fill"
        case .avoidNonVeg:
            return "leaf.fill"
        case .strictFast:
            return "moon.stars.fill"
        case .multipleObservances:
            return "star.circle.fill"
        }
    }

    /// Background gradient colors
    var gradientColors: [Color] {
        switch self {
        case .regular:
            return [.green.opacity(0.8), .green.opacity(0.6)]
        case .avoidNonVeg:
            return [.orange.opacity(0.8), .orange.opacity(0.6)]
        case .strictFast:
            return [.red.opacity(0.8), .red.opacity(0.6)]
        case .multipleObservances:
            return [.purple.opacity(0.8), .purple.opacity(0.6)]
        }
    }
}

// MARK: - Auspicious Day

/// Represents an upcoming auspicious day
struct AuspiciousDay: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let type: AuspiciousDayType
    let date: Date
    let description: String?

    init(
        id: UUID = UUID(),
        name: String,
        type: AuspiciousDayType,
        date: Date,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.date = date
        self.description = description
    }

    /// Formatted date string
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    /// Days until this day
    var daysUntil: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: today, to: targetDate).day ?? 0
    }

    /// Human-readable days until
    var daysUntilFormatted: String {
        switch daysUntil {
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        default:
            return "In \(daysUntil) days"
        }
    }
}

// MARK: - Auspicious Day Type

/// Types of auspicious days
enum AuspiciousDayType: String, Codable, CaseIterable {
    case ekadasi = "Ekadasi"
    case pradosham = "Pradosham"
    case amavasai = "Amavasai"
    case pournami = "Pournami"
    case karthigai = "Karthigai"
    case shivaratri = "Shivaratri"
    case navaratri = "Navaratri"
    case somavaram = "Somavaram"
    case sashti = "Sashti"
    case ashtami = "Ashtami"
    case chaturthi = "Chaturthi"
    case festival = "Festival"

    /// Food restriction for this type
    var foodRestriction: FoodStatusType {
        switch self {
        case .ekadasi:
            return .strictFast
        case .pradosham, .amavasai, .shivaratri, .ashtami, .chaturthi:
            return .avoidNonVeg
        case .pournami, .karthigai, .somavaram, .sashti:
            return .avoidNonVeg
        case .navaratri:
            return .strictFast
        case .festival:
            return .regular
        }
    }

    /// Description of the observance
    var observanceDescription: String {
        switch self {
        case .ekadasi:
            return "11th lunar day - dedicated to Lord Vishnu"
        case .pradosham:
            return "13th lunar day - sacred to Lord Shiva"
        case .amavasai:
            return "New moon day - ancestral rites"
        case .pournami:
            return "Full moon day - highly auspicious"
        case .karthigai:
            return "Karthigai star day - sacred to Lord Murugan"
        case .shivaratri:
            return "Night of Shiva - major fasting day"
        case .navaratri:
            return "Nine nights of Goddess worship"
        case .somavaram:
            return "Monday - sacred to Lord Shiva"
        case .sashti:
            return "6th lunar day - sacred to Lord Murugan"
        case .ashtami:
            return "8th lunar day - sacred to Goddess Durga"
        case .chaturthi:
            return "4th lunar day - sacred to Lord Ganesha"
        case .festival:
            return "Festival day"
        }
    }
}

// MARK: - Sample Data

extension FoodStatus {
    /// Regular day sample
    static let sampleRegular = FoodStatus(
        type: .regular,
        nextAuspiciousDay: .sampleEkadasi
    )

    /// Avoid non-veg sample
    static let sampleAvoidNonVeg = FoodStatus(
        type: .avoidNonVeg,
        reason: "Pradosham tomorrow"
    )

    /// Fasting day sample
    static let sampleFasting = FoodStatus(
        type: .strictFast,
        reason: "Ekadasi"
    )

    /// Default sample
    static let sample = sampleRegular
}

extension AuspiciousDay {
    /// Sample Ekadasi
    static let sampleEkadasi = AuspiciousDay(
        name: "Ekadasi",
        type: .ekadasi,
        date: Date().addingTimeInterval(86400 * 3), // 3 days from now
        description: "Shukla Ekadasi"
    )

    /// Sample Pradosham
    static let samplePradosham = AuspiciousDay(
        name: "Pradosham",
        type: .pradosham,
        date: Date().addingTimeInterval(86400 * 5),
        description: "Evening worship of Lord Shiva"
    )

    /// Default sample
    static let sample = sampleEkadasi
}
