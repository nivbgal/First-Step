import Foundation

enum SideQuestEvaluationState: String, Codable, Equatable {
    case planned
    case inProgress
    case completed
}

struct SideQuestEvaluation: Codable, Equatable {
    let state: SideQuestEvaluationState
    let progressFraction: Double?
    let statusText: String

    static func planned(_ statusText: String = "Coming soon") -> SideQuestEvaluation {
        SideQuestEvaluation(state: .planned, progressFraction: nil, statusText: statusText)
    }

    static func inProgress(progressFraction: Double, statusText: String) -> SideQuestEvaluation {
        SideQuestEvaluation(
            state: .inProgress,
            progressFraction: min(max(progressFraction, 0), 1),
            statusText: statusText
        )
    }

    static func completed(_ statusText: String = "Done") -> SideQuestEvaluation {
        SideQuestEvaluation(state: .completed, progressFraction: 1, statusText: statusText)
    }
}

/// Snapshot of activity inputs the future side-quest engine will evaluate.
struct SideQuestActivitySnapshot: Equatable {
    let totalStepsToday: Int
    let hourlySteps: [Int: Int]
    let now: Date
}
