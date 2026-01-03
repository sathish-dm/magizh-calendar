package com.magizh.calendar.service;

import com.magizh.calendar.model.*;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Service for calculating Panchangam data using Swiss Ephemeris.
 * Provides accurate astronomical calculations for Tamil calendar.
 */
@Service
public class PanchangamService {

    private final AstronomyService astronomyService;
    private final NakshatramCalculator nakshatramCalculator;
    private final ThithiCalculator thithiCalculator;
    private final YogamCalculator yogamCalculator;
    private final KaranamCalculator karanamCalculator;
    private final TimingsCalculator timingsCalculator;
    private final TamilCalendarService tamilCalendarService;

    public PanchangamService(
            AstronomyService astronomyService,
            NakshatramCalculator nakshatramCalculator,
            ThithiCalculator thithiCalculator,
            YogamCalculator yogamCalculator,
            KaranamCalculator karanamCalculator,
            TimingsCalculator timingsCalculator,
            TamilCalendarService tamilCalendarService
    ) {
        this.astronomyService = astronomyService;
        this.nakshatramCalculator = nakshatramCalculator;
        this.thithiCalculator = thithiCalculator;
        this.yogamCalculator = yogamCalculator;
        this.karanamCalculator = karanamCalculator;
        this.timingsCalculator = timingsCalculator;
        this.tamilCalendarService = tamilCalendarService;
    }

    /**
     * Get Panchangam data for a specific date and location.
     *
     * @param date     The date to get panchangam for
     * @param lat      Latitude of the location
     * @param lng      Longitude of the location
     * @param timezone Timezone string (e.g., "Asia/Kolkata")
     * @return PanchangamResponse with all five angams and timings
     */
    public PanchangamResponse getDailyPanchangam(
            LocalDate date,
            double lat,
            double lng,
            String timezone
    ) {
        ZoneId zoneId = ZoneId.of(timezone);

        // Calculate sunrise and sunset for the location
        ZonedDateTime sunrise = astronomyService.calculateSunrise(date, lat, lng, zoneId);
        ZonedDateTime sunset = astronomyService.calculateSunset(date, lat, lng, zoneId);

        // Calculate Tamil date using Sun's position at sunrise
        TamilDate tamilDate = tamilCalendarService.calculate(date, sunrise);

        // Calculate the five angams at sunrise
        Nakshatram nakshatram = nakshatramCalculator.calculate(sunrise);
        Thithi thithi = thithiCalculator.calculate(sunrise);
        Yogam yogam = yogamCalculator.calculate(sunrise);
        Karanam karanam = karanamCalculator.calculate(sunrise);

        // Calculate timings based on sunrise/sunset
        Timings timings = timingsCalculator.calculate(sunrise, sunset, date.getDayOfWeek());

        // Determine food status based on thithi
        FoodStatus foodStatus = determineFoodStatus(thithi);

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

    /**
     * Get Panchangam data for a week starting from the given date.
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
            LocalDate date = startDate.plusDays(i);
            weekData.add(getDailyPanchangam(date, lat, lng, timezone));
        }

        return weekData;
    }

    /**
     * Determine food status based on the thithi.
     * Special thithis like Ekadasi and Amavasya have dietary recommendations.
     */
    private FoodStatus determineFoodStatus(Thithi thithi) {
        String name = thithi.name();

        if (name.contains("Ekadasi")) {
            return FoodStatus.fasting();
        } else if (name.equals("Amavasya")) {
            return FoodStatus.avoidNonVeg();
        } else if (name.equals("Pournami")) {
            return FoodStatus.avoidNonVeg();
        } else if (name.contains("Ashtami")) {
            // Some traditions avoid non-veg on Ashtami
            return FoodStatus.regular();
        }

        return FoodStatus.regular();
    }
}
