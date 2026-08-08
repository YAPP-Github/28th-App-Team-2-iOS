import Testing
@testable import DesignSystem

struct DSEnterNameSpecificationTests {
    @Test("Enter Name 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSEnterName.specification()

        #expect(specification.contentSpacing == 16)
        #expect(specification.labelFontStyle == .body1Bold)
        expectColorEqual(
            specification.labelForegroundAsset,
            DesignSystemAsset.Colors.black
        )
    }
}
