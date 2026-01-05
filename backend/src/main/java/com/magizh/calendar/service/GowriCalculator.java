package com.magizh.calendar.service;

import com.magizh.calendar.model.TimeRange;
import com.magizh.calendar.model.TimeRange.TimingType;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.Duration;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Calculator for Gowri Panchangam (Tamil traditional timekeeping).
 *
 * Gowri Panchangam divides the day (sunrise to sunset) into 8 equal segments,
 * each assigned a specific state. The pattern rotates based on weekday.
 *
 * States: Amirdha (best), Uthi, Laabam, Sugam, Dhanam (auspicious)
 *         Rogam, Soram, Visham (inauspicious)
 */
@Service
public class GowriCalculator {

    // Gowri states for the 8 segments of each day
    // Pattern source: Traditional Pambu Panchangam
    // Index: Sunday=0, Monday=1, ..., Saturday=6
    private static final String[][] GOWRI_PATTERNS = {
        // Sunday (index 0)
        {"UTHI", "ROGAM", "VISHAM", "DHANAM", "SORAM", "LAABAM", "AMIRDHA", "SUGAM"},
        // Monday (index 1)
        {"AMIRDHA", "VISHAM", "ROGAM", "DHANAM", "LAABAM", "SORAM", "UTHI", "SUGAM"},
        // Tuesday (index 2)
        {"ROGAM", "AMIRDHA", "LAABAM", "DHANAM", "UTHI", "VISHAM", "SORAM", "SUGAM"},
        // Wednesday (index 3)
        {"SUGAM", "SORAM", "AMIRDHA", "LAABAM", "ROGAM", "UTHI", "VISHAM", "DHANAM"},
        // Thursday (index 4)
        {"LAABAM", "VISHAM", "UTHI", "AMIRDHA", "SUGAM", "ROGAM", "DHANAM", "SORAM"},
        // Friday (index 5)
        {"DHANAM", "LAABAM", "SUGAM", "UTHI", "ROGAM", "AMIRDHA", "VISHAM", "SORAM"},
        // Saturday (index 6)
        {"SORAM", "SUGAM", "ROGAM", "VISHAM", "AMIRDHA", "DHANAM", "LAABAM", "UTHI"}
    };

    /**
     * Calculate Gowri Nalla Neram (auspicious periods) for a given day.
     *
     * @param sunrise Sunrise time
     * @param sunset Sunset time
     * @param dayOfWeek Day of the week
     * @return List of auspicious time ranges
     */
    public List<TimeRange> calculate(ZonedDateTime sunrise, ZonedDateTime sunset, DayOfWeek dayOfWeek) {
        List<TimeRange> gowriNallaNeram = new ArrayList<>();

        // Calculate segment duration (day divided into 8 parts)
        Duration dayDuration = Duration.between(sunrise, sunset);
        Duration segmentDuration = dayDuration.dividedBy(8);

        // Get day index (Sunday=0, Monday=1, etc.)
        // DayOfWeek: MONDAY=1, TUESDAY=2, ..., SUNDAY=7
        // We need: Sunday=0, Monday=1, ..., Saturday=6
        int dayIndex = (dayOfWeek.getValue() % 7);

        // Get Gowri pattern for this day
        String[] pattern = GOWRI_PATTERNS[dayIndex];

        // Find all auspicious segments
        for (int segment = 0; segment < 8; segment++) {
            String state = pattern[segment];

            if (isAuspicious(state)) {
                ZonedDateTime startTime = sunrise.plus(segmentDuration.multipliedBy(segment));
                ZonedDateTime endTime = startTime.plus(segmentDuration);

                gowriNallaNeram.add(new TimeRange(
                    startTime,
                    endTime,
                    TimingType.GOWRI_NALLA_NERAM
                ));
            }
        }

        return gowriNallaNeram;
    }

    /**
     * Check if a Gowri state is auspicious.
     */
    private boolean isAuspicious(String state) {
        return switch (state) {
            case "AMIRDHA", "UTHI", "LAABAM", "SUGAM", "DHANAM" -> true;
            default -> false;
        };
    }
}
