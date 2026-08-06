import Testing
import Model
@testable import DesignSystem

struct DSLunarSolarSpecificationTests {
    @Test("Select Lunar or Solar Calendar 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSSelectLunarOrSolarCalendar.specification()

        #expect(specification.contentSpacing == 16)
        #expect(specification.optionSpacing == 12)
        #expect(specification.labelFontStyle == .body1Bold)
        expectColorEqual(
            specification.labelForegroundAsset,
            DesignSystemAsset.Colors.black
        )
    }

    @Test("Select Lunar or Solar Calendar 단일 선택과 재탭 유지 검증")
    func testSelectionResolution() {
        #expect(
            DSSelectLunarOrSolarCalendar.resolvedSelection(
                current: nil,
                option: .solar,
                isSelected: true
            ) == .solar
        )
        #expect(
            DSSelectLunarOrSolarCalendar.resolvedSelection(
                current: .solar,
                option: .lunar,
                isSelected: true
            ) == .lunar
        )
        #expect(
            DSSelectLunarOrSolarCalendar.resolvedSelection(
                current: .lunar,
                option: .lunar,
                isSelected: false
            ) == .lunar
        )
        #expect(BirthDateCalendar.solar.dsCalendarTitle == "양력")
        #expect(BirthDateCalendar.lunar.dsCalendarTitle == "음력")
    }
}
