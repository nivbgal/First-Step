// swift-tools-version: 5.9
import PackageDescription

// ============================================================================
// NOTE: This Package.swift exists to give the project a compilable structure
// that can be validated with `swift build` for non-HealthKit code.
//
// HealthKit requires a real Xcode project with entitlements, provisioning
// profiles, and a device target. The recommended setup path is:
//
//   1. Open Xcode → File → New → Project → iOS App (SwiftUI)
//   2. Set product name to "FirstStep", bundle ID to your team's reverse-DNS
//   3. Delete the auto-generated ContentView.swift
//   4. Drag the FirstStep/ folder into the Xcode project navigator
//   5. Add HealthKit capability in Signing & Capabilities
//   6. Build & run on a real device or simulator with Health data
//
// This Package.swift is useful for CI linting and editor autocomplete but
// is NOT the shipping build system.
// ============================================================================

let package = Package(
    name: "FirstStep",
    platforms: [
        .iOS(.v16)
    ],
    targets: [
        .executableTarget(
            name: "FirstStep",
            path: "FirstStep",
            exclude: [
                "App/Info.plist",
                "App/FirstStep.entitlements",
            ]
        )
    ]
)
