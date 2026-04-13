import SwiftUI

/// Home section that owns the live route preview and journey summary.
struct JourneySectionView: View {
    let activeJourney: Journey?
    let progress: JourneyProgress?
    let formattedDistance: String
    let formattedPercent: String

    var body: some View {
        Group {
            if let journey = activeJourney {
                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                    sectionHeader(for: journey)

                    LiveMapView(
                        journeyName: journey.name,
                        destinationType: journey.destinationType,
                        percentComplete: progress?.percentComplete ?? 0
                    )
                    .frame(height: 210)

                    JourneyCardView(
                        journeyName: journey.name,
                        formattedDistance: formattedDistance,
                        formattedPercent: formattedPercent,
                        percentComplete: progress?.percentComplete ?? 0,
                        destinationType: journey.destinationType
                    )
                }
            } else {
                noJourneyPlaceholder
            }
        }
    }

    private func sectionHeader(for journey: Journey) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Live Map")
                    .font(.headline)
                Text(journey.destinationType == .fantasy ? "Fantasy trail preview" : "Real-world route preview")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: journey.destinationType == .fantasy ? "sparkles" : "map.fill")
                .foregroundStyle(journey.destinationType == .fantasy ? AnyShapeStyle(Color.purple) : AnyShapeStyle(AppTheme.primaryGradient))
                .font(.title3)
        }
    }

    private var noJourneyPlaceholder: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Image(systemName: "map")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No active journey")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Pick a destination to unlock the live route preview. Until then, sample journeys can still drive the dashboard.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.spacingLG)
        .frame(maxWidth: .infinity)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusLG)
        .shadow(color: .black.opacity(0.04), radius: AppTheme.cardShadowRadius, y: AppTheme.cardShadowY)
    }
}
