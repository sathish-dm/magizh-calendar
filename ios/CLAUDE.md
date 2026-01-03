# CLAUDE.md - Project Rules for Magizh Tamil Calendar iOS

## Quick Reference

| Item | Value |
|------|-------|
| **iOS Target** | 18.0+ |
| **Swift** | 5.9+ |
| **Architecture** | MVVM |
| **UI Framework** | SwiftUI only |
| **Design System** | iOS 18 Liquid Glass |
| **Repo** | github.com/sathish-dm/magizh-calendar-ios |

---

## Workflow Rules (MUST FOLLOW)

### 1. Build & Verify Before Commit
```bash
# Always run before committing:
xcodebuild -project magizh-calendar-ios.xcodeproj -target magizh-calendar-ios -sdk iphonesimulator build
```
- Build must succeed with **zero errors**
- Run in simulator to verify UI renders correctly
- Test both **light and dark mode**

### 2. Auto Commit & Push
After every major milestone:
1. **Verify** - Build succeeds, app runs correctly
2. **Commit** - Descriptive message with what changed
3. **Push** - Push to `origin/main` immediately

**Major milestones:**
- New feature completed (view, viewmodel, model)
- Bug fix verified
- Refactoring completed
- Configuration changes

### 3. Progress Tracking
After every major change, update `docs/PROGRESS.md`:
- Add completed items with `[x]`
- Add new discovered tasks to "Next Steps"
- Commit PROGRESS.md with related changes

### 4. Error Recovery
| Problem | Action |
|---------|--------|
| Build fails | Fix errors before moving on, never commit broken code |
| UI looks wrong | Check against mockup: `docs/tamil-calendar-liquid-glass.jsx` |
| Stuck on problem | Ask for clarification, don't guess |
| Merge conflict | Resolve carefully, test after |

---

## Project Structure

```
magizh-calendar-ios/
├── CLAUDE.md                 # This file (project rules)
├── magizh-calendar-ios/
│   ├── Models/               # Data models (Codable, Identifiable)
│   ├── ViewModels/           # MVVM view models (ObservableObject)
│   ├── Views/
│   │   ├── Components/       # Reusable UI (GlassCard, etc.)
│   │   ├── Daily/            # Daily view feature
│   │   └── Weekly/           # Weekly view feature (planned)
│   ├── Services/             # API, Location, Notifications (planned)
│   └── Core/                 # Extensions, Utilities (planned)
└── docs/
    ├── PROGRESS.md           # Development progress tracker
    ├── PROJECT_BRIEF.md      # Product requirements & MVP spec
    ├── IOS18_LIQUID_GLASS_GUIDE.md  # Design system specs
    └── tamil-calendar-liquid-glass.jsx  # UI mockup reference
```

### File Limits
- **Views:** Split if > 300 lines
- **ViewModels:** Split if > 200 lines
- **One feature = one folder** (Views/Daily/, Views/Weekly/)

---

## Design System: iOS 18 Liquid Glass

### Materials (use these, not solid colors)
```swift
.ultraThinMaterial  // Most transparent
.thinMaterial
.regularMaterial    // Default for cards
.thickMaterial      // Headers
.ultraThickMaterial // Backgrounds
```

### Spacing (use Spacing enum)
```swift
Spacing.xs   = 4pt   // Tight
Spacing.sm   = 8pt   // Small
Spacing.md   = 12pt  // Medium
Spacing.lg   = 16pt  // Standard (default)
Spacing.xl   = 24pt  // Section gaps
Spacing.xxl  = 32pt  // Screen padding
Spacing.xxxl = 48pt  // Large gaps
```

### Corner Radius (use CornerRadius enum)
```swift
CornerRadius.sm   = 8pt   // Small elements
CornerRadius.md   = 12pt  // Buttons, badges
CornerRadius.lg   = 16pt  // Cards
CornerRadius.xl   = 20pt  // Large cards
CornerRadius.xxl  = 24pt  // Main cards (default)
CornerRadius.xxxl = 32pt  // Headers, major surfaces
```

### Colors (semantic)
| Color | Usage |
|-------|-------|
| Orange/Saffron | Primary (Tamil culture) |
| Green | Auspicious, success |
| Red | Inauspicious, avoid, error |
| Blue | Informational |
| Purple | Nakshatram |
| Indigo | Karanam |

### GlassCard Component
```swift
// Basic usage
GlassCard {
    Text("Content")
}

// With glow (for emphasis)
GlassCard(glowColor: .green) {
    YogamContent()
}

// Custom material
GlassCard(material: .thinMaterial) {
    Content()
}
```

### Visual Rules
```
✓ Corner radius: ≥16pt (cards), ≥24pt (major surfaces)
✓ Materials: Use SwiftUI .material backgrounds
✓ Shadows: Multiple layers (glow + depth)
✓ Animations: Spring physics or smooth easing
✓ Dark mode: Full support required

✗ No solid backgrounds (except images)
✗ No harsh borders
✗ No linear animations
✗ No flat single shadows
```

---

## Tamil Calendar Conventions

### Naming (use Tamil spelling)
```
✓ Panchangam (not Panchang)
✓ Nakshatram (not Nakshatra)
✓ Thithi (not Tithi)
✓ Yogam (not Yoga)
✓ Karanam (not Karana)
✓ Vaaram (not Vara)
```

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
| Kuligai | Inauspicious | Orange |

---

## Code Patterns

### ViewModel Pattern
```swift
@MainActor
class FeatureViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var data: DataType?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: - Public Methods
    func loadData() { }

    // MARK: - Private Methods
    private func process() { }
}
```

### View Pattern
```swift
struct FeatureView: View {
    @StateObject private var viewModel = FeatureViewModel()

    var body: some View {
        // Content
    }

    // MARK: - View Components
    private var headerSection: some View { }
    private var contentSection: some View { }
}

#Preview {
    FeatureView()
}
```

### Sample Data Pattern
Every model should have:
```swift
extension ModelName {
    static let sample = ModelName(...)
    static let sampleAlt = ModelName(...)  // Alternative state
}
```

---

## Git Strategy

- **Branch:** Work on `main` (solo dev)
- **Commits:** Descriptive messages, commit often
- **Push:** Push after every milestone
- **Never:** Force push, commit broken code

### Commit Message Format
```
Short summary of change (imperative mood)

- Detail 1
- Detail 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

---

## Key Commands

```bash
# Build for simulator
xcodebuild -project magizh-calendar-ios.xcodeproj -target magizh-calendar-ios -sdk iphonesimulator build

# Run in simulator
xcrun simctl boot "iPhone 16 Pro"
xcrun simctl install "iPhone 16 Pro" build/Release-iphonesimulator/magizh-calendar-ios.app
xcrun simctl launch "iPhone 16 Pro" com.sats.magizh-calendar-ios

# Switch to dark mode
xcrun simctl ui "iPhone 16 Pro" appearance dark

# Switch to light mode
xcrun simctl ui "iPhone 16 Pro" appearance light

# Git status
git status

# Commit and push
git add -A && git commit -m "message" && git push
```

---

## Checklist Before Moving On

- [ ] Build succeeds (zero errors)
- [ ] App runs in simulator
- [ ] UI matches design mockup
- [ ] Dark mode looks correct
- [ ] Code follows patterns above
- [ ] PROGRESS.md updated
- [ ] Changes committed and pushed
