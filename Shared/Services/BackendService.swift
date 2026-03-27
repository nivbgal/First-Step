import Foundation

/// Abstraction for the backend persistence layer.
/// The v1 implementation will target Firebase (Firestore + Auth).
/// No Firebase SDK dependency is introduced yet — this defines the contract only.
protocol BackendService {
    // MARK: - Auth

    /// Signs in anonymously or with the current device identity.
    func signInAnonymously() async throws -> String // returns user ID

    // MARK: - Journey CRUD

    func saveJourney(_ journey: Journey) async throws
    func fetchActiveJourney(forUser userID: String) async throws -> Journey?
    func updateProgress(_ progress: JourneyProgress) async throws
    func fetchProgress(forJourney journeyID: UUID) async throws -> JourneyProgress?
}

// MARK: - Stub

struct StubBackendService: BackendService {
    func signInAnonymously() async throws -> String {
        return UUID().uuidString
    }

    func saveJourney(_ journey: Journey) async throws {
        // No-op stub
    }

    func fetchActiveJourney(forUser userID: String) async throws -> Journey? {
        return nil
    }

    func updateProgress(_ progress: JourneyProgress) async throws {
        // No-op stub
    }

    func fetchProgress(forJourney journeyID: UUID) async throws -> JourneyProgress? {
        return nil
    }
}
