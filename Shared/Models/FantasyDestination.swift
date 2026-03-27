import Foundation

/// A fantasy destination with a biome, narrative milestones, and total distance.
struct FantasyDestination: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let biome: FantasyBiome
    let distanceMeters: Double
    let milestoneDescriptions: [String]

    init(
        id: UUID = UUID(),
        name: String,
        biome: FantasyBiome,
        distanceMeters: Double,
        milestoneDescriptions: [String] = []
    ) {
        self.id = id
        self.name = name
        self.biome = biome
        self.distanceMeters = distanceMeters
        self.milestoneDescriptions = milestoneDescriptions
    }
}
