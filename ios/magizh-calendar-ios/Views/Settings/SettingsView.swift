import SwiftUI

/// Main settings view with all user preferences
struct SettingsView: View {
    @ObservedObject private var settings = SettingsService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingLocationSearch = false

    var body: some View {
        NavigationStack {
            Form {
                languageSection
                locationSection
                displaySection
                foodPreferencesSection
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
            .sheet(isPresented: $showingLocationSearch) {
                NavigationStack {
                    LocationSearchView(mode: .setDefault) { _ in
                        showingLocationSearch = false
                    }
                }
            }
        }
    }

    // MARK: - Language Section

    private var languageSection: some View {
        Section {
            Picker("Language", selection: $settings.language) {
                ForEach(AppLanguage.allCases) { language in
                    HStack {
                        Text(language.displayName)
                        if language == .tamil {
                            Text("(Tamil)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tag(language)
                }
            }
        } header: {
            Text("Language")
        } footer: {
            Text("Change the app display language. Panchangam names will be shown in the selected language.")
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        Section {
            // Default Location - Search (opens as sheet)
            Button {
                showingLocationSearch = true
            } label: {
                HStack {
                    Text("Default Location")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(settings.defaultLocation.shortDisplayName)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
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
            Text("Search any city worldwide. Timezone is automatically detected.")
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

            // Timezone Display
            Picker("Timezone Display", selection: $settings.timezoneDisplayMode) {
                ForEach(TimezoneDisplayMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
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
        } footer: {
            Text(settings.timezoneDisplayMode.description)
        }
    }

    // MARK: - Food Preferences Section

    private var foodPreferencesSection: some View {
        Section {
            Toggle("I am Vegetarian", isOn: $settings.isVegetarian)

            if settings.isVegetarian {
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.green)
                    Text("Non-veg alerts hidden")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Food Preferences")
        } footer: {
            Text("When enabled, alerts about avoiding non-veg food will be hidden since they don't apply to you.")
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
    var body: some View {
        NavigationStack {
            LocationSearchView(mode: .addFavorite)
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
