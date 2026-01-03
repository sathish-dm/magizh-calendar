package com.magizh.calendar.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for AstronomyService.
 *
 * Reference data sources:
 * - NOAA Solar Calculator: https://gml.noaa.gov/grad/solcalc/
 * - timeanddate.com for sunrise/sunset verification
 *
 * Acceptable tolerance: 2 minutes for sunrise/sunset (accounts for
 * atmospheric refraction variations and algorithm differences)
 */
@DisplayName("AstronomyService Tests")
class AstronomyServiceTest {

    private AstronomyService astronomyService;

    // Chennai coordinates
    private static final double CHENNAI_LAT = 13.0827;
    private static final double CHENNAI_LNG = 80.2707;
    private static final ZoneId CHENNAI_ZONE = ZoneId.of("Asia/Kolkata");

    // New York coordinates
    private static final double NYC_LAT = 40.7128;
    private static final double NYC_LNG = -74.0060;
    private static final ZoneId NYC_ZONE = ZoneId.of("America/New_York");

    // London coordinates
    private static final double LONDON_LAT = 51.5074;
    private static final double LONDON_LNG = -0.1278;
    private static final ZoneId LONDON_ZONE = ZoneId.of("Europe/London");

    @BeforeEach
    void setUp() {
        astronomyService = new AstronomyService();
        astronomyService.init();
    }

    @Test
    @DisplayName("Sunrise calculation for Chennai - January 4, 2026")
    void testSunriseChennai_Jan2026() {
        LocalDate date = LocalDate.of(2026, 1, 4);
        ZonedDateTime sunrise = astronomyService.calculateSunrise(date, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_ZONE);

        // Expected sunrise around 6:32 AM IST (based on NOAA)
        LocalTime expected = LocalTime.of(6, 32);
        LocalTime actual = sunrise.toLocalTime();

        assertTimeWithinTolerance(expected, actual, 2,
                "Chennai sunrise should be around 6:32 AM on Jan 4, 2026");
    }

    @Test
    @DisplayName("Sunset calculation for Chennai - January 4, 2026")
    void testSunsetChennai_Jan2026() {
        LocalDate date = LocalDate.of(2026, 1, 4);
        ZonedDateTime sunset = astronomyService.calculateSunset(date, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_ZONE);

        // Expected sunset around 5:55 PM IST (based on NOAA)
        LocalTime expected = LocalTime.of(17, 55);
        LocalTime actual = sunset.toLocalTime();

        assertTimeWithinTolerance(expected, actual, 2,
                "Chennai sunset should be around 5:55 PM on Jan 4, 2026");
    }

    @ParameterizedTest
    @DisplayName("Sunrise across different dates - Chennai")
    @CsvSource({
        "2026-01-01, 06:31",  // New Year
        "2026-03-21, 06:11",  // Spring Equinox
        "2026-06-21, 05:44",  // Summer Solstice
        "2026-09-23, 05:58",  // Autumn Equinox
        "2026-12-21, 06:28"   // Winter Solstice
    })
    void testSunriseAcrossSeasons(String dateStr, String expectedTimeStr) {
        LocalDate date = LocalDate.parse(dateStr);
        LocalTime expected = LocalTime.parse(expectedTimeStr);

        ZonedDateTime sunrise = astronomyService.calculateSunrise(date, CHENNAI_LAT, CHENNAI_LNG, CHENNAI_ZONE);
        LocalTime actual = sunrise.toLocalTime();

        assertTimeWithinTolerance(expected, actual, 3,
                String.format("Sunrise on %s should be around %s", dateStr, expectedTimeStr));
    }

    @Test
    @DisplayName("Sun longitude increases throughout the year")
    void testSunLongitudeProgression() {
        ZonedDateTime jan1 = LocalDate.of(2026, 1, 1).atStartOfDay(CHENNAI_ZONE).plusHours(12);
        ZonedDateTime apr1 = LocalDate.of(2026, 4, 1).atStartOfDay(CHENNAI_ZONE).plusHours(12);
        ZonedDateTime jul1 = LocalDate.of(2026, 7, 1).atStartOfDay(CHENNAI_ZONE).plusHours(12);
        ZonedDateTime oct1 = LocalDate.of(2026, 10, 1).atStartOfDay(CHENNAI_ZONE).plusHours(12);

        double lonJan = astronomyService.getSunLongitude(jan1);
        double lonApr = astronomyService.getSunLongitude(apr1);
        double lonJul = astronomyService.getSunLongitude(jul1);
        double lonOct = astronomyService.getSunLongitude(oct1);

        // Sun moves approximately 1° per day, so ~90° per quarter
        // January: ~280° (Capricorn), April: ~10° (Aries), July: ~100° (Cancer), October: ~190° (Libra)
        assertTrue(lonJan > 270 && lonJan < 290, "Sun in Capricorn in January: " + lonJan);
        assertTrue(lonApr > 0 && lonApr < 30, "Sun in Aries in April: " + lonApr);
        assertTrue(lonJul > 90 && lonJul < 120, "Sun in Cancer in July: " + lonJul);
        assertTrue(lonOct > 180 && lonOct < 210, "Sun in Libra in October: " + lonOct);
    }

    @Test
    @DisplayName("Moon longitude changes significantly in 24 hours")
    void testMoonLongitudeProgression() {
        ZonedDateTime time1 = LocalDate.of(2026, 1, 4).atStartOfDay(CHENNAI_ZONE).plusHours(12);
        ZonedDateTime time2 = time1.plusHours(24);

        double lon1 = astronomyService.getMoonLongitude(time1);
        double lon2 = astronomyService.getMoonLongitude(time2);

        // Moon moves approximately 12-14° per day
        double diff = (lon2 - lon1 + 360) % 360;
        assertTrue(diff > 10 && diff < 16,
                String.format("Moon should move 10-16° in 24 hours, actual: %.2f°", diff));
    }

    @Test
    @DisplayName("Moon-Sun angle increases over time (thithi progression)")
    void testMoonSunAngleProgression() {
        ZonedDateTime time1 = LocalDate.of(2026, 1, 4).atStartOfDay(CHENNAI_ZONE).plusHours(12);
        ZonedDateTime time2 = time1.plusHours(24);

        double angle1 = astronomyService.getMoonSunAngle(time1);
        double angle2 = astronomyService.getMoonSunAngle(time2);

        // Moon-Sun angle increases ~12° per day (one thithi per day approximately)
        double diff = (angle2 - angle1 + 360) % 360;
        assertTrue(diff > 10 && diff < 14,
                String.format("Moon-Sun angle should increase 10-14° in 24 hours, actual: %.2f°", diff));
    }

    @Test
    @DisplayName("Sunrise in different hemispheres - verify no errors")
    void testSunriseMultipleLocations() {
        LocalDate date = LocalDate.of(2026, 6, 21); // Summer solstice

        // Northern hemisphere - should have early sunrise
        ZonedDateTime londonSunrise = astronomyService.calculateSunrise(date, LONDON_LAT, LONDON_LNG, LONDON_ZONE);
        assertNotNull(londonSunrise, "London sunrise should be calculated");
        assertTrue(londonSunrise.getHour() < 6, "London summer sunrise should be before 6 AM");

        // Southern hemisphere - later sunrise in their winter
        ZonedDateTime sydneySunrise = astronomyService.calculateSunrise(date, -33.8688, 151.2093,
                ZoneId.of("Australia/Sydney"));
        assertNotNull(sydneySunrise, "Sydney sunrise should be calculated");
        assertTrue(sydneySunrise.getHour() >= 6, "Sydney winter sunrise should be after 6 AM");
    }

    @Test
    @DisplayName("Sun+Moon sum for Yogam calculation")
    void testSunMoonSum() {
        ZonedDateTime time = LocalDate.of(2026, 1, 4).atStartOfDay(CHENNAI_ZONE).plusHours(12);

        double sunLong = astronomyService.getSunLongitude(time);
        double moonLong = astronomyService.getMoonLongitude(time);
        double sum = astronomyService.getSunMoonSum(time);

        double expectedSum = (sunLong + moonLong) % 360;
        assertEquals(expectedSum, sum, 0.01, "Sun+Moon sum should match manual calculation");
    }

    // Helper method to assert time is within tolerance
    private void assertTimeWithinTolerance(LocalTime expected, LocalTime actual, int toleranceMinutes, String message) {
        int expectedMinutes = expected.getHour() * 60 + expected.getMinute();
        int actualMinutes = actual.getHour() * 60 + actual.getMinute();
        int diff = Math.abs(expectedMinutes - actualMinutes);

        assertTrue(diff <= toleranceMinutes,
                String.format("%s. Expected: %s, Actual: %s, Difference: %d minutes",
                        message, expected, actual, diff));
    }
}
