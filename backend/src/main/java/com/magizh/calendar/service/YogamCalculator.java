package com.magizh.calendar.service;

import com.magizh.calendar.model.Yogam;
import com.magizh.calendar.model.Yogam.YogamType;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.ZonedDateTime;

/**
 * Calculator for Yogam.
 *
 * Yogam is based on the sum of Sun and Moon longitudes.
 * There are 27 yogams, each spanning 13°20' (800 arc-minutes).
 */
@Service
public class YogamCalculator {

    private static final double YOGAM_SPAN = 360.0 / 27.0; // 13°20'

    // Yogam names (matching iOS enum)
    private static final String[] YOGAMS = {
        "Vishkumbham", "Priti", "Ayushman", "Saubhagya", "Sobhanam",
        "Atiganda", "Sukarma", "Dhriti", "Soola", "Ganda",
        "Vriddhi", "Dhruva", "Vyagatha", "Harshana", "Vajra",
        "Siddhi", "Vyatipata", "Variyan", "Parigha", "Siva",
        "Siddha", "Sadhya", "Subha", "Sukla", "Brahma",
        "Indra", "Vaidhriti"
    };

    // Yogam types (based on traditional classifications)
    private static final YogamType[] YOGAM_TYPES = {
        YogamType.INAUSPICIOUS,  // Vishkumbha
        YogamType.AUSPICIOUS,    // Priti
        YogamType.AUSPICIOUS,    // Ayushman
        YogamType.AUSPICIOUS,    // Saubhagya
        YogamType.AUSPICIOUS,    // Shobhana
        YogamType.INAUSPICIOUS,  // Atiganda
        YogamType.AUSPICIOUS,    // Sukarma
        YogamType.AUSPICIOUS,    // Dhriti
        YogamType.INAUSPICIOUS,  // Shula
        YogamType.INAUSPICIOUS,  // Ganda
        YogamType.AUSPICIOUS,    // Vriddhi
        YogamType.AUSPICIOUS,    // Dhruva
        YogamType.INAUSPICIOUS,  // Vyaghata
        YogamType.AUSPICIOUS,    // Harshana
        YogamType.NEUTRAL,       // Vajra
        YogamType.AUSPICIOUS,    // Siddhi
        YogamType.INAUSPICIOUS,  // Vyatipata
        YogamType.AUSPICIOUS,    // Variyana
        YogamType.INAUSPICIOUS,  // Parigha
        YogamType.AUSPICIOUS,    // Shiva
        YogamType.AUSPICIOUS,    // Siddha
        YogamType.AUSPICIOUS,    // Sadhya
        YogamType.AUSPICIOUS,    // Shubha
        YogamType.AUSPICIOUS,    // Shukla
        YogamType.AUSPICIOUS,    // Brahma
        YogamType.AUSPICIOUS,    // Indra
        YogamType.INAUSPICIOUS   // Vaidhriti
    };

    private final AstronomyService astronomyService;

    public YogamCalculator(AstronomyService astronomyService) {
        this.astronomyService = astronomyService;
    }

    /**
     * Calculate the current Yogam based on Sun+Moon longitude sum.
     *
     * @param baseTime The reference time (typically sunrise)
     * @return Yogam with name, type, start time, and end time
     */
    public Yogam calculate(ZonedDateTime baseTime) {
        double sunMoonSum = astronomyService.getSunMoonSum(baseTime);

        int index = (int) (sunMoonSum / YOGAM_SPAN) % 27;

        String name = YOGAMS[index];
        YogamType type = YOGAM_TYPES[index];

        // Find when this yogam started and when it will end
        ZonedDateTime startTime = findYogamStartTime(baseTime, index);
        ZonedDateTime endTime = findYogamEndTime(baseTime, index);

        return new Yogam(name, type, startTime, endTime);
    }

    /**
     * Get the yogam name for a given Sun+Moon sum.
     */
    public String getYogamName(double sunMoonSum) {
        int index = (int) (sunMoonSum / YOGAM_SPAN) % 27;
        return YOGAMS[index];
    }

    /**
     * Get the yogam type for a given Sun+Moon sum.
     */
    public YogamType getYogamType(double sunMoonSum) {
        int index = (int) (sunMoonSum / YOGAM_SPAN) % 27;
        return YOGAM_TYPES[index];
    }

    private ZonedDateTime findYogamStartTime(ZonedDateTime baseTime, int yogamIndex) {
        // Search backwards to find when this yogam started
        double targetSum = yogamIndex * YOGAM_SPAN;

        ZonedDateTime searchTime = baseTime.minusHours(24);
        ZonedDateTime bestTime = baseTime;

        // Simple search backwards
        while (searchTime.isBefore(baseTime)) {
            double sum = astronomyService.getSunMoonSum(searchTime);
            int currentIndex = (int) (sum / YOGAM_SPAN) % 27;

            if (currentIndex != yogamIndex) {
                // Found transition point
                bestTime = searchTime.plusMinutes(30);
                break;
            }
            searchTime = searchTime.plusMinutes(30);
        }

        return bestTime;
    }

    private ZonedDateTime findYogamEndTime(ZonedDateTime baseTime, int yogamIndex) {
        // Search forward to find when this yogam ends
        double nextYogamSum = ((yogamIndex + 1) % 27) * YOGAM_SPAN;

        ZonedDateTime searchTime = baseTime;
        ZonedDateTime maxTime = baseTime.plusHours(48);

        while (searchTime.isBefore(maxTime)) {
            double sum = astronomyService.getSunMoonSum(searchTime);
            int currentIndex = (int) (sum / YOGAM_SPAN) % 27;

            if (currentIndex != yogamIndex) {
                return searchTime;
            }
            searchTime = searchTime.plusMinutes(30);
        }

        // Fallback: estimate ~24 hours
        return baseTime.plusHours(24);
    }
}
