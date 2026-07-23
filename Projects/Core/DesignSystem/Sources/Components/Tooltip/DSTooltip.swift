import SwiftUI

// MARK: - Core Tooltip Component
public struct DSTooltip: View {
    public struct Specification: Sendable {
        public let bubbleHeight: CGFloat
        public let verticalPadding: CGFloat
        public let horizontalPadding: CGFloat
        public let arrowFrameWidth: CGFloat
        public let arrowWidth: CGFloat
        public let arrowHeight: CGFloat
        public let arrowRotationDegrees: Double
        public let shape: DSComponentShape
        public let fontStyle: FontStyle
        public let backgroundAsset: DesignSystemColors
        public let backgroundOpacity: Double
        public let foregroundAsset: DesignSystemColors
        public let arrowAsset: DSIconAsset
        public let arrowTintAsset: DesignSystemColors
    }

    public static func specification() -> Specification {
        Specification(
            bubbleHeight: 30,
            verticalPadding: 6,
            horizontalPadding: 16,
            arrowFrameWidth: 8,
            arrowWidth: 6.9282,
            arrowHeight: 6,
            arrowRotationDegrees: 180,
            shape: .capsule,
            fontStyle: .body3Medium,
            backgroundAsset: DesignSystemAsset.Colors.black,
            backgroundOpacity: 0.8,
            foregroundAsset: DesignSystemAsset.Colors.white,
            arrowAsset: .tooltipArrow,
            arrowTintAsset: DesignSystemAsset.Colors.black
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
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .foregroundStyle(specification.foregroundAsset.swiftUIColor)
                .padding(.vertical, specification.verticalPadding)
                .padding(.horizontal, specification.horizontalPadding)
                .frame(height: specification.bubbleHeight)
                .background(
                    specification.backgroundAsset.swiftUIColor
                        .opacity(specification.backgroundOpacity)
                )
                .clipShape(specification.shape.swiftUIShape)

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
