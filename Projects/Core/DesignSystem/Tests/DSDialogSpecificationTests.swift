import Testing
@testable import DesignSystem

struct DSDialogSpecificationTests {
    @Test("Dialog 스펙 매핑 검증", arguments: [
        (hasMessage: true, hasSecondaryAction: false),
        (hasMessage: true, hasSecondaryAction: true),
        (hasMessage: false, hasSecondaryAction: false),
        (hasMessage: false, hasSecondaryAction: true)
    ])
    func testSpecification(hasMessage: Bool, hasSecondaryAction: Bool) {
        let specification = DSDialog.specification(
            hasMessage: hasMessage,
            hasSecondaryAction: hasSecondaryAction
        )

        #expect(specification.width == 280)
        #expect(specification.contentHorizontalPadding == 20)
        #expect(specification.contentTopPadding == 20)
        #expect(specification.titleFont == .body2SemiBold)
        expectColorEqual(specification.titleColor, DesignSystemAsset.Colors.gray975)
        #expect(specification.actionTopPadding == 20)
        #expect(specification.actionBottomPadding == 20)
        #expect(specification.shape == .roundedRectangle(cornerRadius: 12))
        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.white)

        #expect(specification.messageFont == (hasMessage ? .body3Regular : nil))
        if hasMessage {
            expectColorEqual(specification.messageColor, DesignSystemAsset.Colors.gray800)
        } else {
            #expect(specification.messageColor == nil)
        }
        #expect(specification.titleMessageSpacing == (hasMessage ? 4 : nil))
        #expect(specification.actionSpacing == (hasSecondaryAction ? 8 : nil))

        #expect(specification.actionButtonSize == .medium)
        #expect(specification.actionButtonFontStyle == .body3SemiBold)
    }
}
