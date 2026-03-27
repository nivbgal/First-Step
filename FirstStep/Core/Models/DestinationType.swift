import Foundation

/// Distinguishes between real-world and fantasy journey destinations.
enum DestinationType: String, Codable, CaseIterable {
    case real
    case fantasy
}
