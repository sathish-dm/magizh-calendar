package com.magizh.calendar.model;

import java.time.ZonedDateTime;

/**
 * Yogam - combination of sun and moon positions (27 yogams)
 * @param name Name of the yogam (Siddhi, Amirtha, etc.)
 * @param type Whether the yogam is auspicious or not
 * @param startTime When this yogam starts
 * @param endTime When this yogam ends
 */
public record Yogam(
    String name,
    YogamType type,
    ZonedDateTime startTime,
    ZonedDateTime endTime
) {
    public enum YogamType {
        AUSPICIOUS("auspicious"),
        INAUSPICIOUS("inauspicious"),
        NEUTRAL("neutral");

        private final String value;

        YogamType(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }

    public static Yogam sampleAuspicious(ZonedDateTime baseTime) {
        return new Yogam(
            "Siddhi",
            YogamType.AUSPICIOUS,
            baseTime.withHour(8).withMinute(30),
            baseTime.withHour(14).withMinute(15)
        );
    }

    public static Yogam sampleInauspicious(ZonedDateTime baseTime) {
        return new Yogam(
            "Vishkumbha",
            YogamType.INAUSPICIOUS,
            baseTime.withHour(6).withMinute(0),
            baseTime.withHour(18).withMinute(0)
        );
    }
}
