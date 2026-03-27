import SwiftUI

/// Main iOS view showing today's steps, a connect button, and journey progress.
struct ContentView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @StateObject private var viewModel: StepsViewModel

    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        _viewModel = StateObject(wrappedValue: StepsViewModel(healthKitManager: healthKitManager))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("First Step")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(spacing: 8) {
                    Text("Today's Steps")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(viewModel.formattedSteps)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                }

                Button(action: {
                    Task {
                        await viewModel.connectAndLoadSteps()
                    }
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text(viewModel.todaySteps > 0 ? "Refresh Steps" : "Connect HealthKit")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)

                VStack(spacing: 8) {
                    Text("Journey Progress")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 24) {
                        VStack {
                            Text(viewModel.formattedDistance)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Distance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        VStack {
                            Text(viewModel.formattedPercent)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Complete")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Text("Select a destination to begin your journey")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Spacer()

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}
