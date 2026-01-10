# Magizh Calendar

Tamil Panchangam Calendar application with Spring Boot backend and iOS app.

## Structure

```
magizh-calendar/
├── backend/     # Spring Boot API (Java 21)
├── ios/         # SwiftUI iOS App
└── scripts/     # Development scripts
```

## Quick Start

```bash
# Start everything
./scripts/start-all.sh

# Or start individually
./scripts/start-backend.sh      # Start API server
./scripts/start-ios.sh --build  # Build and run iOS app

# Stop all services
./scripts/stop-all.sh
```

## Backend

- **Tech**: Spring Boot 3.3, Java 21, Virtual Threads
- **API Docs**: http://localhost:8080/swagger-ui/index.html
- **Health Check**: http://localhost:8080/api/panchangam/health

```bash
cd backend
make run      # Start server
make swagger  # Open Swagger UI
make test     # Run tests
```

## iOS

- **Tech**: SwiftUI, iOS 18, MVVM
- **Design**: Liquid Glass (iOS 18)

```bash
cd ios
xcodebuild -scheme magizh-calendar-ios -sdk iphonesimulator build
```

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/panchangam/daily` | Daily panchangam data |
| `GET /api/panchangam/weekly` | Weekly panchangam data |
| `GET /api/panchangam/health` | Health check |

### Example Request

```bash
# With API key (required in production)
curl -H "X-API-Key: your-api-key" \
     "http://localhost:8080/api/panchangam/daily?date=2026-01-03&lat=13.0827&lng=80.2707&timezone=Asia/Kolkata"

# Health check (no auth required)
curl http://localhost:8080/api/panchangam/health
```

## API Security

The API uses API key authentication for secure access.

### Headers

| Header | Description | Required |
|--------|-------------|----------|
| `X-API-Key` | API key for authentication | Yes (except health) |
| `X-Client-Type` | Client identifier (ios/web) | Optional |

### Rate Limiting

- 60 requests per minute per client
- Returns `429 Too Many Requests` when exceeded
- `Retry-After` header indicates wait time

### Environment Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `API_KEY_IOS` | iOS app API key | - |
| `API_KEY_WEB` | Web app API key | - |
| `API_KEY_DEV` | Development key | `dev-key-for-local-testing` |
| `API_SECURITY_ENABLED` | Enable/disable auth | `true` |
| `CORS_ALLOWED_ORIGINS` | Allowed CORS origins | `*` |
| `RATE_LIMIT_ENABLED` | Enable rate limiting | `true` |

### Profiles

```bash
# Development (security disabled)
mvn spring-boot:run -Dspring.profiles.active=dev

# Production (full security)
mvn spring-boot:run -Dspring.profiles.active=prod
```
