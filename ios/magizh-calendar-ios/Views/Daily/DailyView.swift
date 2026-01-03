import SwiftUI

/// Main daily view displaying panchangam data with iOS 18 Liquid Glass design
/// Follows MVVM pattern with DailyViewModel for state management
struct DailyView: View {

    // MARK: - Properties

    @StateObject private var viewModel = DailyViewModel()
    @ObservedObject private var settings = SettingsService.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var isFloating = false
    @State private var showingSettings = false

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundGradient

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    headerSection

                    if viewModel.isLoading {
                        loadingView
                    } else if let error = viewModel.errorMessage {
                        errorView(message: error)
                    } else if let data = viewModel.panchangamData {
                        contentSection(data: data)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xxxl)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isFloating = true
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(white: 0.1), Color(white: 0.05)]
                : [Color(white: 0.98), Color(white: 0.94)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: Spacing.lg) {
            // Top bar with location and settings
            headerTopBar

            // Main date display
            dateDisplay

            // Tamil date
            tamilDateBadge
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(headerBackground)
    }

    private var headerTopBar: some View {
        HStack {
            // Location badge
            locationBadge

            Spacer()

            // Settings button
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .environment(\.colorScheme, .dark)
            }
        }
    }

    private var locationBadge: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "location.fill")
                .font(.caption2)
            Text(viewModel.currentLocation.shortDisplayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.white.opacity(0.9))
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .environment(\.colorScheme, .dark)
    }

    private var dateDisplay: some View {
        VStack(spacing: Spacing.xs) {
            Text("\(viewModel.selectedDayNumber)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 10)
                .offset(y: isFloating ? -5 : 0)

            Text(viewModel.selectedDateFormatted)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private var tamilDateBadge: some View {
        Group {
            if let data = viewModel.panchangamData {
                Text("\(data.tamilDate.shortFormatted) \u{2022} \(data.vaaram.tamilName)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }

    private var headerBackground: some View {
        RoundedRectangle(cornerRadius: CornerRadius.xxxl, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.5, blue: 0.31).opacity(0.95),
                        Color(red: 1.0, green: 0.39, blue: 0.28).opacity(0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: .orange.opacity(0.3), radius: 20)
            .shadow(color: .black.opacity(0.2), radius: 30, y: 10)
    }

    // MARK: - Content Section

    @ViewBuilder
    private func contentSection(data: PanchangamData) -> some View {
        foodStatusCard(data: data)
        panchangamSection(data: data)
        timingsSection(data: data)
        currentStatusCard(data: data)
        verificationBadge
    }

    // MARK: - Food Status Card

    /// Returns the effective food status considering vegetarian preference
    /// For vegetarians, "Avoid Non-Veg" becomes a regular day since they don't eat non-veg anyway
    private func effectiveFoodStatus(for data: PanchangamData) -> (type: FoodStatusType, isVegModified: Bool) {
        if settings.isVegetarian && data.foodStatus.type == .avoidNonVeg {
            return (.regular, true)
        }
        return (data.foodStatus.type, false)
    }

    private func foodStatusCard(data: PanchangamData) -> some View {
        let (effectiveType, isVegModified) = effectiveFoodStatus(for: data)
        let displayColor = effectiveType == .regular ? Color.green : data.foodStatus.color

        return GlassCard(glowColor: displayColor) {
            HStack(alignment: .top, spacing: Spacing.lg) {
                // Icon
                foodStatusIcon(type: effectiveType, color: displayColor)

                // Content
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(effectiveType == .regular ? "Regular Day" : data.foodStatus.shortMessage)
                        .font(.headline)
                        .fontWeight(.semibold)

                    // Subtitle based on vegetarian status
                    if settings.isVegetarian {
                        if isVegModified {
                            // Was "Avoid Non-Veg" but user is vegetarian
                            Text("No dietary concerns")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else if effectiveType == .regular {
                            Text("No special observances today")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else if effectiveType == .strictFast {
                            Text(data.foodStatus.type.defaultReason)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        // Non-vegetarian user - show full messages
                        Text(effectiveType == .regular
                             ? "Safe to cook non-veg"
                             : data.foodStatus.type.defaultReason)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Next auspicious day badge (show for all users)
                    if let next = data.nextAuspiciousDay {
                        nextAuspiciousBadge(day: next, isVegetarian: settings.isVegetarian)
                    }

                    // Storage warning (only for non-vegetarians with non-regular status)
                    if !settings.isVegetarian && data.foodStatus.type != .regular {
                        Text("Avoid storing overnight")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, Spacing.xs)
                    }
                }

                Spacer()
            }
        }
    }

    private func foodStatusIcon(type: FoodStatusType, color: Color) -> some View {
        let iconName = type == .regular ? "checkmark.circle.fill" : type.iconName

        return Image(systemName: iconName)
            .font(.title2)
            .foregroundStyle(color)
            .frame(width: 48, height: 48)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                    .fill(color.opacity(0.15))
            )
    }

    private func nextAuspiciousBadge(day: AuspiciousDay, isVegetarian: Bool) -> some View {
        // For vegetarians, only show fasting-related upcoming days, not "avoid non-veg" warnings
        let showWarning = !isVegetarian || day.type.foodRestriction == .strictFast

        return Group {
            if showWarning {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: day.type.foodRestriction == .strictFast ? "moon.stars.fill" : "exclamationmark.triangle.fill")
                        .font(.caption2)
                    Text("\(day.name) (\(day.daysUntilFormatted))")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(day.type.foodRestriction == .strictFast ? .purple : .orange)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background((day.type.foodRestriction == .strictFast ? Color.purple : Color.orange).opacity(0.15))
                .clipShape(Capsule())
                .padding(.top, Spacing.xs)
            } else {
                // For vegetarians when next day is just "avoid non-veg", show as upcoming observance info
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text("Upcoming: \(day.name) (\(day.daysUntilFormatted))")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.blue)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color.blue.opacity(0.15))
                .clipShape(Capsule())
                .padding(.top, Spacing.xs)
            }
        }
    }

    // MARK: - Panchangam Section

    private func panchangamSection(data: PanchangamData) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Header
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(.orange)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm, style: .continuous)
                                .fill(Color.orange.opacity(0.15))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today's Panchangam")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("Five Elements of Time")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Angams
                VStack(spacing: Spacing.md) {
                    angamRow(
                        icon: "star.fill",
                        label: "Nakshatram",
                        value: data.nakshatram.name.tamilName,
                        endTime: data.nakshatram.endTimeFormatted,
                        accentColor: .purple
                    )

                    angamRow(
                        icon: "moon.fill",
                        label: "Thithi",
                        value: "\(data.thithi.name.tamilName) (\(data.thithi.paksha.rawValue))",
                        endTime: data.thithi.endTimeFormatted,
                        accentColor: .blue
                    )

                    yogamRow(yogam: data.yogam)

                    angamRow(
                        icon: "arrow.triangle.2.circlepath",
                        label: "Karanam",
                        value: data.karanam.name.tamilName,
                        endTime: data.karanam.endTimeFormatted,
                        accentColor: .indigo
                    )

                    sunriseSunsetRow(data: data)
                }
            }
        }
    }

    private func angamRow(
        icon: String,
        label: String,
        value: String,
        endTime: String,
        accentColor: Color
    ) -> some View {
        HStack(spacing: Spacing.md) {
            // Left accent border
            Rectangle()
                .fill(accentColor)
                .frame(width: 4)

            // Icon
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(accentColor)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm, style: .continuous)
                        .fill(accentColor.opacity(0.1))
                )

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Spacer()

            // End time badge
            Text("Ends \(endTime)")
                .font(.caption2)
                .foregroundStyle(accentColor)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(accentColor.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    private func yogamRow(yogam: Yogam) -> some View {
        let color = yogam.type.color

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                // Left accent border
                Rectangle()
                    .fill(color)
                    .frame(width: 4)

                // Icon
                Image(systemName: "sparkles")
                    .font(.callout)
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm, style: .continuous)
                            .fill(color.opacity(0.1))
                    )

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text("Yogam")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(yogam.name.tamilName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                // Auspicious/Avoid badge
                Text(yogam.type.label)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        Capsule()
                            .fill(color.gradient)
                            .shadow(color: color.opacity(0.3), radius: 8)
                    )
            }

            // Time range
            Text(yogam.timeRangeFormatted)
                .font(.caption)
                .foregroundStyle(color)
                .padding(.leading, 52)

            // Recommendation
            if yogam.type == .auspicious {
                Text("Excellent for: New ventures, important decisions")
                    .font(.caption2)
                    .foregroundStyle(color)
                    .padding(Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm, style: .continuous)
                            .fill(color.opacity(0.1))
                    )
                    .padding(.leading, 52)
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.15), radius: 10)
    }

    private func sunriseSunsetRow(data: PanchangamData) -> some View {
        HStack(spacing: Spacing.xl) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "sunrise.fill")
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sunrise")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(data.sunriseFormatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }

            Divider()
                .frame(height: 32)

            HStack(spacing: Spacing.sm) {
                Image(systemName: "sunset.fill")
                    .foregroundStyle(.indigo)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sunset")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(data.sunsetFormatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }

            Spacer()

            Text(data.dayLengthFormatted)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Timings Section

    private func timingsSection(data: PanchangamData) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Header
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.orange)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm, style: .continuous)
                                .fill(Color.orange.opacity(0.15))
                        )

                    Text("Auspicious Timings")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                // Timings
                VStack(spacing: Spacing.md) {
                    if let firstNallaNeram = data.nallaNeram.first {
                        timingRow(
                            type: .nallaNeram,
                            timeRange: firstNallaNeram,
                            badgeText: "Best Time"
                        )
                    }

                    timingRow(
                        type: .rahukaalam,
                        timeRange: data.rahukaalam,
                        badgeText: "Avoid"
                    )

                    timingRow(
                        type: .yamagandam,
                        timeRange: data.yamagandam,
                        badgeText: "Caution"
                    )
                }
            }
        }
    }

    private func timingRow(
        type: TimeRangeType,
        timeRange: TimeRange,
        badgeText: String
    ) -> some View {
        let color: Color = type.isAuspicious ? .green : (type == .rahukaalam ? .red : .orange)

        return HStack {
            // Left accent
            Rectangle()
                .fill(color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Image(systemName: type.iconName)
                        .foregroundStyle(color)
                    Text(type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Text(badgeText)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(color)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(color.opacity(0.15))
                        .clipShape(Capsule())
                }

                Text(timeRange.formatted)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)

                if timeRange.isCurrentlyActive {
                    if let remaining = timeRange.timeRemainingFormatted {
                        Text(remaining)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.leading, Spacing.sm)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Current Status Card

    @ViewBuilder
    private func currentStatusCard(data: PanchangamData) -> some View {
        if data.yogam.isActive() {
            VStack(spacing: Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Current Status")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))

                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "sparkles")
                            Text("\(data.yogam.name.tamilName) Active")
                                .fontWeight(.semibold)
                        }
                        .font(.title3)
                        .foregroundStyle(.white)

                        if let statusText = viewModel.yogamStatusText {
                            Text(statusText)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xs)
                                .background(.white.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }

                    Spacer()

                    // Current time
                    VStack(alignment: .trailing) {
                        Text(Date(), style: .time)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .offset(y: isFloating ? -3 : 0)
                    }
                }
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.xxl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.5, blue: 0.31).opacity(0.95),
                                Color(red: 1.0, green: 0.39, blue: 0.28).opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: .orange.opacity(0.3), radius: 20)
            .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
        }
    }

    // MARK: - Verification Badge

    private var verificationBadge: some View {
        GlassCard(cornerRadius: CornerRadius.xxl, padding: Spacing.md) {
            HStack(spacing: Spacing.md) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                            .fill(Color.green.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Verified Panchangam Data")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)

                    Text("Thirukanitha method \u{2022} Traditional sources")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    // MARK: - Loading & Error States

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading panchangam...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxxl)
    }

    private func errorView(message: String) -> some View {
        GlassCard(glowColor: .red) {
            VStack(spacing: Spacing.md) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.red)

                Text("Unable to Load")
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button(action: viewModel.retry) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
        }
    }
}

// MARK: - Preview

#Preview("Daily View") {
    DailyView()
}

#Preview("Daily View - Dark") {
    DailyView()
        .preferredColorScheme(.dark)
}
