import Testing
@testable import DesignSystem

struct DSSelectBoxSpecificationTests {
    @Test("SelectBox 스펙 매핑 검증", arguments: [false, true])
    func testSpecifications(isSelected: Bool) {
        let specification = DSSelectBox.specification(isSelected: isSelected)

        #expect(specification.height == 48)
        #expect(specification.verticalPadding == 14)
        #expect(specification.horizontalPadding == 16)
        #expect(specification.borderWidth == 1)
        #expect(specification.shape == .roundedRectangle(cornerRadius: 12))
        #expect(specification.fontStyle == .body1Medium)

        if isSelected {
            expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.primary50)
            expectColorEqual(specification.borderAsset, DesignSystemAsset.Colors.primary600)
            expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.primary700)
        } else {
            expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.white)
            expectColorEqual(specification.borderAsset, DesignSystemAsset.Colors.coolGray300)
            expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.coolGray800)
        }
    }
}
