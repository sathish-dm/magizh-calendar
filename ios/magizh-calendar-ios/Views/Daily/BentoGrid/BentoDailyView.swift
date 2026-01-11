import SwiftUI
import Combine

/// Main Bento Grid layout for daily panchangam view
struct BentoDailyView: View {
    let data: PanchangamData
    let location: Location
    @Binding var showingSettings: Bool
    @ObservedObject var settings = SettingsService.shared
    @ObservedObject var localization = LocalizationService.shared

    // 2-column grid
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    /// Location's timezone for time display
    private var locationTimezone: TimeZone {
        location.timeZone ?? TimeZone.current
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Row 1: Hero Card (full width)
            HeroBentoCard(data: data, location: location, showingSettings: $showingSettings)

            // Row 2: Nalla Neram + Avoid Times (side by side)
            HStack(spacing: Spacing.md) {
                NallaNeramBentoCard(times: data.nallaNeram, locationTimezone: locationTimezone)
                AvoidTimesBentoCard(
                    rahukaalam: data.rahukaalam,
                    yamagandam: data.yamagandam,
                    kuligai: data.kuligai,
                    locationTimezone: locationTimezone
                )
            }
            .frame(height: 150)

            // Row 3: Gowri Nalla Neram (full width, compact)
            if !data.gowriNallaNeram.isEmpty {
                GowriBentoCard(times: data.gowriNallaNeram, locationTimezone: locationTimezone)
            }

            // Row 4: Four small angam cards (2x2)
            HStack(spacing: Spacing.md) {
                AngamBentoCard(
                    type: .nakshatram,
                    value: data.nakshatram.name.localizedName,
                    endTime: "Ends \(data.nakshatram.endTimeForDisplay(locationTimezone: locationTimezone))",
                    accentColor: .purple
                )
                AngamBentoCard(
                    type: .thithi,
                    value: "\(data.thithi.name.localizedName)",
                    endTime: data.thithi.paksha.localizedName,
                    accentColor: .blue
                )
            }
            .frame(height: 100)

            HStack(spacing: Spacing.md) {
                AngamBentoCard(
                    type: .yogam(data.yogam.type),
                    value: data.yogam.name.localizedName,
                    endTime: nil,
                    accentColor: data.yogam.type.color
                )
                SunTimeBentoCard(
                    sunrise: data.sunrise,
                    sunset: data.sunset,
                    locationTimezone: locationTimezone
                )
            }
            .frame(height: 100)

            // Row 5: Karanam + Current Status
            HStack(spacing: Spacing.md) {
                AngamBentoCard(
                    type: .karanam,
                    value: data.karanam.name.localizedName,
                    endTime: "Ends \(data.karanam.endTimeForDisplay(locationTimezone: locationTimezone))",
                    accentColor: .indigo
                )
                CurrentStatusBentoCard(data: data)
            }
            .frame(height: 100)

            // Verification badge (full width)
            VerificationBentoCard()
        }
    }
}

/// Current status card showing active period
struct CurrentStatusBentoCard: View {
    let data: PanchangamData
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header - matches other cards
            HStack(spacing: Spacing.xs) {
                Image(systemName: "clock.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                Text("Now")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Current time - main value
            Text(currentTime, style: .time)
                .font(.subheadline)
                .fontWeight(.bold)

            // Active period - secondary info
            if let activePeriod = getActivePeriod() {
                Text(activePeriod.name)
                    .font(.caption)
                    .foregroundStyle(activePeriod.color)
            }

            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(.regularMaterial)
        )
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    private func getActivePeriod() -> (name: String, color: Color)? {
        if data.rahukaalam.isCurrentlyActive {
            return ("Rahukaalam", .red)
        } else if data.yamagandam.isCurrentlyActive {
            return ("Yamagandam", .orange)
        } else if data.nallaNeram.contains(where: { $0.isCurrentlyActive }) {
            return ("Nalla Neram", .green)
        } else if data.yogam.isActive() {
            return ("\(data.yogam.name.rawValue)", data.yogam.type.color)
        }
        return nil
    }
}

/// Verification badge
struct VerificationBentoCard: View {
    @ObservedObject var localization = LocalizationService.shared

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title3)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text(localization.string(.verifiedPanchangamData))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                Text(localization.string(.thirukanithaMethod))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(.regularMaterial)
        )
    }
}
