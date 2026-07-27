import SwiftUI

// MARK: - Core Tooltip Component
public struct DSTooltip: View {
    public struct Specification: Sendable {
        public let minimumBubbleHeight: CGFloat
        public let horizontalPadding: CGFloat
        public let verticalPadding: CGFloat
        public let lineLimit: Int?
        public let textAlignment: TextAlignment
        public let arrowFrameWidth: CGFloat
        public let arrowWidth: CGFloat
        public let arrowHeight: CGFloat
        public let arrowRotationDegrees: Double
        public let shape: DSComponentShape
        public let fontStyle: FontStyle
        public let backgroundAsset: DesignSystemColors
        public let foregroundAsset: DesignSystemColors
        public let arrowAsset: DSIconAsset
        public let arrowTintAsset: DesignSystemColors
    }

    public static func specification() -> Specification {
        Specification(
            minimumBubbleHeight: 30,
            horizontalPadding: 16,
            verticalPadding: 5,
            lineLimit: nil,
            textAlignment: .center,
            arrowFrameWidth: 8,
            arrowWidth: 6.9282,
            arrowHeight: 6,
            arrowRotationDegrees: 180,
            shape: .capsule,
            fontStyle: .body3Medium,
            backgroundAsset: DesignSystemAsset.Colors.opacity60,
            foregroundAsset: DesignSystemAsset.Colors.white,
            arrowAsset: .tooltipArrow,
            arrowTintAsset: DesignSystemAsset.Colors.opacity60
        )
    }

    private let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var body: some View {
        let specification = Self.specification()

        VStack(spacing: 0) {
            Text(message)
                .dsFont(specification.fontStyle)
                .lineLimit(specification.lineLimit)
                .multilineTextAlignment(specification.textAlignment)
                .foregroundStyle(specification.foregroundAsset.swiftUIColor)
                .padding(.horizontal, specification.horizontalPadding)
                .padding(.vertical, specification.verticalPadding)
                .frame(minHeight: specification.minimumBubbleHeight)
                .background(specification.backgroundAsset.swiftUIColor)
                .clipShape(specification.shape.swiftUIShape)
                .dsDebugDetailGeometry("DSTooltip.Bubble")

            DSIcon(
                specification.arrowAsset,
                width: specification.arrowWidth,
                height: specification.arrowHeight
            )
            .foregroundStyle(specification.arrowTintAsset.swiftUIColor)
            .rotationEffect(.degrees(specification.arrowRotationDegrees))
            .frame(
                width: specification.arrowFrameWidth,
                height: specification.arrowHeight
            )
        }
        .dsDebugGeometry("DSTooltip")
    }
}
