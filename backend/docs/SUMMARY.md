# Magizh Calendar - Architecture Summary

## Overview

Magizh Calendar is a Tamil Panchangam (Hindu calendar) application consisting of:
1. **iOS App** - SwiftUI client with iOS 18 Liquid Glass design
2. **Backend API** - Spring Boot REST API for panchangam calculations

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        iOS App                               │
│              (SwiftUI + iOS 18 Liquid Glass)                │
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  DailyView  │  │ WeeklyView  │  │    SettingsView     │ │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘ │
│         │                │                     │            │
│         └────────────────┼─────────────────────┘            │
│                          │                                   │
│                   ┌──────┴──────┐                           │
│                   │  ViewModel  │                           │
│                   │   (MVVM)    │                           │
│                   └──────┬──────┘                           │
└──────────────────────────┼──────────────────────────────────┘
                           │ HTTP/REST
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                     Backend API                              │
│              (Spring Boot 3.3 + Java 21)                    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                PanchangamController                  │   │
│  │   GET /api/panchangam/daily                         │   │
│  │   GET /api/panchangam/weekly                        │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│  ┌──────────────────────┴──────────────────────────────┐   │
│  │                PanchangamService                     │   │
│  │   - Mock data (current)                             │   │
│  │   - Swiss Ephemeris (planned)                       │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│  ┌──────────────────────┴──────────────────────────────┐   │
│  │              Swiss Ephemeris (Future)                │   │
│  │   - Astronomical calculations                        │   │
│  │   - Planetary positions                              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Panchangam Data Model

### Five Angams (Pancha Angam)
| Angam | Description | Calculation Source |
|-------|-------------|-------------------|
| **Nakshatram** | Lunar mansion (27 stars) | Moon's position in zodiac |
| **Thithi** | Lunar day (30 per month) | Moon phase angle from Sun |
| **Yogam** | Sun-Moon combination (27) | Sum of Sun & Moon longitudes |
| **Karanam** | Half-thithi (60 per month) | Derived from thithi |
| **Vaaram** | Day of week (7) | Standard weekday |

### Timing Information
| Timing | Description | Type |
|--------|-------------|------|
| **Sunrise/Sunset** | Solar times | Location-based |
| **Nalla Neram** | Auspicious periods | Good for activities |
| **Rahukaalam** | Rahu's period | Inauspicious |
| **Yamagandam** | Yama's period | Inauspicious |
| **Kuligai** | Kuligai period | Inauspicious |

## API Response Format

```json
{
  "date": "2026-01-03",
  "tamilDate": {
    "month": "Thai",
    "day": 20,
    "year": "Krodhana",
    "weekday": "Sani"
  },
  "nakshatram": {
    "name": "Rohini",
    "endTime": "2026-01-03T14:45:00+05:30",
    "lord": "Moon"
  },
  "thithi": {
    "name": "Panchami",
    "paksha": "SHUKLA",
    "endTime": "2026-01-03T16:30:00+05:30"
  },
  "yogam": {
    "name": "Siddhi",
    "type": "AUSPICIOUS",
    "startTime": "...",
    "endTime": "..."
  },
  "karanam": {
    "name": "Bava",
    "endTime": "..."
  },
  "timings": {
    "sunrise": "2026-01-03T06:42:00+05:30",
    "sunset": "2026-01-03T17:54:00+05:30",
    "nallaNeram": [...],
    "rahukaalam": {...},
    "yamagandam": {...},
    "kuligai": {...}
  },
  "foodStatus": {
    "type": "REGULAR",
    "message": "No dietary restrictions today",
    "nextAuspicious": {...}
  }
}
```

## Repository Structure

### iOS App (`magizh-calendar-ios`)
```
magizh-calendar-ios/
├── Models/           # Swift data models
├── ViewModels/       # MVVM view models
├── Views/
│   ├── Components/   # GlassCard, etc.
│   └── Daily/        # DailyView
├── Services/         # API, Location (planned)
└── docs/             # Documentation
```

### Backend API (`magizh-calendar-api`)
```
magizh-calendar-api/
├── src/main/java/com/magizh/calendar/
│   ├── controller/   # REST controllers
│   ├── service/      # Business logic
│   ├── model/        # Java Records
│   └── config/       # Configuration (planned)
├── src/main/resources/
│   └── application.yml
└── docs/             # This folder
```

## Technology Choices

### iOS App
| Choice | Reason |
|--------|--------|
| SwiftUI | Modern declarative UI |
| iOS 18+ | Liquid Glass design system |
| MVVM | Clean separation of concerns |
| Combine | Reactive data binding |

### Backend API
| Choice | Reason |
|--------|--------|
| Java 21 | LTS, Records, Virtual Threads |
| Spring Boot 3.3 | Latest features, production ready |
| Records | Immutable DTOs, less boilerplate |
| Virtual Threads | Scalable concurrency |

## Future Enhancements

### Short Term
- Swiss Ephemeris integration for real calculations
- iOS API client integration
- Caching layer

### Medium Term
- Notifications for auspicious days
- Widget support (iOS)
- Offline mode

### Long Term
- Android app
- Web app
- Push notifications
- User preferences sync

## Links

- **iOS Repo:** https://github.com/sathish-dm/magizh-calendar-ios
- **Backend Repo:** https://github.com/sathish-dm/magizh-calendar-api
