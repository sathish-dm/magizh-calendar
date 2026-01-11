import SwiftUI

/// Compact Gowri Nalla Neram card showing all 5 periods
struct GowriBentoCard: View {
    let times: [TimeRange]
    let locationTimezone: TimeZone

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "sparkle")
                        .font(.caption)
                        .foregroundStyle(.green)
                    Text("Gowri Nalla Neram")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                Text("\(times.count) periods")
                    .font(.caption2)
                    .foregroundStyle(.green)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
            }

            // Time pills in horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(times) { time in
                        Text(time.formattedForDisplay(locationTimezone: locationTimezone))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(time.isCurrentlyActive ? .white : .primary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(
                                Capsule()
                                    .fill(time.isCurrentlyActive ? Color.green : Color.secondary.opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(.regularMaterial)
        )
    }
}
