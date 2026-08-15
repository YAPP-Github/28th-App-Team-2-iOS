import Foundation
import Model

enum OnboardingMinimumAgePolicy {
    static var minimumAgeMessage: String { BirthDatePolicy.minimumAgeMessage }

    static func validationMessage(
        for birthDate: BirthDate?,
        asOf referenceDate: Date
    ) -> String? {
        BirthDatePolicy.validateMinimumAge(for: birthDate, minimumAge: 14, asOf: referenceDate)
    }
}
