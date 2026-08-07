import Testing
@testable import DesignSystem

struct DSTodakExampleQuestionSpecificationTests {
    @Test("Todak Example Question 콘텐츠 구간의 Bold 상태 검증")
    func testSegmentEmphasis() {
        let regular = DSTodakExampleQuestion.Segment("일반 문구")
        let bold = DSTodakExampleQuestion.Segment("강조 문구", isBold: true)

        #expect(regular.text == "일반 문구")
        #expect(regular.isBold == false)
        #expect(bold.text == "강조 문구")
        #expect(bold.isBold == true)
    }

    @Test("Todak Example Question 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSTodakExampleQuestion.specification

        #expect(specification.height == 48)
        #expect(specification.shape == .roundedRectangle(cornerRadius: 12))
        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.primary50)
        #expect(specification.fontStyle == .body2Regular)
        expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.coolGray800)
        #expect(specification.emphasizedFontStyle == .body2SemiBold)
        expectColorEqual(specification.emphasizedForegroundAsset, DesignSystemAsset.Colors.coolGray900)
        #expect(specification.horizontalPadding == 18)
        #expect(specification.verticalPadding == 12)
    }
}
