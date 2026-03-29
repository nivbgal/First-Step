import Foundation

/// Core game engine that manages adventures, encounters, and progression.
@MainActor
final class AdventureEngine: ObservableObject {
    @Published var activeAdventure: Adventure?
    @Published var currentEncounter: Encounter?
    @Published var isInEncounter: Bool = false
    @Published var adventureProgress: Double = 0
    
    private var adventures: [Adventure] = []
    private var encounterRegistry: [UUID: Encounter] = [:] // All possible encounters
    private var adventureEncounters: [UUID: [Encounter]] = [:] // Encounters for each adventure
    
    /// Starts a new adventure
    func startAdventure(_ adventure: Adventure, withEncounters encounters: [Encounter] = []) {
        activeAdventure = adventure
        adventureEncounters[adventure.id] = encounters
        adventureProgress = 0
        currentEncounter = nil
        isInEncounter = false
        
        // Register all encounters
        for encounter in encounters {
            encounterRegistry[encounter.id] = encounter
        }
        
        // Check for starting encounter
        checkForEncounter(atDistance: 0)
    }
    
    /// Updates adventure progress based on distance traveled
    func updateProgress(distanceMeters: Double) {
        guard var adventure = activeAdventure else { return }
        
        let previousDistance = adventure.currentDistanceMeters
        adventure.currentDistanceMeters += distanceMeters
        adventureProgress = adventure.percentComplete
        
        // Check for encounters at the new distance
        checkForEncounter(atDistance: adventure.currentDistanceMeters)
        
        // Update active adventure
        activeAdventure = adventure
    }
    
    /// Checks if an encounter should trigger at the given distance
    private func checkForEncounter(atDistance distance: Double) {
        guard let adventure = activeAdventure,
              let encounters = adventureEncounters[adventure.id] else { return }
        
        // Find encounters that should trigger at this distance
        let triggeringEncounters = encounters.filter { encounter in
            !encounter.isCompleted &&
            distance >= encounter.triggerDistance &&
            (adventure.currentEncounterIndex == nil || 
             !encounters.prefix(adventure.currentEncounterIndex ?? 0).contains(where: { $0.id == encounter.id }))
        }.sorted(by: { $0.triggerDistance < $1.triggerDistance })
        
        if let nextEncounter = triggeringEncounters.first {
            triggerEncounter(nextEncounter)
        }
    }
    
    /// Triggers an encounter
    private func triggerEncounter(_ encounter: Encounter) {
        currentEncounter = encounter
        isInEncounter = true
        
        // Update adventure state
        if var adventure = activeAdventure,
           let encounters = adventureEncounters[adventure.id],
           let encounterIndex = encounters.firstIndex(where: { $0.id == encounter.id }) {
            adventure.currentEncounterIndex = encounterIndex
            activeAdventure = adventure
        }
    }
    
    /// Completes the current encounter
    func completeCurrentEncounter(success: Bool = true) {
        guard let encounter = currentEncounter,
              var adventure = activeAdventure,
              var updatedEncounter = encounterRegistry[encounter.id] else { return }
        
        updatedEncounter.isCompleted = success
        
        if success {
            // Apply rewards
            for reward in encounter.rewards {
                if !adventure.unlockedRewards.contains(where: { $0.id == reward.id }) {
                    adventure.unlockedRewards.append(reward)
                }
            }
            
            // Add XP for completing encounter
            let baseXP = 50
            let challengeXP = encounter.challenge != nil ? 25 : 0
            let difficultyMultiplier = encounter.challenge?.difficulty.xpMultiplier ?? 1.0
            let xpEarned = Int(Double(baseXP + challengeXP) * difficultyMultiplier)
            adventure.addExperience(xpEarned)
            
            // Mark as completed in adventure
            if !adventure.completedEncounters.contains(encounter.id) {
                adventure.completedEncounters.append(encounter.id)
            }
        }
        
        // Update registry
        encounterRegistry[encounter.id] = updatedEncounter
        
        // Clear current encounter
        currentEncounter = nil
        isInEncounter = false
        activeAdventure = adventure
        
        // Check for next encounter immediately
        checkForEncounter(atDistance: adventure.currentDistanceMeters)
    }
    
    /// Starts the challenge for the current encounter
    func startCurrentChallenge() {
        guard var encounter = currentEncounter,
              var challenge = encounter.challenge else { return }
        
        challenge.start()
        encounter.challenge = challenge
        currentEncounter = encounter
        encounterRegistry[encounter.id] = encounter
    }
    
    /// Updates the current challenge progress
    func updateChallengeProgress(count: Int) {
        guard var encounter = currentEncounter,
              var challenge = encounter.challenge else { return }
        
        challenge.incrementCount(by: count)
        
        if challenge.isCompleted {
            // Challenge completed successfully
            encounter.challenge = challenge
            currentEncounter = encounter
            encounterRegistry[encounter.id] = encounter
            completeCurrentEncounter(success: true)
        } else if challenge.isTimeExpired {
            // Challenge failed due to time
            completeCurrentEncounter(success: false)
        } else {
            // Update progress
            encounter.challenge = challenge
            currentEncounter = encounter
            encounterRegistry[encounter.id] = encounter
        }
    }
    
    /// Skips the current encounter (if allowed)
    func skipCurrentEncounter() {
        guard let encounter = currentEncounter, !encounter.isRequired else { return }
        completeCurrentEncounter(success: false)
    }
    
    /// Creates a sample adventure for testing
    func createSampleAdventure() -> Adventure {
        let adventure = Adventure(
            name: "The Enchanted Forest",
            description: "A magical forest filled with mysterious creatures and hidden treasures. Your steps will guide you through this living world.",
            theme: .fantasy,
            totalDistanceMeters: 5000, // 5km adventure
            experiencePoints: 0,
            level: 1
        )
        
        let encounters = [
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
            ),
            Encounter(
                name: "Hidden Treasure Chest",
                description: "You spot a glint of gold beneath a pile of autumn leaves.",
                type: .discovery,
                triggerDistance: 4000,
                rewards: [
                    Reward(
                        id: UUID(),
                        name: "Golden Acorn",
                        description: "A magical acorn that seems to pulse with energy.",
                        icon: "🌰",
                        type: .cosmetic,
                        unlockedAt: Date()
                    )
                ]
            )
        ]
        
        startAdventure(adventure, withEncounters: encounters)
        return adventure
    }
    
    /// Generates an AI-powered encounter
    func generateAIEncounter(prompt: String, atDistance distance: Double) async throws -> Encounter {
        // This would call an AI service in production
        // For now, return a sample encounter
        return Encounter(
            name: "AI-Generated Mystery",
            description: "An encounter created just for you based on your journey.",
            type: .mystery,
            triggerDistance: distance,
            aiPrompt: prompt
        )
    }
}