import SwiftUI

/// Compact card for a single side-quest challenge.
struct SideQuestCardView: View {
    let quest: SideQuest
    let evaluation: SideQuestEvaluation

    private var badgeColor: Color {
        switch evaluation.state {
        case .planned:
            return .secondary
        case .inProgress:
            return AppTheme.accent
        case .completed:
            return AppTheme.successGreen
        }
    }

    private var badgeBackground: Color {
        switch evaluation.state {
        case .planned:
            return Color.gray.opacity(0.12)
        case .inProgress:
            return AppTheme.accent.opacity(0.12)
        case .completed:
            return AppTheme.successGreen.opacity(0.15)
        }
    }

    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            ZStack {
                Circle()
                    .fill(badgeBackground)
                    .frame(width: 44, height: 44)

                Image(systemName: evaluation.state == .completed ? "checkmark" : quest.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(badgeColor)
            }

            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                Text(quest.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(quest.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Text(evaluation.statusText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(badgeColor)
        }
        .padding(AppTheme.spacingMD)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusMD)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}
