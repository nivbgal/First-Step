import SwiftUI

/// Prominent card displaying today's step count with a circular progress ring.
struct StepCardView: View {
    let steps: Int
    let formattedSteps: String
    let goalSteps: Int
    let isLoading: Bool

    private var progress: Double {
        guard goalSteps > 0 else { return 0 }
        return min(Double(steps) / Double(goalSteps), 1.0)
    }

    var body: some View {
        VStack(spacing: AppTheme.spacingMD) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AppTheme.primaryGradient,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: progress)

                VStack(spacing: AppTheme.spacingXS) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                    } else {
                        Text(formattedSteps)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .minimumScaleFactor(0.6)
                        Text("steps today")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 180, height: 180)

            if goalSteps > 0 {
                Text("Goal: \(StepFormatter.formattedSteps(goalSteps))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(AppTheme.spacingLG)
        .frame(maxWidth: .infinity)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusLG)
        .shadow(color: .black.opacity(0.06), radius: AppTheme.cardShadowRadius, y: AppTheme.cardShadowY)
    }
}
