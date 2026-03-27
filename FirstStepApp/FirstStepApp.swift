import SwiftUI

@main
struct FirstStepApp: App {
    @StateObject private var healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView(healthKitManager: healthKitManager)
        }
    }
}
