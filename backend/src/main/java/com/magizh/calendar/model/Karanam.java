package com.magizh.calendar.model;

import java.time.ZonedDateTime;

/**
 * Karanam - half of a thithi (60 karanams in a lunar month)
 * @param name Name of the karanam (Bava, Balava, etc.)
 * @param endTime When this karanam ends
 */
public record Karanam(
    String name,
    ZonedDateTime endTime
) {
    public static Karanam sample(ZonedDateTime baseTime) {
        return new Karanam(
            "Bava",
            baseTime.withHour(10).withMinute(15)
        );
    }
}
