import SwiftUI

/// Nalla Neram card showing auspicious times
struct NallaNeramBentoCard: View {
    let times: [TimeRange]
    let locationTimezone: TimeZone
    @ObservedObject var localization = LocalizationService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack(spacing: Spacing.xs) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text(localization.string(.nallaNeram))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            // Time slots
            VStack(alignment: .leading, spacing: Spacing.md) {
                ForEach(Array(times.enumerated()), id: \.element.id) { index, time in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(index == 0 ? localization.string(.morning) : localization.string(.afternoon))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(time.formattedForDisplay(locationTimezone: locationTimezone))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(time.isCurrentlyActive ? .green : .primary)
                    }
                }
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

/// Avoid Times card showing inauspicious periods
struct AvoidTimesBentoCard: View {
    let rahukaalam: TimeRange
    let yamagandam: TimeRange
    let kuligai: TimeRange?
    let locationTimezone: TimeZone
    @ObservedObject var localization = LocalizationService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack(spacing: Spacing.xs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                Text(localization.string(.avoid))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            // Rahukaalam
            VStack(alignment: .leading, spacing: 4) {
                Text(localization.string(.rahukaalam))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(rahukaalam.formattedForDisplay(locationTimezone: locationTimezone))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(rahukaalam.isCurrentlyActive ? .red : .primary)
            }

            // Yamagandam
            VStack(alignment: .leading, spacing: 4) {
                Text(localization.string(.yamagandam))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(yamagandam.formattedForDisplay(locationTimezone: locationTimezone))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(yamagandam.isCurrentlyActive ? .orange : .primary)
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
