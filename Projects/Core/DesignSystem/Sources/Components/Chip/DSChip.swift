import SwiftUI

// MARK: - Core Chip Component
public struct DSChip: View {
    public struct Specification: Sendable {
        public let verticalPadding: CGFloat
        public let horizontalPadding: CGFloat
        public let shape: DSComponentShape
        public let fontStyle: FontStyle
        public let backgroundAsset: DesignSystemColors
        public let foregroundAsset: DesignSystemColors
    }

    public static func specification(isSelected: Bool) -> Specification {
        Specification(
            verticalPadding: 12,
            horizontalPadding: 20,
            shape: .capsule,
            fontStyle: isSelected ? .body2SemiBold : .body2Medium,
            backgroundAsset: isSelected
                ? DesignSystemAsset.Colors.primary500
                : DesignSystemAsset.Colors.gray25,
            foregroundAsset: isSelected
                ? DesignSystemAsset.Colors.white
                : DesignSystemAsset.Colors.coolGray700
        )
    }

    private let title: String
    private let isSelected: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        let specification = Self.specification(isSelected: isSelected)

        Button(action: action) {
            Text(title)
                .dsFont(specification.fontStyle, debugName: "DSChip.Text")
        }
        .buttonStyle(DSChipButtonStyle(specification: specification))
        .dsDebugGeometry("DSChip")
    }
}
