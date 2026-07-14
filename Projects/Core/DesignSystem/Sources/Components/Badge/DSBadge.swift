import SwiftUI

// MARK: - Core Badge Component
public struct DSBadge: View {
    public struct Specification: Sendable {
        public let verticalPadding: CGFloat
        public let horizontalPadding: CGFloat
        public let shape: DSComponentShape
        public let fontStyle: FontStyle
        public let backgroundAsset: DesignSystemColors
        public let foregroundAsset: DesignSystemColors
    }

    public static func specification(variant: DSBadgeVariant) -> Specification {
        let assets: (background: DesignSystemColors, foreground: DesignSystemColors)

        switch variant {
        case .purple:
            assets = (DesignSystemAsset.Colors.primary100, DesignSystemAsset.Colors.primary800)
        case .pink:
            assets = (DesignSystemAsset.Colors.pink100, DesignSystemAsset.Colors.pink800)
        case .green:
            assets = (DesignSystemAsset.Colors.teal100, DesignSystemAsset.Colors.teal800)
        case .yellow:
            assets = (DesignSystemAsset.Colors.orange100, DesignSystemAsset.Colors.orange800)
        case .blue:
            assets = (DesignSystemAsset.Colors.sky100, DesignSystemAsset.Colors.sky800)
        case .gray:
            assets = (DesignSystemAsset.Colors.coolGray100, DesignSystemAsset.Colors.coolGray500)
        }

        return Specification(
            verticalPadding: 3,
            horizontalPadding: 6,
            shape: .roundedRectangle(cornerRadius: 6),
            fontStyle: .caption2SemiBold,
            backgroundAsset: assets.background,
            foregroundAsset: assets.foreground
        )
    }

    private let title: String
    private let variant: DSBadgeVariant
    
    public init(_ title: String, variant: DSBadgeVariant) {
        self.title = title
        self.variant = variant
    }
    
    public var body: some View {
        let specification = Self.specification(variant: variant)

        Text(title)
            .dsFont(specification.fontStyle)
            .lineLimit(1)
            .padding(.vertical, specification.verticalPadding)
            .padding(.horizontal, specification.horizontalPadding)
            .foregroundStyle(specification.foregroundAsset.swiftUIColor)
            .background(specification.backgroundAsset.swiftUIColor)
            .clipShape(specification.shape.swiftUIShape)
    }
}
