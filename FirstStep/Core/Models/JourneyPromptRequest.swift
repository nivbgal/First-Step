import Foundation

/// User-authored request for a prompted journey or trail.
enum JourneyPromptMode: String, Codable, CaseIterable {
    case autoDetect
    case realOnly
    case generatedOnly
}

struct JourneyPromptRequest: Identifiable, Codable, Equatable {
    let id: UUID
    let prompt: String
    let mode: JourneyPromptMode
    let preferredDistanceMeters: Double?
    let originLabel: String?
    let originCoordinate: Coordinate?

    init(
        id: UUID = UUID(),
        prompt: String,
        mode: JourneyPromptMode = .autoDetect,
        preferredDistanceMeters: Double? = nil,
        originLabel: String? = nil,
        originCoordinate: Coordinate? = nil
    ) {
        self.id = id
        self.prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.mode = mode
        self.preferredDistanceMeters = preferredDistanceMeters
        self.originLabel = originLabel
        self.originCoordinate = originCoordinate
    }
}
