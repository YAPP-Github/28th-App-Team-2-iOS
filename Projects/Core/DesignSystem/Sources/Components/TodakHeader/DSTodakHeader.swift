import SwiftUI

public struct DSTodakHeader: View {
    public struct Specification: Sendable {
        public let backgroundAsset: DesignSystemColors
        public let contentHeight: CGFloat
        public let horizontalPadding: CGFloat
        public let iconSize: CGSize
        public let leftIconAsset: DSIconAsset
        public let leftIconTintAsset: DesignSystemColors
        public let leftIconPressedOverlay: DSPressedOverlay
        public let rightIconGap: CGFloat
        public let rightIconTintAsset: DesignSystemColors
        public let rightIconPressedOverlay: DSPressedOverlay
        public let titleFontStyle: FontStyle
        public let titleTextAsset: DesignSystemColors
        public let subtitleFontStyle: FontStyle
        public let subtitleTextAsset: DesignSystemColors
        public let remainingCountFontStyle: FontStyle
        public let remainingCountTextAsset: DesignSystemColors
        public let titleGroupGap: CGFloat
        public let freeChatLimit: Int
    }

    public static func specification() -> Specification {
        Specification(
            backgroundAsset: DesignSystemAsset.Colors.white,
            contentHeight: 48,
            horizontalPadding: 20,
            iconSize: CGSize(width: 20, height: 20),
            leftIconAsset: .deleteLine,
            leftIconTintAsset: DesignSystemAsset.Colors.gray925,
            leftIconPressedOverlay: .standard,
            rightIconGap: 12,
            rightIconTintAsset: DesignSystemAsset.Colors.gray975,
            rightIconPressedOverlay: .standard,
            titleFontStyle: .body2SemiBold,
            titleTextAsset: DesignSystemAsset.Colors.black,
            subtitleFontStyle: .body3Regular,
            subtitleTextAsset: DesignSystemAsset.Colors.gray500,
            remainingCountFontStyle: .body3Medium,
            remainingCountTextAsset: DesignSystemAsset.Colors.gray800,
            titleGroupGap: 4,
            freeChatLimit: 3
        )
    }

    private let remainingFreeChatCount: Int
    private let rightItems: [DSHeaderActionItem]
    private let onClose: () -> Void

    public init(
        remainingFreeChatCount: Int,
        rightItems: [DSHeaderActionItem],
        onClose: @escaping () -> Void
    ) {
        self.remainingFreeChatCount = remainingFreeChatCount
        self.rightItems = rightItems
        self.onClose = onClose
    }

    public var body: some View {
        let spec = Self.specification()

        ZStack {
            titleGroup(spec: spec)

            HStack {
                DSHeaderActionButton(
                    icon: spec.leftIconAsset,
                    action: onClose,
                    iconSize: spec.iconSize,
                    tintAsset: spec.leftIconTintAsset,
                    pressedOverlay: spec.leftIconPressedOverlay
                )

                Spacer()

                HStack(spacing: spec.rightIconGap) {
                    ForEach(rightItems, id: \.identifier) { item in
                        DSHeaderActionButton(
                            icon: item.icon,
                            action: item.action,
                            iconSize: spec.iconSize,
                            tintAsset: spec.rightIconTintAsset,
                            pressedOverlay: spec.rightIconPressedOverlay
                        )
                    }
                }
                .dsDebugDetailGeometry("DSTodakHeader.RightActions")
            }
            .padding(.horizontal, spec.horizontalPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: spec.contentHeight)
        .background(spec.backgroundAsset.swiftUIColor)
        .dsDebugGeometry("DSTodakHeader")
    }

    private func titleGroup(spec: Specification) -> some View {
        HStack(alignment: .center, spacing: spec.titleGroupGap) {
            Text("토닥이")
                .dsFont(spec.titleFontStyle)
                .foregroundColor(spec.titleTextAsset.swiftUIColor)
                .fixedSize()

            (
                Text("오늘 무료 채팅 ")
                    .font(.ds.font(spec.subtitleFontStyle))
                    .foregroundColor(spec.subtitleTextAsset.swiftUIColor)
                + Text("\(remainingFreeChatCount)")
                    .font(.ds.font(spec.remainingCountFontStyle))
                    .foregroundColor(spec.remainingCountTextAsset.swiftUIColor)
                + Text("/\(spec.freeChatLimit)")
                    .font(.ds.font(spec.remainingCountFontStyle))
                    .foregroundColor(spec.subtitleTextAsset.swiftUIColor)
            )
            .modifier(
                DSLineHeightModifier(
                    fontSize: spec.subtitleFontStyle.size,
                    lineHeight: spec.subtitleFontStyle.lineHeight,
                    fontConvertible: spec.subtitleFontStyle.fontConvertible
                )
            )
            .dsDebugTypographyGeometry(
                "Typography.\(String(describing: spec.subtitleFontStyle))"
                + "/\(String(describing: spec.remainingCountFontStyle))"
            )
            .fixedSize()
        }
        .dsDebugDetailGeometry("DSTodakHeader.TitleGroup")
    }
}
