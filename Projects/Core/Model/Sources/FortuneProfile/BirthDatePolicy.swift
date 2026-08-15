import Foundation

public enum BirthDatePolicy: Sendable {
    public static let minimumYear = 1900
    public static let futureDateMessage = "생년월일은 오늘 이전으로 선택해 주세요."
    public static let invalidDateMessage = "생년월일을 다시 확인해 주세요."
    public static let minimumAgeMessage = "토닥운은 만 14세부터 가입할 수 있어요"

    public static func yearRange(
        from minYear: Int = minimumYear,
        asOf referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> ClosedRange<Int> {
        let currentYear = calendar.component(.year, from: referenceDate)
        return minYear...max(minYear, currentYear)
    }

    public static func maximumMonth(
        forYear year: Int,
        asOf referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let currentYear = calendar.component(.year, from: referenceDate)
        if year >= currentYear {
            return calendar.component(.month, from: referenceDate)
        }
        return 12
    }

    public static func maximumDay(
        forYear year: Int,
        month: Int,
        asOf referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let currentYear = calendar.component(.year, from: referenceDate)
        let currentMonth = calendar.component(.month, from: referenceDate)
        let currentDay = calendar.component(.day, from: referenceDate)

        let daysInCurrentMonth = daysInMonth(year: year, month: month, calendar: calendar)

        if year == currentYear && month == currentMonth {
            return min(daysInCurrentMonth, currentDay)
        }
        return daysInCurrentMonth
    }

    public static func daysInMonth(
        year: Int,
        month: Int,
        calendar: Calendar = .current
    ) -> Int {
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        guard let date = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 31
        }
        return range.count
    }

    public static func isLeapYear(_ year: Int) -> Bool {
        (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }

    public static func normalize(
        year: Int,
        month: Int,
        day: Int,
        asOf referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> (month: Int, day: Int) {
        let maxMonth = maximumMonth(forYear: year, asOf: referenceDate, calendar: calendar)
        let normalizedMonth = min(max(month, 1), maxMonth)
        let maxDay = maximumDay(forYear: year, month: normalizedMonth, asOf: referenceDate, calendar: calendar)
        let normalizedDay = min(max(day, 1), maxDay)
        return (normalizedMonth, normalizedDay)
    }

    public static func validateNotInFuture(
        for birthDate: BirthDate?,
        asOf referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> String? {
        guard let birthDate else { return nil }
        guard let date = birthDate.toDate(calendar: calendar) else {
            return invalidDateMessage
        }
        return calendar.startOfDay(for: date) <= calendar.startOfDay(for: referenceDate)
            ? nil
            : futureDateMessage
    }

    public static func validateMinimumAge(
        for birthDate: BirthDate?,
        minimumAge: Int = 14,
        asOf referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> String? {
        guard let birthDate else { return nil }
        guard let dateOfBirth = birthDate.toDate(calendar: calendar) else {
            return invalidDateMessage
        }
        if calendar.startOfDay(for: dateOfBirth) > calendar.startOfDay(for: referenceDate) {
            return futureDateMessage
        }
        guard let eligibleDate = calendar.date(byAdding: .year, value: minimumAge, to: dateOfBirth) else {
            return invalidDateMessage
        }

        return calendar.startOfDay(for: referenceDate) < calendar.startOfDay(for: eligibleDate)
            ? minimumAgeMessage
            : nil
    }
}
