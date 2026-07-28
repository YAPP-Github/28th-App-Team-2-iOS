import Testing
@testable import DesignSystem

struct DSMultiWheelPickerSpecificationTests {
    @Test(
        "Multi WheelPicker 스펙 매핑 검증",
        arguments: DSMultiWheelPickerLayout.allCases
    )
    func testSpecifications(layout: DSMultiWheelPickerLayout) {
        let specification = DSMultiWheelPicker.specification(layout: layout)

        #expect(specification.containerWidth == 292)
        #expect(specification.rowHeight == 34)
        #expect(specification.selectionHeight == 50)
        #expect(specification.shape == .roundedRectangle(cornerRadius: 8))
        #expect(specification.selectedFontStyle == .body1Medium)
        #expect(specification.adjacentFontStyle == .body2Regular)
        #expect(specification.outerFontStyle == .body3Regular)
        expectColorEqual(
            specification.selectionBackgroundAsset,
            DesignSystemAsset.Colors.primary50
        )
        expectColorEqual(
            specification.selectedForegroundAsset,
            DesignSystemAsset.Colors.black
        )
        expectColorEqual(
            specification.adjacentForegroundAsset,
            DesignSystemAsset.Colors.gray700
        )
        expectColorEqual(
            specification.outerForegroundAsset,
            DesignSystemAsset.Colors.gray400
        )

        switch layout {
        case .time:
            #expect(specification.viewportHeight == 165)
            #expect(specification.columnWidths == [40, 40])
            #expect(specification.columnGap == 64)
        case .date:
            #expect(specification.viewportHeight == 178)
            #expect(specification.columnWidths == [60, 40, 40])
            #expect(specification.columnGap == 40)
        }
    }
}
