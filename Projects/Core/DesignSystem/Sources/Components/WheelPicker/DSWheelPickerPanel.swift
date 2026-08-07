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
        public let actionHorizontalPadding: CGFloat
        public let actionVerticalPadding: CGFloat
        public let actionShape: DSComponentShape
        public let headerToPickerSpacing: CGFloat
        public let bottomPadding: CGFloat
        public let sheetBottomSpacing: CGFloat
        public let keyboardSheetBottomSpacing: CGFloat
        public let containerShape: DSComponentShape
        public let dragIndicatorShape: DSComponentShape
        public let titleFontStyle: FontStyle
        public let actionFontStyle: FontStyle
        public let backgroundAsset: DesignSystemColors
        public let shadowColorAsset: DesignSystemColors
        public let shadowOpacity: CGFloat
        public let shadowRadius: CGFloat
        public let shadowOffsetX: CGFloat
        public let shadowOffsetY: CGFloat
        public let dimmingAsset: DesignSystemColors
        public let dragIndicatorAsset: DesignSystemColors
        public let titleForegroundAsset: DesignSystemColors
        public let actionForegroundAsset: DesignSystemColors
        public let actionPressedOverlay: DSPressedOverlay
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
            actionHorizontalPadding: 6,
            actionVerticalPadding: 2.5,
            actionShape: .capsule,
            headerToPickerSpacing: 28,
            bottomPadding: 40,
            sheetBottomSpacing: 40,
            keyboardSheetBottomSpacing: 12,
            containerShape: .roundedRectangle(cornerRadius: 12),
            dragIndicatorShape: .capsule,
            titleFontStyle: .heading3Bold,
            actionFontStyle: .body1Medium,
            backgroundAsset: DesignSystemAsset.Colors.white,
            shadowColorAsset: DesignSystemAsset.Colors.black,
            shadowOpacity: 0.05,
            shadowRadius: 20,
            shadowOffsetX: 0,
            shadowOffsetY: 0,
            dimmingAsset: DesignSystemAsset.Colors.opacity20,
            dragIndicatorAsset: DesignSystemAsset.Colors.gray200,
            titleForegroundAsset: DesignSystemAsset.Colors.black,
            actionForegroundAsset: DesignSystemAsset.Colors.primary700,
            actionPressedOverlay: .standard
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
        .shadow(
            color: specification.shadowColorAsset.swiftUIColor
                .opacity(specification.shadowOpacity),
            radius: specification.shadowRadius,
            x: specification.shadowOffsetX,
            y: specification.shadowOffsetY
        )
        .dsDebugGeometry("DSWheelPickerPanel.\(String(describing: layout))")
    }

    private func header(_ specification: Specification) -> some View {
        HStack(spacing: specification.headerGap) {
            Text(title)
                .dsFont(specification.titleFontStyle)
                .foregroundStyle(specification.titleForegroundAsset.swiftUIColor)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(
                    width: specification.titleWidth,
                    height: specification.headerHeight,
                    alignment: .leading
                )

            Button(action: onSave) {
                Text(actionTitle)
            }
            .buttonStyle(DSWheelPickerPanelActionButtonStyle(specification: specification))
        }
        .frame(height: specification.headerHeight)
        .dsDebugDetailGeometry("DSWheelPickerPanel.Header")
    }
}

private struct DSWheelPickerPanelActionButtonStyle: ButtonStyle {
    let specification: DSWheelPickerPanel.Specification

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .dsFont(specification.actionFontStyle)
            .foregroundStyle(specification.actionForegroundAsset.swiftUIColor)
            .padding(.horizontal, specification.actionHorizontalPadding)
            .padding(.vertical, specification.actionVerticalPadding)
            .contentShape(specification.actionShape.swiftUIShape)
            .dsPressedOverlay(
                isPressed: configuration.isPressed,
                shape: specification.actionShape,
                specification: specification.actionPressedOverlay
            )
            .clipShape(specification.actionShape.swiftUIShape)
    }
}
