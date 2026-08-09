import Foundation
import Model

enum OnboardingMinimumAgePolicy {
    static let minimumAgeMessage = "토닥운은 만 14세부터 가입할 수 있어요"

    static func validationMessage(
        for birthDate: BirthDate?,
        asOf referenceDate: Date
    ) -> String? {
        guard let birthDate else { return nil }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent

        guard
            let dateOfBirth = calendar.date(
                from: DateComponents(
                    year: birthDate.year,
                    month: birthDate.month,
                    day: birthDate.day
                )
            ),
            let eligibleDate = calendar.date(
                byAdding: .year,
                value: 14,
                to: dateOfBirth
            )
        else {
            return "생년월일을 다시 확인해 주세요."
        }

        return calendar.startOfDay(for: referenceDate) < calendar.startOfDay(for: eligibleDate)
            ? minimumAgeMessage
            : nil
    }
}
