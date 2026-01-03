package com.magizh.calendar.model;

import java.time.ZonedDateTime;

/**
 * Nakshatram (lunar mansion/star) - one of 27 nakshatras
 * @param name Name of the nakshatram
 * @param endTime When this nakshatram ends
 * @param lord Ruling deity/planet
 */
public record Nakshatram(
    String name,
    ZonedDateTime endTime,
    String lord
) {
    public static Nakshatram sample(ZonedDateTime baseTime) {
        return new Nakshatram(
            "Rohini",
            baseTime.withHour(14).withMinute(45),
            "Moon"
        );
    }
}
