import Foundation

/// Future-facing prompt entrypoint for custom routes and AI-generated journeys.
@MainActor
final class JourneyPromptViewModel: ObservableObject {
    @Published var promptText: String = ""
    @Published var preferredMode: JourneyPromptMode = .autoDetect
    @Published var preferredDistanceMeters: Double?
    @Published private(set) var latestPlan: JourneyPlan?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let journeyPlanningService: JourneyPlanningService

    init(
        journeyPlanningService: JourneyPlanningService = DefaultJourneyPlanningService(
            realRouteLookupService: StubRealRouteLookupService(),
            generatedJourneyService: StubGeneratedJourneyService()
        )
    ) {
        self.journeyPlanningService = journeyPlanningService
    }

    func planJourney(originLabel: String? = nil, originCoordinate: Coordinate? = nil) async {
        isLoading = true
        errorMessage = nil

        let request = JourneyPromptRequest(
            prompt: promptText,
            mode: preferredMode,
            preferredDistanceMeters: preferredDistanceMeters,
            originLabel: originLabel,
            originCoordinate: originCoordinate
        )

        do {
            latestPlan = try await journeyPlanningService.planJourney(for: request)
        } catch {
            latestPlan = nil
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
