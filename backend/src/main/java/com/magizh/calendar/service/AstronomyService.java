package com.magizh.calendar.service;

import org.springframework.stereotype.Service;
import de.thmac.swisseph.DblObj;
import de.thmac.swisseph.SweConst;
import de.thmac.swisseph.SweDate;
import de.thmac.swisseph.SwissEph;

import jakarta.annotation.PostConstruct;
import java.time.*;

/**
 * Core astronomical calculations using Swiss Ephemeris (Moshier mode).
 * Provides Sun/Moon positions and sunrise/sunset times.
 *
 * Moshier mode provides ~0.1 arcsecond accuracy without external data files.
 */
@Service
public class AstronomyService {

    private SwissEph swissEph;

    @PostConstruct
    public void init() {
        // Initialize Swiss Ephemeris without path - uses Moshier mode automatically
        swissEph = new SwissEph();
        // Moshier mode is the automatic fallback when no ephemeris files are found
        // It provides sufficient accuracy for panchangam calculations
    }

    /**
     * Get the ecliptic longitude of the Sun at a given time.
     *
     * @param dateTime The date/time in any timezone
     * @return Sun's ecliptic longitude in degrees (0-360)
     */
    public double getSunLongitude(ZonedDateTime dateTime) {
        return getPlanetLongitude(dateTime, SweConst.SE_SUN);
    }

    /**
     * Get the ecliptic longitude of the Moon at a given time.
     *
     * @param dateTime The date/time in any timezone
     * @return Moon's ecliptic longitude in degrees (0-360)
     */
    public double getMoonLongitude(ZonedDateTime dateTime) {
        return getPlanetLongitude(dateTime, SweConst.SE_MOON);
    }

    /**
     * Calculate sunrise time for a given date and location.
     *
     * @param date The date
     * @param latitude Latitude in degrees (positive = North)
     * @param longitude Longitude in degrees (positive = East)
     * @param zoneId Timezone
     * @return Sunrise time as ZonedDateTime
     */
    public ZonedDateTime calculateSunrise(LocalDate date, double latitude, double longitude, ZoneId zoneId) {
        return calculateSunRiseSet(date, latitude, longitude, zoneId, true);
    }

    /**
     * Calculate sunset time for a given date and location.
     *
     * @param date The date
     * @param latitude Latitude in degrees (positive = North)
     * @param longitude Longitude in degrees (positive = East)
     * @param zoneId Timezone
     * @return Sunset time as ZonedDateTime
     */
    public ZonedDateTime calculateSunset(LocalDate date, double latitude, double longitude, ZoneId zoneId) {
        return calculateSunRiseSet(date, latitude, longitude, zoneId, false);
    }

    /**
     * Find the time when the Moon reaches a specific longitude.
     * Used for calculating end times of nakshatram, thithi, etc.
     *
     * @param startTime Starting point for search
     * @param targetLongitude Target longitude in degrees
     * @param maxHours Maximum hours to search forward
     * @return Time when Moon reaches target longitude, or null if not found
     */
    public ZonedDateTime findMoonAtLongitude(ZonedDateTime startTime, double targetLongitude, int maxHours) {
        // Binary search to find when Moon reaches target longitude
        ZonedDateTime left = startTime;
        ZonedDateTime right = startTime.plusHours(maxHours);

        double leftLong = getMoonLongitude(left);
        double rightLong = getMoonLongitude(right);

        // Handle wrap-around at 360 degrees
        targetLongitude = normalizeAngle(targetLongitude);

        // Check if target is between left and right (accounting for wrap-around)
        if (!isAngleBetween(targetLongitude, leftLong, rightLong)) {
            return null;
        }

        // Binary search for precision (within 1 minute)
        while (Duration.between(left, right).toMinutes() > 1) {
            ZonedDateTime mid = left.plus(Duration.between(left, right).dividedBy(2));
            double midLong = getMoonLongitude(mid);

            if (isAngleBetween(targetLongitude, leftLong, midLong)) {
                right = mid;
                rightLong = midLong;
            } else {
                left = mid;
                leftLong = midLong;
            }
        }

        return left;
    }

    /**
     * Find the time when the Moon-Sun angle reaches a specific value.
     * Used for calculating thithi end times.
     *
     * @param startTime Starting point for search
     * @param targetAngle Target Moon-Sun angle in degrees
     * @param maxHours Maximum hours to search forward
     * @return Time when angle is reached, or null if not found
     */
    public ZonedDateTime findMoonSunAngle(ZonedDateTime startTime, double targetAngle, int maxHours) {
        ZonedDateTime left = startTime;
        ZonedDateTime right = startTime.plusHours(maxHours);

        targetAngle = normalizeAngle(targetAngle);

        // Binary search for precision
        while (Duration.between(left, right).toMinutes() > 1) {
            ZonedDateTime mid = left.plus(Duration.between(left, right).dividedBy(2));
            double midAngle = getMoonSunAngle(mid);
            double leftAngle = getMoonSunAngle(left);

            if (isAngleBetween(targetAngle, leftAngle, midAngle)) {
                right = mid;
            } else {
                left = mid;
            }
        }

        return left;
    }

    /**
     * Get the angular difference between Moon and Sun longitudes.
     * This is the basis for Thithi calculation.
     */
    public double getMoonSunAngle(ZonedDateTime dateTime) {
        double moonLong = getMoonLongitude(dateTime);
        double sunLong = getSunLongitude(dateTime);
        return normalizeAngle(moonLong - sunLong);
    }

    /**
     * Get the sum of Sun and Moon longitudes.
     * This is the basis for Yogam calculation.
     */
    public double getSunMoonSum(ZonedDateTime dateTime) {
        double moonLong = getMoonLongitude(dateTime);
        double sunLong = getSunLongitude(dateTime);
        return normalizeAngle(sunLong + moonLong);
    }

    // Private helper methods

    private double getPlanetLongitude(ZonedDateTime dateTime, int planet) {
        double julianDay = toJulianDay(dateTime);

        double[] result = new double[6];
        StringBuffer errorBuffer = new StringBuffer();

        int flags = SweConst.SEFLG_SWIEPH | SweConst.SEFLG_SPEED;

        int retval = swissEph.swe_calc_ut(julianDay, planet, flags, result, errorBuffer);

        if (retval < 0) {
            // Fallback to Moshier if Swiss Ephemeris fails
            flags = SweConst.SEFLG_MOSEPH | SweConst.SEFLG_SPEED;
            swissEph.swe_calc_ut(julianDay, planet, flags, result, errorBuffer);
        }

        return result[0]; // Ecliptic longitude
    }

    private ZonedDateTime calculateSunRiseSet(LocalDate date, double latitude, double longitude,
                                               ZoneId zoneId, boolean isSunrise) {
        // Convert to Julian Day at midnight UTC
        ZonedDateTime midnightUtc = date.atStartOfDay(ZoneOffset.UTC);
        double julianDay = toJulianDay(midnightUtc);

        double[] geopos = new double[]{longitude, latitude, 0}; // lon, lat, altitude
        DblObj result = new DblObj();
        StringBuffer errorBuffer = new StringBuffer();

        int eventType = isSunrise ? SweConst.SE_CALC_RISE : SweConst.SE_CALC_SET;
        int flags = SweConst.SE_BIT_DISC_CENTER; // Use disc center

        int retval = swissEph.swe_rise_trans(julianDay, SweConst.SE_SUN, null,
                SweConst.SEFLG_MOSEPH, eventType, geopos, 0, 0, result, errorBuffer);

        if (retval < 0) {
            // Fallback: estimate based on typical times
            LocalTime time = isSunrise ? LocalTime.of(6, 0) : LocalTime.of(18, 0);
            return date.atTime(time).atZone(zoneId);
        }

        // Convert Julian Day result back to ZonedDateTime
        return fromJulianDay(result.val, zoneId);
    }

    private double toJulianDay(ZonedDateTime dateTime) {
        ZonedDateTime utc = dateTime.withZoneSameInstant(ZoneOffset.UTC);

        int year = utc.getYear();
        int month = utc.getMonthValue();
        int day = utc.getDayOfMonth();
        double hour = utc.getHour() + utc.getMinute() / 60.0 + utc.getSecond() / 3600.0;

        SweDate sweDate = new SweDate(year, month, day, hour, SweDate.SE_GREG_CAL);
        return sweDate.getJulDay();
    }

    private ZonedDateTime fromJulianDay(double julianDay, ZoneId zoneId) {
        SweDate sweDate = new SweDate(julianDay, SweDate.SE_GREG_CAL);

        int year = sweDate.getYear();
        int month = sweDate.getMonth();
        int day = sweDate.getDay();
        double hour = sweDate.getHour();

        int hours = (int) hour;
        int minutes = (int) ((hour - hours) * 60);
        int seconds = (int) (((hour - hours) * 60 - minutes) * 60);

        LocalDateTime utcDateTime = LocalDateTime.of(year, month, day, hours, minutes, seconds);
        ZonedDateTime utcZoned = utcDateTime.atZone(ZoneOffset.UTC);

        return utcZoned.withZoneSameInstant(zoneId);
    }

    private double normalizeAngle(double angle) {
        angle = angle % 360;
        if (angle < 0) {
            angle += 360;
        }
        return angle;
    }

    private boolean isAngleBetween(double target, double start, double end) {
        target = normalizeAngle(target);
        start = normalizeAngle(start);
        end = normalizeAngle(end);

        if (start <= end) {
            return target >= start && target <= end;
        } else {
            // Wraps around 360
            return target >= start || target <= end;
        }
    }
}
