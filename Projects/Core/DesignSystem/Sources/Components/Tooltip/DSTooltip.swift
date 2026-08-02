import SwiftUI

// MARK: - Core Tooltip Component
public struct DSTooltip: View {
    public enum ArrowPlacement: Equatable, Sendable {
        case top
        case bottom
    }

    public struct Specification: Sendable {
        public let minimumBubbleHeight: CGFloat
        public let maximumBubbleWidth: CGFloat?
        public let horizontalPadding: CGFloat
        public let verticalPadding: CGFloat
        public let lineLimit: Int?
        public let textAlignment: TextAlignment
        public let arrowFrameWidth: CGFloat
        public let arrowWidth: CGFloat
        public let arrowHeight: CGFloat
        public let arrowRotationDegrees: Double
        public let arrowPlacement: ArrowPlacement
        public let arrowBubbleSpacing: CGFloat
        public let shape: DSComponentShape
        public let fontStyle: FontStyle
        public let backgroundAsset: DesignSystemColors
        public let foregroundAsset: DesignSystemColors
        public let arrowAsset: DSIconAsset
        public let arrowTintAsset: DesignSystemColors
    }

    public static func specification(variant: DSTooltipVariant = .standard) -> Specification {
        switch variant {
        case .standard:
            Specification(
                minimumBubbleHeight: 30,
                maximumBubbleWidth: nil,
                horizontalPadding: 16,
                verticalPadding: 6,
                lineLimit: nil,
                textAlignment: .center,
                arrowFrameWidth: 8,
                arrowWidth: 6.9282,
                arrowHeight: 6,
                arrowRotationDegrees: 180,
                arrowPlacement: .bottom,
                arrowBubbleSpacing: -2,
                shape: .capsule,
                fontStyle: .body3Medium,
                backgroundAsset: DesignSystemAsset.Colors.opacity80,
                foregroundAsset: DesignSystemAsset.Colors.white,
                arrowAsset: .tooltipArrow,
                arrowTintAsset: DesignSystemAsset.Colors.opacity80
            )
        case .white:
            Specification(
                minimumBubbleHeight: 30,
                maximumBubbleWidth: 200,
                horizontalPadding: 16,
                verticalPadding: 6,
                lineLimit: nil,
                textAlignment: .center,
                arrowFrameWidth: 8,
                arrowWidth: 6.9282,
                arrowHeight: 6,
                arrowRotationDegrees: 0,
                arrowPlacement: .top,
                arrowBubbleSpacing: -2,
                shape: .roundedRectangle(cornerRadius: 12),
                fontStyle: .body3Medium,
                backgroundAsset: DesignSystemAsset.Colors.whiteOpacity90,
                foregroundAsset: DesignSystemAsset.Colors.black,
                arrowAsset: .tooltipArrow,
                arrowTintAsset: DesignSystemAsset.Colors.whiteOpacity90
            )
        }
    }

    private let message: String
    private let variant: DSTooltipVariant

    public init(_ message: String, variant: DSTooltipVariant = .standard) {
        self.message = message
        self.variant = variant
    }

    public var body: some View {
        let specification = Self.specification(variant: variant)

        VStack(spacing: specification.arrowBubbleSpacing) {
            switch specification.arrowPlacement {
            case .top:
                arrow(specification)
                bubble(specification)
            case .bottom:
                bubble(specification)
                arrow(specification)
            }
        }
        .dsDebugGeometry("DSTooltip")
    }

    private func bubble(_ specification: Specification) -> some View {
        Text(message)
            .dsFont(specification.fontStyle)
            .lineLimit(specification.lineLimit)
            .multilineTextAlignment(specification.textAlignment)
            .foregroundStyle(specification.foregroundAsset.swiftUIColor)
            .padding(.horizontal, specification.horizontalPadding)
            .padding(.vertical, specification.verticalPadding)
            .frame(minHeight: specification.minimumBubbleHeight)
            .frame(maxWidth: specification.maximumBubbleWidth)
            .background(specification.backgroundAsset.swiftUIColor)
            .clipShape(specification.shape.swiftUIShape)
            .dsDebugDetailGeometry("DSTooltip.Bubble")
    }

    private func arrow(_ specification: Specification) -> some View {
        DSIcon(
            specification.arrowAsset,
            width: specification.arrowWidth,
            height: specification.arrowHeight
        )
        .foregroundStyle(specification.arrowTintAsset.swiftUIColor)
        .rotationEffect(.degrees(specification.arrowRotationDegrees))
        .frame(
            width: specification.arrowFrameWidth,
            height: specification.arrowFrameWidth
        )
    }
}
