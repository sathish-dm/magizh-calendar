# CLAUDE.md - Magizh Calendar Monorepo

## Quick Reference

| Item | Value |
|------|-------|
| **Repo** | github.com/sathish-dm/magizh-calendar |
| **Backend** | Spring Boot 3.3, Java 21 |
| **iOS** | SwiftUI, iOS 18 |
| **Design** | Liquid Glass |

## Monorepo Structure

```
magizh-calendar/
├── backend/          # Spring Boot API (Java 21)
│   └── CLAUDE.md     # Java/Spring conventions
├── ios/              # SwiftUI App (iOS 18)
│   └── CLAUDE.md     # Swift/SwiftUI conventions
├── scripts/          # Development scripts
│   ├── start-all.sh
│   ├── start-backend.sh
│   ├── start-ios.sh
│   └── stop-all.sh
└── CLAUDE.md         # This file (common rules)
```

## Scripts

```bash
# Start everything
./scripts/start-all.sh

# Start individually
./scripts/start-backend.sh      # Maven (default)
./scripts/start-backend.sh --docker
./scripts/start-ios.sh --build  # Build + run
./scripts/start-ios.sh          # Run only

# Stop all
./scripts/stop-all.sh
```

## Git Workflow

### Branch Strategy
- Work on `main` (solo dev)
- Commit often, push after milestones

### Commit Message Format
```
Short summary (imperative mood)

- Detail 1
- Detail 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### Before Committing
1. Backend: `cd backend && mvn clean compile`
2. iOS: `cd ios && xcodebuild -scheme magizh-calendar-ios -sdk iphonesimulator build`
3. Both must pass with zero errors

## Tamil Calendar Conventions

### Naming (use Tamil spelling)
| Correct | Incorrect |
|---------|-----------|
| Panchangam | Panchang |
| Nakshatram | Nakshatra |
| Thithi | Tithi |
| Yogam | Yoga |
| Karanam | Karana |
| Vaaram | Vara |

### Five Angams (Pancha Angam)
1. **Nakshatram** - Lunar mansion (27 stars)
2. **Thithi** - Lunar day (15 per fortnight)
3. **Yogam** - Sun-Moon yoga (27 types)
4. **Karanam** - Half of thithi (11 types)
5. **Vaaram** - Day of week (7 days)

### Time Periods
| Period | Type | Color |
|--------|------|-------|
| Nalla Neram | Auspicious | Green |
| Rahukaalam | Inauspicious | Red |
| Yamagandam | Inauspicious | Orange |

### Semantic Colors
| Color | Usage |
|-------|-------|
| Orange/Saffron | Primary (Tamil culture) |
| Green | Auspicious, success |
| Red | Inauspicious, error |
| Purple | Nakshatram |
| Indigo | Karanam |

## Progress Tracking

Update `PROGRESS.md` after milestones:
- `backend/PROGRESS.md` - API progress
- `ios/docs/PROGRESS.md` - iOS progress

## Subproject Guides

- **Backend:** See `backend/CLAUDE.md` for Java/Spring conventions
- **iOS:** See `ios/CLAUDE.md` for Swift/SwiftUI conventions
