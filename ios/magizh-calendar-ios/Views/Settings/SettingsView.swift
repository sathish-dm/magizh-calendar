import SwiftUI

/// Main settings view with all user preferences
struct SettingsView: View {
    @ObservedObject private var settings = SettingsService.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                locationSection
                displaySection
                notificationsSection
                aboutSection
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        Section {
            // Default Location Picker
            Picker("Default Location", selection: $settings.defaultLocation) {
                ForEach(Location.popularLocations) { location in
                    Text(location.displayName).tag(location)
                }
            }

            // Favorite Locations
            NavigationLink {
                FavoriteLocationsView()
            } label: {
                HStack {
                    Text("Favorite Locations")
                    Spacer()
                    Text("\(settings.favoriteLocations.count)")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Location")
        } footer: {
            Text("Default location is used for panchangam calculations when the app opens.")
        }
    }

    // MARK: - Display Section

    private var displaySection: some View {
        Section {
            // Time Format
            Picker("Time Format", selection: $settings.timeFormat) {
                ForEach(TimeFormat.allCases) { format in
                    Text(format.displayName).tag(format)
                }
            }

            // Date Format
            Picker("Date Format", selection: $settings.dateFormat) {
                ForEach(DateFormat.allCases) { format in
                    Text(format.displayName).tag(format)
                }
            }

            // Theme
            Picker("Theme", selection: $settings.theme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }
        } header: {
            Text("Display")
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        Section {
            Toggle("Enable Notifications", isOn: $settings.notificationsEnabled)

            if settings.notificationsEnabled {
                Text("Notification preferences coming soon")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Get notified about auspicious times and special days.")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.appVersion)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Build")
                Spacer()
                Text(Bundle.main.buildNumber)
                    .foregroundStyle(.secondary)
            }

            Button("Reset to Defaults", role: .destructive) {
                settings.resetToDefaults()
            }
        } header: {
            Text("About")
        }
    }
}

// MARK: - Favorite Locations View

struct FavoriteLocationsView: View {
    @ObservedObject private var settings = SettingsService.shared
    @State private var showingAddLocation = false

    var body: some View {
        List {
            if settings.favoriteLocations.isEmpty {
                ContentUnavailableView(
                    "No Favorites",
                    systemImage: "star",
                    description: Text("Add locations for quick access")
                )
            } else {
                ForEach(settings.favoriteLocations) { location in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(location.name)
                                .font(.headline)
                            Text("\(location.city), \(location.country)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if location.id == settings.defaultLocation.id {
                            Text("Default")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.2), in: Capsule())
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        settings.removeFavorite(settings.favoriteLocations[index])
                    }
                }
            }
        }
        .navigationTitle("Favorite Locations")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddLocation = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddLocation) {
            AddFavoriteLocationView()
        }
    }
}

// MARK: - Add Favorite Location View

struct AddFavoriteLocationView: View {
    @ObservedObject private var settings = SettingsService.shared
    @Environment(\.dismiss) private var dismiss

    var availableLocations: [Location] {
        Location.popularLocations.filter { location in
            !settings.favoriteLocations.contains(where: { $0.id == location.id })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if availableLocations.isEmpty {
                    ContentUnavailableView(
                        "All Added",
                        systemImage: "checkmark.circle",
                        description: Text("All available locations are in your favorites")
                    )
                } else {
                    ForEach(availableLocations) { location in
                        Button {
                            settings.addFavorite(location)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(location.name)
                                        .font(.headline)
                                    Text("\(location.city), \(location.country)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Add Location")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - Previews

#Preview("Settings") {
    SettingsView()
}

#Preview("Favorite Locations") {
    NavigationStack {
        FavoriteLocationsView()
    }
}
