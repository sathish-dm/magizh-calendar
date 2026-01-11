package com.magizh.calendar.service;

import com.magizh.calendar.model.Thithi;
import com.magizh.calendar.model.Thithi.Paksha;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;

/**
 * Calculator for Thithi (lunar day).
 *
 * Thithi is based on the angular distance between Moon and Sun.
 * There are 30 thithis in a lunar month (15 in each paksha).
 * Each thithi spans 12° of the Moon-Sun angle.
 */
@Service
public class ThithiCalculator {

    private static final double THITHI_SPAN = 12.0; // Each thithi = 12°

    // Thithi names (matching iOS enum)
    private static final String[] THITHI_NAMES = {
        "Prathama", "Dvitiya", "Tritiya", "Chaturthi", "Panchami",
        "Sashti", "Saptami", "Ashtami", "Navami", "Dasami",
        "Ekadasi", "Dvadasi", "Trayodasi", "Chaturdasi", "Pournami" // Shukla ends with Pournami
        // Krishna paksha ends with Amavasai
    };

    private final AstronomyService astronomyService;

    public ThithiCalculator(AstronomyService astronomyService) {
        this.astronomyService = astronomyService;
    }

    /**
     * Calculate the current Thithi based on Moon-Sun angle.
     *
     * @param baseTime The reference time (typically sunrise)
     * @return Thithi with name, paksha, and end time
     */
    public Thithi calculate(ZonedDateTime baseTime) {
        double moonSunAngle = astronomyService.getMoonSunAngle(baseTime);

        // Calculate thithi number (1-30)
        int thithiNumber = (int) (moonSunAngle / THITHI_SPAN) + 1;
        if (thithiNumber > 30) thithiNumber = 30;

        // Determine paksha and thithi name
        Paksha paksha;
        String name;

        if (thithiNumber <= 15) {
            // Shukla Paksha (waxing moon, 0-180°)
            paksha = Paksha.SHUKLA;
            if (thithiNumber == 15) {
                name = "Pournami"; // Full Moon
            } else {
                name = THITHI_NAMES[thithiNumber - 1];
            }
        } else {
            // Krishna Paksha (waning moon, 180-360°)
            paksha = Paksha.KRISHNA;
            int krishnaThithi = thithiNumber - 15;
            if (krishnaThithi == 15) {
                name = "Amavasai"; // New Moon
            } else {
                name = THITHI_NAMES[krishnaThithi - 1];
            }
        }

        // Calculate when this thithi ends
        double nextThithiAngle = thithiNumber * THITHI_SPAN;
        if (nextThithiAngle >= 360) nextThithiAngle = 0;

        ZonedDateTime endTime = findThithiEndTime(baseTime, nextThithiAngle);

        return new Thithi(name, paksha, endTime);
    }

    /**
     * Get the thithi number (1-30) from Moon-Sun angle.
     */
    public int getThithiNumber(double moonSunAngle) {
        int num = (int) (moonSunAngle / THITHI_SPAN) + 1;
        return Math.min(num, 30);
    }

    /**
     * Check if the thithi is special (Ekadasi, Pournami, Amavasya, etc.)
     */
    public boolean isSpecialThithi(int thithiNumber) {
        return thithiNumber == 11 || thithiNumber == 15 || // Shukla Ekadasi, Pournami
               thithiNumber == 26 || thithiNumber == 30;   // Krishna Ekadasi, Amavasya
    }

    private ZonedDateTime findThithiEndTime(ZonedDateTime startTime, double targetAngle) {
        // Search up to 48 hours
        ZonedDateTime endTime = astronomyService.findMoonSunAngle(startTime, targetAngle, 48);

        if (endTime == null) {
            // Fallback: estimate based on average thithi duration (~24 hours)
            double currentAngle = astronomyService.getMoonSunAngle(startTime);
            double angleDiff = targetAngle - currentAngle;
            if (angleDiff < 0) angleDiff += 360;
            if (angleDiff > 12) angleDiff = 12; // Cap at one thithi

            // Moon-Sun angle increases ~12° per day
            long hoursToTarget = (long) (angleDiff / 0.5);
            endTime = startTime.plusHours(hoursToTarget);
        }

        return endTime;
    }
}
