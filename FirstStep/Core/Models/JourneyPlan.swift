import Foundation

/// Where the journey definition came from.
enum JourneyPlanSource: String, Codable, Equatable {
    case mapsLookup
    case aiGenerated
}

enum JourneyPlanConfidence: String, Codable, Equatable {
    case exactMatch
    case approximateMatch
    case synthetic
}

/// Future output of the prompt-to-journey planning pipeline.
struct JourneyPlan: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let summary: String
    let destinationType: DestinationType
    let source: JourneyPlanSource
    let confidence: JourneyPlanConfidence
    let totalDistanceMeters: Double
    let routePreview: [Coordinate]
    let originLabel: String?
    let realDestination: RealDestination?
    let fantasyDestination: FantasyDestination?

    init(
        id: UUID = UUID(),
        title: String,
        summary: String,
        destinationType: DestinationType,
        source: JourneyPlanSource,
        confidence: JourneyPlanConfidence,
        totalDistanceMeters: Double,
        routePreview: [Coordinate] = [],
        originLabel: String? = nil,
        realDestination: RealDestination? = nil,
        fantasyDestination: FantasyDestination? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.destinationType = destinationType
        self.source = source
        self.confidence = confidence
        self.totalDistanceMeters = totalDistanceMeters
        self.routePreview = routePreview
        self.originLabel = originLabel
        self.realDestination = realDestination
        self.fantasyDestination = fantasyDestination
    }
}
