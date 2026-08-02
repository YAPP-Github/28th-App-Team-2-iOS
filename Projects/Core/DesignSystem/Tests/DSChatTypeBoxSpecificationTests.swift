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

    private func expectCommonSpecification(_ specification: DSChatTypeBox.Specification) {
        #expect(specification.minimumHeight == 64)
        #expect(specification.maximumHeight == 104)
        #expect(specification.shape == .roundedRectangle(cornerRadius: 24))
        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.white)
        expectColorEqual(specification.strokeAsset, DesignSystemAsset.Colors.gray50)
        #expect(specification.strokeWidth == 1)
        #expect(specification.textFont == .body2Regular)
        expectColorEqual(specification.textColor, DesignSystemAsset.Colors.black)
        expectColorEqual(specification.placeholderColor, DesignSystemAsset.Colors.gray400)
        #expect(specification.textLineHeight == 24)
        #expect(specification.textLeadingPadding == 22)
        #expect(specification.textTrailingPadding == 20)
        #expect(specification.textVerticalPadding == 16)
        #expect(specification.sendButtonSize == 32)
        #expect(specification.sendIconSize == 24)
        expectColorEqual(specification.shadowColorAsset, DesignSystemAsset.Colors.black)
        #expect(specification.shadowOpacity == 0.06)
        #expect(specification.shadowRadius == 20)
        #expect(specification.shadowOffsetY == 4)
    }
}
