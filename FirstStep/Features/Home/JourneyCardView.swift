import SwiftUI

/// Card showing the active journey's progress with a bar and distance info.
struct JourneyCardView: View {
    let journeyName: String
    let formattedDistance: String
    let formattedPercent: String
    let percentComplete: Double
    let destinationType: DestinationType

    private var iconName: String {
        destinationType == .fantasy ? "sparkles" : "map.fill"
    }

    private var accentColor: Color {
        destinationType == .fantasy ? .purple : AppTheme.primaryGradientStart
    }

    private var progressFraction: Double {
        min(max(percentComplete / 100, 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(accentColor)
                    .font(.title3)
                Text("Active Journey")
                    .font(.headline)
                Spacer()
                Text(formattedPercent)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(accentColor)
            }

            Text(journeyName)
                .font(.title3)
                .fontWeight(.semibold)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [accentColor.opacity(0.8), accentColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progressFraction, height: 10)
                        .animation(.easeInOut(duration: 0.6), value: percentComplete)
                }
            }
            .frame(height: 10)

            HStack {
                Label(formattedDistance, systemImage: "figure.walk")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(destinationType == .fantasy ? "Fantasy" : "Real World")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accentColor.opacity(0.12))
                    .foregroundColor(accentColor)
                    .cornerRadius(AppTheme.cornerRadiusSM)
            }
        }
        .padding(AppTheme.spacingMD)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusLG)
        .shadow(color: .black.opacity(0.06), radius: AppTheme.cardShadowRadius, y: AppTheme.cardShadowY)
    }
}
