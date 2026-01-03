package com.magizh.calendar.service;

import com.magizh.calendar.model.*;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Service for calculating Panchangam data.
 * Currently returns mock data; Swiss Ephemeris integration planned.
 */
@Service
public class PanchangamService {

    /**
     * Get Panchangam data for a specific date and location
     *
     * @param date     The date to get panchangam for
     * @param lat      Latitude of the location
     * @param lng      Longitude of the location
     * @param timezone Timezone string (e.g., "Asia/Kolkata")
     * @return PanchangamResponse with all five angams
     */
    public PanchangamResponse getDailyPanchangam(
            LocalDate date,
            double lat,
            double lng,
            String timezone
    ) {
        var zoneId = ZoneId.of(timezone);
        var baseTime = date.atStartOfDay(zoneId);

        return generateMockPanchangam(date, baseTime);
    }

    /**
     * Get Panchangam data for a week starting from the given date
     *
     * @param startDate Start date of the week
     * @param lat       Latitude of the location
     * @param lng       Longitude of the location
     * @param timezone  Timezone string
     * @return List of PanchangamResponse for 7 days
     */
    public List<PanchangamResponse> getWeeklyPanchangam(
            LocalDate startDate,
            double lat,
            double lng,
            String timezone
    ) {
        List<PanchangamResponse> weekData = new ArrayList<>();

        for (int i = 0; i < 7; i++) {
            var date = startDate.plusDays(i);
            weekData.add(getDailyPanchangam(date, lat, lng, timezone));
        }

        return weekData;
    }

    /**
     * Generate mock Panchangam data for development
     * Will be replaced with Swiss Ephemeris calculations
     */
    private PanchangamResponse generateMockPanchangam(LocalDate date, ZonedDateTime baseTime) {
        // Tamil date (simplified mock)
        var tamilDate = new TamilDate(
            getTamilMonth(date),
            getTamilDay(date),
            "Krodhana",
            getTamilWeekday(date)
        );

        // Five angams
        var nakshatram = Nakshatram.sample(baseTime);
        var thithi = Thithi.sample(baseTime);
        var yogam = Yogam.sampleAuspicious(baseTime);
        var karanam = Karanam.sample(baseTime);

        // Timings
        var timings = Timings.sample(baseTime);

        // Food status based on thithi
        var foodStatus = determineFoodStatus(thithi);

        return new PanchangamResponse(
            date,
            tamilDate,
            nakshatram,
            thithi,
            yogam,
            karanam,
            timings,
            foodStatus
        );
    }

    private String getTamilMonth(LocalDate date) {
        // Simplified: map Gregorian months to Tamil months (approximate)
        return switch (date.getMonthValue()) {
            case 1 -> "Thai";
            case 2 -> "Maasi";
            case 3 -> "Panguni";
            case 4 -> "Chithirai";
            case 5 -> "Vaikasi";
            case 6 -> "Aani";
            case 7 -> "Aadi";
            case 8 -> "Aavani";
            case 9 -> "Purattasi";
            case 10 -> "Aippasi";
            case 11 -> "Karthigai";
            case 12 -> "Margazhi";
            default -> "Unknown";
        };
    }

    private int getTamilDay(LocalDate date) {
        // Simplified: offset from Gregorian day
        return ((date.getDayOfMonth() + 16) % 30) + 1;
    }

    private String getTamilWeekday(LocalDate date) {
        return switch (date.getDayOfWeek()) {
            case SUNDAY -> "Nyairu";
            case MONDAY -> "Thingal";
            case TUESDAY -> "Sevvai";
            case WEDNESDAY -> "Budhan";
            case THURSDAY -> "Viyazhan";
            case FRIDAY -> "Velli";
            case SATURDAY -> "Sani";
        };
    }

    private FoodStatus determineFoodStatus(Thithi thithi) {
        // Check for special thithis
        if (thithi.name().contains("Ekadasi")) {
            return FoodStatus.fasting();
        } else if (thithi.name().equals("Amavasya")) {
            return FoodStatus.avoidNonVeg();
        }
        return FoodStatus.regular();
    }
}
