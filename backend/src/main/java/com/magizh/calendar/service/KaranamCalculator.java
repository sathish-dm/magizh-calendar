package com.magizh.calendar.service;

import com.magizh.calendar.model.Karanam;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;

/**
 * Calculator for Karanam.
 *
 * Karanam is half of a Thithi - based on 6° segments of Moon-Sun angle.
 * There are 11 karanams that cycle through the lunar month:
 * - 4 fixed karanams (Shakuni, Chatushpada, Naga, Kimstughna) occur once each
 * - 7 recurring karanams (Bava, Balava, Kaulava, Taitila, Gara, Vanija, Vishti) repeat 8 times
 *
 * Total: 4 + (7 × 8) = 60 karanams per lunar month (30 thithis × 2)
 */
@Service
public class KaranamCalculator {

    private static final double KARANAM_SPAN = 6.0; // Each karanam = 6° (half of thithi's 12°)

    // The 7 recurring karanams (chara karanams)
    private static final String[] RECURRING_KARANAMS = {
        "Bava", "Balava", "Kaulava", "Taitila", "Gara", "Vanija", "Vishti"
    };

    // The 4 fixed karanams (sthira karanams) - matching iOS enum
    private static final String[] FIXED_KARANAMS = {
        "Sakuni", "Chatushpada", "Naga", "Kimstughna"
    };

    private final AstronomyService astronomyService;

    public KaranamCalculator(AstronomyService astronomyService) {
        this.astronomyService = astronomyService;
    }

    /**
     * Calculate the current Karanam based on Moon-Sun angle.
     *
     * @param baseTime The reference time (typically sunrise)
     * @return Karanam with name and end time
     */
    public Karanam calculate(ZonedDateTime baseTime) {
        double moonSunAngle = astronomyService.getMoonSunAngle(baseTime);

        int karanamNumber = (int) (moonSunAngle / KARANAM_SPAN) + 1;
        if (karanamNumber > 60) karanamNumber = 60;

        String name = getKaranamName(karanamNumber);

        // Calculate when this karanam ends
        double nextKaranamAngle = karanamNumber * KARANAM_SPAN;
        if (nextKaranamAngle >= 360) nextKaranamAngle = 0;

        ZonedDateTime endTime = findKaranamEndTime(baseTime, nextKaranamAngle);

        return new Karanam(name, endTime);
    }

    /**
     * Get the karanam name for a given karanam number (1-60).
     *
     * The pattern is:
     * - Karanam 1: Second half of Krishna Chaturdasi = Kimstughna (fixed)
     * - Karanams 2-57: Recurring cycle of 7 karanams (8 complete cycles)
     * - Karanams 58-60: Shakuni, Chatushpada, Naga (fixed)
     */
    public String getKaranamName(int karanamNumber) {
        if (karanamNumber <= 0 || karanamNumber > 60) {
            return RECURRING_KARANAMS[0]; // Default to Bava
        }

        if (karanamNumber == 1) {
            return FIXED_KARANAMS[3]; // Kimstughna
        } else if (karanamNumber >= 58) {
            return FIXED_KARANAMS[karanamNumber - 58]; // Shakuni, Chatushpada, Naga
        } else {
            // Recurring karanams (2-57)
            int recurringIndex = (karanamNumber - 2) % 7;
            return RECURRING_KARANAMS[recurringIndex];
        }
    }

    /**
     * Check if the karanam is Vishti (Bhadra) - considered inauspicious.
     */
    public boolean isVishti(int karanamNumber) {
        String name = getKaranamName(karanamNumber);
        return "Vishti".equals(name);
    }

    private ZonedDateTime findKaranamEndTime(ZonedDateTime startTime, double targetAngle) {
        // Search up to 24 hours (karanams last ~12 hours on average)
        ZonedDateTime endTime = astronomyService.findMoonSunAngle(startTime, targetAngle, 24);

        if (endTime == null) {
            // Fallback: estimate based on average karanam duration (~12 hours)
            double currentAngle = astronomyService.getMoonSunAngle(startTime);
            double angleDiff = targetAngle - currentAngle;
            if (angleDiff < 0) angleDiff += 360;
            if (angleDiff > 6) angleDiff = 6;

            // Moon-Sun angle increases ~12° per day, so ~0.5° per hour
            long hoursToTarget = (long) (angleDiff / 0.5);
            endTime = startTime.plusHours(hoursToTarget);
        }

        return endTime;
    }
}
