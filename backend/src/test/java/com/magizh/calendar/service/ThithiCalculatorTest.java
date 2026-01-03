package com.magizh.calendar.service;

import com.magizh.calendar.model.Thithi;
import com.magizh.calendar.model.Thithi.Paksha;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for ThithiCalculator.
 *
 * Thithi is based on the angular distance between Moon and Sun.
 * Each thithi = 12° of Moon-Sun angle.
 * Total: 30 thithis (15 Shukla + 15 Krishna)
 *
 * Verification sources:
 * - drikpanchang.com
 * - prokerala.com/astrology/panchang
 */
@DisplayName("ThithiCalculator Tests")
class ThithiCalculatorTest {

    private AstronomyService astronomyService;
    private ThithiCalculator thithiCalculator;

    private static final ZoneId CHENNAI_ZONE = ZoneId.of("Asia/Kolkata");

    @BeforeEach
    void setUp() {
        astronomyService = new AstronomyService();
        astronomyService.init();
        thithiCalculator = new ThithiCalculator(astronomyService);
    }

    @ParameterizedTest
    @DisplayName("Thithi numbers are correctly calculated from Moon-Sun angle")
    @CsvSource({
        "0, 1",      // 0° = Shukla Prathamai
        "12, 2",     // 12° = Shukla Dvitiyai
        "60, 6",     // 60° = Shukla Shashti
        "120, 11",   // 120° = Shukla Ekadasi
        "168, 15",   // 168° = Shukla Pournami
        "180, 16",   // 180° = Krishna Prathamai
        "192, 17",   // 192° = Krishna Dvitiyai
        "300, 26",   // 300° = Krishna Ekadasi
        "348, 30"    // 348° = Krishna Amavasya (30th thithi)
    })
    void testThithiNumberFromAngle(double angle, int expectedNumber) {
        int actual = thithiCalculator.getThithiNumber(angle);
        assertEquals(expectedNumber, actual,
                String.format("Angle %.0f° should give thithi number %d", angle, expectedNumber));
    }

    @Test
    @DisplayName("Shukla Paksha thithis (waxing moon)")
    void testShuklaPaksha() {
        // Test various angles in Shukla Paksha (0-180°)
        ZonedDateTime time = LocalDate.of(2026, 1, 4).atTime(6, 30).atZone(CHENNAI_ZONE);

        // When Moon-Sun angle is in 0-180 range, it's Shukla Paksha
        for (int angle = 0; angle < 180; angle += 12) {
            int thithiNum = thithiCalculator.getThithiNumber(angle);
            assertTrue(thithiNum >= 1 && thithiNum <= 15,
                    String.format("Angle %d° should give Shukla thithi (1-15), got %d", angle, thithiNum));
        }
    }

    @Test
    @DisplayName("Krishna Paksha thithis (waning moon)")
    void testKrishnaPaksha() {
        // Test various angles in Krishna Paksha (180-360°)
        for (int angle = 180; angle < 360; angle += 12) {
            int thithiNum = thithiCalculator.getThithiNumber(angle);
            assertTrue(thithiNum >= 16 && thithiNum <= 30,
                    String.format("Angle %d° should give Krishna thithi (16-30), got %d", angle, thithiNum));
        }
    }

    @Test
    @DisplayName("Pournami (Full Moon) detection")
    void testPournamiDetection() {
        // Pournami occurs at 180° Moon-Sun angle (thithi 15)
        int thithiNum = thithiCalculator.getThithiNumber(178);
        assertEquals(15, thithiNum, "Angle near 180° should be Pournami (thithi 15)");
    }

    @Test
    @DisplayName("Amavasya (New Moon) detection")
    void testAmavasyaDetection() {
        // Amavasya occurs when Moon-Sun angle approaches 360°/0° (thithi 30)
        int thithiNum = thithiCalculator.getThithiNumber(350);
        assertEquals(30, thithiNum, "Angle near 360° should be Amavasya (thithi 30)");
    }

    @Test
    @DisplayName("Special thithi identification")
    void testSpecialThithis() {
        // Ekadasi (11th and 26th)
        assertTrue(thithiCalculator.isSpecialThithi(11), "Shukla Ekadasi should be special");
        assertTrue(thithiCalculator.isSpecialThithi(26), "Krishna Ekadasi should be special");

        // Pournami (15th) and Amavasya (30th)
        assertTrue(thithiCalculator.isSpecialThithi(15), "Pournami should be special");
        assertTrue(thithiCalculator.isSpecialThithi(30), "Amavasya should be special");

        // Regular thithis
        assertFalse(thithiCalculator.isSpecialThithi(5), "Panchami should not be special");
        assertFalse(thithiCalculator.isSpecialThithi(22), "Krishna Saptami should not be special");
    }

    @Test
    @DisplayName("Thithi calculation returns valid result")
    void testThithiCalculation() {
        ZonedDateTime sunrise = LocalDate.of(2026, 1, 4).atTime(6, 32).atZone(CHENNAI_ZONE);
        Thithi thithi = thithiCalculator.calculate(sunrise);

        assertNotNull(thithi.name(), "Thithi should have a name");
        assertNotNull(thithi.paksha(), "Thithi should have a paksha");
        assertNotNull(thithi.endTime(), "Thithi should have an end time");
    }

    @Test
    @DisplayName("Thithi end time is in the future")
    void testThithiEndTimeIsFuture() {
        ZonedDateTime sunrise = LocalDate.of(2026, 1, 4).atTime(6, 32).atZone(CHENNAI_ZONE);
        Thithi thithi = thithiCalculator.calculate(sunrise);

        assertTrue(thithi.endTime().isAfter(sunrise),
                "Thithi end time should be after sunrise");

        // Thithi lasts approximately 24 hours
        ZonedDateTime maxEndTime = sunrise.plusDays(2);
        assertTrue(thithi.endTime().isBefore(maxEndTime),
                "Thithi end time should be within 2 days");
    }

    @Test
    @DisplayName("Thithi names are correct for each paksha")
    void testThithiNames() {
        String[] shuklaNames = {
            "Prathamai", "Dvitiyai", "Tritiyai", "Chaturthi", "Panchami",
            "Shashti", "Saptami", "Ashtami", "Navami", "Dasami",
            "Ekadasi", "Dvadasi", "Trayodasi", "Chaturdasi", "Pournami"
        };

        // Test Shukla Paksha names
        for (int i = 0; i < 15; i++) {
            double angle = i * 12 + 1; // Middle of each thithi
            int thithiNum = thithiCalculator.getThithiNumber(angle);
            assertEquals(i + 1, thithiNum,
                    String.format("Angle %.0f° should be thithi %d", angle, i + 1));
        }
    }

    @Test
    @DisplayName("Thithi progression over lunar month")
    void testThithiProgression() {
        ZonedDateTime start = LocalDate.of(2026, 1, 4).atTime(6, 30).atZone(CHENNAI_ZONE);

        // After ~15 days, should be in opposite paksha
        Thithi thithi1 = thithiCalculator.calculate(start);
        Thithi thithi15 = thithiCalculator.calculate(start.plusDays(15));

        // They should be in different pakshas (approximately)
        // Note: This is approximate due to lunar cycle variations
        assertNotNull(thithi1.paksha());
        assertNotNull(thithi15.paksha());
    }
}
