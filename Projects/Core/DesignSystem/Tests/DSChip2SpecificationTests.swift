import Testing
@testable import DesignSystem

struct DSChip2SpecificationTests {
    @Test("Chip2 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSChip2.specification

        #expect(specification.verticalPadding == 5)
        #expect(specification.horizontalPadding == 10)
        #expect(specification.shape == .capsule)
        #expect(specification.fontStyle == .body3Medium)
        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.primary700)
        expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.white)
    }
}
