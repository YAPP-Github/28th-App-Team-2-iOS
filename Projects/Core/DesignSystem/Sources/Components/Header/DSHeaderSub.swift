import SwiftUI

public struct DSHeaderSub: View {
    public struct Specification: Sendable {
        public let backgroundAsset: DesignSystemColors
        public let contentHeight: CGFloat
        public let horizontalPadding: CGFloat
        public let titleFontStyle: FontStyle
        public let titleTextAsset: DesignSystemColors
        public let actionIconSize: CGSize
        public let actionIconTintAsset: DesignSystemColors
        public let actionIconPressedOverlay: DSPressedOverlay
    }

    public static func specification() -> Specification {
        Specification(
            backgroundAsset: DesignSystemAsset.Colors.white,
            contentHeight: 48,
            horizontalPadding: 20,
            titleFontStyle: .body2SemiBold,
            titleTextAsset: DesignSystemAsset.Colors.black,
            actionIconSize: CGSize(width: 20, height: 20),
            actionIconTintAsset: DesignSystemAsset.Colors.gray975,
            actionIconPressedOverlay: .standard
        )
    }

    private let title: String
    private let leftItem: DSHeaderActionItem?
    private let rightItem: DSHeaderActionItem?

    public init(
        title: String,
        leftItem: DSHeaderActionItem? = nil,
        rightItem: DSHeaderActionItem? = nil
    ) {
        self.title = title
        self.leftItem = leftItem
        self.rightItem = rightItem
    }

    public var body: some View {
        let spec = Self.specification()

        ZStack {
            Text(title)
                .dsFont(spec.titleFontStyle)
                .foregroundColor(spec.titleTextAsset.swiftUIColor)
                .fixedSize()
                .dsDebugDetailGeometry("DSHeaderSub.Title")

            HStack(spacing: 0) {
                if let leftItem {
                    DSHeaderActionButton(
                        icon: leftItem.icon,
                        action: leftItem.action,
                        iconSize: spec.actionIconSize,
                        tintAsset: spec.actionIconTintAsset,
                        pressedOverlay: spec.actionIconPressedOverlay
                    )
                    .dsDebugDetailGeometry("DSHeaderSub.LeftAction")
                }

                Spacer(minLength: 0)

                if let rightItem {
                    DSHeaderActionButton(
                        icon: rightItem.icon,
                        action: rightItem.action,
                        iconSize: spec.actionIconSize,
                        tintAsset: spec.actionIconTintAsset,
                        pressedOverlay: spec.actionIconPressedOverlay
                    )
                    .dsDebugDetailGeometry("DSHeaderSub.RightAction")
                }
            }
            .padding(.horizontal, spec.horizontalPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: spec.contentHeight)
        .background(spec.backgroundAsset.swiftUIColor)
        .dsDebugGeometry("DSHeaderSub")
    }
}
