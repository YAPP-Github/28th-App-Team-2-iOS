import SwiftUI

// MARK: - Core Chip2 Component
public struct DSChip2: View {
    public struct Specification: Sendable {
        public let verticalPadding: CGFloat
        public let horizontalPadding: CGFloat
        public let shape: DSComponentShape
        public let fontStyle: FontStyle
        public let backgroundAsset: DesignSystemColors
        public let foregroundAsset: DesignSystemColors
    }

    public static var specification: Specification {
        Specification(
            verticalPadding: 5,
            horizontalPadding: 10,
            shape: .capsule,
            fontStyle: .body3Medium,
            backgroundAsset: DesignSystemAsset.Colors.primary700,
            foregroundAsset: DesignSystemAsset.Colors.white
        )
    }

    private let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        let specification = Self.specification

        Text(title)
            .dsFont(specification.fontStyle)
            .lineLimit(1)
            .padding(.vertical, specification.verticalPadding)
            .padding(.horizontal, specification.horizontalPadding)
            .foregroundColor(specification.foregroundAsset.swiftUIColor)
            .background(specification.backgroundAsset.swiftUIColor)
            .clipShape(specification.shape.swiftUIShape)
            .dsDebugGeometry("DSChip2")
    }
}
