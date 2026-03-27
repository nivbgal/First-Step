import Foundation
import CoreGraphics

/// Fetches street-level imagery for a given coordinate.
/// Future implementation will integrate with Google Street View Static API.
protocol StreetViewService {
    /// Returns image data for the street-level view at the given coordinate.
    func fetchImage(at coordinate: Coordinate, size: CGSize) async throws -> Data
}

// MARK: - Stub

struct StubStreetViewService: StreetViewService {
    func fetchImage(at coordinate: Coordinate, size: CGSize) async throws -> Data {
        return Data()
    }
}
