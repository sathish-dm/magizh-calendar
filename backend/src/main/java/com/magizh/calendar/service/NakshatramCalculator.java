package com.magizh.calendar.service;

import com.magizh.calendar.model.Nakshatram;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;

/**
 * Calculator for Nakshatram (lunar mansion/star).
 *
 * The Moon travels through 27 nakshatrams during its orbit.
 * Each nakshatram spans 13°20' (13.333... degrees) of the ecliptic.
 */
@Service
public class NakshatramCalculator {

    private static final double NAKSHATRAM_SPAN = 360.0 / 27.0; // 13°20' = 13.333...°

    // Tamil names for nakshatrams (matching iOS enum)
    private static final String[] NAKSHATRAMS = {
        "Ashwini", "Bharani", "Krithigai", "Rohini", "Mrigashirisham",
        "Thiruvathirai", "Punarpoosam", "Poosam", "Ayilyam", "Magam",
        "Pooram", "Uthiram", "Hastham", "Chithirai", "Swathi",
        "Visagam", "Anusham", "Kettai", "Moolam", "Pooradam",
        "Uthiradam", "Thiruvonam", "Avittam", "Sathayam",
        "Poorattathi", "Uthirattathi", "Revathi"
    };

    // Lords (ruling planets) for each nakshatram
    private static final String[] LORDS = {
        "Ketu", "Venus", "Sun", "Moon", "Mars",
        "Rahu", "Jupiter", "Saturn", "Mercury", "Ketu",
        "Venus", "Sun", "Moon", "Mars", "Rahu",
        "Jupiter", "Saturn", "Mercury", "Ketu", "Venus",
        "Sun", "Moon", "Mars", "Rahu",
        "Jupiter", "Saturn", "Mercury"
    };

    private final AstronomyService astronomyService;

    public NakshatramCalculator(AstronomyService astronomyService) {
        this.astronomyService = astronomyService;
    }

    /**
     * Calculate the current Nakshatram based on Moon's position.
     *
     * @param baseTime The reference time (typically sunrise)
     * @return Nakshatram with name, lord, and end time
     */
    public Nakshatram calculate(ZonedDateTime baseTime) {
        double moonLongitude = astronomyService.getMoonLongitude(baseTime);

        int index = (int) (moonLongitude / NAKSHATRAM_SPAN);
        index = index % 27; // Ensure within bounds

        String name = NAKSHATRAMS[index];
        String lord = LORDS[index];

        // Calculate when Moon will enter the next nakshatram
        double nextNakshatramStart = (index + 1) * NAKSHATRAM_SPAN;
        if (nextNakshatramStart >= 360) {
            nextNakshatramStart = 0;
        }

        ZonedDateTime endTime = findNakshatramEndTime(baseTime, nextNakshatramStart);

        return new Nakshatram(name, endTime, lord);
    }

    /**
     * Get the nakshatram name for a given Moon longitude.
     */
    public String getNakshatramName(double moonLongitude) {
        int index = (int) (moonLongitude / NAKSHATRAM_SPAN) % 27;
        return NAKSHATRAMS[index];
    }

    /**
     * Get the nakshatram index (0-26) for a given Moon longitude.
     */
    public int getNakshatramIndex(double moonLongitude) {
        return (int) (moonLongitude / NAKSHATRAM_SPAN) % 27;
    }

    private ZonedDateTime findNakshatramEndTime(ZonedDateTime startTime, double targetLongitude) {
        // Search up to 48 hours for the Moon to reach target longitude
        ZonedDateTime endTime = astronomyService.findMoonAtLongitude(startTime, targetLongitude, 48);

        if (endTime == null) {
            // Fallback: estimate based on average Moon motion (~13° per day)
            double moonLong = astronomyService.getMoonLongitude(startTime);
            double angleDiff = targetLongitude - moonLong;
            if (angleDiff < 0) angleDiff += 360;

            // Moon moves ~0.5° per hour on average
            long hoursToTarget = (long) (angleDiff / 0.5);
            endTime = startTime.plusHours(hoursToTarget);
        }

        return endTime;
    }
}
