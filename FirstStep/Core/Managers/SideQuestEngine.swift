import Foundation

/// Evaluates side-quest progress from activity snapshots.
struct SideQuestEngine {
    static func evaluate(
        quest: SideQuest,
        activity: SideQuestActivitySnapshot
    ) -> SideQuestEvaluation {
        guard quest.availability == .active else {
            return .planned("Planned for a later milestone")
        }

        switch quest.rule.kind {
        case .stepGoal:
            let target = max(quest.rule.targetSteps ?? 0, 1)
            let progress = min(Double(activity.totalStepsToday) / Double(target), 1.0)
            if progress >= 1 {
                return .completed()
            }
            return .inProgress(
                progressFraction: progress,
                statusText: "\(Int(progress * 100))%"
            )
        case .stepGoalBeforeHour, .consecutiveActiveHours:
            return .planned("Rule engine not wired yet")
        }
    }
}
