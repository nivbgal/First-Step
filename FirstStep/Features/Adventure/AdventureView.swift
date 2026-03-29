import SwiftUI

/// Primary game screen showing adventure progress, encounters, and challenges.
struct AdventureView: View {
    @StateObject private var viewModel: AdventureViewModel
    @State private var showHealthKitError = false
    @State private var showEncounterSheet = false
    @State private var showChallengeSheet = false
    @State private var showRewardsSheet = false
    
    init(healthKitManager: HealthKitManager) {
        _viewModel = StateObject(wrappedValue: AdventureViewModel(healthKitManager: healthKitManager))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.spacingLG) {
                    headerSection
                    playerStatsSection
                    stepCardSection
                    healthKitButton
                    adventureProgressSection
                    encounterSection
                    rewardsSection
                }
                .padding(.horizontal, AppTheme.spacingMD)
                .padding(.bottom, AppTheme.spacingXL)
            }
            .background(AppTheme.subtleBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showEncounterSheet) {
                if let encounter = viewModel.currentEncounter {
                    EncounterView(encounter: encounter, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showChallengeSheet) {
                if let challenge = viewModel.currentChallenge {
                    ChallengeView(challenge: challenge, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showRewardsSheet) {
                RewardsView(rewards: viewModel.unlockedRewards)
            }
        }
        .navigationViewStyle(.stack)
        .task {
            await viewModel.loadOnAppear()
        }
        .alert("HealthKit Error", isPresented: $showHealthKitError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
        .onChange(of: viewModel.isInEncounter) { isInEncounter in
            if isInEncounter {
                showEncounterSheet = true
            }
        }
        .onChange(of: viewModel.isChallengeActive) { isChallengeActive in
            if isChallengeActive {
                showChallengeSheet = true
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                Text("First Step")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Adventure Awaits")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: { showRewardsSheet = true }) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(AppTheme.primaryGradient)
            }
        }
        .padding(.top, AppTheme.spacingMD)
    }
    
    private var playerStatsSection: some View {
        HStack(spacing: AppTheme.spacingLG) {
            StatCard(
                title: "Level",
                value: "\(viewModel.playerLevel)",
                icon: "star.fill",
                color: .yellow
            )
            
            StatCard(
                title: "XP",
                value: "\(viewModel.playerXP)/\(viewModel.nextLevelXP)",
                icon: "bolt.fill",
                color: .blue
            )
            
            StatCard(
                title: "Rewards",
                value: "\(viewModel.unlockedRewards.count)",
                icon: "gift.fill",
                color: .purple
            )
        }
    }
    
    private var stepCardSection: some View {
        StepCardView(
            steps: viewModel.todaySteps,
            formattedSteps: viewModel.formattedSteps,
            goalSteps: 10_000,
            isLoading: viewModel.isLoading
        )
    }
    
    private var healthKitButton: some View {
        Button(action: {
            Task {
                await viewModel.connectAndLoadSteps()
                if viewModel.errorMessage != nil {
                    showHealthKitError = true
                }
            }
        }) {
            HStack(spacing: AppTheme.spacingSM) {
                Image(systemName: viewModel.isAuthorized ? "arrow.clockwise" : "heart.fill")
                Text(viewModel.isAuthorized ? "Refresh Steps" : "Connect Health")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.primaryGradient)
            .foregroundColor(.white)
            .cornerRadius(AppTheme.cornerRadiusMD)
        }
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.6 : 1)
    }
    
    private var adventureProgressSection: some View {
        Group {
            if let adventure = viewModel.activeAdventure {
                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                    HStack {
                        Text(adventure.name)
                            .font(.headline)
                        Spacer()
                        Text(adventure.theme.icon)
                            .font(.title2)
                    }
                    
                    Text(adventure.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    ProgressView(value: viewModel.adventureProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(adventure.theme.color)))
                    
                    HStack {
                        Text(viewModel.adventureDistance)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(viewModel.adventurePercent)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(AppTheme.spacingMD)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadiusLG)
                .shadow(color: .black.opacity(0.04), radius: AppTheme.cardShadowRadius, y: AppTheme.cardShadowY)
            } else {
                noAdventurePlaceholder
            }
        }
    }
    
    private var noAdventurePlaceholder: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Image(systemName: "map")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No active adventure")
                .font(.headline)
                .foregroundColor(.secondary)
            Button("Start Sample Adventure") {
                viewModel.loadSampleAdventure()
            }
            .buttonStyle(.borderedProminent)
            Text("A full adventure selector is coming in the next update.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.spacingLG)
        .frame(maxWidth: .infinity)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusLG)
        .shadow(color: .black.opacity(0.04), radius: AppTheme.cardShadowRadius, y: AppTheme.cardShadowY)
    }
    
    private var encounterSection: some View {
        Group {
            if viewModel.isInEncounter {
                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Encounter!")
                            .font(.headline)
                        Spacer()
                        Button("View") {
                            showEncounterSheet = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if let encounter = viewModel.currentEncounter {
                        Text(encounter.name)
                            .font(.subheadline)
                        Text(encounter.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(AppTheme.spacingMD)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadiusLG)
                .shadow(color: .black.opacity(0.04), radius: AppTheme.cardShadowRadius, y: AppTheme.cardShadowY)
            }
        }
    }
    
    private var rewardsSection: some View {
        Group {
            if !viewModel.unlockedRewards.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                    HStack {
                        Text("Recent Rewards")
                            .font(.headline)
                        Spacer()
                        Button("See All") {
                            showRewardsSheet = true
                        }
                        .font(.caption)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.spacingMD) {
                            ForEach(viewModel.unlockedRewards.prefix(3)) { reward in
                                RewardCard(reward: reward)
                            }
                        }
                    }
                }
                .padding(AppTheme.spacingMD)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadiusLG)
                .shadow(color: .black.opacity(0.04), radius: AppTheme.cardShadowRadius, y: AppTheme.cardShadowY)
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.spacingXS) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.spacingMD)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusMD)
    }
}

struct RewardCard: View {
    let reward: Reward
    
    var body: some View {
        VStack(spacing: AppTheme.spacingXS) {
            Text(reward.icon)
                .font(.title)
            Text(reward.name)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .padding(AppTheme.spacingSM)
        .background(AppTheme.subtleBackground)
        .cornerRadius(AppTheme.cornerRadiusMD)
    }
}

// MARK: - Preview

struct AdventureView_Previews: PreviewProvider {
    static var previews: some View {
        AdventureView(healthKitManager: HealthKitManager())
    }
}