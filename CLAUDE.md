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

## Development Workflow for Major Changes

**CRITICAL: Follow this workflow for EVERY major change (features, refactoring, bug fixes)**

### Phase 1: Implementation
1. **Write the Code**
   - Backend: Implement feature in `backend/src/main/java/`
   - iOS: Implement feature in `ios/magizh-calendar-ios/`
   - Follow existing patterns and conventions

### Phase 2: Add Test Cases
**Backend:**
```bash
cd backend

# Create test file in src/test/java/
# Example: src/test/java/com/magizh/calendar/service/FeatureTest.java

# Test structure:
# - Unit tests for each public method
# - Integration tests for end-to-end flows
# - Edge cases and error handling
# - Real-world data scenarios
```

**iOS:**
```bash
cd ios

# Create test file in Tests/UnitTests/
# Example: Tests/UnitTests/FeatureTests.swift

# Test structure:
# - Unit tests for models and services
# - UI component tests
# - Data parsing tests
# - Edge cases and nil handling
```

### Phase 3: Verify Everything Works

**Backend Verification:**
```bash
cd backend

# 1. Run all tests
mvn test

# Expected: Tests run: XX, Failures: 0, Errors: 0

# 2. Clean build
mvn clean compile

# Expected: BUILD SUCCESS

# 3. Run the app and test manually
mvn spring-boot:run

# Test API endpoints:
# curl http://localhost:8080/api/panchangam/health
# curl http://localhost:8080/api/panchangam/daily?date=YYYY-MM-DD&lat=13.0827&lng=80.2707&timezone=Asia/Kolkata
```

**iOS Verification:**
```bash
cd ios

# 1. Run all tests
xcodebuild test -project magizh-calendar-ios.xcodeproj \
  -scheme magizh-calendar-iosTests \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2'

# Expected: ** TEST SUCCEEDED **

# 2. Build the app
xcodebuild -scheme magizh-calendar-ios -sdk iphonesimulator build

# Expected: ** BUILD SUCCEEDED **

# 3. Run in simulator and test manually
# - Boot simulator: xcrun simctl boot "iPhone 16 Pro"
# - Install app: xcrun simctl install booted path/to/app
# - Launch app: xcrun simctl launch booted com.sats.magizh-calendar-ios
# - Test UI, verify data, check for crashes
```

### Phase 4: Update Documentation

**Update README.md (if needed):**
- New features? Add to Features section
- New API endpoints? Add to API Documentation
- New dependencies? Add to Installation section
- Configuration changes? Update Setup instructions

**Update PROGRESS.md:**
```bash
# Backend progress
vim backend/PROGRESS.md
# Add:
# - ## [Date] - Feature Name
# - Description of what was added
# - Files modified
# - Test coverage

# iOS progress
vim ios/docs/PROGRESS.md
# Add:
# - ## [Date] - Feature Name
# - UI changes
# - New screens/components
# - Test coverage
```

### Phase 5: Commit and Push

**Checklist before commit:**
- [ ] All backend tests pass (mvn test)
- [ ] All iOS tests pass (xcodebuild test)
- [ ] Backend builds successfully (mvn clean compile)
- [ ] iOS builds successfully (xcodebuild build)
- [ ] Manual testing completed (app runs without crashes)
- [ ] README.md updated (if needed)
- [ ] PROGRESS.md updated
- [ ] No console errors or warnings

**Commit:**
```bash
# Stage all changes
git add .

# Commit with descriptive message
git commit -m "$(cat <<'EOF'
Add [Feature Name]

Backend:
- Implemented [backend changes]
- Added [X] test cases
- Updated [files modified]

iOS:
- Implemented [iOS changes]
- Added [X] test cases
- Updated UI in [screens]

Testing:
- Backend: XX tests, all passing
- iOS: XX tests, all passing
- Manual testing: verified on iPhone 16 Pro simulator

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"

# Push to remote
git push origin main
```

### Example Workflow

**Scenario: Adding Gowri Nalla Neram Feature**

```bash
# 1. Implementation
# - Created GowriCalculator.java (backend)
# - Updated TimingsCalculator.java, Timings.java, TimeRange.java
# - Updated iOS models: TimeRange.swift, PanchangamData.swift
# - Updated DailyView.swift to display Gowri times

# 2. Test Cases
cd backend
# - Created GowriCalculatorTest.java with 11 test cases
# - Updated PanchangamIntegrationTest.java
mvn test
# Result: Tests run: 66, Failures: 0, Errors: 0 ✅

cd ../ios
# - iOS unit tests already cover model parsing
xcodebuild test ...
# Result: TEST SUCCEEDED ✅

# 3. Verification
# Backend:
mvn spring-boot:run
curl http://localhost:8080/api/panchangam/daily?date=2026-01-05...
# Result: gowriNallaNeram returns 5 periods ✅

# iOS:
# Built and ran in simulator
# Verified: Gowri Nalla Neram shows 5 periods ✅

# 4. Update Documentation
vim backend/PROGRESS.md
# Added: ## 2026-01-05 - Gowri Nalla Neram Feature

vim ios/docs/PROGRESS.md
# Added: ## 2026-01-05 - Gowri Nalla Neram Display

# 5. Commit and Push
git add .
git commit -m "Add Gowri Nalla Neram calculation and display..."
git push origin main
# ✅ Done!
```

### Common Mistakes to Avoid

❌ **Don't:**
- Skip writing test cases
- Commit without running tests
- Push code that doesn't build
- Forget to update PROGRESS.md
- Commit with "WIP" or "temp" messages
- Skip manual testing

✅ **Do:**
- Write tests BEFORE or WITH the feature
- Run all tests before committing
- Test manually in simulator/app
- Update documentation
- Write descriptive commit messages
- Verify backend and iOS work together

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
