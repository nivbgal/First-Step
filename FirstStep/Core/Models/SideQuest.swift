import Foundation

/// An in-app challenge mechanic. Side quests are mini-goals that add variety
/// to the daily walking experience without requiring Apple Watch workout control.
struct SideQuest: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let targetSteps: Int
    let iconName: String
    var isComplete: Bool

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        targetSteps: Int,
        iconName: String = "figure.walk",
        isComplete: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.targetSteps = targetSteps
        self.iconName = iconName
        self.isComplete = isComplete
    }
}
