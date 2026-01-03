package com.magizh.calendar.model;

import java.time.ZonedDateTime;

/**
 * Thithi (lunar day) - one of 30 thithis in a lunar month
 * @param name Name of the thithi (Prathamai, Dvitiyai, etc.)
 * @param paksha Fortnight (Shukla = waxing, Krishna = waning)
 * @param endTime When this thithi ends
 */
public record Thithi(
    String name,
    Paksha paksha,
    ZonedDateTime endTime
) {
    public enum Paksha {
        SHUKLA("Shukla"),  // Waxing moon
        KRISHNA("Krishna"); // Waning moon

        private final String displayName;

        Paksha(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    public static Thithi sample(ZonedDateTime baseTime) {
        return new Thithi(
            "Panchami",
            Paksha.SHUKLA,
            baseTime.withHour(16).withMinute(30)
        );
    }
}
