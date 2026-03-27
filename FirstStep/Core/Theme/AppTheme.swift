import SwiftUI

/// Lightweight design system for First Step.
enum AppTheme {
    // MARK: - Colors

    static let primaryGradientStart = Color(red: 0.26, green: 0.63, blue: 0.96)  // Sky blue
    static let primaryGradientEnd = Color(red: 0.18, green: 0.42, blue: 0.91)    // Deep blue
    static let accent = Color(red: 0.98, green: 0.55, blue: 0.24)                // Warm orange
    static let successGreen = Color(red: 0.18, green: 0.80, blue: 0.44)
    static let cardBackground = Color(.systemBackground)
    static let subtleBackground = Color(.secondarySystemBackground)

    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryGradientStart, primaryGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Corner Radius

    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusMD: CGFloat = 12
    static let cornerRadiusLG: CGFloat = 16

    // MARK: - Shadows

    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat = 4
}
