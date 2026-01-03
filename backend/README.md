# Magizh Calendar API

Tamil Panchangam Calendar API built with Spring Boot 3.3 and Java 21.

## Features

- Daily and weekly Panchangam data
- Five angams (Nakshatram, Thithi, Yogam, Karanam, Vaaram)
- Auspicious/inauspicious timings (Nalla Neram, Rahukaalam, Yamagandam)
- Food status guidance
- Location-aware calculations

## Tech Stack

- Java 21 (LTS)
- Spring Boot 3.3
- Virtual Threads enabled
- Swiss Ephemeris (planned)

## API Endpoints

### Get Daily Panchangam
```
GET /api/panchangam/daily?date=2026-01-03&lat=13.0827&lng=80.2707&timezone=Asia/Kolkata
```

### Get Weekly Panchangam
```
GET /api/panchangam/weekly?startDate=2026-01-03&lat=13.0827&lng=80.2707&timezone=Asia/Kolkata
```

### Health Check
```
GET /api/panchangam/health
```

## Running Locally

```bash
# Build
./mvnw clean package

# Run
./mvnw spring-boot:run

# Or run the JAR
java -jar target/magizh-calendar-api-0.0.1-SNAPSHOT.jar
```

The API will be available at `http://localhost:8080`

## Configuration

Default configuration in `application.yml`:
- Port: 8080
- Virtual threads: enabled
- CORS: enabled for all origins

## Development

This API currently returns mock data. Swiss Ephemeris integration is planned for accurate astronomical calculations.

## License

Private - Magizh Calendar Project
