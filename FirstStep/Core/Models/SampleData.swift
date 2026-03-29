import Foundation

/// Sample data so the UI feels like a product during development.
enum SampleData {
    // Legacy journey data (for backward compatibility)
    static let enchantedForestJourney = Journey(
        name: "Path to the Enchanted Forest",
        destinationType: .fantasy,
        totalDistanceMeters: 10_000
    )

    static let tokyoJourney = Journey(
        name: "Walk to Tokyo Tower",
        destinationType: .real,
        totalDistanceMeters: 25_000
    )

    // New adventure data
    static let sampleAdventures: [Adventure] = [
        Adventure(
            name: "The Enchanted Forest",
            description: "A magical forest filled with mysterious creatures and hidden treasures. Your steps will guide you through this living world.",
            theme: .fantasy,
            totalDistanceMeters: 5000,
            experiencePoints: 0,
            level: 1
        ),
        Adventure(
            name: "Mars Colony Expedition",
            description: "Navigate the red planet's surface, avoiding dust storms and discovering ancient artifacts.",
            theme: .sciFi,
            totalDistanceMeters: 8000,
            experiencePoints: 150,
            level: 2
        ),
        Adventure(
            name: "Haunted Victorian Mansion",
            description: "Explore a mysterious mansion, solving puzzles and uncovering secrets in each room.",
            theme: .mystery,
            totalDistanceMeters: 3000,
            experiencePoints: 50,
            level: 1
        )
    ]

    static let sideQuests: [SideQuest] = [
        SideQuest(
            title: "Morning Stride",
            description: "Walk 2,000 steps before 9 AM",
            rule: .stepGoalBeforeHour(2_000, cutoffHour: 9),
            iconName: "sunrise.fill",
            availability: .planned
        ),
        SideQuest(
            title: "Steady Pace",
            description: "Log steps in 3 consecutive hours",
            rule: .consecutiveActiveHours(3, minimumStepsPerHour: 1_000),
            iconName: "timer",
            availability: .planned
        ),
        SideQuest(
            title: "Explorer",
            description: "Reach 10,000 steps in a single day",
            rule: .stepGoal(10_000),
            iconName: "map.fill",
            availability: .planned
        ),
    ]

    static let fantasyDestinations: [FantasyDestination] = [
        FantasyDestination(
            name: "Glowshroom Glade",
            biome: .enchantedForest,
            distanceMeters: 5_000,
            milestoneDescriptions: [
                "You step beneath the first canopy of luminescent trees.",
                "Strange spores drift past — the forest welcomes you.",
                "The glade opens ahead, glowing softly in twilight.",
            ]
        ),
        FantasyDestination(
            name: "Prismatic Depths",
            biome: .crystalCaverns,
            distanceMeters: 8_000,
            milestoneDescriptions: [
                "You descend through a narrow fissure into cool darkness.",
                "Crystals begin to hum as you approach the central chamber.",
                "A vast geode cavern stretches before you, alive with color.",
            ]
        ),
        FantasyDestination(
            name: "Cirrus Keep",
            biome: .cloudKingdom,
            distanceMeters: 12_000,
            milestoneDescriptions: [
                "A spiral staircase of frozen vapor rises before you.",
                "Between the clouds, floating gardens drift lazily.",
                "The Keep materializes — translucent towers against endless sky.",
            ]
        ),
    ]

    // Sample encounters for adventures
    static let forestEncounters: [Encounter] = [
        Encounter(
            name: "Moss-Covered Gate",
            description: "An ancient stone gate blocks your path, covered in glowing moss.",
            type: .obstacle,
            triggerDistance: 1000,
            challenge: Challenge(
                name: "Jumping Jacks",
                description: "Perform jumping jacks to build enough energy to push open the gate.",
                type: .jumpingJacks,
                targetCount: 20,
                timeLimitSeconds: 60,
                difficulty: .easy,
                instructions: "Stand with feet together, jump while spreading legs and raising arms, then return to starting position.",
                successMessage: "The gate creaks open! You feel energized and ready to continue.",
                failureMessage: "The gate remains stubbornly closed. You'll need to find another way."
            ),
            rewards: [
                Reward(
                    id: UUID(),
                    name: "Forest Key",
                    description: "A wooden key that glows with faint magic.",
                    icon: "🗝️",
                    type: .utility,
                    unlockedAt: Date()
                )
            ],
            isRequired: true
        ),
        Encounter(
            name: "Grumpy River Troll",
            description: "A large troll guards a narrow bridge across a rushing river.",
            type: .enemy,
            triggerDistance: 2500,
            challenge: Challenge(
                name: "Squats",
                description: "Perform squats to show the troll your strength and intimidate it.",
                type: .squats,
                targetCount: 15,
                timeLimitSeconds: 45,
                difficulty: .medium,
                instructions: "Stand with feet shoulder-width apart, lower your body as if sitting in a chair, then return to standing.",
                successMessage: "The troll grunts in respect and steps aside!",
                failureMessage: "The troll laughs at your weakness and demands a toll."
            ),
            rewards: [
                Reward(
                    id: UUID(),
                    name: "Troll's Blessing",
                    description: "The troll's grudging respect makes you feel stronger.",
                    icon: "🛡️",
                    type: .ability,
                    unlockedAt: Date()
                )
            ]
        )
    ]
}
