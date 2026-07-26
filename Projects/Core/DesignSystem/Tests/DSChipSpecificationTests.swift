import Testing
@testable import DesignSystem

struct DSChipSpecificationTests {
    @Test("Chip 스펙 매핑 검증", arguments: [false, true])
    func testSpecifications(isSelected: Bool) {
        let specification = DSChip.specification(isSelected: isSelected)

        #expect(specification.verticalPadding == 12)
        #expect(specification.horizontalPadding == 20)
        #expect(specification.shape == .capsule)
        expectColorEqual(specification.pressedOverlay.asset, DesignSystemAsset.Colors.gray975)
        #expect(specification.pressedOverlay.opacity == 0.16)

        if isSelected {
            #expect(specification.fontStyle == .body2SemiBold)
            expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.primary500)
            expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.white)
        } else {
            #expect(specification.fontStyle == .body2Medium)
            expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray25)
            expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.coolGray700)
        }
    }
}
