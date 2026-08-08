import Testing
import Model
@testable import DesignSystem

struct DSSelectGenderSpecificationTests {
    @Test("Select Gender 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSSelectGender.specification()

        #expect(specification.contentSpacing == 16)
        #expect(specification.optionSpacing == 12)
        #expect(specification.labelFontStyle == .body1Bold)
        expectColorEqual(
            specification.labelForegroundAsset,
            DesignSystemAsset.Colors.black
        )
    }

    @Test("Select Gender 단일 선택과 재탭 유지 검증")
    func testSelectionResolution() {
        #expect(
            DSSelectGender.resolvedSelection(
                current: nil,
                option: .male,
                isSelected: true
            ) == .male
        )
        #expect(
            DSSelectGender.resolvedSelection(
                current: .male,
                option: .female,
                isSelected: true
            ) == .female
        )
        #expect(
            DSSelectGender.resolvedSelection(
                current: .male,
                option: .male,
                isSelected: false
            ) == .male
        )
        #expect(Gender.male.dsGenderTitle == "남성")
        #expect(Gender.female.dsGenderTitle == "여성")
    }
}
