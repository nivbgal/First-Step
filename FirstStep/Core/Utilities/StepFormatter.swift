import Foundation

/// Formatting helpers for step counts and distances.
enum StepFormatter {
    private static let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }()

    private static let distanceFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 1
        return f
    }()

    /// Formats a step count with comma grouping (e.g., "12,345").
    static func formattedSteps(_ steps: Int) -> String {
        numberFormatter.string(from: NSNumber(value: steps)) ?? "\(steps)"
    }

    /// Formats meters as a human-readable distance string.
    static func formattedDistance(meters: Double) -> String {
        if meters >= 1000 {
            let km = meters / 1000
            return "\(distanceFormatter.string(from: NSNumber(value: km)) ?? String(format: "%.1f", km)) km"
        }
        return "\(Int(meters)) m"
    }

    /// Formats a percentage (0–100) as a display string.
    static func formattedPercent(_ percent: Double) -> String {
        return "\(Int(percent))%"
    }
}
