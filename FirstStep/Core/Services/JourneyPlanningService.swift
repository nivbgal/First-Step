import Foundation

/// Looks up a real-world route for a free-form prompt.
protocol RealRouteLookupService {
    func findBestMatch(for request: JourneyPromptRequest) async throws -> JourneyPlan?
}

/// Generates a synthetic journey when a real-world lookup does not succeed.
protocol GeneratedJourneyService {
    func generateJourney(for request: JourneyPromptRequest) async throws -> JourneyPlan
}

/// Orchestrates prompt-to-journey planning with real lookup first and AI fallback.
protocol JourneyPlanningService {
    func planJourney(for request: JourneyPromptRequest) async throws -> JourneyPlan
}

enum JourneyPlanningError: LocalizedError {
    case emptyPrompt

    var errorDescription: String? {
        switch self {
        case .emptyPrompt:
            return "Enter a route, trail, or world to explore."
        }
    }
}

struct DefaultJourneyPlanningService: JourneyPlanningService {
    private let realRouteLookupService: RealRouteLookupService
    private let generatedJourneyService: GeneratedJourneyService

    init(
        realRouteLookupService: RealRouteLookupService,
        generatedJourneyService: GeneratedJourneyService
    ) {
        self.realRouteLookupService = realRouteLookupService
        self.generatedJourneyService = generatedJourneyService
    }

    func planJourney(for request: JourneyPromptRequest) async throws -> JourneyPlan {
        guard !request.prompt.isEmpty else {
            throw JourneyPlanningError.emptyPrompt
        }

        if request.mode != .generatedOnly,
           let mappedJourney = try await realRouteLookupService.findBestMatch(for: request) {
            return mappedJourney
        }

        return try await generatedJourneyService.generateJourney(for: request)
    }
}

struct StubRealRouteLookupService: RealRouteLookupService {
    func findBestMatch(for request: JourneyPromptRequest) async throws -> JourneyPlan? {
        let normalizedPrompt = request.prompt.lowercased()

        guard normalizedPrompt.contains("tokyo") || normalizedPrompt.contains("tower") else {
            return nil
        }

        let destination = RealDestination(
            name: "Tokyo Tower",
            latitude: 35.6586,
            longitude: 139.7454,
            distanceMeters: request.preferredDistanceMeters ?? 25_000
        )

        return JourneyPlan(
            title: "Walk to Tokyo Tower",
            summary: "Matched to a real-world route candidate from the prompt.",
            destinationType: .real,
            source: .mapsLookup,
            confidence: .approximateMatch,
            totalDistanceMeters: destination.distanceMeters,
            routePreview: [
                request.originCoordinate ?? Coordinate(latitude: 35.6762, longitude: 139.6503),
                destination.coordinate,
            ],
            originLabel: request.originLabel,
            realDestination: destination,
            fantasyDestination: nil
        )
    }
}

struct StubGeneratedJourneyService: GeneratedJourneyService {
    func generateJourney(for request: JourneyPromptRequest) async throws -> JourneyPlan {
        let title = request.prompt.isEmpty ? "Untitled Journey" : request.prompt
        let distance = request.preferredDistanceMeters ?? 12_000
        let fantasyDestination = FantasyDestination(
            name: title,
            biome: .enchantedForest,
            distanceMeters: distance,
            milestoneDescriptions: [
                "A custom route takes shape from your prompt.",
                "The trail bends into places no public map can resolve.",
                "The generated destination crystallizes ahead."
            ]
        )

        return JourneyPlan(
            title: title,
            summary: "Generated from the user's prompt because no real-world route matched cleanly.",
            destinationType: .fantasy,
            source: .aiGenerated,
            confidence: .synthetic,
            totalDistanceMeters: distance,
            routePreview: request.originCoordinate.map { [$0] } ?? [],
            originLabel: request.originLabel,
            realDestination: nil,
            fantasyDestination: fantasyDestination
        )
    }
}
