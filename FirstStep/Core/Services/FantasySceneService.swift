import Foundation

/// Generates or retrieves fantasy scene imagery/descriptions for a biome and progress point.
/// Future implementation may use AI image generation or a curated asset library.
protocol FantasySceneService {
    /// Returns a narrative description for the current position in a fantasy journey.
    func sceneDescription(biome: FantasyBiome, progressFraction: Double) async throws -> String

    /// Returns image data representing the fantasy scene.
    func sceneImage(biome: FantasyBiome, progressFraction: Double) async throws -> Data
}

// MARK: - Stub

struct StubFantasySceneService: FantasySceneService {
    func sceneDescription(biome: FantasyBiome, progressFraction: Double) async throws -> String {
        let percent = Int(progressFraction * 100)
        return "You are \(percent)% through the \(biome.rawValue). \(biome.description)"
    }

    func sceneImage(biome: FantasyBiome, progressFraction: Double) async throws -> Data {
        return Data()
    }
}
