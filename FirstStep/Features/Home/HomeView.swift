import SwiftUI

/// Primary dashboard screen showing steps, journey progress, and side quests.
struct HomeView: View {
    @StateObject private var viewModel: StepsViewModel
    @State private var showHealthKitError = false

    init(healthKitManager: HealthKitManager) {
        _viewModel = StateObject(wrappedValue: StepsViewModel(healthKitManager: healthKitManager))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.spacingLG) {
                    headerSection
                    stepCardSection
                    healthKitButton
                    journeySection
                    sideQuestSection
                }
                .padding(.horizontal, AppTheme.spacingMD)
                .padding(.bottom, AppTheme.spacingXL)
            }
            .background(AppTheme.subtleBackground.ignoresSafeArea())
            .navigationBarHidden(true)
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
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                Text("First Step")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(dateString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "figure.walk.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(AppTheme.primaryGradient)
        }
        .padding(.top, AppTheme.spacingMD)
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

    private var journeySection: some View {
        Group {
            if let journey = viewModel.activeJourney {
                JourneyCardView(
                    journeyName: journey.name,
                    formattedDistance: viewModel.formattedDistance,
                    formattedPercent: viewModel.formattedPercent,
                    percentComplete: viewModel.progress?.percentComplete ?? 0,
                    destinationType: journey.destinationType
                )
            } else {
                noJourneyPlaceholder
            }
        }
    }

    private var noJourneyPlaceholder: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Image(systemName: "map")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No active journey")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("A destination picker is coming in the next milestone. For now, a sample journey is loaded automatically.")
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

    private var sideQuestSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack {
                Text("Side Quests")
                    .font(.headline)
                Image(systemName: "sparkle")
                    .foregroundColor(AppTheme.accent)
            }

            ForEach(viewModel.sideQuests) { quest in
                SideQuestCardView(
                    quest: quest,
                    evaluation: viewModel.sideQuestEvaluation(for: quest)
                )
            }
        }
    }

    // MARK: - Helpers

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
}
