package com.magizh.calendar.model;

import java.time.ZonedDateTime;

/**
 * Time range for various periods (Nalla Neram, Rahukaalam, etc.)
 * @param startTime Start of the period
 * @param endTime End of the period
 * @param type Type of timing period
 */
public record TimeRange(
    ZonedDateTime startTime,
    ZonedDateTime endTime,
    TimingType type
) {
    public enum TimingType {
        NALLA_NERAM("nallaNeram", true),
        RAHUKAALAM("rahukaalam", false),
        YAMAGANDAM("yamagandam", false),
        KULIGAI("kuligai", false),
        GOWRI_NALLA_NERAM("gowriNallaNeram", true);

        private final String value;
        private final boolean auspicious;

        TimingType(String value, boolean auspicious) {
            this.value = value;
            this.auspicious = auspicious;
        }

        public String getValue() {
            return value;
        }

        public boolean isAuspicious() {
            return auspicious;
        }
    }

    public String formatted() {
        return String.format("%02d:%02d - %02d:%02d",
            startTime.getHour(), startTime.getMinute(),
            endTime.getHour(), endTime.getMinute());
    }
}
