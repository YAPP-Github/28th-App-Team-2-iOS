import SwiftUI

public struct DSPopoverItem {
    public let identifier: UUID
    public let title: String

    fileprivate let action: () -> Void

    public init(
        identifier: UUID = UUID(),
        title: String,
        action: @escaping () -> Void
    ) {
        self.identifier = identifier
        self.title = title
        self.action = action
    }
}

// MARK: - Core Popover Component
public struct DSPopover: View {
    public struct Specification: Sendable {
        public let minimumItemWidth: CGFloat
        public let itemHeight: CGFloat
        public let containerPadding: CGFloat
        public let itemSpacing: CGFloat
        public let contentHorizontalPadding: CGFloat
        public let containerShape: DSComponentShape
        public let itemShape: DSComponentShape
        public let fontStyle: FontStyle
        public let backgroundAsset: DesignSystemColors
        public let foregroundAsset: DesignSystemColors
        public let pressedOverlay: DSPressedOverlay
        public let shadowColorAsset: DesignSystemColors
        public let shadowOpacity: CGFloat
        public let shadowRadius: CGFloat
        public let shadowX: CGFloat
        public let shadowY: CGFloat
    }

    public static func specification() -> Specification {
        Specification(
            minimumItemWidth: 100,
            itemHeight: 44,
            containerPadding: 8,
            itemSpacing: 4,
            contentHorizontalPadding: 12,
            containerShape: .roundedRectangle(cornerRadius: 12),
            itemShape: .roundedRectangle(cornerRadius: 8),
            fontStyle: .body3Medium,
            backgroundAsset: DesignSystemAsset.Colors.white,
            foregroundAsset: DesignSystemAsset.Colors.gray925,
            pressedOverlay: .standard,
            shadowColorAsset: DesignSystemAsset.Colors.black,
            shadowOpacity: 0.08,
            shadowRadius: 10,
            shadowX: 0,
            shadowY: 0
        )
    }

    private let items: [DSPopoverItem]

    public init(items: [DSPopoverItem]) {
        self.items = items
    }

    public var body: some View {
        let specification = Self.specification()

        VStack(alignment: .leading, spacing: specification.itemSpacing) {
            ForEach(Array(items.enumerated()), id: \.element.identifier) { index, item in
                Button(action: item.action) {
                    Text(item.title)
                        .dsFont(specification.fontStyle)
                        .padding(.horizontal, specification.contentHorizontalPadding)
                        .dsDebugDetailGeometry("DSPopover.Item[\(index)].Content")
                }
                .buttonStyle(DSPopoverItemButtonStyle(specification: specification))
                .dsDebugDetailGeometry("DSPopover.Item[\(index)]")
            }
        }
        .padding(specification.containerPadding)
        .background(specification.backgroundAsset.swiftUIColor)
        .clipShape(specification.containerShape.swiftUIShape)
        .shadow(
            color: specification.shadowColorAsset.swiftUIColor.opacity(specification.shadowOpacity),
            radius: specification.shadowRadius,
            x: specification.shadowX,
            y: specification.shadowY
        )
        .dsDebugGeometry("DSPopover")
    }
}
