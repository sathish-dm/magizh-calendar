package com.magizh.calendar.model;

import java.time.ZonedDateTime;
import java.util.List;

/**
 * All timing information for a day
 * @param sunrise Sunrise time
 * @param sunset Sunset time
 * @param nallaNeram List of auspicious time periods
 * @param rahukaalam Inauspicious period ruled by Rahu
 * @param yamagandam Inauspicious period ruled by Yama
 * @param kuligai Inauspicious period (optional)
 */
public record Timings(
    ZonedDateTime sunrise,
    ZonedDateTime sunset,
    List<TimeRange> nallaNeram,
    TimeRange rahukaalam,
    TimeRange yamagandam,
    TimeRange kuligai
) {
    public static Timings sample(ZonedDateTime baseTime) {
        var sunrise = baseTime.withHour(6).withMinute(42);
        var sunset = baseTime.withHour(17).withMinute(54);

        var nallaNeram1 = new TimeRange(
            baseTime.withHour(9).withMinute(15),
            baseTime.withHour(10).withMinute(30),
            TimeRange.TimingType.NALLA_NERAM
        );
        var nallaNeram2 = new TimeRange(
            baseTime.withHour(15).withMinute(0),
            baseTime.withHour(16).withMinute(30),
            TimeRange.TimingType.NALLA_NERAM
        );

        var rahukaalam = new TimeRange(
            baseTime.withHour(13).withMinute(30),
            baseTime.withHour(15).withMinute(0),
            TimeRange.TimingType.RAHUKAALAM
        );

        var yamagandam = new TimeRange(
            baseTime.withHour(7).withMinute(30),
            baseTime.withHour(9).withMinute(0),
            TimeRange.TimingType.YAMAGANDAM
        );

        var kuligai = new TimeRange(
            baseTime.withHour(10).withMinute(30),
            baseTime.withHour(12).withMinute(0),
            TimeRange.TimingType.KULIGAI
        );

        return new Timings(
            sunrise, sunset,
            List.of(nallaNeram1, nallaNeram2),
            rahukaalam, yamagandam, kuligai
        );
    }
}
