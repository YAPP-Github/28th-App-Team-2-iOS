import SwiftUI

public struct DSUserChat: View {
    public struct Specification: Sendable {
        public let height: CGFloat
        public let topLeadingRadius: CGFloat
        public let topTrailingRadius: CGFloat
        public let bottomLeadingRadius: CGFloat
        public let bottomTrailingRadius: CGFloat
        public let backgroundAsset: DesignSystemColors
        public let fontStyle: FontStyle
        public let foregroundAsset: DesignSystemColors
        public let horizontalPadding: CGFloat
        public let verticalPadding: CGFloat
    }

    public static let specification = Specification(
        height: 48,
        topLeadingRadius: 12,
        topTrailingRadius: 0,
        bottomLeadingRadius: 12,
        bottomTrailingRadius: 12,
        backgroundAsset: DesignSystemAsset.Colors.gray50,
        fontStyle: .body2Medium,
        foregroundAsset: DesignSystemAsset.Colors.black,
        horizontalPadding: 18,
        verticalPadding: 12
    )

    private let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var body: some View {
        let specification = Self.specification

        Text(message)
            .dsFont(specification.fontStyle)
            .foregroundStyle(specification.foregroundAsset.swiftUIColor)
            .padding(.horizontal, specification.horizontalPadding)
            .padding(.vertical, specification.verticalPadding)
            .frame(minHeight: specification.height)
            .background(specification.backgroundAsset.swiftUIColor)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: specification.topLeadingRadius,
                    bottomLeadingRadius: specification.bottomLeadingRadius,
                    bottomTrailingRadius: specification.bottomTrailingRadius,
                    topTrailingRadius: specification.topTrailingRadius
                )
            )
            .dsDebugGeometry("DSUserChat")
    }
}
