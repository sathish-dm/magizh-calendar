import SwiftUI

/// Badge showing the data source (API or Mock)
/// Only visible in debug builds
struct DataSourceBadge: View {
    let isUsingMockData: Bool

    var body: some View {
        #if DEBUG
        HStack(spacing: 4) {
            Circle()
                .fill(isUsingMockData ? Color.orange : Color.green)
                .frame(width: 6, height: 6)

            Text(isUsingMockData ? "Mock Data" : "Live API")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(isUsingMockData ? Color.orange.opacity(0.5) : Color.green.opacity(0.5), lineWidth: 1)
        )
        #else
        EmptyView()
        #endif
    }
}

/// Environment badge showing current environment
/// Only visible in non-production builds
struct EnvironmentBadge: View {
    var body: some View {
        #if DEBUG
        if AppEnvironment.current != .production {
            Text(AppEnvironment.current.displayName.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.purple.opacity(0.8), in: Capsule())
                .foregroundColor(.white)
        }
        #endif
    }
}

#Preview("Data Source Badges") {
    VStack(spacing: 20) {
        DataSourceBadge(isUsingMockData: false)
        DataSourceBadge(isUsingMockData: true)
        EnvironmentBadge()
    }
    .padding()
    .background(Color.black)
}
