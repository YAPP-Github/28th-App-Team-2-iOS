import Foundation
import Model

enum PartnerBirthDatePolicy {
    static let futureDateMessage = "생년월일은 오늘 이전으로 선택해 주세요."

    static func validationMessage(for birthDate: BirthDate?, asOf referenceDate: Date) -> String? {
        guard let birthDate else { return nil }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent
        guard let date = calendar.date(
            from: DateComponents(year: birthDate.year, month: birthDate.month, day: birthDate.day)
        ) else {
            return "생년월일을 다시 확인해 주세요."
        }

        return calendar.startOfDay(for: date) < calendar.startOfDay(for: referenceDate)
            ? nil
            : futureDateMessage
    }
}
