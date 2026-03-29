import SwiftUI

struct EncounterView: View {
    let encounter: Encounter
    @ObservedObject var viewModel: AdventureViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.spacingLG) {
                    encounterHeader
                    encounterDescription
                    
                    if let challenge = encounter.challenge {
                        challengeSection(challenge)
                    }
                    
                    rewardsSection
                    
                    if encounter.isRequired {
                        requiredNotice
                    }
                    
                    actionButtons
                }
                .padding(AppTheme.spacingLG)
            }
            .navigationTitle("Encounter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var encounterHeader: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Text(encounter.type.icon)
                .font(.system(size: 64))
            
            Text(encounter.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(encounter.type.rawValue)
                .font(.caption)
                .padding(.horizontal, AppTheme.spacingMD)
                .padding(.vertical, AppTheme.spacingXS)
                .background(Color(encounter.type.color).opacity(0.2))
                .foregroundColor(Color(encounter.type.color))
                .cornerRadius(AppTheme.cornerRadiusSM)
        }
    }
    
    private var encounterDescription: some View {
        Text(encounter.description)
            .font(.body)
            .multilineTextAlignment(.center)
            .padding()
            .background(AppTheme.subtleBackground)
            .cornerRadius(AppTheme.cornerRadiusMD)
    }
    
    private func challengeSection(_ challenge: Challenge) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack {
                Text("Challenge")
                    .font(.headline)
                Spacer()
                Text(challenge.difficulty.rawValue)
                    .font(.caption)
                    .padding(.horizontal, AppTheme.spacingSM)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(AppTheme.cornerRadiusSM)
            }
            
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                Text(challenge.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(challenge.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("Instructions")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(challenge.instructions)
                    .font(.caption)
                
                HStack {
                    Image(systemName: "target")
                    Text("Goal: \(challenge.targetCount) \(challenge.type.unit)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if let timeLimit = challenge.timeLimitSeconds {
                    HStack {
                        Image(systemName: "clock")
                        Text("Time limit: \(timeLimit) seconds")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadiusMD)
        }
    }
    
    private var rewardsSection: some View {
        Group {
            if !encounter.rewards.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                    Text("Rewards")
                        .font(.headline)
                    
                    ForEach(encounter.rewards) { reward in
                        HStack(spacing: AppTheme.spacingMD) {
                            Text(reward.icon)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(reward.name)
                                    .font(.subheadline)
                                Text(reward.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(reward.type.rawValue)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                        .padding(.vertical, AppTheme.spacingXS)
                    }
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadiusMD)
            }
        }
    }
    
    private var requiredNotice: some View {
        HStack(spacing: AppTheme.spacingSM) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            Text("This encounter is required to continue your adventure.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(AppTheme.cornerRadiusMD)
    }
    
    private var actionButtons: some View {
        VStack(spacing: AppTheme.spacingMD) {
            if encounter.challenge != nil {
                Button(action: {
                    viewModel.startCurrentChallenge()
                    dismiss()
                }) {
                    Text("Start Challenge")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primaryGradient)
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.cornerRadiusMD)
                }
                
                if !encounter.isRequired {
                    Button("Skip Encounter") {
                        viewModel.skipCurrentEncounter()
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            } else {
                // Encounter without a challenge (just discovery/story)
                Button(action: {
                    viewModel.completeCurrentEncounter(success: true)
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primaryGradient)
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.cornerRadiusMD)
                }
            }
        }
    }
}

struct EncounterView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEncounter = Encounter(
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
                successMessage: "The gate creaks open!",
                failureMessage: "The gate remains closed."
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
        )
        
        EncounterView(
            encounter: sampleEncounter,
            viewModel: AdventureViewModel(healthKitManager: HealthKitManager())
        )
    }
}