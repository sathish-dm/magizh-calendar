import Foundation
import SwiftUI
import Combine

/// Service for managing user settings with UserDefaults persistence
@MainActor
final class SettingsService: ObservableObject {

    // MARK: - Singleton

    static let shared = SettingsService()

    // MARK: - Storage Keys

    private enum Keys {
        static let defaultLocation = "defaultLocation"
        static let timeFormat = "timeFormat"
        static let dateFormat = "dateFormat"
        static let theme = "theme"
        static let notificationsEnabled = "notificationsEnabled"
        static let favoriteLocations = "favoriteLocations"
        static let lastViewedDate = "lastViewedDate"
    }

    // MARK: - Published Properties

    @Published var timeFormat: TimeFormat {
        didSet { UserDefaults.standard.set(timeFormat.rawValue, forKey: Keys.timeFormat) }
    }

    @Published var dateFormat: DateFormat {
        didSet { UserDefaults.standard.set(dateFormat.rawValue, forKey: Keys.dateFormat) }
    }

    @Published var theme: AppTheme {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: Keys.theme) }
    }

    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled) }
    }

    @Published var defaultLocation: Location {
        didSet {
            if let data = try? JSONEncoder().encode(defaultLocation) {
                UserDefaults.standard.set(data, forKey: Keys.defaultLocation)
            }
        }
    }

    @Published var favoriteLocations: [Location] {
        didSet {
            if let data = try? JSONEncoder().encode(favoriteLocations) {
                UserDefaults.standard.set(data, forKey: Keys.favoriteLocations)
            }
        }
    }

    var lastViewedDate: Date {
        get { Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: Keys.lastViewedDate)) }
        set { UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: Keys.lastViewedDate) }
    }

    // MARK: - Initialization

    private init() {
        // Load time format
        if let rawValue = UserDefaults.standard.string(forKey: Keys.timeFormat),
           let format = TimeFormat(rawValue: rawValue) {
            self.timeFormat = format
        } else {
            self.timeFormat = .twelveHour
        }

        // Load date format
        if let rawValue = UserDefaults.standard.string(forKey: Keys.dateFormat),
           let format = DateFormat(rawValue: rawValue) {
            self.dateFormat = format
        } else {
            self.dateFormat = .full
        }

        // Load theme
        if let rawValue = UserDefaults.standard.string(forKey: Keys.theme),
           let appTheme = AppTheme(rawValue: rawValue) {
            self.theme = appTheme
        } else {
            self.theme = .system
        }

        // Load notifications enabled
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)

        // Load default location
        if let data = UserDefaults.standard.data(forKey: Keys.defaultLocation),
           let location = try? JSONDecoder().decode(Location.self, from: data) {
            self.defaultLocation = location
        } else {
            self.defaultLocation = .chennai
        }

        // Load favorite locations
        if let data = UserDefaults.standard.data(forKey: Keys.favoriteLocations),
           let locations = try? JSONDecoder().decode([Location].self, from: data) {
            self.favoriteLocations = locations
        } else {
            self.favoriteLocations = []
        }
    }

    // MARK: - Favorite Locations Management

    /// Add a location to favorites
    func addFavorite(_ location: Location) {
        guard !favoriteLocations.contains(where: { $0.id == location.id }) else { return }
        favoriteLocations.append(location)
    }

    /// Remove a location from favorites
    func removeFavorite(_ location: Location) {
        favoriteLocations.removeAll { $0.id == location.id }
    }

    /// Check if a location is in favorites
    func isFavorite(_ location: Location) -> Bool {
        favoriteLocations.contains(where: { $0.id == location.id })
    }

    /// Toggle favorite status
    func toggleFavorite(_ location: Location) {
        if isFavorite(location) {
            removeFavorite(location)
        } else {
            addFavorite(location)
        }
    }

    // MARK: - Formatting Helpers

    /// Format a date using the user's preferred format
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.dateFormatString
        return formatter.string(from: date)
    }

    /// Format a time using the user's preferred format
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = timeFormat.dateFormatString
        return formatter.string(from: date)
    }

    /// Format a time range using the user's preferred format
    func formatTimeRange(start: Date, end: Date) -> String {
        "\(formatTime(start)) - \(formatTime(end))"
    }

    // MARK: - Reset

    /// Reset all settings to defaults
    func resetToDefaults() {
        defaultLocation = .chennai
        timeFormat = .twelveHour
        dateFormat = .full
        theme = .system
        notificationsEnabled = false
        favoriteLocations = []
    }
}
