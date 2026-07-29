import Testing
@testable import DesignSystem

struct DSPopoverSpecificationTests {
    @Test("Popover 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSPopover.specification()

        #expect(specification.minimumItemWidth == 100)
        #expect(specification.itemHeight == 44)
        #expect(specification.containerPadding == 8)
        #expect(specification.itemSpacing == 4)
        #expect(specification.contentHorizontalPadding == 12)
        #expect(specification.containerShape == .roundedRectangle(cornerRadius: 12))
        #expect(specification.itemShape == .roundedRectangle(cornerRadius: 8))
        #expect(specification.fontStyle == .body3Medium)
        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.white)
        expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.gray925)
        expectColorEqual(specification.pressedOverlay.asset, DesignSystemAsset.Colors.gray975)
        #expect(specification.pressedOverlay.opacity == 0.16)
        expectColorEqual(specification.shadowColorAsset, DesignSystemAsset.Colors.black)
        #expect(specification.shadowOpacity == 0.08)
        #expect(specification.shadowRadius == 10)
        #expect(specification.shadowX == 0)
        #expect(specification.shadowY == 0)
    }
}
