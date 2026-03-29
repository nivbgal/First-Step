import Foundation

/// A dynamic event that occurs during an adventure, requiring user interaction.
struct Encounter: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let type: EncounterType
    let triggerDistance: Double // At what distance (meters) this encounter triggers
    let challenge: Challenge?
    let rewards: [Reward]
    let isRequired: Bool // Whether the encounter must be completed to continue
    var isCompleted: Bool = false
    let aiPrompt: String? // Prompt for AI-generated content
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        type: EncounterType,
        triggerDistance: Double,
        challenge: Challenge? = nil,
        rewards: [Reward] = [],
        isRequired: Bool = false,
        isCompleted: Bool = false,
        aiPrompt: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.triggerDistance = triggerDistance
        self.challenge = challenge
        self.rewards = rewards
        self.isRequired = isRequired
        self.isCompleted = isCompleted
        self.aiPrompt = aiPrompt
    }
}

enum EncounterType: String, Codable, CaseIterable {
    case obstacle = "Obstacle" // Locked gate, fallen tree, river
    enemy = "Enemy" // Troll, bandit, monster
    environmental = "Environmental" // Storm, earthquake, fog
    puzzle = "Puzzle" // Riddle, pattern matching
    boss = "Boss" // Major battle
    friendly = "Friendly" // Merchant, guide, ally
    discovery = "Discovery" // Treasure, secret area
    story = "Story" // Plot advancement
    
    var icon: String {
        switch self {
        case .obstacle: return "🚧"
        case .enemy: return "👹"
        case .environmental: return "🌪️"
        case .puzzle: return "🧩"
        case .boss: return "👑"
        case .friendly: return "👋"
        case .discovery: return "💎"
        case .story: return "📖"
        }
    }
    
    var color: String {
        switch self {
        case .obstacle: return "yellow"
        case .enemy: return "red"
        case .environmental: return "blue"
        case .puzzle: return "purple"
        case .boss: return "black"
        case .friendly: return "green"
        case .discovery: return "gold"
        case .story: return "indigo"
        }
    }
}

/// A fitness challenge that must be completed to overcome an encounter.
struct Challenge: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let type: ChallengeType
    let targetCount: Int
    let timeLimitSeconds: Int?
    let difficulty: Difficulty
    let instructions: String
    let successMessage: String
    let failureMessage: String
    
    var currentCount: Int = 0
    var isCompleted: Bool = false
    var startTime: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        type: ChallengeType,
        targetCount: Int,
        timeLimitSeconds: Int? = nil,
        difficulty: Difficulty = .medium,
        instructions: String,
        successMessage: String,
        failureMessage: String,
        currentCount: Int = 0,
        isCompleted: Bool = false,
        startTime: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.targetCount = targetCount
        self.timeLimitSeconds = timeLimitSeconds
        self.difficulty = difficulty
        self.instructions = instructions
        self.successMessage = successMessage
        self.failureMessage = failureMessage
        self.currentCount = currentCount
        self.isCompleted = isCompleted
        self.startTime = startTime
    }
    
    mutating func start() {
        startTime = Date()
        currentCount = 0
        isCompleted = false
    }
    
    mutating func incrementCount(by amount: Int = 1) {
        currentCount += amount
        if currentCount >= targetCount {
            isCompleted = true
        }
    }
    
    var timeRemaining: TimeInterval? {
        guard let startTime = startTime, let timeLimit = timeLimitSeconds else { return nil }
        let elapsed = Date().timeIntervalSince(startTime)
        return max(0, Double(timeLimit) - elapsed)
    }
    
    var isTimeExpired: Bool {
        guard let timeRemaining = timeRemaining else { return false }
        return timeRemaining <= 0
    }
}

enum ChallengeType: String, Codable, CaseIterable {
    case jumpingJacks = "Jumping Jacks"
    case squats = "Squats"
    case pushUps = "Push-ups"
    case lunges = "Lunges"
    case highKnees = "High Knees"
    case burpees = "Burpees"
    case planks = "Planks" // Time-based
    case running = "Running" // Distance-based
    case steps = "Steps" // Step count
    
    var icon: String {
        switch self {
        case .jumpingJacks: return "🤸"
        case .squats: return "🦵"
        case .pushUps: return "💪"
        case .lunges: return "🚶"
        case .highKnees: return "🏃"
        case .burpees: return "🔥"
        case .planks: return "🕐"
        case .running: return "👟"
        case .steps: return "👣"
        }
    }
    
    var unit: String {
        switch self {
        case .planks: return "seconds"
        case .running: return "meters"
        default: return "reps"
        }
    }
    
    var sensorType: SensorType? {
        switch self {
        case .jumpingJacks, .squats, .pushUps, .lunges, .highKnees, .burpees:
            return .motion
        case .planks:
            return .motion // Could use accelerometer for stability
        case .running:
            return .distance
        case .steps:
            return .stepCount
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    
    var multiplier: Double {
        switch self {
        case .easy: return 0.5
        case .medium: return 1.0
        case .hard: return 1.5
        case .expert: return 2.0
        }
    }
    
    var xpMultiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        case .expert: return 3.0
        }
    }
}

enum SensorType: String, Codable {
    case motion = "Motion"
    case distance = "Distance"
    case stepCount = "Step Count"
    case heartRate = "Heart Rate"
}