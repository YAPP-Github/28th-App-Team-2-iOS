import SwiftUI
import Testing
import Model
@testable import DesignSystem

struct DSSajuBasicFieldsViewTests {
    @Test("DSSajuBasicFieldsView 초기화 및 뷰 계층 구성 검증")
    func testDSSajuBasicFieldsViewInitialization() {
        var gender: Gender? = .female
        var calendarType: BirthDateCalendar? = .solar
        var birthDate: BirthDate? = BirthDate(year: 1995, month: 5, day: 20)
        var birthTime: BirthTimePeriod? = .saTime
        var isBirthTimeUnknown = false

        let view = DSSajuBasicFieldsView(
            gender: Binding(get: { gender }, set: { gender = $0 }),
            calendarType: Binding(get: { calendarType }, set: { calendarType = $0 }),
            birthDate: Binding(get: { birthDate }, set: { birthDate = $0 }),
            birthTime: Binding(get: { birthTime }, set: { birthTime = $0 }),
            isBirthTimeUnknown: Binding(get: { isBirthTimeUnknown }, set: { isBirthTimeUnknown = $0 }),
            birthDateValidationMessage: "생년월일 에러",
            unknownTimeInfoText: "시간 안내",
            spacing: 24
        )

        #expect(gender == .female)
        #expect(calendarType == .solar)
        #expect(birthDate?.year == 1995)
        #expect(birthTime == .saTime)
        #expect(!isBirthTimeUnknown)
    }
}
