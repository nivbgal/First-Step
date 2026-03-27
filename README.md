# First Step

**First Step** is a native SwiftUI iPhone app that gamifies walking by turning your daily steps into virtual journeys to real-world and fantasy destinations.

## V1 Scope — iPhone Only

This milestone establishes the iPhone-only native foundation. There is **no separate Apple Watch target** in V1 — step data recorded by Apple Watch (or any other source) is read through HealthKit on the iPhone.

### What's Included

```
FirstStep/
├── App/
│   ├── FirstStepApp.swift          App entry point
│   ├── Info.plist                  HealthKit usage description
│   └── FirstStep.entitlements      HealthKit capability
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift          Main dashboard screen
│   │   ├── StepCardView.swift      Circular step-count display
│   │   └── JourneyCardView.swift   Active journey progress card
│   └── SideQuests/
│       └── SideQuestCardView.swift Side-quest placeholder/status card
└── Core/
    ├── Models/
    │   ├── Journey.swift           Active journey state
    │   ├── JourneyProgress.swift   Progress tracking
    │   ├── DestinationType.swift   Real vs fantasy enum
    │   ├── RealDestination.swift   Real-world target + Coordinate
    │   ├── FantasyDestination.swift Fantasy target with milestones
    │   ├── FantasyBiome.swift      Five biome types
    │   ├── SideQuest.swift         In-app challenge model
    │   ├── SideQuestRule.swift     Deferred side-quest rule definitions
    │   ├── SideQuestEvaluation.swift Side-quest evaluation state
    │   └── SampleData.swift        Demo journeys and quests
    ├── Services/
    │   ├── BackendService.swift    Firebase contract + stub
    │   ├── JourneyPlanningService.swift Prompt-to-route orchestration + stubs
    │   ├── FantasySceneService.swift Scene generation contract + stub
    │   ├── RouteProgressService.swift MapKit contract + stub
    │   └── StreetViewService.swift Street View contract + stub
    ├── Managers/
    │   ├── HealthKitManager.swift  HealthKit auth + step queries
    │   ├── JourneyEngine.swift     Steps → meters → percent
    │   └── SideQuestEngine.swift   Future side-quest evaluator
    ├── ViewModels/
    │   ├── StepsViewModel.swift    State coordinator for Home
    │   └── JourneyPromptViewModel.swift Prompted journey planner state
    ├── Utilities/
    │   └── StepFormatter.swift     Number formatting helpers
    └── Theme/
        └── AppTheme.swift          Colors, spacing, corner radii
```

### iPhone Screens

| Screen | Description |
|--------|-------------|
| **Home / Dashboard** | Header with date, circular step-count ring, HealthKit connect button, active journey progress card, side-quest list |
| **Step Card** | Animated circular progress ring showing today's steps against a 10K goal |
| **Journey Card** | Journey name, linear progress bar, distance walked, destination type badge |
| **Side Quest Cards** | Placeholder challenge cards that expose deferred rules/status without fake completion logic |

### HealthKit Integration

- **Read-only** access to `HKQuantityType.stepCount`
- Reads today's cumulative steps using `HKStatisticsQuery` (includes Apple Watch data)
- Modern Swift concurrency (`async/await` with `CheckedContinuation`)
- Authorization request with user-facing usage description
- Error states surfaced via alert

### Architecture

- **SwiftUI-first** — all views use `@StateObject` / `@ObservedObject`
- **Protocol-oriented services** — every external dependency is behind a protocol with a stub
- **`@MainActor` safety** — HealthKitManager and StepsViewModel are main-actor isolated
- **Sample data** — demo journey and side quests are pre-loaded so the UI demonstrates real visuals
- **Deferred side-quest engine** — side-quest rule types and evaluation states exist now, while complex rule execution remains turned off
- **Prompt-to-journey planning layer** — free-form user prompts can flow through real-route lookup first and AI generation as a fallback
- **Design system** — `AppTheme` provides consistent colors, gradients, spacing, and corner radii

### Placeholders for Future Milestones

| Future Feature | Current State |
|---|---|
| Firebase backend | `BackendService` protocol + `StubBackendService` |
| Prompted custom routes | `JourneyPlanningService` + `JourneyPromptViewModel` scaffolding; no UI yet |
| Route visualization | `RouteProgressService` protocol + stub |
| Street View imagery | `StreetViewService` protocol + stub |
| Fantasy scene generation | `FantasySceneService` protocol + stub |
| Destination picker | Sample journey auto-loaded; prompt/picker UI not yet built |
| Apple Watch companion | Deferred to a later milestone |

## Setup

### Quick Start (Xcode)

1. Open `FirstStep.xcodeproj` in Xcode 15+
2. Select a development team under **Signing & Capabilities**
3. Select the **FirstStepApp** scheme and an iOS simulator/device, then Build & Run
4. HealthKit requires a real device or a simulator with Health data seeded

### Regenerating the Xcode Project

If you modify the directory structure or add new source files, regenerate the project:

**Option A — XcodeGen** (if installed): `xcodegen generate`

**Option B — Python script** (no dependencies): `python3 generate_xcodeproj.py`

### Remaining Steps Before First Build

The generated `.xcodeproj` is structurally complete but was created outside Xcode. On first open:

1. **Set your development team** — Xcode > target > Signing & Capabilities > Team
2. **Verify HealthKit capability** — the entitlements file is wired, but you may need to toggle the HealthKit capability on/off in Xcode once to register it with your provisioning profile
3. **Add an Asset Catalog** — create `Assets.xcassets` in `FirstStep/App/` with an AppIcon set (Xcode > File > New > Asset Catalog). The build settings reference `AppIcon` but no catalog exists yet

### Package.swift (editor / CI)

A `Package.swift` is included for editor autocomplete and CI linting. It is **not** the shipping build system — HealthKit entitlements require a real Xcode project.

```bash
swift build   # validates syntax; HealthKit APIs require iOS SDK stubs
```

## What's Next — Recommended Milestones

### ~~Milestone 2: Xcode Project & Build Verification~~ ✅ Complete
- ~~Create a proper `.xcodeproj` with the FirstStep/ source tree~~
- Remaining: verify the scaffold compiles cleanly in Xcode, add Asset Catalog

### Milestone 3: Firebase Integration
- Add Firebase SDK via Swift Package Manager
- Implement `FirebaseBackendService` conforming to `BackendService`
- Add anonymous auth and Firestore journey/progress persistence

### Milestone 4: Destination Catalog & Journey Selection
- Build a destination picker UI (real-world and fantasy)
- Add a free-form prompt flow that attempts a real-world route lookup before generating a custom fantasy trail
- Seed initial destination data
- Wire up journey creation flow

### Milestone 5: Route Visualization & Side Quests
- Integrate MapKit for real-world route display
- Build fantasy scene rendering
- Implement side-quest rule evaluation with richer HealthKit activity inputs

### Milestone 6: Apple Watch Companion
- Add watchOS target
- Implement WatchConnectivity for syncing journey state
- Background HealthKit delivery for passive step updates
- Watch complications

## License

Private — All rights reserved.
