import Foundation

/// Keys for all localizable UI strings
enum LocalizedStringKey: String, CaseIterable {
    // Navigation & Headers
    case todaysPanchangam
    case fiveElementsOfTime
    case auspiciousTimings
    case currentStatus
    case settings
    case done
    case cancel

    // Panchangam Labels
    case nakshatram
    case thithi
    case yogam
    case karanam
    case vaaram
    case sunrise
    case sunset
    case dayLength
    case ends

    // Time Periods
    case nallaNeram
    case rahukaalam
    case yamagandam
    case kuligai

    // Status Labels
    case auspicious
    case inauspicious
    case neutral
    case avoid
    case bestTime
    case caution
    case remaining
    case active

    // Food Status
    case regularDay
    case avoidNonVeg
    case fastingDay
    case specialDay
    case noDietaryConcerns
    case safeToCoookNonVeg
    case avoidStoringOvernight
    case noSpecialObservances

    // Settings
    case location
    case defaultLocation
    case favoriteLocations
    case display
    case timeFormat
    case dateFormat
    case theme
    case language
    case foodPreferences
    case iAmVegetarian
    case nonVegAlertsHidden
    case notifications
    case enableNotifications
    case about
    case version
    case build
    case resetToDefaults

    // Settings Footers
    case defaultLocationFooter
    case vegetarianFooter
    case notificationsFooter

    // Favorite Locations
    case noFavorites
    case addLocationsForQuickAccess
    case allAdded
    case allLocationsInFavorites
    case addLocation
    case defaultBadge

    // Verification
    case verifiedPanchangamData
    case thirukanithaMethod

    // Loading & Errors
    case loadingPanchangam
    case unableToLoad
    case tryAgain

    // Yogam Recommendations
    case excellentForNewVentures
    case notificationPreferencesComingSoon

    // Misc
    case upcoming
    case today
    case tomorrow
    case paksha
    case shukla
    case krishna
    case waxingMoon
    case waningMoon
}

/// Container for all UI string translations
final class UIStrings {
    static let shared = UIStrings()

    private let translations: [AppLanguage: [LocalizedStringKey: String]] = [
        .english: [
            // Navigation & Headers
            .todaysPanchangam: "Today's Panchangam",
            .fiveElementsOfTime: "Five Elements of Time",
            .auspiciousTimings: "Auspicious Timings",
            .currentStatus: "Current Status",
            .settings: "Settings",
            .done: "Done",
            .cancel: "Cancel",

            // Panchangam Labels
            .nakshatram: "Nakshatram",
            .thithi: "Thithi",
            .yogam: "Yogam",
            .karanam: "Karanam",
            .vaaram: "Vaaram",
            .sunrise: "Sunrise",
            .sunset: "Sunset",
            .dayLength: "Day Length",
            .ends: "Ends",

            // Time Periods
            .nallaNeram: "Nalla Neram",
            .rahukaalam: "Rahukaalam",
            .yamagandam: "Yamagandam",
            .kuligai: "Kuligai",

            // Status Labels
            .auspicious: "AUSPICIOUS",
            .inauspicious: "INAUSPICIOUS",
            .neutral: "NEUTRAL",
            .avoid: "Avoid",
            .bestTime: "Best Time",
            .caution: "Caution",
            .remaining: "remaining",
            .active: "Active",

            // Food Status
            .regularDay: "Regular Day",
            .avoidNonVeg: "Avoid Non-Veg",
            .fastingDay: "Fasting Day",
            .specialDay: "Special Day",
            .noDietaryConcerns: "No dietary concerns",
            .safeToCoookNonVeg: "Safe to cook non-veg",
            .avoidStoringOvernight: "Avoid storing overnight",
            .noSpecialObservances: "No special observances today",

            // Settings
            .location: "Location",
            .defaultLocation: "Default Location",
            .favoriteLocations: "Favorite Locations",
            .display: "Display",
            .timeFormat: "Time Format",
            .dateFormat: "Date Format",
            .theme: "Theme",
            .language: "Language",
            .foodPreferences: "Food Preferences",
            .iAmVegetarian: "I am Vegetarian",
            .nonVegAlertsHidden: "Non-veg alerts hidden",
            .notifications: "Notifications",
            .enableNotifications: "Enable Notifications",
            .about: "About",
            .version: "Version",
            .build: "Build",
            .resetToDefaults: "Reset to Defaults",

            // Settings Footers
            .defaultLocationFooter: "Default location is used for panchangam calculations when the app opens.",
            .vegetarianFooter: "When enabled, alerts about avoiding non-veg food will be hidden since they don't apply to you.",
            .notificationsFooter: "Get notified about auspicious times and special days.",

            // Favorite Locations
            .noFavorites: "No Favorites",
            .addLocationsForQuickAccess: "Add locations for quick access",
            .allAdded: "All Added",
            .allLocationsInFavorites: "All available locations are in your favorites",
            .addLocation: "Add Location",
            .defaultBadge: "Default",

            // Verification
            .verifiedPanchangamData: "Verified Panchangam Data",
            .thirukanithaMethod: "Thirukanitha method \u{2022} Traditional sources",

            // Loading & Errors
            .loadingPanchangam: "Loading panchangam...",
            .unableToLoad: "Unable to Load",
            .tryAgain: "Try Again",

            // Yogam Recommendations
            .excellentForNewVentures: "Excellent for: New ventures, important decisions",
            .notificationPreferencesComingSoon: "Notification preferences coming soon",

            // Misc
            .upcoming: "Upcoming",
            .today: "Today",
            .tomorrow: "Tomorrow",
            .paksha: "Paksha",
            .shukla: "Shukla",
            .krishna: "Krishna",
            .waxingMoon: "Waxing Moon",
            .waningMoon: "Waning Moon"
        ],

        .tamil: [
            // Navigation & Headers
            .todaysPanchangam: "இன்றைய பஞ்சாங்கம்",
            .fiveElementsOfTime: "ஐந்து அங்கங்கள்",
            .auspiciousTimings: "நல்ல நேரங்கள்",
            .currentStatus: "தற்போதைய நிலை",
            .settings: "அமைப்புகள்",
            .done: "முடிந்தது",
            .cancel: "ரத்து",

            // Panchangam Labels
            .nakshatram: "நட்சத்திரம்",
            .thithi: "திதி",
            .yogam: "யோகம்",
            .karanam: "கரணம்",
            .vaaram: "வாரம்",
            .sunrise: "சூரிய உதயம்",
            .sunset: "சூரிய அஸ்தமனம்",
            .dayLength: "பகல் நேரம்",
            .ends: "முடிவு",

            // Time Periods
            .nallaNeram: "நல்ல நேரம்",
            .rahukaalam: "ராகு காலம்",
            .yamagandam: "எமகண்டம்",
            .kuligai: "குளிகை",

            // Status Labels
            .auspicious: "நல்லது",
            .inauspicious: "தவிர்க்கவும்",
            .neutral: "சாதாரணம்",
            .avoid: "தவிர்க்கவும்",
            .bestTime: "சிறந்த நேரம்",
            .caution: "எச்சரிக்கை",
            .remaining: "மீதம்",
            .active: "செயலில்",

            // Food Status
            .regularDay: "சாதாரண நாள்",
            .avoidNonVeg: "அசைவம் தவிர்க்கவும்",
            .fastingDay: "விரத நாள்",
            .specialDay: "விசேஷ நாள்",
            .noDietaryConcerns: "உணவுக் கட்டுப்பாடு இல்லை",
            .safeToCoookNonVeg: "அசைவம் சமைக்கலாம்",
            .avoidStoringOvernight: "இரவு முழுவதும் சேமிக்க வேண்டாம்",
            .noSpecialObservances: "இன்று விசேஷ நாள் இல்லை",

            // Settings
            .location: "இடம்",
            .defaultLocation: "இயல்புநிலை இடம்",
            .favoriteLocations: "பிடித்த இடங்கள்",
            .display: "காட்சி",
            .timeFormat: "நேர வடிவம்",
            .dateFormat: "தேதி வடிவம்",
            .theme: "தீம்",
            .language: "மொழி",
            .foodPreferences: "உணவு விருப்பங்கள்",
            .iAmVegetarian: "நான் சைவம்",
            .nonVegAlertsHidden: "அசைவ எச்சரிக்கைகள் மறைக்கப்பட்டன",
            .notifications: "அறிவிப்புகள்",
            .enableNotifications: "அறிவிப்புகளை இயக்கு",
            .about: "பற்றி",
            .version: "பதிப்பு",
            .build: "உருவாக்கம்",
            .resetToDefaults: "இயல்புநிலைக்கு மீட்டமை",

            // Settings Footers
            .defaultLocationFooter: "செயலி திறக்கும்போது பஞ்சாங்க கணக்கீட்டிற்கு இந்த இடம் பயன்படுத்தப்படும்.",
            .vegetarianFooter: "இயக்கப்படும்போது, அசைவ உணவு தவிர்க்க வேண்டிய எச்சரிக்கைகள் மறைக்கப்படும்.",
            .notificationsFooter: "நல்ல நேரங்கள் மற்றும் விசேஷ நாட்கள் பற்றி அறிவிப்புகள் பெறுங்கள்.",

            // Favorite Locations
            .noFavorites: "பிடித்தவை இல்லை",
            .addLocationsForQuickAccess: "விரைவான அணுகலுக்கு இடங்களைச் சேர்க்கவும்",
            .allAdded: "அனைத்தும் சேர்க்கப்பட்டன",
            .allLocationsInFavorites: "கிடைக்கும் அனைத்து இடங்களும் உங்கள் பிடித்தவையில் உள்ளன",
            .addLocation: "இடம் சேர்",
            .defaultBadge: "இயல்புநிலை",

            // Verification
            .verifiedPanchangamData: "சரிபார்க்கப்பட்ட பஞ்சாங்கம்",
            .thirukanithaMethod: "திருக்கணித முறை \u{2022} பாரம்பரிய ஆதாரங்கள்",

            // Loading & Errors
            .loadingPanchangam: "பஞ்சாங்கம் ஏற்றப்படுகிறது...",
            .unableToLoad: "ஏற்ற முடியவில்லை",
            .tryAgain: "மீண்டும் முயற்சிக்கவும்",

            // Yogam Recommendations
            .excellentForNewVentures: "சிறந்தது: புதிய முயற்சிகள், முக்கிய முடிவுகள்",
            .notificationPreferencesComingSoon: "அறிவிப்பு விருப்பங்கள் விரைவில் வரும்",

            // Misc
            .upcoming: "வரவிருக்கும்",
            .today: "இன்று",
            .tomorrow: "நாளை",
            .paksha: "பக்ஷம்",
            .shukla: "சுக்ல",
            .krishna: "கிருஷ்ண",
            .waxingMoon: "வளர்பிறை",
            .waningMoon: "தேய்பிறை"
        ]
    ]

    func get(_ key: LocalizedStringKey, for language: AppLanguage) -> String {
        translations[language]?[key] ?? translations[.english]?[key] ?? key.rawValue
    }
}
