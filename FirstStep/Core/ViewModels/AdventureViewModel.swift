import Foundation

/// ViewModel that coordinates HealthKit step data with adventure game mechanics.
/// This is the new core ViewModel that replaces StepsViewModel for the game-like experience.
@MainActor
final class AdventureViewModel: ObservableObject {
    @Published var todaySteps: Int = 0
    @Published var formattedSteps: String = "0"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Adventure state
    @Published var activeAdventure: Adventure?
    @Published var currentEncounter: Encounter?
    @Published var isInEncounter: Bool = false
    @Published var adventureProgress: Double = 0
    @Published var adventureDistance: String = "0 m"
    @Published var adventurePercent: String = "0%"
    @Published var playerLevel: Int = 1
    @Published var playerXP: Int = 0
    @Published var nextLevelXP: Int = 100
    @Published var unlockedRewards: [Reward] = []
    
    // Challenge state (if in an encounter with a challenge)
    @Published var currentChallenge: Challenge?
    @Published var challengeProgress: Double = 0
    @Published var challengeTimeRemaining: String?
    @Published var isChallengeActive: Bool = false
    
    private let healthKitManager: HealthKitManager
    private let adventureEngine: AdventureEngine
    
    init(healthKitManager: HealthKitManager, adventureEngine: AdventureEngine = AdventureEngine()) {
        self.healthKitManager = healthKitManager
        self.adventureEngine = adventureEngine
        
        // Set up observation of adventure engine
        setupObservers()
        
        // Load a sample adventure for demo
        loadSampleAdventure()
    }
    
    private func setupObservers() {
        // Observe adventure engine changes
        Task { @MainActor in
            for await adventure in adventureEngine.$activeAdventure.values {
                activeAdventure = adventure
                updateAdventureUI()
            }
        }
        
        Task { @MainActor in
            for await encounter in adventureEngine.$currentEncounter.values {
                currentEncounter = encounter
                isInEncounter = encounter != nil
                if let challenge = encounter?.challenge {
                    currentChallenge = challenge
                    isChallengeActive = true
                    startChallengeTimer()
                } else {
                    currentChallenge = nil
                    isChallengeActive = false
                }
            }
        }
        
        Task { @MainActor in
            for await progress in adventureEngine.$adventureProgress.values {
                adventureProgress = progress
                updateAdventureUI()
            }
        }
    }
    
    /// Loads any restorable HealthKit state and existing step data on appear.
    func loadOnAppear() async {
        isLoading = true
        errorMessage = nil

        await healthKitManager.refreshAuthorizationState()

        if healthKitManager.isAuthorized {
            await healthKitManager.fetchTodaySteps()
            todaySteps = healthKitManager.todaySteps
            formattedSteps = StepFormatter.formattedSteps(todaySteps)
            
            // Convert steps to distance (approx 0.76 meters per step)
            let distanceMeters = Double(todaySteps) * 0.76
            adventureEngine.updateProgress(distanceMeters: distanceMeters)
        }

        if let error = healthKitManager.errorMessage {
            errorMessage = error
        }

        isLoading = false
    }
    
    /// Requests HealthKit permission and loads today's steps.
    func connectAndLoadSteps() async {
        isLoading = true
        errorMessage = nil

        await healthKitManager.requestAuthorization()

        if let error = healthKitManager.errorMessage {
            errorMessage = error
            isLoading = false
            return
        }

        await healthKitManager.fetchTodaySteps()
        todaySteps = healthKitManager.todaySteps
        formattedSteps = StepFormatter.formattedSteps(todaySteps)
        
        // Convert steps to distance
        let distanceMeters = Double(todaySteps) * 0.76
        adventureEngine.updateProgress(distanceMeters: distanceMeters)

        if let error = healthKitManager.errorMessage {
            errorMessage = error
        }

        isLoading = false
    }
    
    /// Starts a new adventure
    func startAdventure(_ adventure: Adventure, withEncounters encounters: [Encounter] = []) {
        adventureEngine.startAdventure(adventure, withEncounters: encounters)
    }
    
    /// Loads a sample adventure for demonstration
    func loadSampleAdventure() {
        let adventure = adventureEngine.createSampleAdventure()
        activeAdventure = adventure
        updateAdventureUI()
    }
    
    /// Completes the current encounter
    func completeCurrentEncounter(success: Bool = true) {
        adventureEngine.completeCurrentEncounter(success: success)
    }
    
    /// Starts the current challenge
    func startCurrentChallenge() {
        adventureEngine.startCurrentChallenge()
    }
    
    /// Updates challenge progress (e.g., when exercise is detected)
    func updateChallengeProgress(count: Int) {
        adventureEngine.updateChallengeProgress(count: count)
        if let challenge = currentChallenge {
            challengeProgress = Double(challenge.currentCount) / Double(challenge.targetCount)
            
            if let timeRemaining = challenge.timeRemaining {
                let minutes = Int(timeRemaining) / 60
                let seconds = Int(timeRemaining) % 60
                challengeTimeRemaining = String(format: "%d:%02d", minutes, seconds)
            }
        }
    }
    
    /// Skips the current encounter
    func skipCurrentEncounter() {
        adventureEngine.skipCurrentEncounter()
    }
    
    /// Refreshes step data and updates adventure progress
    func refreshSteps() async {
        await healthKitManager.fetchTodaySteps()
        todaySteps = healthKitManager.todaySteps
        formattedSteps = StepFormatter.formattedSteps(todaySteps)
        
        // Convert steps to distance
        let distanceMeters = Double(todaySteps) * 0.76
        adventureEngine.updateProgress(distanceMeters: distanceMeters)
    }
    
    private func updateAdventureUI() {
        guard let adventure = activeAdventure else {
            adventureDistance = "0 m"
            adventurePercent = "0%"
            playerLevel = 1
            playerXP = 0
            nextLevelXP = 100
            unlockedRewards = []
            return
        }
        
        adventureDistance = StepFormatter.formattedDistance(meters: adventure.currentDistanceMeters)
        adventurePercent = StepFormatter.formattedPercent(adventure.percentComplete)
        playerLevel = adventure.level
        playerXP = adventure.experiencePoints
        nextLevelXP = adventure.nextLevelXP
        unlockedRewards = adventure.unlockedRewards
    }
    
    private func startChallengeTimer() {
        // Start a timer to update challenge time remaining
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let challenge = self.currentChallenge else { return }
                
                if let timeRemaining = challenge.timeRemaining {
                    let minutes = Int(timeRemaining) / 60
                    let seconds = Int(timeRemaining) % 60
                    self.challengeTimeRemaining = String(format: "%d:%02d", minutes, seconds)
                    
                    if challenge.isTimeExpired {
                        self.completeCurrentEncounter(success: false)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// Need to import Combine for the timer
import Combine