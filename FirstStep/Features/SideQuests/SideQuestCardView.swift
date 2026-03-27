import SwiftUI

/// Compact card for a single side-quest challenge.
struct SideQuestCardView: View {
    let quest: SideQuest
    let currentSteps: Int

    private var progress: Double {
        guard quest.targetSteps > 0 else { return 0 }
        return min(Double(currentSteps) / Double(quest.targetSteps), 1.0)
    }

    private var isComplete: Bool {
        currentSteps >= quest.targetSteps
    }

    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            ZStack {
                Circle()
                    .fill(isComplete ? AppTheme.successGreen.opacity(0.15) : AppTheme.accent.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: isComplete ? "checkmark" : quest.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isComplete ? AppTheme.successGreen : AppTheme.accent)
            }

            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                Text(quest.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(quest.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if !isComplete {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(AppTheme.spacingMD)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusMD)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}
