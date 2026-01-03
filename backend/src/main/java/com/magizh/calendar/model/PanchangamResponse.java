package com.magizh.calendar.model;

import java.time.LocalDate;

/**
 * Complete Panchangam response for a single day
 * Contains all five angams plus timing and food information
 *
 * @param date Gregorian date
 * @param tamilDate Tamil calendar date
 * @param nakshatram Current nakshatram (lunar mansion)
 * @param thithi Current thithi (lunar day)
 * @param yogam Current yogam
 * @param karanam Current karanam
 * @param timings All timing information
 * @param foodStatus Food guidance for the day
 */
public record PanchangamResponse(
    LocalDate date,
    TamilDate tamilDate,
    Nakshatram nakshatram,
    Thithi thithi,
    Yogam yogam,
    Karanam karanam,
    Timings timings,
    FoodStatus foodStatus
) {}
