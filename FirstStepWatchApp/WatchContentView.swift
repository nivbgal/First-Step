import SwiftUI

/// watchOS companion view showing steps and journey progress.
struct WatchContentView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @StateObject private var viewModel: StepsViewModel

    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        _viewModel = StateObject(wrappedValue: StepsViewModel(healthKitManager: healthKitManager))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("First Step")
                    .font(.headline)

                Text(viewModel.formattedSteps)
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text("steps today")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.formattedPercent)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("complete")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(viewModel.formattedDistance)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("walked")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Button("Load Steps") {
                    Task {
                        await viewModel.connectAndLoadSteps()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
    }
}
