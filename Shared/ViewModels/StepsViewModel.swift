import Foundation

/// ViewModel for displaying step count and journey progress on both iOS and watchOS.
@MainActor
final class StepsViewModel: ObservableObject {
    @Published var todaySteps: Int = 0
    @Published var formattedSteps: String = "0"
    @Published var progress: JourneyProgress?
    @Published var formattedPercent: String = "0%"
    @Published var formattedDistance: String = "0 m"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let healthKitManager: HealthKitManager
    private var activeJourney: Journey?

    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
    }

    /// Requests HealthKit permission and loads today's steps.
    func connectAndLoadSteps() async {
        isLoading = true
        errorMessage = nil

        await healthKitManager.requestAuthorization()

        if let error = healthKitManager.errorMessage {
            errorMessage = error
            isLoading = false
            return
        }

        await healthKitManager.fetchTodaySteps()
        todaySteps = healthKitManager.todaySteps
        formattedSteps = StepFormatter.formattedSteps(todaySteps)

        if let error = healthKitManager.errorMessage {
            errorMessage = error
        }

        updateProgress()
        isLoading = false
    }

    /// Sets the active journey for progress tracking.
    func setActiveJourney(_ journey: Journey) {
        activeJourney = journey
        updateProgress()
    }

    private func updateProgress() {
        guard let journey = activeJourney else {
            formattedPercent = "0%"
            formattedDistance = "0 m"
            return
        }
        let prog = JourneyEngine.calculateProgress(journey: journey, steps: todaySteps)
        progress = prog
        formattedPercent = StepFormatter.formattedPercent(prog.percentComplete)
        formattedDistance = StepFormatter.formattedDistance(meters: prog.metersCompleted)
    }
}
