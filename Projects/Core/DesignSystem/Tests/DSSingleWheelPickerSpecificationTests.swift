import Testing
@testable import DesignSystem

struct DSSingleWheelPickerSpecificationTests {
    @Test("Single WheelPicker 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSSingleWheelPicker.specification()

        #expect(specification.containerWidth == 292)
        #expect(specification.viewportHeight == 175)
        #expect(specification.rowHeight == 34)
        #expect(specification.selectionHeight == 47)
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
    }
}
