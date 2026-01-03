package com.magizh.calendar.service;

import com.magizh.calendar.model.TamilDate;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZonedDateTime;

/**
 * Service for Tamil calendar calculations.
 *
 * The Tamil calendar is a solar calendar where:
 * - Months are based on the Sun's position in zodiac signs (rasis)
 * - Year starts when Sun enters Mesha (Aries) - typically mid-April
 * - Year names follow a 60-year cycle (Prabhava to Akshaya)
 */
@Service
public class TamilCalendarService {

    // Tamil month names (based on Sun's position in zodiac)
    private static final String[] TAMIL_MONTHS = {
        "Chithirai",   // Mesha (Aries) - mid-April to mid-May
        "Vaikasi",     // Vrishabha (Taurus)
        "Aani",        // Mithuna (Gemini)
        "Aadi",        // Kataka (Cancer)
        "Aavani",      // Simha (Leo)
        "Purattasi",   // Kanya (Virgo)
        "Aippasi",     // Tula (Libra)
        "Karthigai",   // Vrischika (Scorpio)
        "Margazhi",    // Dhanu (Sagittarius)
        "Thai",        // Makara (Capricorn)
        "Maasi",       // Kumbha (Aquarius)
        "Panguni"      // Meena (Pisces)
    };

    // Tamil weekday names
    private static final String[] TAMIL_WEEKDAYS = {
        "Nyairu",      // Sunday
        "Thingal",     // Monday
        "Sevvai",      // Tuesday
        "Budhan",      // Wednesday
        "Viyazhan",    // Thursday
        "Velli",       // Friday
        "Sani"         // Saturday
    };

    // 60-year cycle names (Prabhava to Akshaya)
    private static final String[] YEAR_NAMES = {
        "Prabhava", "Vibhava", "Shukla", "Pramodoota", "Prajotpatti",
        "Angirasa", "Srimukha", "Bhava", "Yuva", "Dhatu",
        "Eeshwara", "Vehudhanya", "Pramathi", "Vikrama", "Vrisha",
        "Chitrabhanu", "Svabhanu", "Tarana", "Parthiva", "Vyaya",
        "Sarvajit", "Sarvadhari", "Virodhi", "Vikruti", "Khara",
        "Nandana", "Vijaya", "Jaya", "Manmatha", "Durmukhi",
        "Hevilambi", "Vilambi", "Vikari", "Sharvari", "Plava",
        "Shubhakrut", "Shobhakrut", "Krodhi", "Vishvavasu", "Parabhava",
        "Plavanga", "Kilaka", "Saumya", "Sadharana", "Virodhikrut",
        "Paritapi", "Pramadeecha", "Ananda", "Rakshasa", "Nala",
        "Pingala", "Kalayukti", "Siddharthi", "Raudra", "Durmathi",
        "Dundubhi", "Rudhirodgari", "Raktakshi", "Krodhana", "Akshaya"
    };

    // Approximate date when each Tamil month starts (day of Gregorian month)
    // Sun enters each zodiac sign around these dates
    private static final int[][] MONTH_START_DATES = {
        {4, 14},   // Chithirai starts ~April 14
        {5, 15},   // Vaikasi starts ~May 15
        {6, 15},   // Aani starts ~June 15
        {7, 17},   // Aadi starts ~July 17
        {8, 17},   // Aavani starts ~August 17
        {9, 17},   // Purattasi starts ~September 17
        {10, 18},  // Aippasi starts ~October 18
        {11, 17},  // Karthigai starts ~November 17
        {12, 16},  // Margazhi starts ~December 16
        {1, 15},   // Thai starts ~January 15
        {2, 13},   // Maasi starts ~February 13
        {3, 15}    // Panguni starts ~March 15
    };

    private final AstronomyService astronomyService;

    public TamilCalendarService(AstronomyService astronomyService) {
        this.astronomyService = astronomyService;
    }

    /**
     * Calculate Tamil date for a given Gregorian date.
     *
     * @param date The Gregorian date
     * @param sunrise Sunrise time (for accurate Sun position)
     * @return TamilDate with month, day, year name, and weekday
     */
    public TamilDate calculate(LocalDate date, ZonedDateTime sunrise) {
        // Get Sun's longitude to determine Tamil month
        double sunLongitude = astronomyService.getSunLongitude(sunrise);

        // Determine Tamil month from Sun's zodiac position
        int monthIndex = getTamilMonthFromSunPosition(sunLongitude);
        String tamilMonth = TAMIL_MONTHS[monthIndex];

        // Calculate Tamil day within the month
        int tamilDay = calculateTamilDay(date, monthIndex);

        // Calculate Tamil year name
        String yearName = calculateYearName(date);

        // Get Tamil weekday
        String weekday = getTamilWeekday(date.getDayOfWeek());

        return new TamilDate(tamilMonth, tamilDay, yearName, weekday);
    }

    /**
     * Get Tamil month based on Sun's ecliptic longitude.
     * Each zodiac sign (rasi) spans 30 degrees.
     */
    private int getTamilMonthFromSunPosition(double sunLongitude) {
        // Sun at 0° = Aries (Mesha) = Chithirai
        // Each rasi spans 30°
        int rasiIndex = (int) (sunLongitude / 30.0);
        return rasiIndex % 12;
    }

    /**
     * Calculate the Tamil day within the current month.
     * This is approximate - proper calculation requires knowing exact month start.
     */
    private int calculateTamilDay(LocalDate date, int monthIndex) {
        // Find the approximate start date of the current Tamil month
        int[] startDate = MONTH_START_DATES[monthIndex];
        int startMonth = startDate[0];
        int startDay = startDate[1];

        // Create start date in the appropriate year
        int year = date.getYear();
        LocalDate monthStart;

        if (date.getMonthValue() < startMonth ||
            (date.getMonthValue() == startMonth && date.getDayOfMonth() < startDay)) {
            // Month started in previous Gregorian year (for months like Thai, Maasi, Panguni)
            if (monthIndex >= 9) { // Thai (Jan), Maasi (Feb), Panguni (Mar)
                year = date.getYear();
            }
        }

        try {
            monthStart = LocalDate.of(year, startMonth, startDay);
        } catch (Exception e) {
            // Handle edge cases (e.g., Feb 29)
            monthStart = LocalDate.of(year, startMonth, Math.min(startDay, 28));
        }

        // Calculate days since month start
        long daysSinceStart = java.time.temporal.ChronoUnit.DAYS.between(monthStart, date);

        // Tamil day (1-based)
        int tamilDay = (int) daysSinceStart + 1;

        // Ensure valid range (1-32, Tamil months can have 29-32 days)
        if (tamilDay < 1) tamilDay = 1;
        if (tamilDay > 32) tamilDay = 32;

        return tamilDay;
    }

    /**
     * Calculate the Tamil year name from the 60-year cycle.
     * The cycle started in 3102 BCE (Kali Yuga).
     */
    private String calculateYearName(LocalDate date) {
        // Tamil New Year is typically April 14
        int year = date.getYear();
        int month = date.getMonthValue();

        // If before Tamil New Year (April 14), use previous year
        if (month < 4 || (month == 4 && date.getDayOfMonth() < 14)) {
            year--;
        }

        // Calculate position in 60-year cycle
        // Kali Yuga started in 3102 BCE, and year 1 of the cycle was Prabhava
        // Current calculation based on CE years
        // Year 2000 CE was approximately "Vikruti" (year 24 in cycle)
        int kaliYears = year + 3102; // Years since Kali Yuga
        int cyclePosition = (kaliYears - 1) % 60;

        return YEAR_NAMES[cyclePosition];
    }

    /**
     * Get Tamil weekday name.
     */
    public String getTamilWeekday(DayOfWeek dayOfWeek) {
        // Convert Java DayOfWeek (Monday=1) to our index (Sunday=0)
        int index = dayOfWeek.getValue() % 7; // Sunday becomes 0
        return TAMIL_WEEKDAYS[index];
    }

    /**
     * Get the Tamil month name for an index (0-11).
     */
    public String getTamilMonthName(int index) {
        return TAMIL_MONTHS[index % 12];
    }
}
