import Foundation

/// A playable adventure that turns fitness into a game.
/// Replaces the simpler Journey model with game-like mechanics.
struct Adventure: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let theme: AdventureTheme
    let totalDistanceMeters: Double
    var currentDistanceMeters: Double
    var isActive: Bool
    let createdAt: Date
    
    // Game mechanics
    var experiencePoints: Int
    var level: Int
    var currentEncounterIndex: Int?
    var completedEncounters: [UUID] // IDs of completed encounters
    var unlockedRewards: [Reward]
    
    // World state
    var worldState: [String: AnyCodable] // Dynamic world properties
    
    // Associated destinations
    var realDestinationID: UUID?
    var fantasyDestinationID: UUID?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        theme: AdventureTheme,
        totalDistanceMeters: Double,
        currentDistanceMeters: Double = 0,
        isActive: Bool = true,
        createdAt: Date = Date(),
        experiencePoints: Int = 0,
        level: Int = 1,
        currentEncounterIndex: Int? = nil,
        completedEncounters: [UUID] = [],
        unlockedRewards: [Reward] = [],
        worldState: [String: AnyCodable] = [:],
        realDestinationID: UUID? = nil,
        fantasyDestinationID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.theme = theme
        self.totalDistanceMeters = totalDistanceMeters
        self.currentDistanceMeters = currentDistanceMeters
        self.isActive = isActive
        self.createdAt = createdAt
        self.experiencePoints = experiencePoints
        self.level = level
        self.currentEncounterIndex = currentEncounterIndex
        self.completedEncounters = completedEncounters
        self.unlockedRewards = unlockedRewards
        self.worldState = worldState
        self.realDestinationID = realDestinationID
        self.fantasyDestinationID = fantasyDestinationID
    }
    
    var percentComplete: Double {
        guard totalDistanceMeters > 0 else { return 0 }
        return min(currentDistanceMeters / totalDistanceMeters, 1.0)
    }
    
    var nextLevelXP: Int {
        // Simple leveling curve: 100 XP per level
        level * 100
    }
    
    var canLevelUp: Bool {
        experiencePoints >= nextLevelXP
    }
    
    mutating func addExperience(_ points: Int) {
        experiencePoints += points
        while canLevelUp {
            experiencePoints -= nextLevelXP
            level += 1
            // TODO: Add level-up rewards
        }
    }
    
    mutating func addDistance(_ meters: Double) {
        currentDistanceMeters += meters
        // Add XP for distance traveled
        let xpEarned = Int(meters / 10) // 1 XP per 10 meters
        addExperience(xpEarned)
    }
}

enum AdventureTheme: String, Codable, CaseIterable {
    case fantasy = "Fantasy"
    case sciFi = "Sci-Fi"
    case postApocalyptic = "Post-Apocalyptic"
    case mystery = "Mystery"
    case historical = "Historical"
    case nature = "Nature"
    
    var icon: String {
        switch self {
        case .fantasy: return "🌲"
        case .sciFi: return "🚀"
        case .postApocalyptic: return "🏚️"
        case .mystery: return "🔍"
        case .historical: return "🏛️"
        case .nature: return "🌿"
        }
    }
    
    var color: String {
        switch self {
        case .fantasy: return "purple"
        case .sciFi: return "blue"
        case .postApocalyptic: return "orange"
        case .mystery: return "indigo"
        case .historical: return "brown"
        case .nature: return "green"
        }
    }
}

struct Reward: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let type: RewardType
    let unlockedAt: Date
    
    enum RewardType: String, Codable {
        case cosmetic = "Cosmetic"
        case ability = "Ability"
        case story = "Story"
        case utility = "Utility"
    }
}

// Helper for dynamic world state
struct AnyCodable: Codable, Equatable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map(AnyCodable.init))
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues(AnyCodable.init))
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(value, context)
        }
    }
    
    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        // Simple equality check - in production you'd want more robust comparison
        String(describing: lhs.value) == String(describing: rhs.value)
    }
}