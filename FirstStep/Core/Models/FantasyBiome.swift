import Foundation

/// Biome types for fantasy destinations.
enum FantasyBiome: String, Codable, CaseIterable {
    case enchantedForest = "Enchanted Forest"
    case crystalCaverns = "Crystal Caverns"
    case cloudKingdom = "Cloud Kingdom"
    case volcanicIslands = "Volcanic Islands"
    case underwaterRuins = "Underwater Ruins"

    var description: String {
        switch self {
        case .enchantedForest: return "A mystical forest filled with glowing flora and ancient trees."
        case .crystalCaverns: return "Sparkling underground caverns lined with luminous crystals."
        case .cloudKingdom: return "Floating islands and sky-bridges high above the clouds."
        case .volcanicIslands: return "Fiery islands where magma rivers meet the sea."
        case .underwaterRuins: return "Sunken temples and coral-covered ruins beneath the waves."
        }
    }
}
