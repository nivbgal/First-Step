import Foundation

/// Converts raw step counts into journey progress (meters and percent complete).
struct JourneyEngine {
    /// Average stride length in meters. A reasonable default for walking.
    static let defaultStrideMeters: Double = 0.762 // ~30 inches

    /// Converts a step count to distance in meters.
    static func metersFromSteps(_ steps: Int, strideMeters: Double = defaultStrideMeters) -> Double {
        Double(steps) * strideMeters
    }

    /// Calculates updated progress for a journey given today's step count.
    static func calculateProgress(
        journey: Journey,
        steps: Int,
        strideMeters: Double = defaultStrideMeters
    ) -> JourneyProgress {
        let meters = metersFromSteps(steps, strideMeters: strideMeters)
        let fraction = journey.totalDistanceMeters > 0
            ? min(meters / journey.totalDistanceMeters, 1.0)
            : 0
        return JourneyProgress(
            journeyID: journey.id,
            stepsCompleted: steps,
            metersCompleted: meters,
            percentComplete: fraction * 100,
            lastUpdated: Date()
        )
    }
}
