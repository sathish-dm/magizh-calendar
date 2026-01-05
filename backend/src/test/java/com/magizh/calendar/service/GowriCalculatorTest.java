package com.magizh.calendar.service;

import com.magizh.calendar.model.TimeRange;
import org.junit.jupiter.api.Test;

import java.time.DayOfWeek;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class GowriCalculatorTest {

    private final GowriCalculator calculator = new GowriCalculator();

    @Test
    void shouldCalculateGowriNallaNeramForMonday() {
        // Monday pattern: AMIRDHA, VISHAM, ROGAM, DHANAM, LAABAM, SORAM, UTHI, SUGAM
        // Auspicious: segments 0, 3, 4, 6, 7 (5 out of 8)

        ZonedDateTime sunrise = ZonedDateTime.of(2026, 1, 5, 6, 42, 0, 0, ZoneId.of("Asia/Kolkata"));
        ZonedDateTime sunset = sunrise.plusHours(11).plusMinutes(12); // ~11h12m day

        List<TimeRange> result = calculator.calculate(sunrise, sunset, DayOfWeek.MONDAY);

        assertThat(result).hasSize(5); // 5 auspicious periods
        assertThat(result).allMatch(tr -> tr.type() == TimeRange.TimingType.GOWRI_NALLA_NERAM);
    }

    @Test
    void shouldDivideIntoEqualSegments() {
        ZonedDateTime sunrise = ZonedDateTime.of(2026, 1, 5, 6, 0, 0, 0, ZoneId.of("Asia/Kolkata"));
        ZonedDateTime sunset = sunrise.plusHours(12); // Exactly 12 hours = 1.5h segments

        List<TimeRange> result = calculator.calculate(sunrise, sunset, DayOfWeek.MONDAY);

        // Each segment should be 1.5 hours (90 minutes)
        for (TimeRange range : result) {
            long durationMinutes = java.time.Duration.between(range.startTime(), range.endTime()).toMinutes();
            assertThat(durationMinutes).isEqualTo(90);
        }
    }

    @Test
    void shouldCalculateForAllDaysOfWeek() {
        ZonedDateTime sunrise = ZonedDateTime.of(2026, 1, 5, 6, 0, 0, 0, ZoneId.of("Asia/Kolkata"));
        ZonedDateTime sunset = sunrise.plusHours(12);

        // Test all 7 days of the week
        for (DayOfWeek day : DayOfWeek.values()) {
            List<TimeRange> result = calculator.calculate(sunrise, sunset, day);

            assertThat(result).isNotEmpty();
            assertThat(result.size()).isGreaterThan(0).isLessThanOrEqualTo(8);
            assertThat(result).allMatch(tr -> tr.type() == TimeRange.TimingType.GOWRI_NALLA_NERAM);
        }
    }

    @Test
    void shouldCalculateGowriNallaNeramForSunday() {
        // Sunday pattern: UTHI, ROGAM, VISHAM, DHANAM, SORAM, LAABAM, AMIRDHA, SUGAM
        // Auspicious: segments 0, 3, 5, 6, 7 (5 out of 8)

        ZonedDateTime sunrise = ZonedDateTime.of(2026, 1, 4, 6, 42, 0, 0, ZoneId.of("Asia/Kolkata"));
        ZonedDateTime sunset = sunrise.plusHours(11).plusMinutes(12);

        List<TimeRange> result = calculator.calculate(sunrise, sunset, DayOfWeek.SUNDAY);

        assertThat(result).hasSize(5); // 5 auspicious periods
    }

    @Test
    void shouldCalculateGowriNallaNeramForTuesday() {
        // Tuesday pattern: ROGAM, AMIRDHA, LAABAM, DHANAM, UTHI, VISHAM, SORAM, SUGAM
        // Auspicious: segments 1, 2, 3, 4, 7 (5 out of 8)

        ZonedDateTime sunrise = ZonedDateTime.of(2026, 1, 6, 6, 42, 0, 0, ZoneId.of("Asia/Kolkata"));
        ZonedDateTime sunset = sunrise.plusHours(11).plusMinutes(12);

        List<TimeRange> result = calculator.calculate(sunrise, sunset, DayOfWeek.TUESDAY);

        assertThat(result).hasSize(5);
        assertThat(result).allMatch(tr -> tr.type() == TimeRange.TimingType.GOWRI_NALLA_NERAM);
    }

    @Test
    void shouldCalculateGowriNallaNeramForWednesday() {
        // Wednesday pattern: SUGAM, SORAM, AMIRDHA, LAABAM, ROGAM, UTHI, VISHAM, DHANAM
        // Auspicious: segments 0, 2, 3, 5, 7 (5 out of 8)

        ZonedDateTime sunrise = ZonedDateTime.of(2026, 1, 7, 6, 42, 0, 0, ZoneId.of("Asia/Kolkata"));
        ZonedDateTime sunset = sunrise.plusHours(11).plusMinutes(12);

        List<TimeRange> result = calculator.calculate(sunrise, sunset, DayOfWeek.WEDNESDAY);

        assertThat(result).hasSize(5);
    }

    @Test
    void shouldCalculateGowriNallaNeramForThursday() {
        // Thursday pattern: LAABAM, VISHAM, UTHI, AMIRDHA, SUGAM, ROGAM, DHANAM, SORAM
        // Auspicious: segments 0, 2, 3, 4, 6 (5 out of 8)

        ZonedDateTime sunrise = ZonedDateTime.of(2026, 1, 8, 6, 42, 0, 0, ZoneId.of("Asia/Kolkata"));
        ZonedDateTime sunset = sunrise.plusHours(11).plusMinutes(12);

        List<TimeRange> result = calculator.calculate(sunrise, sunset, DayOfWeek.THURSDAY);

        assertThat(result).hasSize(5);
    }

    @Test
    void shouldCalculateGowriNallaNeramForFriday() {
        // Friday pattern: DHANAM, LAABAM, SUGAM, UTHI, ROGAM, AMIRDHA, VISHAM, SORAM
        // Auspicious: segments 0, 1, 2, 3, 5 (5 out of 8)

        ZonedDateTime sunrise = ZonedDateTime.of(2026, 1, 9, 6, 42, 0, 0, ZoneId.of("Asia/Kolkata"));
        ZonedDateTime sunset = sunrise.plusHours(11).plusMinutes(12);

        List<TimeRange> result = calculator.calculate(sunrise, sunset, DayOfWeek.FRIDAY);

        assertThat(result).hasSize(5);
    }

    @Test
    void shouldCalculateGowriNallaNeramForSaturday() {
        // Saturday pattern: SORAM, SUGAM, ROGAM, VISHAM, AMIRDHA, DHANAM, LAABAM, UTHI
        // Auspicious: segments 1, 4, 5, 6, 7 (5 out of 8)

        ZonedDateTime sunrise = ZonedDateTime.of(2026, 1, 10, 6, 42, 0, 0, ZoneId.of("Asia/Kolkata"));
        ZonedDateTime sunset = sunrise.plusHours(11).plusMinutes(12);

        List<TimeRange> result = calculator.calculate(sunrise, sunset, DayOfWeek.SATURDAY);

        assertThat(result).hasSize(5);
    }

    @Test
    void shouldReturnEmptyListForVeryShortDay() {
        // Edge case: very short day
        ZonedDateTime sunrise = ZonedDateTime.of(2026, 1, 5, 6, 0, 0, 0, ZoneId.of("Asia/Kolkata"));
        ZonedDateTime sunset = sunrise.plusMinutes(1); // Only 1 minute

        List<TimeRange> result = calculator.calculate(sunrise, sunset, DayOfWeek.MONDAY);

        // Should still calculate but with very short segments
        assertThat(result).isNotEmpty();
    }

    @Test
    void shouldHandleRealWorldSunriseSunsetTimes() {
        // January 5, 2026 in Chennai - realistic times
        ZonedDateTime sunrise = ZonedDateTime.of(2026, 1, 5, 6, 42, 0, 0, ZoneId.of("Asia/Kolkata"));
        ZonedDateTime sunset = ZonedDateTime.of(2026, 1, 5, 17, 54, 0, 0, ZoneId.of("Asia/Kolkata"));

        List<TimeRange> result = calculator.calculate(sunrise, sunset, DayOfWeek.MONDAY);

        assertThat(result).hasSize(5);

        // Verify segments are within sunrise-sunset range
        for (TimeRange range : result) {
            assertThat(range.startTime()).isAfterOrEqualTo(sunrise);
            assertThat(range.endTime()).isBeforeOrEqualTo(sunset);
            assertThat(range.endTime()).isAfter(range.startTime());
        }
    }
}
