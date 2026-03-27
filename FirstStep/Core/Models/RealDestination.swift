import Foundation

/// A real-world destination the user can walk toward.
struct RealDestination: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let coordinate: Coordinate
    let distanceMeters: Double

    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double, distanceMeters: Double) {
        self.id = id
        self.name = name
        self.coordinate = Coordinate(latitude: latitude, longitude: longitude)
        self.distanceMeters = distanceMeters
    }
}

/// Codable-friendly coordinate (CLLocationCoordinate2D is not Codable).
struct Coordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
}
