import SwiftUI

public struct DSUserChat: View {
    public struct Specification: Sendable {
        public let height: CGFloat
        public let shape: DSComponentShape
        public let backgroundAsset: DesignSystemColors
        public let fontStyle: FontStyle
        public let foregroundAsset: DesignSystemColors
        public let horizontalPadding: CGFloat
        public let verticalPadding: CGFloat
    }

    public static let specification = Specification(
        height: 48,
        shape: .unevenRoundedRectangle(
            topLeadingRadius: 12,
            topTrailingRadius: 0,
            bottomLeadingRadius: 12,
            bottomTrailingRadius: 12
        ),
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
            .clipShape(specification.shape.swiftUIShape)
            .dsDebugGeometry("DSUserChat")
    }
}
