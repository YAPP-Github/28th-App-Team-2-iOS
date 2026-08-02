import Testing
@testable import DesignSystem

struct DSUserChatSpecificationTests {
    @Test("User Chat 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSUserChat.specification

        #expect(specification.height == 48)
        #expect(specification.topLeadingRadius == 12)
        #expect(specification.topTrailingRadius == 0)
        #expect(specification.bottomLeadingRadius == 12)
        #expect(specification.bottomTrailingRadius == 12)
        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray50)
        #expect(specification.fontStyle == .body2Medium)
        expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.black)
        #expect(specification.horizontalPadding == 18)
        #expect(specification.verticalPadding == 12)
    }
}
