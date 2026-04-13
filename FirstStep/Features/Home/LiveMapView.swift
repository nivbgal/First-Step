import SwiftUI

/// Stylized route preview for the active journey.
///
/// This intentionally avoids MapKit for now and instead presents a future-friendly
/// trail surface with a progress path, markers, and subtle terrain styling.
struct LiveMapView: View {
    let journeyName: String
    let destinationType: DestinationType
    let percentComplete: Double
    @State private var isPulsing = false

    private var progressFraction: Double {
        min(max(percentComplete / 100, 0), 1)
    }

    private var accentColors: [Color] {
        destinationType == .fantasy
            ? [Color.purple.opacity(0.95), Color.pink.opacity(0.85)]
            : [AppTheme.primaryGradientStart, AppTheme.primaryGradientEnd]
    }

    private var surfaceGradient: LinearGradient {
        destinationType == .fantasy
            ? LinearGradient(
                colors: [
                    Color.purple.opacity(0.18),
                    Color.indigo.opacity(0.14),
                    Color.pink.opacity(0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            : LinearGradient(
                colors: [
                    AppTheme.primaryGradientStart.opacity(0.16),
                    AppTheme.primaryGradientEnd.opacity(0.10),
                    Color.white.opacity(0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let routePoints = routePoints(in: size)
            let routePath = routePath(for: routePoints)
            let progressPoint = point(at: progressFraction, along: routePoints)

            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG, style: .continuous)
                    .fill(surfaceGradient)

                terrainGlow(in: size)

                gridOverlay()
                    .opacity(0.2)

                routePathLayer(routePath)

                if progressFraction < 1 {
                    remainingRouteLayer(routePath, progressFraction: progressFraction)
                }

                routeMarkers(
                    startPoint: routePoints.first ?? .zero,
                    progressPoint: progressPoint,
                    endPoint: routePoints.last ?? .zero
                )

                topBadge
                    .padding(AppTheme.spacingMD)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                bottomBadge
                    .padding(AppTheme.spacingMD)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
        }
        .onAppear {
            if !isPulsing {
                isPulsing = true
            }
        }
    }

    private var topBadge: some View {
        HStack(spacing: AppTheme.spacingSM) {
            Image(systemName: destinationType == .fantasy ? "sparkles" : "location.fill")
                .font(.caption.weight(.semibold))
            Text("Live trail preview")
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, AppTheme.spacingSM)
        .padding(.vertical, 6)
        .background(Color(.systemBackground).opacity(0.82))
        .foregroundColor(destinationType == .fantasy ? .purple : AppTheme.primaryGradientEnd)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.28), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
    }

    private var bottomBadge: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(journeyName)
                .font(.caption.weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(progressLabel)
                .font(.caption2.weight(.medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, AppTheme.spacingSM)
        .padding(.vertical, 6)
        .background(Color(.systemBackground).opacity(0.80))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM, style: .continuous)
                .stroke(Color.white.opacity(0.26), lineWidth: 1)
        )
    }

    private var progressLabel: String {
        "\(Int(progressFraction * 100))% en route"
    }

    private func terrainGlow(in size: CGSize) -> some View {
        ZStack {
            Circle()
                .fill(accentColors[0].opacity(0.18))
                .frame(width: size.width * 0.42, height: size.width * 0.42)
                .blur(radius: 22)
                .offset(x: size.width * 0.22, y: -size.height * 0.18)

            Circle()
                .fill(accentColors[1].opacity(0.12))
                .frame(width: size.width * 0.30, height: size.width * 0.30)
                .blur(radius: 18)
                .offset(x: -size.width * 0.28, y: size.height * 0.16)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.16))
                .frame(width: size.width * 0.56, height: size.height * 0.18)
                .blur(radius: 14)
                .offset(x: size.width * 0.12, y: size.height * 0.22)
        }
    }

    private func gridOverlay() -> some View {
        Canvas { context, canvasSize in
            var gridPath = Path()

            let columns = 6
            let rows = 4

            for column in 1..<columns {
                let x = canvasSize.width * CGFloat(column) / CGFloat(columns)
                gridPath.move(to: CGPoint(x: x, y: 0))
                gridPath.addLine(to: CGPoint(x: x, y: canvasSize.height))
            }

            for row in 1..<rows {
                let y = canvasSize.height * CGFloat(row) / CGFloat(rows)
                gridPath.move(to: CGPoint(x: 0, y: y))
                gridPath.addLine(to: CGPoint(x: canvasSize.width, y: y))
            }

            context.stroke(
                gridPath,
                with: .color(Color.white.opacity(0.55)),
                style: StrokeStyle(lineWidth: 1, lineCap: .round)
            )
        }
    }

    private func routePathLayer(_ routePath: Path) -> some View {
        routePath.stroke(
            LinearGradient(
                colors: accentColors.map { $0.opacity(0.95) },
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
        )
        .shadow(color: accentColors[0].opacity(0.24), radius: 10, y: 5)
        .opacity(0.35)
    }

    private func remainingRouteLayer(_ routePath: Path, progressFraction: Double) -> some View {
        routePath.trimmedPath(from: CGFloat(progressFraction), to: 1)
            .stroke(
                Color.primary.opacity(0.18),
                style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round, dash: [6, 8])
            )
    }

    private func routeMarkers(startPoint: CGPoint, progressPoint: CGPoint, endPoint: CGPoint) -> some View {
        ZStack {
            marker(
                at: startPoint,
                fill: Color.white,
                stroke: accentColors[0].opacity(0.45),
                icon: "flag.checkered",
                iconColor: accentColors[0]
            )

            pulseMarker(at: progressPoint)

            marker(
                at: endPoint,
                fill: accentColors[0].opacity(0.95),
                stroke: Color.white.opacity(0.85),
                icon: destinationType == .fantasy ? "sparkles" : "mappin",
                iconColor: .white
            )
        }
    }

    private func marker(
        at point: CGPoint,
        fill: Color,
        stroke: Color,
        icon: String,
        iconColor: Color
    ) -> some View {
        ZStack {
            Circle()
                .fill(fill)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(stroke, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.10), radius: 4, y: 2)

            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(iconColor)
        }
        .position(point)
    }

    private func pulseMarker(at point: CGPoint) -> some View {
        ZStack {
            Circle()
                .fill(accentColors[0].opacity(0.18))
                .frame(width: 38, height: 38)

            Circle()
                .fill(Color.white)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(accentColors[0], lineWidth: 3)
                )

            Circle()
                .stroke(accentColors[0].opacity(0.35), lineWidth: 2)
                .frame(width: 28, height: 28)
        }
        .position(point)
        .scaleEffect(isPulsing ? 1.08 : 0.92)
        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: isPulsing)
    }

    private func routePath(for points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }

        path.move(to: first)

        guard points.count > 1 else { return path }

        for index in 1..<points.count {
            let previous = points[index - 1]
            let current = points[index]
            let midpoint = CGPoint(
                x: (previous.x + current.x) / 2,
                y: (previous.y + current.y) / 2
            )
            let verticalLift: CGFloat = destinationType == .fantasy
                ? (index.isMultiple(of: 2) ? -18 : 20)
                : (index.isMultiple(of: 2) ? 12 : -10)
            let horizontalShift: CGFloat = destinationType == .fantasy ? 16 : 10
            let control = CGPoint(
                x: midpoint.x + (index.isMultiple(of: 2) ? horizontalShift : -horizontalShift),
                y: midpoint.y + verticalLift
            )

            path.addQuadCurve(to: current, control: control)
        }

        return path
    }

    private func routePoints(in size: CGSize) -> [CGPoint] {
        let w = size.width
        let h = size.height

        switch destinationType {
        case .real:
            return [
                CGPoint(x: w * 0.12, y: h * 0.78),
                CGPoint(x: w * 0.23, y: h * 0.69),
                CGPoint(x: w * 0.37, y: h * 0.73),
                CGPoint(x: w * 0.50, y: h * 0.60),
                CGPoint(x: w * 0.66, y: h * 0.56),
                CGPoint(x: w * 0.81, y: h * 0.38),
                CGPoint(x: w * 0.90, y: h * 0.22)
            ]
        case .fantasy:
            return [
                CGPoint(x: w * 0.10, y: h * 0.80),
                CGPoint(x: w * 0.18, y: h * 0.58),
                CGPoint(x: w * 0.32, y: h * 0.66),
                CGPoint(x: w * 0.47, y: h * 0.46),
                CGPoint(x: w * 0.61, y: h * 0.57),
                CGPoint(x: w * 0.75, y: h * 0.31),
                CGPoint(x: w * 0.90, y: h * 0.18)
            ]
        }
    }

    private func point(at progress: Double, along points: [CGPoint]) -> CGPoint {
        guard let first = points.first else { return .zero }
        guard points.count > 1 else { return first }

        let clamped = min(max(progress, 0), 1)
        if clamped <= 0 { return first }
        if clamped >= 1 { return points[points.count - 1] }

        let segments = zip(points, points.dropFirst())
        let lengths = segments.map { segmentLength($0.0, $0.1) }
        let totalLength = lengths.reduce(0, +)
        guard totalLength > 0 else { return first }

        var targetLength = totalLength * clamped

        for (index, length) in lengths.enumerated() {
            if targetLength <= length {
                let start = points[index]
                let end = points[index + 1]
                let ratio = length > 0 ? targetLength / length : 0
                return CGPoint(
                    x: start.x + (end.x - start.x) * ratio,
                    y: start.y + (end.y - start.y) * ratio
                )
            }

            targetLength -= length
        }

        return points[points.count - 1]
    }

    private func segmentLength(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        return hypot(dx, dy)
    }
}
