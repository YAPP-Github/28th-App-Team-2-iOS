import SwiftUI

public struct DSWheelPickerPanel: View {
    public struct Specification: Sendable {
        public let containerWidth: CGFloat
        public let containerHeight: CGFloat
        public let horizontalPadding: CGFloat
        public let topPadding: CGFloat
        public let dragIndicatorWidth: CGFloat
        public let dragIndicatorHeight: CGFloat
        public let dragIndicatorToHeaderSpacing: CGFloat
        public let headerHeight: CGFloat
        public let titleWidth: CGFloat
        public let headerGap: CGFloat
        public let actionWidth: CGFloat
        public let actionHeight: CGFloat
        public let headerToPickerSpacing: CGFloat
        public let bottomPadding: CGFloat
        public let sheetBottomSpacing: CGFloat
        public let keyboardSheetBottomSpacing: CGFloat
        public let containerShape: DSComponentShape
        public let dragIndicatorShape: DSComponentShape
        public let titleFontStyle: FontStyle
        public let actionFontStyle: FontStyle
        public let backgroundAsset: DesignSystemColors
        public let dimmingAsset: DesignSystemColors
        public let dragIndicatorAsset: DesignSystemColors
        public let titleForegroundAsset: DesignSystemColors
        public let actionForegroundAsset: DesignSystemColors
    }

    public static func specification(
        layout: DSWheelPickerPanelLayout
    ) -> Specification {
        let containerHeight: CGFloat

        switch layout {
        case .single:
            containerHeight = 319
        case .time:
            containerHeight = 309
        case .date:
            containerHeight = 322
        }

        return Specification(
            containerWidth: 352,
            containerHeight: containerHeight,
            horizontalPadding: 30,
            topPadding: 14,
            dragIndicatorWidth: 44,
            dragIndicatorHeight: 4,
            dragIndicatorToHeaderSpacing: 26,
            headerHeight: 32,
            titleWidth: 220,
            headerGap: 28,
            actionWidth: 44,
            actionHeight: 31,
            headerToPickerSpacing: 28,
            bottomPadding: 40,
            sheetBottomSpacing: 40,
            keyboardSheetBottomSpacing: 12,
            containerShape: .roundedRectangle(cornerRadius: 12),
            dragIndicatorShape: .capsule,
            titleFontStyle: .heading3Bold,
            actionFontStyle: .body1Medium,
            backgroundAsset: DesignSystemAsset.Colors.white,
            dimmingAsset: DesignSystemAsset.Colors.opacity20,
            dragIndicatorAsset: DesignSystemAsset.Colors.gray200,
            titleForegroundAsset: DesignSystemAsset.Colors.black,
            actionForegroundAsset: DesignSystemAsset.Colors.primary700
        )
    }

    private let layout: DSWheelPickerPanelLayout
    private let title: String
    private let actionTitle: String
    private let onSave: () -> Void
    private let content: AnyView

    public init<Content: View>(
        layout: DSWheelPickerPanelLayout,
        title: String,
        actionTitle: String = "저장",
        onSave: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.layout = layout
        self.title = title
        self.actionTitle = actionTitle
        self.onSave = onSave
        self.content = AnyView(content())
    }

    public var body: some View {
        let specification = Self.specification(layout: layout)

        VStack(spacing: 0) {
            specification.dragIndicatorShape.swiftUIShape
                .fill(specification.dragIndicatorAsset.swiftUIColor)
                .frame(
                    width: specification.dragIndicatorWidth,
                    height: specification.dragIndicatorHeight
                )
                .accessibilityHidden(true)
                .dsDebugDetailGeometry("DSWheelPickerPanel.DragIndicator")
                .padding(.top, specification.topPadding)

            header(specification)
                .padding(.top, specification.dragIndicatorToHeaderSpacing)
                .padding(.horizontal, specification.horizontalPadding)

            content
                .padding(.top, specification.headerToPickerSpacing)

            Spacer(minLength: specification.bottomPadding)
        }
        .frame(
            width: specification.containerWidth,
            height: specification.containerHeight
        )
        .background(
            specification.containerShape.swiftUIShape
                .fill(specification.backgroundAsset.swiftUIColor)
        )
        .clipShape(specification.containerShape.swiftUIShape)
        .dsDebugGeometry("DSWheelPickerPanel.\(String(describing: layout))")
    }

    private func header(_ specification: Specification) -> some View {
        HStack(spacing: specification.headerGap) {
            Text(title)
                .dsFont(specification.titleFontStyle)
                .foregroundStyle(specification.titleForegroundAsset.swiftUIColor)
                .frame(
                    maxWidth: .infinity,
                    minHeight: specification.headerHeight,
                    maxHeight: specification.headerHeight,
                    alignment: .leading
                )

            Button(actionTitle, action: onSave)
                .buttonStyle(.plain)
                .dsFont(specification.actionFontStyle)
                .foregroundStyle(specification.actionForegroundAsset.swiftUIColor)
                .frame(
                    width: specification.actionWidth,
                    height: specification.actionHeight
                )
        }
        .frame(height: specification.headerHeight)
        .dsDebugDetailGeometry("DSWheelPickerPanel.Header")
    }
}
