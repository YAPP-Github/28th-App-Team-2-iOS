import Foundation
import Testing
@testable import Model

struct BirthDatePolicyTests {
    private var testCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private var referenceDate: Date {
        let components = DateComponents(year: 2026, month: 8, day: 15)
        return testCalendar.date(from: components)!
    }

    @Test("윤년 2월은 29일까지이고 평년 2월은 28일까지이다")
    func testDaysInMonthForFebruary() {
        #expect(BirthDatePolicy.daysInMonth(year: 2024, month: 2, calendar: testCalendar) == 29)
        #expect(BirthDatePolicy.daysInMonth(year: 2023, month: 2, calendar: testCalendar) == 28)
        #expect(BirthDatePolicy.daysInMonth(year: 2000, month: 2, calendar: testCalendar) == 29)
        #expect(BirthDatePolicy.daysInMonth(year: 1900, month: 2, calendar: testCalendar) == 28)
    }

    @Test("현재 연도 선택 시 현재 월 및 일자를 초과할 수 없다")
    func testMaximumMonthAndDayForCurrentYear() {
        #expect(BirthDatePolicy.maximumMonth(forYear: 2026, asOf: referenceDate, calendar: testCalendar) == 8)
        #expect(BirthDatePolicy.maximumMonth(forYear: 2025, asOf: referenceDate, calendar: testCalendar) == 12)

        #expect(BirthDatePolicy.maximumDay(forYear: 2026, month: 8, asOf: referenceDate, calendar: testCalendar) == 15)
        #expect(BirthDatePolicy.maximumDay(forYear: 2026, month: 7, asOf: referenceDate, calendar: testCalendar) == 31)
    }

    @Test("정규화 로직은 31일이 없는 달의 일수를 올바르게 보정한다")
    func testNormalizeAdjustsInvalidDay() {
        let (month1, day1) = BirthDatePolicy.normalize(
            year: 2024,
            month: 2,
            day: 31,
            asOf: referenceDate,
            calendar: testCalendar
        )
        #expect(month1 == 2)
        #expect(day1 == 29)

        let (month2, day2) = BirthDatePolicy.normalize(
            year: 2023,
            month: 2,
            day: 31,
            asOf: referenceDate,
            calendar: testCalendar
        )
        #expect(month2 == 2)
        #expect(day2 == 28)

        let (month3, day3) = BirthDatePolicy.normalize(
            year: 2026,
            month: 8,
            day: 20,
            asOf: referenceDate,
            calendar: testCalendar
        )
        #expect(month3 == 8)
        #expect(day3 == 15)
    }

    @Test("연도 선택 범위 검증")
    func testYearRange() {
        let range = BirthDatePolicy.yearRange(from: 1900, asOf: referenceDate, calendar: testCalendar)
        #expect(range.lowerBound == 1900)
        #expect(range.upperBound == 2026)
    }

    @Test("미래 날짜 유효성 검증")
    func testValidateNotInFuture() {
        #expect(BirthDatePolicy.validateNotInFuture(for: nil, asOf: referenceDate, calendar: testCalendar) == nil)

        let validDate = BirthDate(year: 2026, month: 8, day: 14)
        #expect(BirthDatePolicy.validateNotInFuture(for: validDate, asOf: referenceDate, calendar: testCalendar) == nil)

        let todayDate = BirthDate(year: 2026, month: 8, day: 15)
        #expect(BirthDatePolicy.validateNotInFuture(for: todayDate, asOf: referenceDate, calendar: testCalendar) == nil)

        let futureDate = BirthDate(year: 2026, month: 8, day: 16)
        #expect(
            BirthDatePolicy.validateNotInFuture(for: futureDate, asOf: referenceDate, calendar: testCalendar)
                == BirthDatePolicy.futureDateMessage
        )

        let invalidDate = BirthDate(year: 2023, month: 2, day: 29)
        #expect(
            BirthDatePolicy.validateNotInFuture(for: invalidDate, asOf: referenceDate, calendar: testCalendar)
                == BirthDatePolicy.invalidDateMessage
        )
    }

    @Test("만 14세 미만 유효성 검증")
    func testValidateMinimumAge() {
        #expect(
            BirthDatePolicy.validateMinimumAge(for: nil, minimumAge: 14, asOf: referenceDate, calendar: testCalendar)
                == nil
        )

        let eligibleDate = BirthDate(year: 2012, month: 8, day: 15)
        #expect(
            BirthDatePolicy.validateMinimumAge(
                for: eligibleDate, minimumAge: 14, asOf: referenceDate, calendar: testCalendar
            )
                == nil
        )

        let underAgeDate = BirthDate(year: 2012, month: 8, day: 16)
        #expect(
            BirthDatePolicy.validateMinimumAge(
                for: underAgeDate, minimumAge: 14, asOf: referenceDate, calendar: testCalendar
            )
                == BirthDatePolicy.minimumAgeMessage
        )

        let futureDate = BirthDate(year: 2027, month: 1, day: 1)
        #expect(
            BirthDatePolicy.validateMinimumAge(
                for: futureDate, minimumAge: 14, asOf: referenceDate, calendar: testCalendar
            )
                == BirthDatePolicy.futureDateMessage
        )
    }

    @Test("BirthDate Date 변환 및 Comparable 검증")
    func testBirthDateConversionAndComparison() {
        let birthDate = BirthDate(year: 1995, month: 5, day: 20)
        let convertedDate = birthDate.toDate(calendar: testCalendar)
        #expect(convertedDate != nil)

        let backToBirthDate = BirthDate(date: convertedDate!, calendar: testCalendar)
        #expect(backToBirthDate == birthDate)

        let older = BirthDate(year: 1990, month: 1, day: 1)
        let younger = BirthDate(year: 2000, month: 1, day: 1)
        #expect(older < younger)
        #expect(birthDate.description == "1995-05-20")
        #expect(birthDate.formattedDate == "1995-05-20")

        let invalidDate = BirthDate(year: 2024, month: 2, day: 31)
        #expect(invalidDate.toDate(calendar: testCalendar) == nil)

        let parsed = BirthDate(yyyyMMdd: "1999-12-31")
        #expect(parsed == BirthDate(year: 1999, month: 12, day: 31))
        #expect(BirthDate(yyyyMMdd: "invalid") == nil)
    }

    @Test("Gender 및 BirthDateCalendar 메타데이터 검증")
    func testGenderAndCalendarMetadata() {
        #expect(Gender.male.title == "남성")
        #expect(Gender.female.title == "여성")
        #expect(Gender.male.apiValue == "MALE")
        #expect(Gender.female.apiValue == "FEMALE")

        #expect(BirthDateCalendar.solar.title == "양력")
        #expect(BirthDateCalendar.lunar.title == "음력")
        #expect(BirthDateCalendar.solar.apiValue == "SOLAR")
        #expect(BirthDateCalendar.lunar.apiValue == "LUNAR")
    }
}
