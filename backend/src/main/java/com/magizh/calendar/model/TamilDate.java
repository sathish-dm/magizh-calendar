package com.magizh.calendar.model;

/**
 * Tamil calendar date representation
 * @param month Tamil month name (Chithirai, Vaikasi, etc.)
 * @param day Day of the Tamil month (1-32)
 * @param year Tamil year name (Krodhana, Viswavasu, etc.)
 * @param weekday Day of week in Tamil (Nyairu, Thingal, etc.)
 */
public record TamilDate(
    String month,
    int day,
    String year,
    String weekday
) {
    public static TamilDate sample() {
        return new TamilDate("Margazhi", 19, "Krodhana", "Velli");
    }
}
