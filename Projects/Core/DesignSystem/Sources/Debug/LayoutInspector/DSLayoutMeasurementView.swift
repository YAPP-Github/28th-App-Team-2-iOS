#if DEBUG
import SwiftUI

struct DSLayoutMeasurementView: View {
    let measurement: DSLayoutMeasurement

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: measurement.start)
                path.addLine(to: measurement.end)
                addTick(to: &path, at: measurement.start)
                addTick(to: &path, at: measurement.end)
            }
            .stroke(Color.red, style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))

            Text(distanceText)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(.red, in: RoundedRectangle(cornerRadius: 4))
                .position(labelPosition)
        }
    }

    private var labelPosition: CGPoint {
        let midpoint = CGPoint(
            x: (measurement.start.x + measurement.end.x) / 2,
            y: (measurement.start.y + measurement.end.y) / 2
        )

        return switch measurement.axis {
        case .horizontal:
            CGPoint(x: midpoint.x, y: midpoint.y - 12)
        case .vertical:
            CGPoint(x: midpoint.x + 22, y: midpoint.y)
        }
    }

    private var distanceText: String {
        if abs(measurement.distance.rounded() - measurement.distance) < 0.05 {
            return "\(Int(measurement.distance.rounded()))pt"
        }
        return String(format: "%.1fpt", measurement.distance)
    }

    private func addTick(to path: inout Path, at point: CGPoint) {
        switch measurement.axis {
        case .horizontal:
            path.move(to: CGPoint(x: point.x, y: point.y - 4))
            path.addLine(to: CGPoint(x: point.x, y: point.y + 4))
        case .vertical:
            path.move(to: CGPoint(x: point.x - 4, y: point.y))
            path.addLine(to: CGPoint(x: point.x + 4, y: point.y))
        }
    }
}
#endif
