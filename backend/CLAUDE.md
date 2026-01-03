# Magizh Calendar API - Claude Code Guide

## Project Overview
Tamil Panchangam Calendar REST API built with Spring Boot 3.3 and Java 21.

## Tech Stack
- **Java 21** (LTS) - Records, Pattern Matching, Virtual Threads
- **Spring Boot 3.3.7** - Latest stable release
- **Maven** - Build tool
- **Virtual Threads** - Enabled for scalable concurrency

## Project Structure
```
src/main/java/com/magizh/calendar/
├── MagizhCalendarApiApplication.java   # Entry point
├── controller/
│   └── PanchangamController.java       # REST endpoints
├── service/
│   └── PanchangamService.java          # Business logic
├── model/                              # Java 21 Records
│   ├── PanchangamResponse.java
│   ├── TamilDate.java
│   ├── Nakshatram.java
│   ├── Thithi.java
│   ├── Yogam.java
│   ├── Karanam.java
│   ├── TimeRange.java
│   ├── Timings.java
│   └── FoodStatus.java
└── config/                             # Configuration (planned)
```

## API Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/panchangam/daily` | Daily panchangam data |
| GET | `/api/panchangam/weekly` | Weekly panchangam data |
| GET | `/api/panchangam/health` | Health check |

### Query Parameters
- `date` / `startDate` - Date in YYYY-MM-DD format
- `lat` - Latitude (default: 13.0827 Chennai)
- `lng` - Longitude (default: 80.2707 Chennai)
- `timezone` - Timezone string (default: Asia/Kolkata)

## Commands
```bash
# Build
mvn clean compile

# Run
mvn spring-boot:run

# Package
mvn clean package

# Run JAR
java -jar target/magizh-calendar-api-0.0.1-SNAPSHOT.jar
```

## Coding Conventions

### Java 21 Features to Use
- **Records** for all DTOs (immutable by default)
- **Sealed interfaces** for type hierarchies
- **Pattern matching** in switch expressions
- **var** for local variable type inference
- **Text blocks** for multi-line strings

### Spring Conventions
- Constructor injection (no @Autowired needed)
- @Validated for input validation
- ResponseEntity for HTTP responses
- @CrossOrigin for CORS

### Example Record
```java
public record TamilDate(
    String month,
    int day,
    String year,
    String weekday
) {}
```

### Example Controller
```java
@GetMapping("/daily")
public ResponseEntity<PanchangamResponse> getDaily(
    @RequestParam @NotNull LocalDate date,
    @RequestParam(defaultValue = "13.0827") double lat
) {
    return ResponseEntity.ok(service.getDailyPanchangam(date, lat, lng, tz));
}
```

## Workflow Rules
1. Run `mvn clean compile` after changes
2. Test endpoints with curl before committing
3. Update PROGRESS.md after milestones
4. Commit with descriptive messages

## Configuration
- Port: 8080
- Virtual threads: enabled
- CORS: all origins allowed (dev mode)
- Actuator endpoints: health, info

## Related Projects
- **iOS App:** `magizh-calendar-ios` - SwiftUI client
- **Docs:** See `docs/SUMMARY.md` for architecture overview
