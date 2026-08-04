import SwiftUI

public struct DSHeaderMain: View {
    public struct Specification: Sendable {
        public let backgroundAsset: DesignSystemColors
        public let contentHeight: CGFloat
        public let horizontalPadding: CGFloat
        public let titleGroupGap: CGFloat
        public let titleFontStyle: FontStyle
        public let titleTextAsset: DesignSystemColors
        public let subtitleFontStyle: FontStyle
        public let subtitleTextAsset: DesignSystemColors
        public let actionIconSize: CGSize
        public let actionIconTintAsset: DesignSystemColors
        public let actionIconPressedOverlay: DSPressedOverlay
    }

    public static func specification() -> Specification {
        Specification(
            backgroundAsset: DesignSystemAsset.Colors.white,
            contentHeight: 60,
            horizontalPadding: 20,
            titleGroupGap: 12,
            titleFontStyle: .heading4Bold,
            titleTextAsset: DesignSystemAsset.Colors.black,
            subtitleFontStyle: .body3Regular,
            subtitleTextAsset: DesignSystemAsset.Colors.gray500,
            actionIconSize: CGSize(width: 24, height: 24),
            actionIconTintAsset: DesignSystemAsset.Colors.gray975,
            actionIconPressedOverlay: .standard
        )
    }

    private let title: String
    private let subtitle: String?
    private let rightItem: DSHeaderActionItem?

    public init(
        title: String,
        subtitle: String? = nil,
        rightItem: DSHeaderActionItem? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.rightItem = rightItem
    }

    public var body: some View {
        let spec = Self.specification()

        HStack(spacing: 0) {
            HStack(spacing: spec.titleGroupGap) {
                Text(title)
                    .dsFont(spec.titleFontStyle)
                    .foregroundColor(spec.titleTextAsset.swiftUIColor)
                    .fixedSize()

                if let subtitle {
                    Text(subtitle)
                        .dsFont(spec.subtitleFontStyle)
                        .foregroundColor(spec.subtitleTextAsset.swiftUIColor)
                        .fixedSize()
                }
            }
            .dsDebugDetailGeometry("DSHeaderMain.TitleGroup")

            Spacer(minLength: 0)

            if let rightItem {
                DSHeaderActionButton(
                    icon: rightItem.icon,
                    action: rightItem.action,
                    iconSize: spec.actionIconSize,
                    tintAsset: spec.actionIconTintAsset,
                    pressedOverlay: spec.actionIconPressedOverlay
                )
            }
        }
        .padding(.horizontal, spec.horizontalPadding)
        .frame(maxWidth: .infinity)
        .frame(height: spec.contentHeight)
        .background(spec.backgroundAsset.swiftUIColor)
        .dsDebugGeometry("DSHeaderMain")
    }
}
