package com.magizh.calendar.model;

/**
 * Food status and recommendations for the day
 * @param type Type of food guidance
 * @param message User-friendly message
 * @param nextAuspicious Information about next auspicious day (if applicable)
 */
public record FoodStatus(
    FoodType type,
    String message,
    NextAuspiciousDay nextAuspicious
) {
    public enum FoodType {
        REGULAR("regular"),
        FASTING("fasting"),
        AVOID_NON_VEG("avoidNonVeg"),
        SPECIAL("special");

        private final String value;

        FoodType(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }

    public record NextAuspiciousDay(
        String name,
        String date,
        int daysAway
    ) {}

    public static FoodStatus regular() {
        return new FoodStatus(
            FoodType.REGULAR,
            "No dietary restrictions today",
            new NextAuspiciousDay("Ekadasi", "Jan 10", 7)
        );
    }

    public static FoodStatus fasting() {
        return new FoodStatus(
            FoodType.FASTING,
            "Ekadasi - Fasting recommended",
            null
        );
    }

    public static FoodStatus avoidNonVeg() {
        return new FoodStatus(
            FoodType.AVOID_NON_VEG,
            "Amavasya - Avoid non-vegetarian food",
            new NextAuspiciousDay("Pournami", "Jan 15", 12)
        );
    }
}
