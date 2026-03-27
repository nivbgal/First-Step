import Foundation
import HealthKit

/// Manages HealthKit authorization and step-count queries.
///
/// Reads today's cumulative step count — this includes steps recorded
/// by Apple Watch and any other sources synced into HealthKit.
@MainActor
final class HealthKitManager: ObservableObject {
    @Published var todaySteps: Int = 0
    @Published var isAuthorized: Bool = false
    @Published var errorMessage: String?

    private let healthStore = HKHealthStore()
    private let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

    /// Whether HealthKit is available on this device.
    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    /// Requests read authorization for step count data.
    func requestAuthorization() async {
        guard isAvailable else {
            errorMessage = "HealthKit is not available on this device."
            return
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: [stepCountType])
            isAuthorized = true
            errorMessage = nil
        } catch {
            errorMessage = "HealthKit authorization failed: \(error.localizedDescription)"
            isAuthorized = false
        }
    }

    /// Reads today's cumulative step count.
    func fetchTodaySteps() async {
        guard isAvailable else { return }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        do {
            let statistics = try await withCheckedThrowingContinuation {
                (continuation: CheckedContinuation<HKStatistics, Error>) in
                let query = HKStatisticsQuery(
                    quantityType: stepCountType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, statistics, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let statistics = statistics {
                        continuation.resume(returning: statistics)
                    } else {
                        // No data yet today — return empty statistics
                        continuation.resume(
                            returning: HKStatistics(
                                quantityType: self.stepCountType,
                                quantitySamplePredicate: predicate,
                                options: .cumulativeSum
                            )
                        )
                    }
                }
                healthStore.execute(query)
            }

            let count = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
            todaySteps = Int(count)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to fetch steps: \(error.localizedDescription)"
        }
    }
}
