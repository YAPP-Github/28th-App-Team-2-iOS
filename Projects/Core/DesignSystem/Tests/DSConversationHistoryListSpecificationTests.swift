import Testing
@testable import DesignSystem

struct DSConversationHistoryListSpecTests {
    @Test("Conversation History List 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSConversationHistoryList.specification

        #expect(specification.contentWidth == 353)
        #expect(specification.horizontalPadding == 20)
        #expect(specification.topPadding == 20)
        #expect(specification.bottomPadding == 20)
        #expect(specification.titleFont == .body1Medium)
        expectColorEqual(specification.titleColorAsset, DesignSystemAsset.Colors.black)
        #expect(specification.titleLineLimit == 1)
        #expect(specification.titleTruncationMode == .tail)
        #expect(specification.titleIndicatorWidth == 320)
        #expect(specification.indicatorSize == 6)
        expectColorEqual(specification.indicatorColorAsset, DesignSystemAsset.Colors.red400)
        #expect(specification.titleIndicatorSpacing == 6)
        #expect(specification.deleteIcon == .delete)
        #expect(specification.deleteIconSize == 23)
        expectColorEqual(specification.deleteIconColorAsset, DesignSystemAsset.Colors.gray500)
        #expect(specification.titleDeleteSpacing == 10)
        #expect(specification.timeFont == .body3Regular)
        expectColorEqual(specification.timeColorAsset, DesignSystemAsset.Colors.gray600)
        #expect(specification.titleTimeSpacing == 10)
    }
}
