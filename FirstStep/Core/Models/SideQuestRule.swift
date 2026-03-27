import Foundation

/// Canonical rule definition for future side-quest evaluation.
enum SideQuestRuleKind: String, Codable, Equatable {
    case stepGoal
    case stepGoalBeforeHour
    case consecutiveActiveHours
}

struct SideQuestRule: Codable, Equatable {
    let kind: SideQuestRuleKind
    let targetSteps: Int?
    let cutoffHour: Int?
    let requiredHours: Int?
    let minimumStepsPerHour: Int?

    static func stepGoal(_ targetSteps: Int) -> SideQuestRule {
        SideQuestRule(
            kind: .stepGoal,
            targetSteps: targetSteps,
            cutoffHour: nil,
            requiredHours: nil,
            minimumStepsPerHour: nil
        )
    }

    static func stepGoalBeforeHour(_ targetSteps: Int, cutoffHour: Int) -> SideQuestRule {
        SideQuestRule(
            kind: .stepGoalBeforeHour,
            targetSteps: targetSteps,
            cutoffHour: cutoffHour,
            requiredHours: nil,
            minimumStepsPerHour: nil
        )
    }

    static func consecutiveActiveHours(_ requiredHours: Int, minimumStepsPerHour: Int) -> SideQuestRule {
        SideQuestRule(
            kind: .consecutiveActiveHours,
            targetSteps: nil,
            cutoffHour: nil,
            requiredHours: requiredHours,
            minimumStepsPerHour: minimumStepsPerHour
        )
    }

    /// Short human-readable summary for placeholder UI and debug output.
    var planningSummary: String {
        switch kind {
        case .stepGoal:
            return "Reach \(targetSteps ?? 0) total steps."
        case .stepGoalBeforeHour:
            return "Reach \(targetSteps ?? 0) steps before \(cutoffHour ?? 0):00."
        case .consecutiveActiveHours:
            return "Stay active for \(requiredHours ?? 0) consecutive hours."
        }
    }
}
