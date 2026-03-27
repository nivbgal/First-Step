import Foundation

/// Provides route-progress data (e.g., waypoints along a real-world route).
/// Future implementation will integrate with Apple MapKit for directions.
protocol RouteProgressService {
    /// Fetches waypoints for a route from origin to the given real destination.
    func fetchRoute(to destination: RealDestination) async throws -> [Coordinate]

    /// Returns the interpolated coordinate at a given fraction (0…1) along the route.
    func coordinateAtFraction(_ fraction: Double, along route: [Coordinate]) -> Coordinate
}

// MARK: - Stub

struct StubRouteProgressService: RouteProgressService {
    func fetchRoute(to destination: RealDestination) async throws -> [Coordinate] {
        // Placeholder: returns origin and destination only.
        return [
            Coordinate(latitude: 0, longitude: 0),
            destination.coordinate
        ]
    }

    func coordinateAtFraction(_ fraction: Double, along route: [Coordinate]) -> Coordinate {
        guard let first = route.first else {
            return Coordinate(latitude: 0, longitude: 0)
        }
        guard let last = route.last, route.count >= 2 else {
            return first
        }
        let lat = first.latitude + (last.latitude - first.latitude) * fraction
        let lon = first.longitude + (last.longitude - first.longitude) * fraction
        return Coordinate(latitude: lat, longitude: lon)
    }
}
