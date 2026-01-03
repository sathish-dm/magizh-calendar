import SwiftUI

/// Displays the five angams (Pancha Angam) of a day's Panchangam
/// Shows: Nakshatram, Thithi, Yogam, Karanam, and Sunrise/Sunset
/// Uses the iOS 18 Liquid Glass design language
struct PanchangamCard: View {
    // MARK: - Properties

    let panchangam: PanchangamData

    // MARK: - Body

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                headerSection
                angamsList
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Label("Today's Panchangam", systemImage: "sun.max.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Five Elements of Time")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Verification badge
            Image(systemName: "checkmark.seal.fill")
                .font(.title3)
                .foregroundStyle(.green)
        }
    }

    // MARK: - Angams List

    private var angamsList: some View {
        VStack(spacing: Spacing.md) {
            AngamRow(
                icon: "star.fill",
                name: "Nakshatram",
                value: panchangam.nakshatram.name.tamilName,
                endTime: panchangam.nakshatram.endTimeFormatted,
                accentColor: .purple
            )

            AngamRow(
                icon: "moon.fill",
                name: "Thithi",
                value: panchangam.thithi.fullName,
                endTime: panchangam.thithi.endTimeFormatted,
                accentColor: .blue
            )

            YogamRow(yogam: panchangam.yogam)

            AngamRow(
                icon: "circle.hexagongrid.fill",
                name: "Karanam",
                value: panchangam.karanam.name.tamilName,
                endTime: panchangam.karanam.endTimeFormatted,
                accentColor: .indigo
            )

            SunTimesRow(
                sunrise: panchangam.sunriseFormatted,
                sunset: panchangam.sunsetFormatted,
                dayLength: panchangam.dayLengthFormatted
            )
        }
    }
}

// MARK: - Angam Row Component

/// A single row displaying one angam (Nakshatram, Thithi, Karanam)
struct AngamRow: View {
    let icon: String
    let name: String
    let value: String
    let endTime: String?
    let accentColor: Color

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon with colored background
            iconView

            // Name and value
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(name)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Spacer()

            // End time badge
            if let endTime = endTime {
                endTimeBadge(endTime)
            }
        }
        .padding(Spacing.md)
        .background(rowBackground)
    }

    private var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: 14))
            .foregroundStyle(accentColor)
            .frame(width: 32, height: 32)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(accentColor.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(accentColor.opacity(0.3), lineWidth: 1)
                    )
            )
    }

    private func endTimeBadge(_ time: String) -> some View {
        Text("Ends \(time)")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: CornerRadius.lg)
            .fill(.ultraThinMaterial)
            .overlay(
                Rectangle()
                    .fill(accentColor)
                    .frame(width: 3),
                alignment: .leading
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }
}

// MARK: - Yogam Row Component

/// Special row for Yogam with auspicious/inauspicious indicator
struct YogamRow: View {
    let yogam: Yogam

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            iconView

            // Name and time
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Yogam")
                    .font(.caption)
                    .foregroundStyle(yogam.color)

                Text(yogam.name.tamilName)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(yogam.timeRangeFormatted)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Auspicious/Avoid badge
            statusBadge
        }
        .padding(Spacing.md)
        .background(rowBackground)
    }

    private var iconView: some View {
        Image(systemName: yogam.type.iconName)
            .font(.system(size: 14))
            .foregroundStyle(yogam.color)
            .frame(width: 32, height: 32)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(yogam.color.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(yogam.color.opacity(0.3), lineWidth: 1)
                    )
            )
    }

    private var statusBadge: some View {
        Text(yogam.type.label)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [yogam.color, yogam.color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: yogam.color.opacity(0.3), radius: 8)
            )
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: CornerRadius.lg)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(yogam.color.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: yogam.color.opacity(0.15), radius: 10)
    }
}

// MARK: - Sun Times Row Component

/// Row displaying sunrise, sunset, and day length
struct SunTimesRow: View {
    let sunrise: String
    let sunset: String
    let dayLength: String

    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Sunrise
            sunTimeItem(
                icon: "sunrise.fill",
                label: "Sunrise",
                time: sunrise,
                color: .orange
            )

            Divider()
                .frame(height: 40)

            // Sunset
            sunTimeItem(
                icon: "sunset.fill",
                label: "Sunset",
                time: sunset,
                color: .pink
            )

            Divider()
                .frame(height: 40)

            // Day length
            sunTimeItem(
                icon: "sun.max.fill",
                label: "Day",
                time: dayLength,
                color: .yellow
            )
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(.ultraThinMaterial)
        )
    }

    private func sunTimeItem(
        icon: String,
        label: String,
        time: String,
        color: Color
    ) -> some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(time)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview("Panchangam Card - Auspicious") {
    ZStack {
        LinearGradient(
            colors: [Color.orange.opacity(0.2), Color.pink.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            PanchangamCard(panchangam: .sample)
                .padding()
        }
    }
}

#Preview("Panchangam Card - Inauspicious") {
    ZStack {
        LinearGradient(
            colors: [Color.gray.opacity(0.2), Color.blue.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            PanchangamCard(panchangam: .sampleInauspicious)
                .padding()
        }
    }
}

#Preview("Panchangam Card - Dark Mode") {
    ZStack {
        Color.black.ignoresSafeArea()

        ScrollView {
            PanchangamCard(panchangam: .sample)
                .padding()
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Individual Components") {
    ZStack {
        Color(white: 0.95).ignoresSafeArea()

        VStack(spacing: Spacing.lg) {
            AngamRow(
                icon: "star.fill",
                name: "Nakshatram",
                value: "Rohini",
                endTime: "2:45 PM",
                accentColor: .purple
            )

            YogamRow(yogam: .sampleAuspicious)

            YogamRow(yogam: .sampleInauspicious)

            SunTimesRow(
                sunrise: "6:42 AM",
                sunset: "5:54 PM",
                dayLength: "11h 12m"
            )
        }
        .padding()
    }
}
