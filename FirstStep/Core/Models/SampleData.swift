import Foundation

/// Sample journey data so the UI feels like a product during development.
enum SampleData {
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

    static let sideQuests: [SideQuest] = [
        SideQuest(
            title: "Morning Stride",
            description: "Walk 2,000 steps before 9 AM",
            targetSteps: 2_000,
            iconName: "sunrise.fill",
            isComplete: false
        ),
        SideQuest(
            title: "Steady Pace",
            description: "Log steps in 3 consecutive hours",
            targetSteps: 3_000,
            iconName: "timer",
            isComplete: false
        ),
        SideQuest(
            title: "Explorer",
            description: "Reach 10,000 steps in a single day",
            targetSteps: 10_000,
            iconName: "map.fill",
            isComplete: false
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
}
