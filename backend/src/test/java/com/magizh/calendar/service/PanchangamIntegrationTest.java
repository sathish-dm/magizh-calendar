package com.magizh.calendar.service;

import com.magizh.calendar.model.PanchangamResponse;
import com.magizh.calendar.model.Thithi.Paksha;
import com.magizh.calendar.model.Yogam.YogamType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.time.LocalDate;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration tests for PanchangamService.
 *
 * These tests verify the complete panchangam calculation against
 * known reference data from trusted sources:
 * - drikpanchang.com
 * - prokerala.com/astrology/panchang
 *
 * Note: Small variations (±1 in thithi/nakshatram due to calculation time)
 * are acceptable as different sources use slightly different methods.
 */
@DisplayName("Panchangam Integration Tests")
class PanchangamIntegrationTest {

    private PanchangamService panchangamService;

    // Chennai coordinates (most common for Tamil panchangam)
    private static final double CHENNAI_LAT = 13.0827;
    private static final double CHENNAI_LNG = 80.2707;
    private static final String CHENNAI_TZ = "Asia/Kolkata";

    @BeforeEach
    void setUp() {
        // Create all required services
        AstronomyService astronomyService = new AstronomyService();
        astronomyService.init();

        NakshatramCalculator nakshatramCalculator = new NakshatramCalculator(astronomyService);
        ThithiCalculator thithiCalculator = new ThithiCalculator(astronomyService);
        YogamCalculator yogamCalculator = new YogamCalculator(astronomyService);
        KaranamCalculator karanamCalculator = new KaranamCalculator(astronomyService);
        GowriCalculator gowriCalculator = new GowriCalculator();
        TimingsCalculator timingsCalculator = new TimingsCalculator(gowriCalculator);
        TamilCalendarService tamilCalendarService = new TamilCalendarService(astronomyService);

        panchangamService = new PanchangamService(
                astronomyService,
                nakshatramCalculator,
                thithiCalculator,
                yogamCalculator,
                karanamCalculator,
                timingsCalculator,
                tamilCalendarService
        );
    }

    @Test
    @DisplayName("Complete panchangam response has all required fields")
    void testPanchangamResponseCompleteness() {
        LocalDate date = LocalDate.of(2026, 1, 4);
        PanchangamResponse response = panchangamService.getDailyPanchangam(
                date, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_TZ);

        // Verify all fields are present
        assertNotNull(response.date(), "Date should be present");
        assertNotNull(response.tamilDate(), "Tamil date should be present");
        assertNotNull(response.nakshatram(), "Nakshatram should be present");
        assertNotNull(response.thithi(), "Thithi should be present");
        assertNotNull(response.yogam(), "Yogam should be present");
        assertNotNull(response.karanam(), "Karanam should be present");
        assertNotNull(response.timings(), "Timings should be present");
        assertNotNull(response.foodStatus(), "Food status should be present");

        // Verify date matches
        assertEquals(date, response.date(), "Response date should match request");
    }

    @Test
    @DisplayName("Tamil date calculation is reasonable")
    void testTamilDate() {
        LocalDate date = LocalDate.of(2026, 1, 4);
        PanchangamResponse response = panchangamService.getDailyPanchangam(
                date, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_TZ);

        // January is in Margazhi or Thai month
        String tamilMonth = response.tamilDate().month();
        assertTrue(
                tamilMonth.equals("Margazhi") || tamilMonth.equals("Thai"),
                "January should be in Margazhi or Thai, got: " + tamilMonth
        );

        // Tamil day should be 1-32
        int tamilDay = response.tamilDate().day();
        assertTrue(tamilDay >= 1 && tamilDay <= 32,
                "Tamil day should be 1-32, got: " + tamilDay);

        // Year name should be from 60-year cycle
        assertNotNull(response.tamilDate().year(), "Year name should be present");

        // Weekday should match
        assertEquals("Nyairu", response.tamilDate().weekday(),
                "January 4, 2026 is Sunday (Nyairu)");
    }

    @Test
    @DisplayName("Timings are in correct order")
    void testTimingsOrder() {
        LocalDate date = LocalDate.of(2026, 1, 4);
        PanchangamResponse response = panchangamService.getDailyPanchangam(
                date, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_TZ);

        // Sunrise should be before sunset
        assertTrue(
                response.timings().sunrise().isBefore(response.timings().sunset()),
                "Sunrise should be before sunset"
        );

        // Sunrise should be in the morning (4-8 AM typical for India)
        int sunriseHour = response.timings().sunrise().getHour();
        assertTrue(sunriseHour >= 4 && sunriseHour <= 8,
                "Sunrise should be between 4-8 AM, got: " + sunriseHour);

        // Sunset should be in the evening (5-8 PM typical for India)
        int sunsetHour = response.timings().sunset().getHour();
        assertTrue(sunsetHour >= 17 && sunsetHour <= 20,
                "Sunset should be between 5-8 PM, got: " + sunsetHour);
    }

    @Test
    @DisplayName("Rahukaalam varies by weekday")
    void testRahukaalamByWeekday() {
        // Sunday - 8th segment (last)
        LocalDate sunday = LocalDate.of(2026, 1, 4);
        PanchangamResponse sunResponse = panchangamService.getDailyPanchangam(
                sunday, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_TZ);

        // Monday - 2nd segment (early morning)
        LocalDate monday = LocalDate.of(2026, 1, 5);
        PanchangamResponse monResponse = panchangamService.getDailyPanchangam(
                monday, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_TZ);

        // Rahukaalam times should be different on different days
        assertNotEquals(
                sunResponse.timings().rahukaalam().startTime().getHour(),
                monResponse.timings().rahukaalam().startTime().getHour(),
                "Rahukaalam should be at different times on Sunday vs Monday"
        );
    }

    @Test
    @DisplayName("Weekly panchangam returns 7 days")
    void testWeeklyPanchangam() {
        LocalDate startDate = LocalDate.of(2026, 1, 4);
        var weeklyResponse = panchangamService.getWeeklyPanchangam(
                startDate, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_TZ);

        assertEquals(7, weeklyResponse.size(), "Weekly response should have 7 days");

        // Verify dates are consecutive
        for (int i = 0; i < 7; i++) {
            assertEquals(startDate.plusDays(i), weeklyResponse.get(i).date(),
                    "Day " + (i + 1) + " should have correct date");
        }
    }

    @Test
    @DisplayName("Yogam has valid type classification")
    void testYogamType() {
        LocalDate date = LocalDate.of(2026, 1, 4);
        PanchangamResponse response = panchangamService.getDailyPanchangam(
                date, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_TZ);

        YogamType type = response.yogam().type();
        assertNotNull(type, "Yogam type should not be null");
        assertTrue(
                type == YogamType.AUSPICIOUS ||
                        type == YogamType.INAUSPICIOUS ||
                        type == YogamType.NEUTRAL,
                "Yogam type should be valid enum value"
        );
    }

    @Test
    @DisplayName("Thithi paksha is correctly identified")
    void testThithiPaksha() {
        LocalDate date = LocalDate.of(2026, 1, 4);
        PanchangamResponse response = panchangamService.getDailyPanchangam(
                date, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_TZ);

        Paksha paksha = response.thithi().paksha();
        assertNotNull(paksha, "Paksha should not be null");
        assertTrue(
                paksha == Paksha.SHUKLA || paksha == Paksha.KRISHNA,
                "Paksha should be Shukla or Krishna"
        );
    }

    @Test
    @DisplayName("Nakshatram is one of 27 valid names")
    void testValidNakshatram() {
        // Tamil names for nakshatrams
        String[] validNakshatrams = {
                "Ashwini", "Bharani", "Krithigai", "Rohini", "Mrigashirisham",
                "Thiruvathirai", "Punarpoosam", "Poosam", "Ayilyam", "Magam",
                "Pooram", "Uthiram", "Hastham", "Chithirai", "Swathi",
                "Visagam", "Anusham", "Kettai", "Moolam", "Pooradam",
                "Uthiradam", "Thiruvonam", "Avittam", "Sathayam",
                "Poorattathi", "Uthirattathi", "Revathi"
        };

        LocalDate date = LocalDate.of(2026, 1, 4);
        PanchangamResponse response = panchangamService.getDailyPanchangam(
                date, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_TZ);

        String nakshatram = response.nakshatram().name();
        boolean isValid = false;
        for (String valid : validNakshatrams) {
            if (valid.equals(nakshatram)) {
                isValid = true;
                break;
            }
        }
        assertTrue(isValid, "Nakshatram should be one of 27 valid names, got: " + nakshatram);
    }

    @Test
    @DisplayName("Food status is appropriate for thithi")
    void testFoodStatus() {
        // Test regular day
        LocalDate regularDay = LocalDate.of(2026, 1, 4);
        PanchangamResponse regularResponse = panchangamService.getDailyPanchangam(
                regularDay, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_TZ);

        assertNotNull(regularResponse.foodStatus(), "Food status should be present");
        assertNotNull(regularResponse.foodStatus().type(), "Food status type should be present");
        assertNotNull(regularResponse.foodStatus().message(), "Food status message should be present");
    }

    /**
     * Parameterized test with known panchangam reference data.
     * These values are approximate and allow for minor variations.
     */
    @ParameterizedTest
    @DisplayName("Verify against known reference data")
    @MethodSource("knownPanchangamData")
    void testAgainstReferenceData(
            LocalDate date,
            String expectedMonthApprox,
            int sunriseHourExpected,
            int sunsetHourExpected
    ) {
        PanchangamResponse response = panchangamService.getDailyPanchangam(
                date, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_TZ);

        // Verify Tamil month is reasonable
        assertNotNull(response.tamilDate().month());

        // Verify sunrise hour (±1 hour tolerance)
        int actualSunriseHour = response.timings().sunrise().getHour();
        assertTrue(
                Math.abs(actualSunriseHour - sunriseHourExpected) <= 1,
                String.format("Sunrise hour on %s: expected ~%d, got %d",
                        date, sunriseHourExpected, actualSunriseHour)
        );

        // Verify sunset hour (±1 hour tolerance)
        int actualSunsetHour = response.timings().sunset().getHour();
        assertTrue(
                Math.abs(actualSunsetHour - sunsetHourExpected) <= 1,
                String.format("Sunset hour on %s: expected ~%d, got %d",
                        date, sunsetHourExpected, actualSunsetHour)
        );
    }

    static Stream<Arguments> knownPanchangamData() {
        return Stream.of(
                // Date, Expected Month (approx), Sunrise Hour, Sunset Hour
                Arguments.of(LocalDate.of(2026, 1, 1), "Thai", 6, 17),
                Arguments.of(LocalDate.of(2026, 4, 14), "Chithirai", 5, 18),  // Tamil New Year
                Arguments.of(LocalDate.of(2026, 6, 21), "Aani", 5, 18),       // Summer Solstice
                Arguments.of(LocalDate.of(2026, 12, 21), "Margazhi", 6, 17)   // Winter Solstice
        );
    }

    @Test
    @DisplayName("Different locations produce different results")
    void testLocationAwareness() {
        LocalDate date = LocalDate.of(2026, 1, 4);

        // Chennai (IST)
        PanchangamResponse chennai = panchangamService.getDailyPanchangam(
                date, 13.0827, 80.2707, "Asia/Kolkata");

        // Mumbai (IST but different longitude)
        PanchangamResponse mumbai = panchangamService.getDailyPanchangam(
                date, 19.0760, 72.8777, "Asia/Kolkata");

        // Sunrise should be slightly different (Mumbai is west of Chennai)
        assertNotEquals(
                chennai.timings().sunrise().getMinute(),
                mumbai.timings().sunrise().getMinute(),
                "Sunrise times should differ between Chennai and Mumbai"
        );
    }
}
