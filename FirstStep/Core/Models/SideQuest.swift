import Foundation

/// An in-app challenge mechanic. Side quests are mini-goals that add variety
/// to the daily walking experience without requiring Apple Watch workout control.
enum SideQuestAvailability: String, Codable, Equatable {
    case planned
    case active
}

struct SideQuest: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let rule: SideQuestRule
    let iconName: String
    let availability: SideQuestAvailability

    init(
        id: UUID = UUID(),
        title: String,
        description: String
        rule: SideQuestRule,
        iconName: String = "figure.walk",
        availability: SideQuestAvailability = .planned
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.rule = rule
        self.iconName = iconName
        self.availability = availability
    }
}
