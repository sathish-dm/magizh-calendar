package com.magizh.calendar.service;

import com.magizh.calendar.model.TimeRange;
import com.magizh.calendar.model.TimeRange.TimingType;
import com.magizh.calendar.model.Timings;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.Duration;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Calculator for daily timings (Rahukaalam, Yamagandam, Kuligai, Nalla Neram).
 *
 * These timings are based on dividing the day (sunrise to sunset) into 8 equal parts.
 * Each inauspicious period occupies one of these 8 segments, with the segment
 * varying by day of the week.
 */
@Service
public class TimingsCalculator {

    // Rahukaalam segment for each day (1-8, where 1 is first segment after sunrise)
    // Traditional order: Sun=8, Mon=2, Tue=7, Wed=5, Thu=6, Fri=4, Sat=3
    private static final int[] RAHUKAALAM_SEGMENTS = {
        8, // Sunday
        2, // Monday
        7, // Tuesday
        5, // Wednesday
        6, // Thursday
        4, // Friday
        3  // Saturday
    };

    // Yamagandam segment for each day
    // Traditional order: Sun=5, Mon=4, Tue=3, Wed=2, Thu=1, Fri=7, Sat=6
    private static final int[] YAMAGANDAM_SEGMENTS = {
        5, // Sunday
        4, // Monday
        3, // Tuesday
        2, // Wednesday
        1, // Thursday
        7, // Friday
        6  // Saturday
    };

    // Kuligai (Gulikai) segment for each day
    // Traditional order: Sun=7, Mon=6, Tue=5, Wed=4, Thu=3, Fri=2, Sat=1
    private static final int[] KULIGAI_SEGMENTS = {
        7, // Sunday
        6, // Monday
        5, // Tuesday
        4, // Wednesday
        3, // Thursday
        2, // Friday
        1  // Saturday
    };

    /**
     * Calculate all timings for a given day.
     *
     * @param sunrise Sunrise time
     * @param sunset Sunset time
     * @param dayOfWeek Day of the week
     * @return Timings object with all calculated periods
     */
    public Timings calculate(ZonedDateTime sunrise, ZonedDateTime sunset, DayOfWeek dayOfWeek) {
        // Calculate segment duration (day divided into 8 parts)
        Duration dayDuration = Duration.between(sunrise, sunset);
        Duration segmentDuration = dayDuration.dividedBy(8);

        int dayIndex = dayOfWeek.getValue() % 7; // Convert to 0-6 (Sunday=0)
        if (dayOfWeek == DayOfWeek.SUNDAY) {
            dayIndex = 0;
        } else {
            dayIndex = dayOfWeek.getValue(); // Monday=1, ..., Saturday=6
        }
        // Adjust: DayOfWeek.MONDAY = 1, but we need Sunday = 0
        dayIndex = dayOfWeek.getValue() == 7 ? 0 : dayOfWeek.getValue() % 7;
        // Actually: Sunday=7 in Java, so handle correctly
        dayIndex = (dayOfWeek.getValue() % 7); // Sun=0, Mon=1, ..., Sat=6

        // Calculate Rahukaalam
        int rahuSegment = RAHUKAALAM_SEGMENTS[dayIndex];
        TimeRange rahukaalam = calculateSegment(sunrise, segmentDuration, rahuSegment, TimingType.RAHUKAALAM);

        // Calculate Yamagandam
        int yamaSegment = YAMAGANDAM_SEGMENTS[dayIndex];
        TimeRange yamagandam = calculateSegment(sunrise, segmentDuration, yamaSegment, TimingType.YAMAGANDAM);

        // Calculate Kuligai
        int kuligaiSegment = KULIGAI_SEGMENTS[dayIndex];
        TimeRange kuligai = calculateSegment(sunrise, segmentDuration, kuligaiSegment, TimingType.KULIGAI);

        // Calculate Nalla Neram (auspicious periods)
        List<TimeRange> nallaNeram = calculateNallaNeram(sunrise, sunset, segmentDuration,
                rahuSegment, yamaSegment, kuligaiSegment);

        return new Timings(sunrise, sunset, nallaNeram, rahukaalam, yamagandam, kuligai);
    }

    private TimeRange calculateSegment(ZonedDateTime sunrise, Duration segmentDuration,
                                        int segment, TimingType type) {
        // Segments are 1-based
        ZonedDateTime startTime = sunrise.plus(segmentDuration.multipliedBy(segment - 1));
        ZonedDateTime endTime = startTime.plus(segmentDuration);

        return new TimeRange(startTime, endTime, type);
    }

    private List<TimeRange> calculateNallaNeram(ZonedDateTime sunrise, ZonedDateTime sunset,
                                                 Duration segmentDuration,
                                                 int rahuSegment, int yamaSegment, int kuligaiSegment) {
        List<TimeRange> nallaNeram = new ArrayList<>();

        // Find auspicious segments (those not occupied by inauspicious timings)
        // Traditional Nalla Neram periods are specific times based on planetary hours
        // For simplicity, we'll mark segments not occupied by Rahu/Yama/Kuligai as potentially auspicious

        // Common approach: Morning Nalla Neram (before Rahukaalam) and
        // Afternoon Nalla Neram (after Rahukaalam ends if applicable)

        // Simple heuristic: First half of day and after sunset minus inauspicious periods
        // For now, provide two standard auspicious periods

        // Morning Nalla Neram: typically 9-10:30 AM equivalent
        ZonedDateTime morningStart = sunrise.plusHours(2).plusMinutes(30);
        ZonedDateTime morningEnd = morningStart.plusHours(1).plusMinutes(30);

        // Check if this overlaps with any inauspicious period
        if (!overlapsWithInauspicious(morningStart, morningEnd, sunrise, segmentDuration,
                rahuSegment, yamaSegment, kuligaiSegment)) {
            nallaNeram.add(new TimeRange(morningStart, morningEnd, TimingType.NALLA_NERAM));
        }

        // Afternoon Nalla Neram: typically 3-4:30 PM equivalent
        ZonedDateTime afternoonStart = sunrise.plusHours(9);
        ZonedDateTime afternoonEnd = afternoonStart.plusHours(1).plusMinutes(30);

        if (afternoonEnd.isBefore(sunset) && !overlapsWithInauspicious(afternoonStart, afternoonEnd,
                sunrise, segmentDuration, rahuSegment, yamaSegment, kuligaiSegment)) {
            nallaNeram.add(new TimeRange(afternoonStart, afternoonEnd, TimingType.NALLA_NERAM));
        }

        return nallaNeram;
    }

    private boolean overlapsWithInauspicious(ZonedDateTime start, ZonedDateTime end,
                                              ZonedDateTime sunrise, Duration segmentDuration,
                                              int rahuSegment, int yamaSegment, int kuligaiSegment) {
        // Check overlap with each inauspicious segment
        for (int segment : new int[]{rahuSegment, yamaSegment, kuligaiSegment}) {
            ZonedDateTime segStart = sunrise.plus(segmentDuration.multipliedBy(segment - 1));
            ZonedDateTime segEnd = segStart.plus(segmentDuration);

            if (start.isBefore(segEnd) && end.isAfter(segStart)) {
                return true;
            }
        }
        return false;
    }
}
