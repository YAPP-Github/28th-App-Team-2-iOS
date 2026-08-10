import ComposableArchitecture

extension OnboardingFeature {
    func reduceFortuneInformation(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch action {
        case let .genderChanged(gender):
            state.gender = gender
            return .none

        case let .birthDateCalendarChanged(calendar):
            state.birthDateCalendar = calendar
            return .none

        case let .birthDateChanged(birthDate):
            state.birthDate = birthDate
            state.birthDateAgeValidationMessage = OnboardingMinimumAgePolicy
                .validationMessage(for: birthDate, asOf: now)
            return .none

        case let .birthTimePeriodChanged(period):
            state.birthTimePeriod = period
            if period != nil {
                state.isBirthTimeUnknown = false
            }
            return .none

        case let .birthTimeUnknownChanged(isUnknown):
            state.isBirthTimeUnknown = isUnknown
            if isUnknown {
                state.birthTimePeriod = nil
            }
            return .none

        case .fortuneInformationNextButtonTapped:
            state.birthDateAgeValidationMessage = OnboardingMinimumAgePolicy
                .validationMessage(for: state.birthDate, asOf: now)
            guard state.isFortuneInformationValid else { return .none }
            state.onboardingStep = .userStatus
            return .none

        default:
            return .none
        }
    }
}
