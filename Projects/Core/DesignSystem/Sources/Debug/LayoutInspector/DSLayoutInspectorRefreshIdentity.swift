#if DEBUG
import SwiftUI

enum DSLayoutInspectorRefreshIdentity {
    static func reportedRegions(
        _ regions: [DSLayoutRegion],
        displayScale: CGFloat
    ) -> String {
        regions.map { region in
            let frame = [region.frame.minX, region.frame.minY, region.frame.width, region.frame.height]
                .map { quantized($0, displayScale: displayScale) }
                .joined(separator: ":")
            return "\(region.regionID):\(frame)"
        }
        .sorted()
        .joined(separator: "|")
    }

    static func make(
        reportedRegionIdentity: String,
        layoutSize: CGSize,
        safeAreaInsets: EdgeInsets,
        displayScale: CGFloat
    ) -> String {
        let layoutValues = [
            layoutSize.width, layoutSize.height,
            safeAreaInsets.top, safeAreaInsets.leading,
            safeAreaInsets.bottom, safeAreaInsets.trailing
        ]
        let layout = layoutValues
            .map { quantized($0, displayScale: displayScale) }
            .joined(separator: ":")
        return "\(reportedRegionIdentity)|\(layout)"
    }

    private static func quantized(_ value: CGFloat, displayScale: CGFloat) -> String {
        String(Int((value * displayScale).rounded()))
    }
}

enum DSLayoutInspectorControl {
    static func button(
        title: String,
        systemImage: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 34, height: 34)
                .foregroundStyle(isActive ? .black : .white)
                .background(
                    isActive ? Color.yellow : Color.black.opacity(0.82),
                    in: RoundedRectangle(cornerRadius: 9)
                )
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(title)
        .accessibilityIdentifier(
            "\(DSLayoutInspectorConstants.accessibilityPrefix).\(title)"
        )
    }

    static func outlineColor(for source: DSLayoutRegionSource) -> Color {
        switch source {
        case .view: .orange
        case .accessibility: .cyan
        case .designSystem: .purple
        case .designSystemDetail: .mint
        }
    }
}
#endif
