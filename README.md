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
│       └── SideQuestCardView.swift Side-quest challenge card
└── Core/
    ├── Models/
    │   ├── Journey.swift           Active journey state
    │   ├── JourneyProgress.swift   Progress tracking
    │   ├── DestinationType.swift   Real vs fantasy enum
    │   ├── RealDestination.swift   Real-world target + Coordinate
    │   ├── FantasyDestination.swift Fantasy target with milestones
    │   ├── FantasyBiome.swift      Five biome types
    │   ├── SideQuest.swift         In-app challenge model
    │   └── SampleData.swift        Demo journeys and quests
    ├── Services/
    │   ├── BackendService.swift    Firebase contract + stub
    │   ├── FantasySceneService.swift Scene generation contract + stub
    │   ├── RouteProgressService.swift MapKit contract + stub
    │   └── StreetViewService.swift Street View contract + stub
    ├── Managers/
    │   ├── HealthKitManager.swift  HealthKit auth + step queries
    │   └── JourneyEngine.swift     Steps → meters → percent
    ├── ViewModels/
    │   └── StepsViewModel.swift    State coordinator for Home
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
| **Side Quest Cards** | Mini-challenge cards with icon, description, and completion percentage |

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
- **Design system** — `AppTheme` provides consistent colors, gradients, spacing, and corner radii

### Placeholders for Future Milestones

| Future Feature | Current State |
|---|---|
| Firebase backend | `BackendService` protocol + `StubBackendService` |
| Route visualization | `RouteProgressService` protocol + stub |
| Street View imagery | `StreetViewService` protocol + stub |
| Fantasy scene generation | `FantasySceneService` protocol + stub |
| Destination picker | Sample journey auto-loaded; picker UI not yet built |
| Apple Watch companion | Deferred to a later milestone |

## Setup

### Quick Start (Xcode)

1. Open Xcode 15+ → **File → New → Project → iOS App** (SwiftUI, Swift)
2. Set product name to `FirstStep`
3. Delete the auto-generated `ContentView.swift`
4. Drag the `FirstStep/` folder into the Xcode project navigator
5. In **Signing & Capabilities**, add **HealthKit**
6. Build and run on a real device or simulator with Health data

### Package.swift (editor / CI)

A `Package.swift` is included for editor autocomplete and CI linting. It is **not** the shipping build system — HealthKit entitlements require a real Xcode project.

```bash
swift build   # validates syntax; HealthKit APIs require iOS SDK stubs
```

## What's Next — Recommended Milestones

### Milestone 2: Xcode Project & Build Verification
- Create a proper `.xcodeproj` with the FirstStep/ source tree
- Verify the project compiles and runs on a device
- Confirm HealthKit permission dialog and step reading work end-to-end

### Milestone 3: Firebase Integration
- Add Firebase SDK via Swift Package Manager
- Implement `FirebaseBackendService` conforming to `BackendService`
- Add anonymous auth and Firestore journey/progress persistence

### Milestone 4: Destination Catalog & Journey Selection
- Build a destination picker UI (real-world and fantasy)
- Seed initial destination data
- Wire up journey creation flow

### Milestone 5: Route Visualization & Side Quests
- Integrate MapKit for real-world route display
- Build fantasy scene rendering
- Implement side-quest completion logic with HealthKit triggers

### Milestone 6: Apple Watch Companion
- Add watchOS target
- Implement WatchConnectivity for syncing journey state
- Background HealthKit delivery for passive step updates
- Watch complications

## License

Private — All rights reserved.
