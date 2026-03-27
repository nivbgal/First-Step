import SwiftUI

@main
struct FirstStepWatchApp: App {
    @StateObject private var healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            WatchContentView(healthKitManager: healthKitManager)
        }
    }
}
