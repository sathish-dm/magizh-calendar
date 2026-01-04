import Foundation

/// Translations for all Panchangam terminology
final class PanchangamStrings {
    static let shared = PanchangamStrings()

    // MARK: - Nakshatram Names (27 stars)

    private let nakshatramNames: [AppLanguage: [String: String]] = [
        .english: [
            "Ashwini": "Ashwini",
            "Bharani": "Bharani",
            "Krithigai": "Krithigai",
            "Rohini": "Rohini",
            "Mrigashirisham": "Mrigashirisham",
            "Thiruvathirai": "Thiruvathirai",
            "Punarpoosam": "Punarpoosam",
            "Poosam": "Poosam",
            "Ayilyam": "Ayilyam",
            "Magam": "Magam",
            "Pooram": "Pooram",
            "Uthiram": "Uthiram",
            "Hastham": "Hastham",
            "Chithirai": "Chithirai",
            "Swathi": "Swathi",
            "Visagam": "Visagam",
            "Anusham": "Anusham",
            "Kettai": "Kettai",
            "Moolam": "Moolam",
            "Pooradam": "Pooradam",
            "Uthiradam": "Uthiradam",
            "Thiruvonam": "Thiruvonam",
            "Avittam": "Avittam",
            "Sathayam": "Sathayam",
            "Poorattathi": "Poorattathi",
            "Uthirattathi": "Uthirattathi",
            "Revathi": "Revathi"
        ],
        .tamil: [
            "Ashwini": "அசுவினி",
            "Bharani": "பரணி",
            "Krithigai": "கார்த்திகை",
            "Rohini": "ரோகிணி",
            "Mrigashirisham": "மிருகசீரிடம்",
            "Thiruvathirai": "திருவாதிரை",
            "Punarpoosam": "புனர்பூசம்",
            "Poosam": "பூசம்",
            "Ayilyam": "ஆயில்யம்",
            "Magam": "மகம்",
            "Pooram": "பூரம்",
            "Uthiram": "உத்திரம்",
            "Hastham": "அஸ்தம்",
            "Chithirai": "சித்திரை",
            "Swathi": "சுவாதி",
            "Visagam": "விசாகம்",
            "Anusham": "அனுஷம்",
            "Kettai": "கேட்டை",
            "Moolam": "மூலம்",
            "Pooradam": "பூராடம்",
            "Uthiradam": "உத்திராடம்",
            "Thiruvonam": "திருவோணம்",
            "Avittam": "அவிட்டம்",
            "Sathayam": "சதயம்",
            "Poorattathi": "பூரட்டாதி",
            "Uthirattathi": "உத்திரட்டாதி",
            "Revathi": "ரேவதி"
        ]
    ]

    // MARK: - Thithi Names (16 thithis)

    private let thithiNames: [AppLanguage: [String: String]] = [
        .english: [
            "Prathama": "Prathama",
            "Dvitiya": "Dvitiya",
            "Tritiya": "Tritiya",
            "Chaturthi": "Chaturthi",
            "Panchami": "Panchami",
            "Sashti": "Sashti",
            "Saptami": "Saptami",
            "Ashtami": "Ashtami",
            "Navami": "Navami",
            "Dasami": "Dasami",
            "Ekadasi": "Ekadasi",
            "Dvadasi": "Dvadasi",
            "Trayodasi": "Trayodasi",
            "Chaturdasi": "Chaturdasi",
            "Pournami": "Pournami",
            "Amavasai": "Amavasai"
        ],
        .tamil: [
            "Prathama": "பிரதமை",
            "Dvitiya": "துவிதியை",
            "Tritiya": "திருதியை",
            "Chaturthi": "சதுர்த்தி",
            "Panchami": "பஞ்சமி",
            "Sashti": "சஷ்டி",
            "Saptami": "சப்தமி",
            "Ashtami": "அஷ்டமி",
            "Navami": "நவமி",
            "Dasami": "தசமி",
            "Ekadasi": "ஏகாதசி",
            "Dvadasi": "துவாதசி",
            "Trayodasi": "திரயோதசி",
            "Chaturdasi": "சதுர்தசி",
            "Pournami": "பௌர்ணமி",
            "Amavasai": "அமாவாசை"
        ]
    ]

    // MARK: - Paksha Names

    private let pakshaNames: [AppLanguage: [String: String]] = [
        .english: [
            "Shukla": "Shukla",
            "Krishna": "Krishna"
        ],
        .tamil: [
            "Shukla": "வளர்பிறை",
            "Krishna": "தேய்பிறை"
        ]
    ]

    // MARK: - Yogam Names (27 yogams)

    private let yogamNames: [AppLanguage: [String: String]] = [
        .english: [
            "Vishkumbham": "Vishkumbham",
            "Priti": "Priti",
            "Ayushman": "Ayushman",
            "Saubhagya": "Saubhagya",
            "Sobhanam": "Sobhanam",
            "Atiganda": "Atiganda",
            "Sukarma": "Sukarma",
            "Dhriti": "Dhriti",
            "Soola": "Soola",
            "Ganda": "Ganda",
            "Vriddhi": "Vriddhi",
            "Dhruva": "Dhruva",
            "Vyagatha": "Vyagatha",
            "Harshana": "Harshana",
            "Vajra": "Vajra",
            "Siddhi": "Siddhi",
            "Vyatipata": "Vyatipata",
            "Variyan": "Variyan",
            "Parigha": "Parigha",
            "Siva": "Siva",
            "Siddha": "Siddha",
            "Sadhya": "Sadhya",
            "Subha": "Subha",
            "Sukla": "Sukla",
            "Brahma": "Brahma",
            "Indra": "Indra",
            "Vaidhriti": "Vaidhriti"
        ],
        .tamil: [
            "Vishkumbham": "விஷ்கும்பம்",
            "Priti": "பிரீதி",
            "Ayushman": "ஆயுஷ்மான்",
            "Saubhagya": "சௌபாக்யம்",
            "Sobhanam": "சோபனம்",
            "Atiganda": "அதிகண்டம்",
            "Sukarma": "சுகர்மா",
            "Dhriti": "திருதி",
            "Soola": "சூலம்",
            "Ganda": "கண்டம்",
            "Vriddhi": "விருத்தி",
            "Dhruva": "த்ருவம்",
            "Vyagatha": "வியாகாதம்",
            "Harshana": "ஹர்ஷணம்",
            "Vajra": "வஜ்ரம்",
            "Siddhi": "சித்தி",
            "Vyatipata": "வியதீபாதம்",
            "Variyan": "வரியான்",
            "Parigha": "பரிகம்",
            "Siva": "சிவம்",
            "Siddha": "சித்தம்",
            "Sadhya": "சாத்யம்",
            "Subha": "சுபம்",
            "Sukla": "சுக்லம்",
            "Brahma": "பிரம்மம்",
            "Indra": "இந்திரம்",
            "Vaidhriti": "வைத்ருதி"
        ]
    ]

    // MARK: - Karanam Names (11 karanams)

    private let karanamNames: [AppLanguage: [String: String]] = [
        .english: [
            "Bava": "Bava",
            "Balava": "Balava",
            "Kaulava": "Kaulava",
            "Taitila": "Taitila",
            "Gara": "Gara",
            "Vanija": "Vanija",
            "Vishti": "Vishti",
            "Sakuni": "Sakuni",
            "Chatushpada": "Chatushpada",
            "Naga": "Naga",
            "Kimstughna": "Kimstughna"
        ],
        .tamil: [
            "Bava": "பவம்",
            "Balava": "பாலவம்",
            "Kaulava": "கௌலவம்",
            "Taitila": "தைதுலம்",
            "Gara": "கரஜம்",
            "Vanija": "வணிஜம்",
            "Vishti": "விஷ்டி",
            "Sakuni": "சகுனி",
            "Chatushpada": "சதுஷ்பாதம்",
            "Naga": "நாகம்",
            "Kimstughna": "கிம்ஸ்துக்னம்"
        ]
    ]

    // MARK: - Helper Methods

    func nakshatram(_ englishName: String, for language: AppLanguage) -> String {
        nakshatramNames[language]?[englishName] ?? englishName
    }

    func thithi(_ englishName: String, for language: AppLanguage) -> String {
        thithiNames[language]?[englishName] ?? englishName
    }

    func paksha(_ englishName: String, for language: AppLanguage) -> String {
        pakshaNames[language]?[englishName] ?? englishName
    }

    func yogam(_ englishName: String, for language: AppLanguage) -> String {
        yogamNames[language]?[englishName] ?? englishName
    }

    func karanam(_ englishName: String, for language: AppLanguage) -> String {
        karanamNames[language]?[englishName] ?? englishName
    }
}
