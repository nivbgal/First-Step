import SwiftUI

@main
struct FirstStepApp: App {
    @StateObject private var healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            // Switch to AdventureView for the game-like experience
            AdventureView(healthKitManager: healthKitManager)
            // To switch back to the original simple version, use:
            // HomeView(healthKitManager: healthKitManager)
        }
    }
}
