# iOS CLAUDE.md - Swift/SwiftUI Conventions

> Common rules in `../CLAUDE.md`

## Tech Stack

| Component | Value |
|-----------|-------|
| Swift | 5.9+ |
| UI Framework | SwiftUI |
| Architecture | MVVM |
| Min iOS | 18.0 |
| Design | Liquid Glass |

## Project Structure

```
magizh-calendar-ios/
├── Models/               # Data models (Codable, Identifiable)
├── ViewModels/           # MVVM view models (ObservableObject)
├── Views/
│   ├── Components/       # GlassCard, DataSourceBadge
│   └── Daily/            # Daily view feature
├── Services/
│   ├── APIConfig.swift
│   ├── APIResponse.swift
│   ├── Environment.swift
│   └── PanchangamAPIService.swift
└── Assets.xcassets/
```

## Commands

```bash
# Build
xcodebuild -scheme magizh-calendar-ios -sdk iphonesimulator build

# Run tests
xcodebuild test -project magizh-calendar-ios.xcodeproj -scheme magizh-calendar-iosTests -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2'

# Run on simulator
xcrun simctl launch booted com.sats.magizh-calendar-ios

# Dark/Light mode
xcrun simctl ui booted appearance dark
xcrun simctl ui booted appearance light
```

## Development Workflow (IMPORTANT)

**For every major change, follow this workflow:**

1. **Write/Update Unit Tests** - Add tests for new functionality in `Tests/UnitTests/`
2. **Run All Tests** - Ensure all tests pass before committing
3. **Build the App** - Verify the app compiles without errors
4. **Commit and Push** - Commit changes with a descriptive message

```bash
# Step 1: Run tests
xcodebuild test -project magizh-calendar-ios.xcodeproj -scheme magizh-calendar-iosTests -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2'

# Step 2: Build app
xcodebuild -scheme magizh-calendar-ios -sdk iphonesimulator build

# Step 3: Commit and push (if tests pass)
git add .
git commit -m "feat: description of changes"
git push
```

## Test Structure

```
Tests/UnitTests/
├── LocationTests.swift        # Location model tests
├── TimeRangeTests.swift       # Time range tests
├── FoodStatusTests.swift      # Food status tests
├── SettingsServiceTests.swift # Settings persistence tests
├── DailyViewModelTests.swift  # ViewModel tests
└── PanchangamDataTests.swift  # Panchangam model tests
```

### Writing Tests
```swift
import XCTest
@testable import magizh_calendar_ios

final class FeatureTests: XCTestCase {
    func testFeatureBehavior() {
        // Arrange
        let sut = Feature()

        // Act
        let result = sut.doSomething()

        // Assert
        XCTAssertEqual(result, expectedValue)
    }
}
```

## iOS 18 Liquid Glass Design

### Materials
```swift
.ultraThinMaterial  // Most transparent
.thinMaterial
.regularMaterial    // Default for cards
.thickMaterial      // Headers
```

### GlassCard Component
```swift
GlassCard {
    Text("Content")
}

GlassCard(glowColor: .green) {
    AuspiciousContent()
}
```

### Visual Rules
```
✓ Corner radius: ≥16pt (cards), ≥24pt (major surfaces)
✓ Materials: Use SwiftUI .material backgrounds
✓ Shadows: Multiple layers (glow + depth)
✓ Dark mode: Full support required

✗ No solid backgrounds
✗ No harsh borders
```

## Code Patterns

### ViewModel
```swift
@MainActor
class FeatureViewModel: ObservableObject {
    @Published private(set) var data: DataType?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    func loadData() async { }
}
```

### View
```swift
struct FeatureView: View {
    @StateObject private var viewModel = FeatureViewModel()

    var body: some View {
        // Content
    }

    private var headerSection: some View { }
    private var contentSection: some View { }
}

#Preview {
    FeatureView()
}
```

### Actor-based Service
```swift
actor PanchangamAPIService {
    func fetchDaily(...) async throws -> Response { }
}
```

### Sample Data
```swift
extension ModelName {
    static let sample = ModelName(...)
}
```

## Swift 6 Concurrency

### Sendable Models
```swift
struct APIResponse: Codable, Sendable { }
```

### MainActor for UI
```swift
@MainActor
func toDomainModel() -> DomainModel { }
```

### Nonisolated Properties
```swift
nonisolated static var baseURL: String { }
```

## Environment Configuration

```swift
enum AppEnvironment {
    case development  // localhost:8080
    case staging      // staging-api.magizh.com
    case production   // api.magizh.com

    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}
```

## File Limits

- Views: Split if > 300 lines
- ViewModels: Split if > 200 lines
- One feature = one folder
