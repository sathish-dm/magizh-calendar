import Foundation

/// Translations for calendar-related terms (months, weekdays)
final class CalendarStrings {
    static let shared = CalendarStrings()

    // MARK: - Tamil Month Names (12 months)

    private let monthNames: [AppLanguage: [String: String]] = [
        .english: [
            "Chithirai": "Chithirai",
            "Vaikasi": "Vaikasi",
            "Aani": "Aani",
            "Aadi": "Aadi",
            "Aavani": "Aavani",
            "Purattasi": "Purattasi",
            "Aippasi": "Aippasi",
            "Karthigai": "Karthigai",
            "Margazhi": "Margazhi",
            "Thai": "Thai",
            "Maasi": "Maasi",
            "Panguni": "Panguni"
        ],
        .tamil: [
            "Chithirai": "சித்திரை",
            "Vaikasi": "வைகாசி",
            "Aani": "ஆனி",
            "Aadi": "ஆடி",
            "Aavani": "ஆவணி",
            "Purattasi": "புரட்டாசி",
            "Aippasi": "ஐப்பசி",
            "Karthigai": "கார்த்திகை",
            "Margazhi": "மார்கழி",
            "Thai": "தை",
            "Maasi": "மாசி",
            "Panguni": "பங்குனி"
        ]
    ]

    // MARK: - Weekday Names (7 days)

    private let weekdayNames: [AppLanguage: [String: String]] = [
        .english: [
            "Nyayiru": "Sunday",
            "Thingal": "Monday",
            "Chevvai": "Tuesday",
            "Budhan": "Wednesday",
            "Viyazhan": "Thursday",
            "Velli": "Friday",
            "Sani": "Saturday"
        ],
        .tamil: [
            "Nyayiru": "ஞாயிறு",
            "Thingal": "திங்கள்",
            "Chevvai": "செவ்வாய்",
            "Budhan": "புதன்",
            "Viyazhan": "வியாழன்",
            "Velli": "வெள்ளி",
            "Sani": "சனி"
        ]
    ]

    // MARK: - Helper Methods

    func month(_ englishName: String, for language: AppLanguage) -> String {
        monthNames[language]?[englishName] ?? englishName
    }

    func weekday(_ englishName: String, for language: AppLanguage) -> String {
        weekdayNames[language]?[englishName] ?? englishName
    }
}
