import SwiftUI

/// A reusable glass card component following iOS 18 Liquid Glass design language
/// Used as the base component for all cards throughout the app
///
/// Features:
/// - Translucent material background
/// - Multiple shadow layers for depth
/// - Optional glow effect for emphasis
/// - Smooth corner radius
/// - Dark mode support
///
/// Usage:
/// ```swift
/// GlassCard {
///     Text("Your content here")
/// }
///
/// GlassCard(glowColor: .green) {
///     YogamCardContent()
/// }
/// ```
struct GlassCard<Content: View>: View {
    // MARK: - Properties

    let content: Content
    let glowColor: Color?
    let cornerRadius: CGFloat
    let padding: CGFloat
    let material: Material

    // MARK: - Environment

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Initialization

    /// Creates a glass card with customizable properties
    /// - Parameters:
    ///   - glowColor: Optional color for glow effect (used for emphasis cards like Yogam)
    ///   - cornerRadius: Corner radius of the card (default: 24)
    ///   - padding: Internal padding of the card (default: 16)
    ///   - material: SwiftUI Material to use (default: .regularMaterial)
    ///   - content: The content to display inside the card
    init(
        glowColor: Color? = nil,
        cornerRadius: CGFloat = CornerRadius.xxl,
        padding: CGFloat = Spacing.lg,
        material: Material = .regularMaterial,
        @ViewBuilder content: () -> Content
    ) {
        self.glowColor = glowColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.material = material
        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        content
            .padding(padding)
            .background(cardBackground)
            .compositingGroup()
            .shadow(
                color: glowShadowColor,
                radius: glowColor != nil ? 20 : 0
            )
            .shadow(
                color: depthShadowColor,
                radius: 20,
                x: 0,
                y: 8
            )
            .shadow(
                color: secondaryDepthShadowColor,
                radius: 40,
                x: 0,
                y: 16
            )
    }

    // MARK: - View Components

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(material)
            .overlay(borderOverlay)
            .overlay(glowBorderOverlay)
    }

    /// White border overlay for glass effect
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                borderGradient,
                lineWidth: 1
            )
    }

    /// Colored border overlay when glow is enabled
    @ViewBuilder
    private var glowBorderOverlay: some View {
        if let glowColor = glowColor {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    glowColor.opacity(0.3),
                    lineWidth: 2
                )
        }
    }

    // MARK: - Computed Colors

    /// Gradient for the border (top-light, bottom-darker)
    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(colorScheme == .dark ? 0.2 : 0.4),
                Color.white.opacity(colorScheme == .dark ? 0.05 : 0.15)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Glow shadow color (if glow is enabled)
    private var glowShadowColor: Color {
        glowColor?.opacity(0.3) ?? .clear
    }

    /// Primary depth shadow
    private var depthShadowColor: Color {
        colorScheme == .dark
            ? Color.black.opacity(0.3)
            : Color.black.opacity(0.1)
    }

    /// Secondary (softer) depth shadow
    private var secondaryDepthShadowColor: Color {
        colorScheme == .dark
            ? Color.black.opacity(0.15)
            : Color.black.opacity(0.05)
    }
}

// MARK: - Design System Tokens

/// Spacing constants for consistent layout
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

/// Corner radius constants
enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

// MARK: - View Modifier Alternative

/// View modifier for applying glass card style to any view
struct GlassCardModifier: ViewModifier {
    let glowColor: Color?
    let cornerRadius: CGFloat
    let material: Material

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(material)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                Color.white.opacity(colorScheme == .dark ? 0.15 : 0.3),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: glowColor?.opacity(0.3) ?? .clear,
                radius: glowColor != nil ? 20 : 0
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                radius: 20,
                x: 0,
                y: 8
            )
    }
}

extension View {
    /// Applies glass card styling to any view
    /// - Parameters:
    ///   - glowColor: Optional glow color for emphasis
    ///   - cornerRadius: Corner radius (default: 24)
    ///   - material: Material to use (default: .regularMaterial)
    func glassCard(
        glowColor: Color? = nil,
        cornerRadius: CGFloat = CornerRadius.xxl,
        material: Material = .regularMaterial
    ) -> some View {
        modifier(GlassCardModifier(
            glowColor: glowColor,
            cornerRadius: cornerRadius,
            material: material
        ))
    }
}

// MARK: - Preview

#Preview("Glass Card - Default") {
    ZStack {
        LinearGradient(
            colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: Spacing.lg) {
            GlassCard {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Label("Today's Panchangam", systemImage: "sun.max.fill")
                        .font(.headline)

                    Text("Rohini Nakshatram until 2:45 PM")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GlassCard(glowColor: .green) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("Yogam")
                            .font(.caption)
                            .foregroundStyle(.green)

                        Spacer()

                        Text("AUSPICIOUS")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.green.gradient))
                    }

                    Text("Siddhi Yogam")
                        .font(.headline)
                        .fontWeight(.bold)

                    Text("8:30 AM - 2:15 PM")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GlassCard(glowColor: .red) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("Yogam")
                            .font(.caption)
                            .foregroundStyle(.red)

                        Spacer()

                        Text("AVOID")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.red.gradient))
                    }

                    Text("Vyatipata Yogam")
                        .font(.headline)
                        .fontWeight(.bold)

                    Text("Avoid important activities")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}

#Preview("Glass Card - Dark Mode") {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: Spacing.lg) {
            GlassCard {
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.orange)
                    Text("Regular Day - No Restrictions")
                        .font(.subheadline)
                    Spacer()
                }
            }

            GlassCard(glowColor: .orange, material: .thinMaterial) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Tomorrow")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Pradosham")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("Avoid non-veg tonight")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("Glass Card - Materials") {
    ZStack {
        LinearGradient(
            colors: [.purple, .blue, .teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: Spacing.md) {
            GlassCard(material: .ultraThinMaterial) {
                Text("Ultra Thin Material")
                    .frame(maxWidth: .infinity)
            }

            GlassCard(material: .thinMaterial) {
                Text("Thin Material")
                    .frame(maxWidth: .infinity)
            }

            GlassCard {
                Text("Regular Material (Default)")
                    .frame(maxWidth: .infinity)
            }

            GlassCard(material: .thickMaterial) {
                Text("Thick Material")
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
    }
}
