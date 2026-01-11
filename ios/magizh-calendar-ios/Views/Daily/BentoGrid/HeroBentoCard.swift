import SwiftUI

/// Hero card displaying date, Tamil date, and food status
struct HeroBentoCard: View {
    let data: PanchangamData
    let location: Location
    @Binding var showingSettings: Bool
    @ObservedObject var settings = SettingsService.shared
    @ObservedObject var localization = LocalizationService.shared
    @State private var isFloating = false

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Top row: Location + Food Status + Settings
            HStack(alignment: .center, spacing: Spacing.sm) {
                locationBadge
                Spacer()
                foodStatusBadge
                settingsButton
            }
            .frame(height: 32)

            // Center: Large date number
            Text("\(Calendar.current.component(.day, from: data.date))")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 10)
                .offset(y: isFloating ? -4 : 0)

            // Date string
            Text(data.date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.9))

            // Tamil date badge
            Text("\(data.tamilDate.localizedFormatted) \u{2022} \(data.vaaram.localizedName)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(heroBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xxl, style: .continuous))
        .shadow(color: .orange.opacity(0.3), radius: 20)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isFloating = true
            }
        }
    }

    private var locationBadge: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "location.fill")
                .font(.caption2)
            Text(location.shortDisplayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.white.opacity(0.9))
        .padding(.horizontal, Spacing.md)
        .frame(height: 28)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .environment(\.colorScheme, .dark)
    }

    private var settingsButton: some View {
        Button {
            showingSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 28, height: 28)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .environment(\.colorScheme, .dark)
        }
    }

    private var foodStatusBadge: some View {
        let (effectiveType, _) = effectiveFoodStatus
        let color = effectiveType == .regular ? Color.green : data.foodStatus.color

        return HStack(spacing: Spacing.xs) {
            Image(systemName: effectiveType.iconName)
                .font(.caption2)
            Text(effectiveType == .regular ? "OK" : effectiveType.shortLabel)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, Spacing.sm)
        .frame(height: 28)
        .background(color.gradient)
        .clipShape(Capsule())
    }

    private var effectiveFoodStatus: (type: FoodStatusType, isVegModified: Bool) {
        if settings.isVegetarian && data.foodStatus.type == .avoidNonVeg {
            return (.regular, true)
        }
        return (data.foodStatus.type, false)
    }

    private var heroBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.5, blue: 0.31).opacity(0.95),
                Color(red: 1.0, green: 0.39, blue: 0.28).opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - FoodStatusType Extension

private extension FoodStatusType {
    var shortLabel: String {
        switch self {
        case .regular: return "OK"
        case .avoidNonVeg: return "Veg"
        case .strictFast: return "Fast"
        case .multipleObservances: return "Special"
        }
    }
}
