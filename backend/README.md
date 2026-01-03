# Magizh Calendar API

Tamil Panchangam Calendar API built with Spring Boot 3.3 and Java 21.

## Features

- Daily and weekly Panchangam data
- Five angams (Nakshatram, Thithi, Yogam, Karanam, Vaaram)
- Auspicious/inauspicious timings (Nalla Neram, Rahukaalam, Yamagandam)
- Food status guidance
- Location-aware calculations
- OpenAPI/Swagger documentation
- RFC 7807 Problem Details for errors
- Docker support

## Tech Stack

| Component | Technology |
|-----------|------------|
| Language | Java 21 (LTS) |
| Framework | Spring Boot 3.3.7 |
| Build | Maven |
| Concurrency | Virtual Threads |
| DTOs | Java Records |
| Docs | SpringDoc OpenAPI 2.3 |

## Quick Start

### Using Make (Recommended)

```bash
make run       # Start server
make build     # Compile project
make test      # Run tests
make swagger   # Open Swagger UI
make health    # Check health endpoint
make daily     # Test daily endpoint
```

### Using Maven

```bash
./mvnw spring-boot:run
```

### Using Docker

```bash
# Build and run
make docker-build
make docker-run

# Or using docker-compose
docker-compose up -d
```

## API Documentation

Swagger UI: http://localhost:8080/swagger-ui/index.html

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/panchangam/daily` | Daily panchangam data |
| `GET /api/panchangam/weekly` | Weekly panchangam data |
| `GET /api/panchangam/health` | Health check |

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `date` | LocalDate | No | Today | Date (YYYY-MM-DD) |
| `lat` | double | No | 13.0827 | Latitude |
| `lng` | double | No | 80.2707 | Longitude |
| `timezone` | String | No | Asia/Kolkata | Timezone ID |

### Example Requests

```bash
# Daily panchangam for Chennai
curl "http://localhost:8080/api/panchangam/daily?date=2026-01-03&lat=13.0827&lng=80.2707&timezone=Asia/Kolkata"

# Weekly panchangam
curl "http://localhost:8080/api/panchangam/weekly?startDate=2026-01-03"

# Health check
curl "http://localhost:8080/api/panchangam/health"
```

## Project Structure

```
backend/
├── src/main/java/com/magizh/calendar/
│   ├── MagizhCalendarApiApplication.java
│   ├── config/
│   │   ├── GlobalExceptionHandler.java  # RFC 7807 errors
│   │   ├── OpenApiConfig.java           # Swagger config
│   │   └── RequestLoggingConfig.java    # Request logging
│   ├── controller/
│   │   └── PanchangamController.java
│   ├── model/
│   │   ├── PanchangamResponse.java      # Main response
│   │   ├── TamilDate.java
│   │   ├── Nakshatram.java
│   │   ├── Thithi.java
│   │   ├── Yogam.java
│   │   └── ...
│   └── service/
│       └── PanchangamService.java
├── src/main/resources/
│   └── application.yml
├── Dockerfile
├── docker-compose.yml
├── Makefile
└── pom.xml
```

## Configuration

Default settings in `application.yml`:

```yaml
server:
  port: 8080

spring:
  threads:
    virtual:
      enabled: true  # Java 21 Virtual Threads

logging:
  level:
    com.magizh: DEBUG
```

## Development

This API currently returns mock data. Swiss Ephemeris integration is planned for accurate astronomical calculations.

Part of the [Magizh Calendar](https://github.com/sathish-dm/magizh-calendar) monorepo.
