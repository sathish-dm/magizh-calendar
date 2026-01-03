# Backend CLAUDE.md - Java/Spring Conventions

> Common rules in `../CLAUDE.md`

## Tech Stack

| Component | Version |
|-----------|---------|
| Java | 21 (LTS) |
| Spring Boot | 3.3.7 |
| Build | Maven |
| Concurrency | Virtual Threads |
| Docs | SpringDoc OpenAPI 2.3 |

## Project Structure

```
src/main/java/com/magizh/calendar/
├── MagizhCalendarApiApplication.java
├── controller/
│   └── PanchangamController.java
├── service/
│   └── PanchangamService.java
├── model/                    # Java 21 Records
│   ├── PanchangamResponse.java
│   ├── TamilDate.java
│   └── ...
└── config/
    ├── GlobalExceptionHandler.java
    ├── OpenApiConfig.java
    └── RequestLoggingConfig.java
```

## Commands

```bash
# Using Make (recommended)
make run          # Start server
make build        # Compile
make test         # Run tests
make swagger      # Open Swagger UI
make docker-run   # Run in Docker

# Using Maven
./mvnw spring-boot:run
./mvnw clean compile
./mvnw clean package
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/panchangam/daily` | Daily panchangam |
| GET | `/api/panchangam/weekly` | Weekly panchangam |
| GET | `/api/panchangam/health` | Health check |

**Swagger UI:** http://localhost:8080/swagger-ui/index.html

## Java 21 Conventions

### Use Records for DTOs
```java
public record TamilDate(
    String month,
    int day,
    String year,
    String weekday
) {}
```

### Use Sealed Interfaces
```java
public sealed interface YogamType
    permits Auspicious, Inauspicious, Neutral {}
```

### Use Pattern Matching
```java
return switch (type) {
    case Auspicious a -> "green";
    case Inauspicious i -> "red";
    default -> "gray";
};
```

## Spring Conventions

### Constructor Injection
```java
// No @Autowired needed
public PanchangamController(PanchangamService service) {
    this.service = service;
}
```

### Validation
```java
@GetMapping("/daily")
public PanchangamResponse getDaily(
    @RequestParam @DateTimeFormat(iso = ISO.DATE) LocalDate date,
    @RequestParam(defaultValue = "13.0827") double lat
) { }
```

### Error Responses (RFC 7807)
```java
@ExceptionHandler(Exception.class)
public ProblemDetail handleException(Exception ex) {
    return ProblemDetail.forStatusAndDetail(
        HttpStatus.INTERNAL_SERVER_ERROR,
        ex.getMessage()
    );
}
```

## Configuration

```yaml
# application.yml
spring:
  threads:
    virtual:
      enabled: true  # Java 21 Virtual Threads

server:
  port: 8080
```
