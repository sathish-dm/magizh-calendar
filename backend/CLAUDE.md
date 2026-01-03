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
mvn spring-boot:run
mvn clean compile
mvn clean package
```

## Development Workflow (IMPORTANT)

**For every major change, follow this workflow:**

1. **Write/Update Unit Tests** - Add tests for new functionality in `src/test/java/`
2. **Run All Tests** - Ensure all tests pass before committing
3. **Build the App** - Verify the app compiles without errors
4. **Commit and Push** - Commit changes with a descriptive message

```bash
# Step 1: Run tests
make test
# or: mvn test

# Step 2: Build app
make build
# or: mvn clean compile

# Step 3: Commit and push (if tests pass)
git add .
git commit -m "feat: description of changes"
git push
```

## Test Structure

```
src/test/java/com/magizh/calendar/
├── controller/
│   └── PanchangamControllerTest.java
├── service/
│   └── PanchangamServiceTest.java
└── model/
    └── *Test.java
```

### Writing Tests
```java
@SpringBootTest
class PanchangamServiceTest {

    @Autowired
    private PanchangamService service;

    @Test
    void shouldCalculateNakshatram() {
        // Arrange
        LocalDate date = LocalDate.of(2025, 1, 15);

        // Act
        var result = service.getDailyPanchangam(date, 13.0827, 80.2707, "Asia/Kolkata");

        // Assert
        assertThat(result.nakshatram()).isNotNull();
    }
}
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
