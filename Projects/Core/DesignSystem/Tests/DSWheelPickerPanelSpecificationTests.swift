import CoreGraphics
import Testing
@testable import DesignSystem

struct DSWheelPickerPanelSpecificationTests {
    @Test(
        "WheelPicker Panel 공통 스펙 매핑 검증",
        arguments: DSWheelPickerPanelLayout.allCases
    )
    func testCommonSpecifications(layout: DSWheelPickerPanelLayout) {
        let specification = DSWheelPickerPanel.specification(layout: layout)

        #expect(specification.containerWidth == 352)
        #expect(specification.horizontalPadding == 30)
        #expect(specification.topPadding == 14)
        #expect(specification.dragIndicatorWidth == 44)
        #expect(specification.dragIndicatorHeight == 4)
        #expect(specification.dragIndicatorToHeaderSpacing == 26)
        #expect(specification.headerHeight == 32)
        #expect(specification.titleWidth == 220)
        #expect(specification.headerGap == 28)
        #expect(specification.actionHorizontalPadding == 6)
        #expect(specification.actionVerticalPadding == 2.5)
        #expect(specification.actionShape == .capsule)
        #expect(specification.headerToPickerSpacing == 28)
        #expect(specification.bottomPadding == 40)
        #expect(specification.sheetBottomSpacing == 40)
        #expect(specification.keyboardSheetBottomSpacing == 12)
        #expect(specification.containerShape == .roundedRectangle(cornerRadius: 12))
        #expect(specification.dragIndicatorShape == .capsule)
        #expect(specification.titleFontStyle == .heading3Bold)
        #expect(specification.actionFontStyle == .body1Medium)
        expectColorEqual(
            specification.backgroundAsset,
            DesignSystemAsset.Colors.white
        )
        expectColorEqual(
            specification.shadowColorAsset,
            DesignSystemAsset.Colors.black
        )
        #expect(specification.shadowOpacity == 0.05)
        #expect(specification.shadowRadius == 20)
        #expect(specification.shadowOffsetX == 0)
        #expect(specification.shadowOffsetY == 0)
        expectColorEqual(
            specification.dimmingAsset,
            DesignSystemAsset.Colors.opacity20
        )
        expectColorEqual(
            specification.dragIndicatorAsset,
            DesignSystemAsset.Colors.gray200
        )
        expectColorEqual(
            specification.titleForegroundAsset,
            DesignSystemAsset.Colors.black
        )
        expectColorEqual(
            specification.actionForegroundAsset,
            DesignSystemAsset.Colors.primary700
        )
        expectColorEqual(
            specification.actionPressedOverlay.asset,
            DesignSystemAsset.Colors.gray975
        )
        #expect(specification.actionPressedOverlay.opacity == 0.16)
    }

    @Test(
        "WheelPicker Panel 레이아웃별 높이 매핑 검증",
        arguments: [
            (DSWheelPickerPanelLayout.single, CGFloat(319)),
            (DSWheelPickerPanelLayout.time, CGFloat(309)),
            (DSWheelPickerPanelLayout.date, CGFloat(322))
        ]
    )
    func testContainerHeight(
        layout: DSWheelPickerPanelLayout,
        expectedHeight: CGFloat
    ) {
        let specification = DSWheelPickerPanel.specification(layout: layout)

        #expect(specification.containerHeight == expectedHeight)
    }
}
