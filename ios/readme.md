# Magizh Calendar iOS

Tamil Panchangam Calendar app built with SwiftUI and iOS 18 Liquid Glass design.

## Features

- Daily Panchangam view with all five angams
- iOS 18 Liquid Glass glassmorphism design
- Live API integration with mock data fallback
- Environment-based configuration (dev/staging/production)
- Data source indicator (DEBUG builds only)

## Tech Stack

| Component | Technology |
|-----------|------------|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Architecture | MVVM |
| Networking | Async/Await, Actor |
| Min iOS | 18.0 |
| Design | Liquid Glass (iOS 18) |

## Quick Start

### Using Scripts (from monorepo root)

```bash
# Build and run
./scripts/start-ios.sh --build

# Just launch (if already built)
./scripts/start-ios.sh
```

### Using Xcode

```bash
open magizh-calendar-ios.xcodeproj
```

Then press `Cmd+R` to build and run.

### Using Command Line

```bash
# Build
xcodebuild -scheme magizh-calendar-ios -sdk iphonesimulator build

# Run on simulator
xcrun simctl launch booted com.sats.magizh-calendar-ios
```

## Environment Configuration

The app supports three environments configured in `Services/Environment.swift`:

| Environment | API URL | Timeout |
|-------------|---------|---------|
| Development | `http://localhost:8080` | 30s |
| Staging | `https://staging-api.magizh.com` | 15s |
| Production | `https://api.magizh.com` | 10s |

Environment is selected automatically:
- **DEBUG builds** → Development
- **Release builds** → Production

## Project Structure

```
ios/
├── magizh-calendar-ios/
│   ├── Models/
│   │   ├── PanchangamData.swift     # Main data model
│   │   ├── TamilDate.swift
│   │   ├── Nakshatram.swift
│   │   ├── Thithi.swift
│   │   ├── Yogam.swift
│   │   └── ...
│   ├── ViewModels/
│   │   └── DailyViewModel.swift     # Daily view state
│   ├── Views/
│   │   ├── Components/
│   │   │   ├── GlassCard.swift      # Glassmorphism card
│   │   │   ├── PanchangamCard.swift
│   │   │   └── DataSourceBadge.swift
│   │   └── Daily/
│   │       └── DailyView.swift      # Main daily view
│   ├── Services/
│   │   ├── APIConfig.swift          # API endpoints
│   │   ├── APIResponse.swift        # Response models
│   │   ├── Environment.swift        # Environment config
│   │   └── PanchangamAPIService.swift
│   └── Assets.xcassets/
├── magizh-calendar-ios.xcodeproj/
└── docs/
    ├── PROGRESS.md
    ├── PROJECT_BRIEF.md
    └── IOS18_LIQUID_GLASS_GUIDE.md
```

## API Integration

The app fetches data from the Spring Boot backend:

```swift
// Services/PanchangamAPIService.swift
actor PanchangamAPIService {
    func fetchDailyPanchangam(
        date: Date,
        latitude: Double,
        longitude: Double,
        timezone: String
    ) async throws -> PanchangamAPIResponse
}
```

**Fallback behavior:** If the API is unreachable, the app falls back to mock data and displays an orange "Mock Data" badge.

## Data Source Badge

In DEBUG builds, a badge shows the data source:
- **Green "Live API"** - Data from backend
- **Orange "Mock Data"** - Using local mock data

## Design

The app features iOS 18 Liquid Glass design with:
- Gradient header with Tamil date
- Glassmorphism cards for panchangam data
- Food status with conditional glow effects
- Timing cards for Nalla Neram, Rahukaalam

## Development

### Requirements
- Xcode 16+
- iOS 18.0+ Simulator or device
- Backend running on `localhost:8080` (for live data)

### Running with Backend

```bash
# Terminal 1: Start backend
./scripts/start-backend.sh

# Terminal 2: Start iOS
./scripts/start-ios.sh --build
```

Or use:
```bash
./scripts/start-all.sh
```

## Documentation

- `docs/PROJECT_BRIEF.md` - Complete project specification
- `docs/PROGRESS.md` - Development progress tracking
- `docs/IOS18_LIQUID_GLASS_GUIDE.md` - Design specifications
- `CLAUDE.md` - AI coding assistant guide

Part of the [Magizh Calendar](https://github.com/sathish-dm/magizh-calendar) monorepo.
