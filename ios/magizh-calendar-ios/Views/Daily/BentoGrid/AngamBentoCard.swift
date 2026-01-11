import SwiftUI

/// Small card for displaying individual Pancha Angam elements
struct AngamBentoCard: View {
    let type: AngamType
    let value: String
    let endTime: String?
    let accentColor: Color

    @ObservedObject var localization = LocalizationService.shared

    enum AngamType {
        case nakshatram
        case thithi
        case yogam(YogamType)
        case karanam

        var icon: String {
            switch self {
            case .nakshatram: return "star.fill"
            case .thithi: return "moon.fill"
            case .yogam: return "sparkles"
            case .karanam: return "arrow.triangle.2.circlepath"
            }
        }

        var label: String {
            switch self {
            case .nakshatram: return "Nakshatram"
            case .thithi: return "Thithi"
            case .yogam: return "Yogam"
            case .karanam: return "Karanam"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Icon and label
            HStack(spacing: Spacing.xs) {
                Image(systemName: type.icon)
                    .font(.caption2)
                    .foregroundStyle(accentColor)
                Text(type.label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Value
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // End time or Yogam badge
            if case .yogam(let yogamType) = type {
                Text(yogamType == .auspicious ? "Good" : (yogamType == .inauspicious ? "Avoid" : ""))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 3)
                    .background(accentColor.gradient)
                    .clipShape(Capsule())
            } else if let endTime = endTime {
                Text(endTime)
                    .font(.caption2)
                    .foregroundStyle(accentColor)
            }

            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(.regularMaterial)
        )
    }
}

/// Sunrise/Sunset compact card
struct SunTimeBentoCard: View {
    let sunrise: Date
    let sunset: Date

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }

    private var dayLength: String {
        let interval = sunset.timeIntervalSince(sunrise)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack(spacing: Spacing.xs) {
                Image(systemName: "sun.max.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                Text("Sun")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Sunrise time
            Text(timeFormatter.string(from: sunrise))
                .font(.subheadline)
                .fontWeight(.bold)

            // Sunset time
            Text(timeFormatter.string(from: sunset))
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(.regularMaterial)
        )
    }
}
