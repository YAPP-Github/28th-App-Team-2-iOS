import Testing
import Model
@testable import DesignSystem

struct DSEnterDateOfBirthSpecificationTests {
    @Test("Enter Date of Birth 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSEnterDateOfBirth.specification()

        #expect(specification.contentSpacing == 16)
        #expect(specification.labelFontStyle == .body1Bold)
        expectColorEqual(
            specification.labelForegroundAsset,
            DesignSystemAsset.Colors.black
        )
    }

    @Test("Enter Date of Birth 모델 표시 문자열 검증")
    func testDisplayTitle() {
        #expect(DSEnterDateOfBirth.displayTitle(for: nil) == nil)
        #expect(
            DSEnterDateOfBirth.displayTitle(
                for: BirthDate(year: 1999, month: 2, day: 13)
            ) == "1999년 2월 13일"
        )
    }

    @Test("Enter Date of Birth 표시 binding clear 전달 검증")
    func testSelectionResolution() {
        let birthDate = BirthDate(year: 1999, month: 2, day: 13)

        #expect(
            DSEnterDateOfBirth.resolvedSelection(
                current: birthDate,
                displayValue: "1999년 2월 13일"
            ) == birthDate
        )
        #expect(
            DSEnterDateOfBirth.resolvedSelection(
                current: birthDate,
                displayValue: nil
            ) == nil
        )
    }
}
