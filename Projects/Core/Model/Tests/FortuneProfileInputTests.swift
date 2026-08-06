import Testing
@testable import Model

struct FortuneProfileInputTests {
    @Test("입력 선택 모델의 항목 순서 검증")
    func testSelectionCases() {
        #expect(Gender.allCases == [.male, .female])
        #expect(Relationship.allCases == [.partner, .friend, .colleague])
        #expect(BirthDateCalendar.allCases == [.solar, .lunar])
        #expect(
            BirthTimePeriod.allCases == [
                .jaTime, .chukTime, .inTime, .myoTime, .jinTime, .saTime,
                .oTime, .miTime, .sinTime, .yuTime, .sulTime, .haeTime
            ]
        )
    }

    @Test("생년월일 값 보존 검증")
    func testBirthDate() {
        let birthDate = BirthDate(year: 1999, month: 2, day: 13)

        #expect(birthDate.year == 1999)
        #expect(birthDate.month == 2)
        #expect(birthDate.day == 13)
    }

    @Test("출생 시간 구간 경계 검증")
    func testBirthTimePeriodBoundaries() {
        #expect(BirthTimePeriod.jaTime.startHour == 23)
        #expect(BirthTimePeriod.jaTime.startMinute == 30)
        #expect(BirthTimePeriod.jaTime.endHour == 1)
        #expect(BirthTimePeriod.jaTime.endMinute == 29)

        #expect(BirthTimePeriod.inTime.startHour == 3)
        #expect(BirthTimePeriod.inTime.endHour == 5)

        #expect(BirthTimePeriod.haeTime.startHour == 21)
        #expect(BirthTimePeriod.haeTime.endHour == 23)
    }
}
