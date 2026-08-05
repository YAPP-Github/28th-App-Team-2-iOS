import Testing
@testable import DesignSystem

struct DSChatTypeBoxSpecificationTests {
    @Test("Chat Type Box 빈 입력 스펙 매핑 검증")
    func testEmptySpecification() {
        let specification = DSChatTypeBox.specification(isFilled: false)

        expectCommonSpecification(specification)
        expectColorEqual(specification.sendButtonBackgroundAsset, DesignSystemAsset.Colors.gray50)
        expectColorEqual(specification.sendIconColorAsset, DesignSystemAsset.Colors.gray400)
    }

    @Test("Chat Type Box 입력 완료 스펙 매핑 검증")
    func testFilledSpecification() {
        let specification = DSChatTypeBox.specification(isFilled: true)

        expectCommonSpecification(specification)
        expectColorEqual(specification.sendButtonBackgroundAsset, DesignSystemAsset.Colors.primary600)
        expectColorEqual(specification.sendIconColorAsset, DesignSystemAsset.Colors.white)
    }

    @Test("Chat Type Box 레이아웃 메트릭은 단일 줄부터 최대 높이 초과까지 일관되게 계산한다")
    func testLayoutMetrics() {
        let specification = DSChatTypeBox.specification(isFilled: true)

        let singleLine = DSChatTypeBox.layoutMetrics(
            specification: specification,
            textContentHeight: 0
        )
        #expect(singleLine.textEditorHeight == 24)
        #expect(singleLine.contentHeight == 32)
        #expect(singleLine.topPadding == 16)
        #expect(singleLine.boxHeight == 64)
        #expect(singleLine.contentAlignment == .center)
        #expect(!singleLine.exceedsMaximumTextHeight)

        let multiLine = DSChatTypeBox.layoutMetrics(
            specification: specification,
            textContentHeight: 48
        )
        #expect(multiLine.textEditorHeight == 48)
        #expect(multiLine.contentHeight == 48)
        #expect(multiLine.topPadding == 16)
        #expect(multiLine.boxHeight == 80)
        #expect(multiLine.contentAlignment == .bottom)
        #expect(!multiLine.exceedsMaximumTextHeight)

        let maximumHeight = DSChatTypeBox.layoutMetrics(
            specification: specification,
            textContentHeight: 72
        )
        #expect(maximumHeight.textEditorHeight == 72)
        #expect(maximumHeight.contentHeight == 72)
        #expect(maximumHeight.topPadding == 16)
        #expect(maximumHeight.boxHeight == 104)
        #expect(maximumHeight.contentAlignment == .bottom)
        #expect(!maximumHeight.exceedsMaximumTextHeight)

        let overflowing = DSChatTypeBox.layoutMetrics(
            specification: specification,
            textContentHeight: 96
        )
        #expect(overflowing.textEditorHeight == 88)
        #expect(overflowing.contentHeight == 88)
        #expect(overflowing.topPadding == 0)
        #expect(overflowing.boxHeight == 104)
        #expect(overflowing.contentAlignment == .bottom)
        #expect(overflowing.exceedsMaximumTextHeight)
    }

    private func expectCommonSpecification(_ specification: DSChatTypeBox.Specification) {
        #expect(specification.minimumHeight == 64)
        #expect(specification.maximumHeight == 104)
        #expect(specification.shape == .roundedRectangle(cornerRadius: 24))
        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.white)
        expectColorEqual(specification.strokeAsset, DesignSystemAsset.Colors.gray50)
        #expect(specification.strokeWidth == 1)
        #expect(specification.textFont == .body2Regular)
        expectColorEqual(specification.textColor, DesignSystemAsset.Colors.black)
        expectColorEqual(specification.placeholderColor, DesignSystemAsset.Colors.gray500)
        #expect(specification.textLineHeight == 24)
        #expect(specification.textLeadingPadding == 22)
        #expect(specification.textTrailingPadding == 20)
        #expect(specification.textVerticalPadding == 16)
        #expect(specification.sendIcon == .arrowUpward)
        #expect(specification.sendButtonSize == 32)
        #expect(specification.sendIconSize == 24)
        expectColorEqual(specification.shadowColorAsset, DesignSystemAsset.Colors.black)
        #expect(specification.shadowOpacity == 0.06)
        #expect(specification.shadowRadius == 20)
        #expect(specification.shadowOffsetY == 4)
    }
}
