# First Step

**First Step** is an iOS + Apple Watch app that gamifies walking by turning your daily steps into virtual journeys to real-world and fantasy destinations.

## Current State — Initial Scaffold

This is the foundational codebase scaffold. It establishes the project structure, core domain models, service abstractions, and minimal UI for both iOS and watchOS. No third-party SDKs (Firebase, Google Maps) are integrated yet — only protocols and stubs are in place.

### What's Included

#### Shared Core (`Shared/`)

| Layer | Files | Description |
|-------|-------|-------------|
| **Models** | `Journey.swift`, `DestinationType.swift`, `RealDestination.swift`, `FantasyDestination.swift`, `FantasyBiome.swift`, `JourneyProgress.swift` | Domain model types for journeys, destinations (real and fantasy), biome definitions, and progress tracking. |
| **Services** | `RouteProgressService.swift`, `StreetViewService.swift`, `FantasySceneService.swift`, `BackendService.swift` | Protocol definitions + stub implementations for route progress (MapKit-ready), street-view imagery (Google Street View-ready), fantasy scene generation, and Firebase backend persistence. |
| **Managers** | `HealthKitManager.swift`, `JourneyEngine.swift` | `HealthKitManager` requests HealthKit authorization and reads today's cumulative step count. `JourneyEngine` converts steps → meters → percent-complete for a given journey. |
| **ViewModels** | `StepsViewModel.swift` | Observable view model that coordinates HealthKit data with journey progress, shared by iOS and watchOS. |
| **Utilities** | `StepFormatter.swift` | Formatting helpers for step counts, distances, and percentages. |

#### iOS App (`FirstStepApp/`)

- `FirstStepApp.swift` — SwiftUI app entry point
- `ContentView.swift` — Main screen with app title, today's step count, HealthKit connect button, and journey progress summary
- `Info.plist` — HealthKit usage description

#### watchOS App (`FirstStepWatchApp/`)

- `FirstStepWatchApp.swift` — SwiftUI watchOS app entry point
- `WatchContentView.swift` — Compact watch view with steps, progress percentage, distance, and a load button
- `Info.plist` — HealthKit usage description

### HealthKit Integration

- Requests **read-only** access to step count data (`HKQuantityType.stepCount`)
- Reads today's cumulative step count using `HKStatisticsQuery`
- Uses modern Swift concurrency (`async/await` with `CheckedContinuation`)

### Architecture Notes

- **SwiftUI-first** — all views use SwiftUI with `@StateObject` / `@ObservedObject` patterns
- **Protocol-oriented services** — every external dependency is behind a protocol with a stub implementation, making it easy to swap in real implementations
- **Shared code** — models, services, managers, and view models live in `Shared/` and are intended to be compiled into both the iOS and watchOS targets
- **No secrets committed** — Firebase config, API keys, and xcconfig files are gitignored

## Setup

1. Open the project in Xcode 15+
2. Create an Xcode project/workspace that references these source files (or set up an Xcode project with the directory structure)
3. Add the HealthKit capability to both the iOS and watchOS targets
4. Add `Shared/` sources to both targets
5. Build and run on a device (HealthKit requires a real device or simulator with Health data)

## What's Next — Recommended MVP Milestones

### Milestone 2: Xcode Project & Build Verification
- Create a proper `.xcodeproj` / `.xcworkspace` with iOS and watchOS targets
- Verify the scaffold compiles cleanly on both platforms
- Add HealthKit entitlements to both targets

### Milestone 3: Firebase Integration
- Add Firebase SDK via Swift Package Manager
- Implement `FirebaseBackendService` conforming to `BackendService`
- Add anonymous auth and Firestore journey/progress persistence

### Milestone 4: Destination Catalog & Journey Selection
- Build a destination picker UI (real-world and fantasy)
- Seed initial destination data
- Wire up journey creation flow

### Milestone 5: Route Visualization
- Integrate MapKit for real-world route display
- Build fantasy scene rendering (static assets or AI-generated)
- Add progress visualization along the route

### Milestone 6: Watch Companion & Live Updates
- Implement WatchConnectivity for syncing journey state
- Add background HealthKit delivery for passive step updates
- Build watch complications for at-a-glance progress

## License

Private — All rights reserved.
