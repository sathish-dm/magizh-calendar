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

```
GET /api/panchangam/daily?date=2026-01-03&lat=13.0827&lng=80.2707&timezone=Asia/Kolkata
```
