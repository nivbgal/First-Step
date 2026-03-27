import Foundation

/// A journey the user undertakes — either toward a real or fantasy destination.
struct Journey: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let destinationType: DestinationType
    let totalDistanceMeters: Double
    var isActive: Bool
    let createdAt: Date

    /// The associated real destination ID, if applicable.
    var realDestinationID: UUID?
    /// The associated fantasy destination ID, if applicable.
    var fantasyDestinationID: UUID?

    init(
        id: UUID = UUID(),
        name: String,
        destinationType: DestinationType,
        totalDistanceMeters: Double,
        isActive: Bool = true,
        createdAt: Date = Date(),
        realDestinationID: UUID? = nil,
        fantasyDestinationID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.destinationType = destinationType
        self.totalDistanceMeters = totalDistanceMeters
        self.isActive = isActive
        self.createdAt = createdAt
        self.realDestinationID = realDestinationID
        self.fantasyDestinationID = fantasyDestinationID
    }
}
