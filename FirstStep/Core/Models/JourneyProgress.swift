import Foundation

/// Tracks the user's progress within a journey.
struct JourneyProgress: Codable, Equatable {
    let journeyID: UUID
    var stepsCompleted: Int
    var metersCompleted: Double
    var percentComplete: Double
    var lastUpdated: Date

    init(
        journeyID: UUID,
        stepsCompleted: Int = 0,
        metersCompleted: Double = 0,
        percentComplete: Double = 0,
        lastUpdated: Date = Date()
    ) {
        self.journeyID = journeyID
        self.stepsCompleted = stepsCompleted
        self.metersCompleted = metersCompleted
        self.percentComplete = percentComplete
        self.lastUpdated = lastUpdated
    }
}
