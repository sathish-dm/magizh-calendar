# Tamil Calendar iOS App - Project Brief

## Project Vision
Build a **modern, location-aware Tamil calendar app** that solves real pain points of 20+ million Tamil speakers worldwide, with special focus on the diaspora community.

---

## Core Differentiation (Your Competitive Edge)

### 1. **Smart Food Planning Alerts** 🍛 (NO COMPETITOR HAS THIS)
- Evening notifications before auspicious days
- "Tomorrow is Ekadasi - avoid cooking/storing non-veg tonight"
- Weekly meal planning view
- Customizable observation preferences

### 2. **Accurate Location-Based Calculations** 🌍 (MAJOR PAIN POINT)
- Automatic timezone detection
- City-specific Rahukaalam, Nalla Neram, Yogam timings
- Multi-location support (track Chennai + current location)
- Proper handling for diaspora in US, UK, Singapore, etc.

### 3. **Verified Panchangam Accuracy** ✓
- Traditional five-angam structure (Nakshatram, Thithi, Yogam, Karanam, Vaaram)
- Thirukanitha calculation method
- Clear data source attribution
- Cross-verification against Pambu Panchangam

### 4. **Modern, Clean Design** 🎨
- Minimalist interface (unlike cluttered competitors)
- **iOS 18 Liquid Glass aesthetic** - translucent materials, depth, soft glows
- Card-based layout with glassmorphism
- Dark mode support with adaptive materials
- Beautiful widgets
- Smooth spring-based animations

### 5. **Honest Monetization** 💰
- No intrusive ads during spiritual content
- Lifetime purchases honored forever
- Cross-platform subscription sync
- Transparent pricing

---

## MVP Feature Set (Phase 1 - 8 weeks)

### Must Have (Core Features)

#### A. Daily View
- [ ] Large date display with Tamil date overlay
- [ ] Five Angams in traditional order (Nakshatram, Thithi, Yogam, Karanam, Sunrise/Sunset)
- [ ] Food status card (regular vs auspicious day)
- [ ] Auspicious timings (Nalla Neram, Rahukaalam, Yamagandam)
- [ ] Current time indicator showing active period
- [ ] Location display (city, state)

#### B. Weekly View
- [ ] 7-day grid with Tamil dates
- [ ] Auspicious day markers (Ekadasi, Pradosham, etc.)
- [ ] Yogam indicators
- [ ] Food planning overview
- [ ] Swipe navigation

#### C. Smart Notifications
- [ ] Evening alert (7 PM) before auspicious days
- [ ] Morning reminder on auspicious day
- [ ] Weekly summary (Sunday evening)
- [ ] Customizable alert times
- [ ] User preference selection (which days to observe)

#### D. Location Features
- [ ] Automatic location detection via GPS
- [ ] Manual city selection (with search)
- [ ] Timezone-aware calculations
- [ ] Store preferred location
- [ ] Popular cities quick-select (Chennai, Coimbatore, New York, London, Singapore)

#### E. Settings & Onboarding
- [ ] First-launch onboarding (3-screen tutorial)
- [ ] Food alert preferences
- [ ] Location settings
- [ ] Notification preferences
- [ ] About/Data source info

### Nice to Have (Phase 2 - Future)
- [ ] Monthly calendar view
- [ ] Home screen widgets (Today, Week)
- [ ] Lock screen widgets (iOS 16+)
- [ ] Apple Watch companion
- [ ] Siri shortcuts
- [ ] Multiple location tracking
- [ ] Historical data (2000-present)
- [ ] Festival reminders
- [ ] Export to Apple Calendar
- [ ] Dark mode customization
- [ ] Tamil language support

---

## Technical Architecture

### Backend/API Layer
**YOU NEED THIS** - Panchangam calculations are complex

**Option 1: Build Your Own API**
```
Technologies:
- Spring Boot (Java) - you're familiar with this
- Swiss Ephemeris library for calculations
- PostgreSQL for caching
- Deploy on: AWS/Railway/Render

Endpoints:
- GET /api/panchangam/daily?date={date}&lat={lat}&lng={lng}&tz={timezone}
- GET /api/panchangam/weekly?startDate={date}&lat={lat}&lng={lng}&tz={timezone}
- GET /api/yogam/current?lat={lat}&lng={lng}&tz={timezone}
```

**Option 2: Use Existing API (Faster MVP)**
- ProKerala Tamil Panchangam API
- Tamilsonline Panchangam API
- Drik Panchang API

### iOS App Stack

**Language & Framework:**
- Swift 5.9+
- SwiftUI (for modern UI + iOS 18 materials)
- Combine (for reactive programming)
- **iOS 18 Liquid Glass design language** (see IOS18_LIQUID_GLASS_GUIDE.md)

**Architecture:**
- MVVM (Model-View-ViewModel)
- Repository pattern for data layer
- Dependency Injection

**Key Libraries:**
```swift
// Networking
- URLSession (native) or Alamofire

// Local Storage
- SwiftData (iOS 17+) or CoreData
- UserDefaults for preferences

// Location
- CoreLocation (native)

// Notifications
- UserNotifications (native)

// UI
- SwiftUI (native)
- Charts framework for visualizations
```

**Data Flow:**
```
User -> View -> ViewModel -> Repository -> API/Cache -> Response
                    ↓
              Update View
```

---

## File Structure

```
TamilCalendar/
├── App/
│   ├── TamilCalendarApp.swift
│   └── AppDelegate.swift
├── Core/
│   ├── Extensions/
│   ├── Utilities/
│   └── Constants/
├── Models/
│   ├── PanchangamData.swift
│   ├── TamilDate.swift
│   ├── Yogam.swift
│   └── FoodAlert.swift
├── ViewModels/
│   ├── DailyViewModel.swift
│   ├── WeeklyViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Daily/
│   │   ├── DailyView.swift
│   │   ├── FoodStatusCard.swift
│   │   ├── PanchangamCard.swift
│   │   └── TimingsCard.swift
│   ├── Weekly/
│   │   └── WeeklyView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       └── (Reusable UI components)
├── Services/
│   ├── NetworkService.swift
│   ├── LocationService.swift
│   ├── NotificationService.swift
│   └── PanchangamRepository.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Localizations/
└── Tests/
    ├── UnitTests/
    └── UITests/
```

---

## Data Models

### Core Models

```swift
// PanchangamData.swift
struct PanchangamData: Codable {
    let date: Date
    let tamilDate: TamilDate
    let location: Location
    
    // Five Angams
    let nakshatram: Nakshatram
    let thithi: Thithi
    let yogam: Yogam
    let karanam: Karanam
    let vaaram: Vaaram
    
    // Timings
    let sunrise: Date
    let sunset: Date
    let nallaNeram: [TimeRange]
    let rahukaalam: TimeRange
    let yamagandam: TimeRange
    
    // Derived
    let foodStatus: FoodStatus
    let nextAuspiciousDay: AuspiciousDay?
}

// Yogam.swift
struct Yogam: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: YogamType // .auspicious, .inauspicious, .neutral
    let startTime: Date
    let endTime: Date
    let description: String?
    
    enum YogamType: String, Codable {
        case auspicious = "auspicious"
        case inauspicious = "inauspicious"
        case neutral = "neutral"
    }
}

// FoodAlert.swift
struct FoodAlert: Identifiable {
    let id: UUID
    let date: Date
    let type: AlertType
    let message: String
    let nextAuspiciousDay: String
    
    enum AlertType {
        case avoidNonVeg
        case regularDay
        case multipleAuspicious
    }
}
```

---

## User Preferences Storage

```swift
// UserPreferences.swift
struct UserPreferences: Codable {
    // Location
    var preferredLocation: Location?
    var autoDetectLocation: Bool = true
    
    // Food Alerts
    var enableFoodAlerts: Bool = true
    var observedDays: Set<ObservedDay> = [.ekadasi, .pradosham]
    var alertTime: Date = Date() // 7:00 PM
    var alertStyle: AlertStyle = .dayBefore
    
    // UI
    var defaultView: ViewType = .daily
    var enableDarkMode: Bool = false // or auto
    
    enum ObservedDay: String, Codable, CaseIterable {
        case ekadasi, pradosham, amavasai, pournami
        case karthigai, shivaratri, navaratri
        case somavaram, sashti, ashtami, chaturthi
    }
    
    enum AlertStyle: String, Codable {
        case dayBefore, twoDaysBefore, weeklyOnly
    }
    
    enum ViewType: String, Codable {
        case daily, weekly
    }
}
```

---

## Development Phases

### Week 1-2: Foundation
- [ ] Project setup in Xcode
- [ ] Basic navigation structure (TabView or custom)
- [ ] API integration (choose backend option)
- [ ] Models and ViewModels
- [ ] Repository pattern implementation

### Week 3-4: Daily View
- [ ] Daily view UI (5 cards)
- [ ] Live data from API
- [ ] Location detection
- [ ] Current time indicator
- [ ] Swipe navigation

### Week 5-6: Weekly View & Notifications
- [ ] Weekly grid view
- [ ] Food planning overview
- [ ] Local notification setup
- [ ] Alert scheduling logic
- [ ] User preferences

### Week 7-8: Polish & Testing
- [ ] Settings screen
- [ ] Onboarding flow
- [ ] Error handling
- [ ] Offline support (cache)
- [ ] Testing
- [ ] App Store assets

---

## Critical Success Factors

### 1. **Data Accuracy** (Non-negotiable)
- Verify against Pambu Panchangam 2026
- Test with multiple locations (Chennai, New York, London)
- Cross-check yogam calculations
- Get validation from Tamil astrology expert

### 2. **Location Reliability** (Your differentiator)
- Test in different timezones
- Handle DST changes
- Graceful degradation if GPS fails
- Accurate timezone mapping

### 3. **Notification Timing** (Critical feature)
- Reliable delivery (even when app closed)
- Respect user's timezone
- Clear, actionable messages
- Easy to customize

### 4. **Performance** (User experience)
- App launch < 2 seconds
- Smooth scrolling/swiping
- Responsive UI (60fps)
- Low battery consumption

### 5. **Design Quality** (Modern appeal)
- Consistent spacing/typography
- Proper dark mode
- Smooth animations
- Accessibility support

---

## Testing Strategy

### Unit Tests (30% coverage minimum)
- [ ] Panchangam calculations
- [ ] Date conversions (Gregorian ↔ Tamil)
- [ ] Notification scheduling logic
- [ ] Location timezone mapping

### Integration Tests
- [ ] API integration
- [ ] Location service
- [ ] Notification delivery
- [ ] Data caching

### Manual Testing Checklist
- [ ] All timezones (EST, PST, GMT, IST, SGT)
- [ ] Date edge cases (month boundaries, year boundaries)
- [ ] Different device sizes (SE, Pro, Pro Max, iPad)
- [ ] iOS versions (16, 17, 18)
- [ ] Dark/Light modes
- [ ] Airplane mode (offline)
- [ ] Low battery mode
- [ ] Background refresh

---

## API Requirements

### Backend Must Provide

**Daily Panchangam Endpoint:**
```json
GET /api/panchangam/daily
?date=2026-01-02
&lat=13.0827
&lng=80.2707
&timezone=Asia/Kolkata

Response:
{
  "date": "2026-01-02",
  "tamilDate": {
    "month": "Thai",
    "day": 16,
    "year": "Visuvaavasu",
    "weekday": "Velli"
  },
  "nakshatram": {
    "name": "Rohini",
    "endTime": "2026-01-02T14:45:00+05:30"
  },
  "thithi": {
    "name": "Panchami",
    "paksha": "Shukla",
    "endTime": "2026-01-02T16:30:00+05:30"
  },
  "yogam": {
    "name": "Amirtha",
    "type": "auspicious",
    "startTime": "2026-01-02T08:30:00+05:30",
    "endTime": "2026-01-02T14:15:00+05:30"
  },
  "karanam": {
    "name": "Bava",
    "endTime": "2026-01-02T10:15:00+05:30"
  },
  "timings": {
    "sunrise": "2026-01-02T06:42:00+05:30",
    "sunset": "2026-01-02T17:54:00+05:30",
    "nallaNeram": [
      {
        "start": "2026-01-02T09:15:00+05:30",
        "end": "2026-01-02T10:30:00+05:30"
      }
    ],
    "rahukaalam": {
      "start": "2026-01-02T13:30:00+05:30",
      "end": "2026-01-02T15:00:00+05:30"
    }
  },
  "foodStatus": {
    "type": "regular",
    "nextAuspicious": {
      "name": "Pradosham",
      "date": "2026-01-03"
    }
  }
}
```

**Location Support:**
- Store popular cities with coordinates
- Reverse geocoding for auto-detected locations
- Timezone database

---

## Monetization Strategy (Future)

### Free Tier
- Full daily/weekly views
- Basic notifications
- Single location
- Standard themes

### Premium ($2.99/month or $24.99/year)
- Unlimited locations
- Advanced widgets
- Family sharing (5 users)
- Priority notifications
- Historical data (2000-present)
- Export features
- Custom themes
- Ad-free

### Lifetime ($49.99)
- All premium features forever
- Show "Lifetime license honored" badge
- Cross-platform sync (future Android app)

---

## Success Metrics

### Week 1-4 (MVP)
- [ ] App launches successfully
- [ ] Shows accurate Tamil date
- [ ] Displays panchangam for today
- [ ] Location detection works

### Week 5-8 (Launch Ready)
- [ ] Food alerts deliver reliably
- [ ] Works in 3+ timezones correctly
- [ ] All 5 angams display with correct timings
- [ ] 10 beta testers validate accuracy

### Post-Launch (3 months)
- [ ] 1,000 downloads
- [ ] 4.5+ star rating
- [ ] <5% crash rate
- [ ] 40%+ day-7 retention
- [ ] 5+ positive reviews mentioning food alerts or location accuracy

---

## Risk Mitigation

### Risk 1: Panchangam Calculation Errors
**Mitigation:**
- Use established libraries (Swiss Ephemeris)
- Cross-verify with traditional sources
- Beta test with Tamil astrology community
- Display data source/calculation method

### Risk 2: Notification Reliability
**Mitigation:**
- Use UNUserNotificationCenter properly
- Test background refresh
- Fallback to local calculations
- User setting to adjust timing

### Risk 3: Location Inaccuracy
**Mitigation:**
- Manual city selection always available
- Popular cities pre-configured
- Clear error messages
- Graceful degradation

### Risk 4: API Dependency
**Mitigation:**
- Aggressive caching (30 days ahead)
- Offline mode with cached data
- Retry logic with exponential backoff
- Consider embedding lightweight calculation library

---

## Getting Started

### Day 1 Checklist
1. [ ] Create new Xcode project (iOS App, SwiftUI, minimum iOS 16)
2. [ ] Set up Git repository
3. [ ] Create folder structure as outlined above
4. [ ] Add CLAUDE.md to project root
5. [ ] Decide on backend (build vs. use existing API)
6. [ ] Create basic models (PanchangamData, TamilDate)
7. [ ] Set up first view (DailyView) with dummy data

### First Feature to Build
**Start with Daily View with static data:**
1. Create UI matching mockup
2. Use hardcoded PanchangamData
3. Get design pixel-perfect
4. Then connect to API

**Why this order?**
- Validate design quickly
- No backend dependency initially
- Can show progress immediately
- Easier to iterate on UI

---

## Resources You'll Need

### Tamil Calendar References
- Pambu Panchangam 2025-2026 (buy physical copy for verification)
- ProKerala Panchangam: https://www.prokerala.com/astrology/tamil-panchangam/
- Tamilsonline: https://www.tamilsonline.com/panchangam/

### Development Tools
- Xcode 15+
- SF Symbols app (for icons)
- Figma/Sketch (if designing custom elements)
- Postman (for API testing)

### Learning Resources
- SwiftUI by Example: https://www.hackingwithswift.com/quick-start/swiftui
- MVVM in SwiftUI: https://www.swiftbysundell.com/
- iOS notifications: https://developer.apple.com/documentation/usernotifications

---

## Questions to Answer Before Starting

1. **Backend decision:** Build your own API or use existing?
2. **iOS version support:** iOS 16+ or iOS 17+ (affects widget capabilities)?
3. **Launch timeline:** 8 weeks realistic? Or aim for 12 weeks?
4. **Beta testing:** Who will validate accuracy (family, community)?
5. **Monetization:** Launch free first, or freemium from day 1?

---

## Your Competitive Advantages Summary

1. ✅ **Food planning alerts** - NO ONE ELSE HAS THIS
2. ✅ **Location accuracy** - MAJOR PAIN POINT SOLVED
3. ✅ **Modern design** - STANDS OUT IMMEDIATELY  
4. ✅ **Data verification** - BUILDS TRUST
5. ✅ **Honest monetization** - RESPECTS USERS

**Focus on these 5 things and you'll have a winner!**

---

Good luck! 🚀

When ready to code, use CLAUDE.md as your AI coding assistant guide.
