import AuthSession
import ComposableArchitecture
import Foundation
import Model

extension OnboardingFeature {
    // The explicit action cases intentionally guard every asynchronous transition.
    // swiftlint:disable:next cyclomatic_complexity
    func reduceSignup(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .userStatusNextButtonTapped:
            guard !state.signupPhase.isLoading,
                  let input = state.signupInput else { return .none }

            state.signupPhase = .signingUp
            return signupEffect(input)

        case let .signupResponse(.success(tokens)):
            guard state.signupPhase == .signingUp else { return .none }
            state.pendingSignupTokens = tokens
            state.signupPhase = .savingSession
            return saveSignupTokensEffect(tokens)

        case let .signupResponse(.failure(error)):
            guard state.signupPhase == .signingUp else { return .none }

            if error == .expired {
                state.onboardingToken = nil
                state.pendingSignupTokens = nil
                state.signupPhase = .idle
                state.isSignupExpirationDialogPresented = true
                return .none
            }

            state.signupPhase = .failed(.signup(error))
            return .none

        case .signupExpirationDialogConfirmed:
            guard state.isSignupExpirationDialogPresented else { return .none }

            state.discardOnboardingState()
            state.route = .login
            return .none

        case .signupTokenStorageSucceeded:
            guard state.signupPhase == .savingSession else { return .none }
            state.pendingSignupTokens = nil
            state.onboardingToken = nil
            state.signupPhase = .requestingNotificationAuthorization
            return requestNotificationAuthorizationEffect()

        case .notificationAuthorizationResponse:
            guard state.signupPhase == .requestingNotificationAuthorization else { return .none }
            state.signupPhase = .idle
            state.route = .home
            return .send(.delegate(.authenticationCompleted))

        case let .signupTokenStorageFailed(error):
            guard state.signupPhase == .savingSession else { return .none }
            state.signupPhase = .failed(.tokenStorage(error))
            return .none

        default:
            return .none
        }
    }

    func reduceSignupRetry(into state: inout State, action: Action) -> Effect<Action> {
        guard case .signupRetryButtonTapped = action,
              case .failed = state.signupPhase else { return .none }

        if let pendingSignupTokens = state.pendingSignupTokens {
            state.signupPhase = .savingSession
            return saveSignupTokensEffect(pendingSignupTokens)
        }

        guard let input = state.signupInput else { return .none }
        state.signupPhase = .signingUp
        return signupEffect(input)
    }

    func signupEffect(_ input: SignupInput) -> Effect<Action> {
        .run { send in
            await send(
                .signupResponse(
                    Result { try await authClient.signup(input) }
                        .mapError(AuthClientError.init)
                )
            )
        }
        .cancellable(id: OnboardingCancelID.signup)
    }

    func saveSignupTokensEffect(_ tokens: SessionTokens) -> Effect<Action> {
        .run { send in
            do {
                try await authSession.save(tokens)
                await send(.signupTokenStorageSucceeded)
            } catch {
                await send(.signupTokenStorageFailed(AuthSessionError(error, fallback: .saveFailed)))
            }
        }
        .cancellable(id: OnboardingCancelID.signup)
    }

    func requestNotificationAuthorizationEffect() -> Effect<Action> {
        .run { send in
            await send(
                .notificationAuthorizationResponse(
                    await notificationAuthorizationClient.requestAuthorization()
                )
            )
        }
        .cancellable(id: OnboardingCancelID.signup)
    }
}

extension OnboardingFeature.State {
    mutating func discardOnboardingState() {
        onboardingToken = nil
        pendingSignupTokens = nil
        signupPhase = .idle
        onboardingStep = .terms
        terms = OnboardingTerm.defaultTerms
        selectedTermDetail = nil
        isSignupExpirationDialogPresented = false
        isOnboardingExitConfirmationPresented = false
        onboardingName = ""
        gender = nil
        birthDateCalendar = nil
        birthDate = nil
        birthDateAgeValidationMessage = nil
        birthTimePeriod = nil
        isBirthTimeUnknown = false
        dailyRoutine = nil
        romanticRelationshipStatus = nil
    }

    public var signupInput: SignupInput? {
        guard let onboardingToken,
              !onboardingToken.isEmpty,
              isOnboardingNameValid,
              isFortuneInformationValid,
              isUserStatusValid,
              let gender,
              let birthDateCalendar,
              let birthDate,
              let dailyRoutine,
              let romanticRelationshipStatus else {
            return nil
        }

        let birthTime = isBirthTimeUnknown ? "UNKNOWN" : birthTimePeriod?.apiValue
        guard let birthTime else { return nil }

        return SignupInput(
            onboardingToken: onboardingToken,
            name: onboardingName,
            birthDate: String(format: "%04d-%02d-%02d", birthDate.year, birthDate.month, birthDate.day),
            birthTime: birthTime,
            calendarType: birthDateCalendar.signupValue,
            gender: gender.signupValue,
            job: dailyRoutine.signupValue,
            relationshipStatus: romanticRelationshipStatus.signupValue
        )
    }
}

private extension Gender {
    var signupValue: String {
        switch self {
        case .male: "MALE"
        case .female: "FEMALE"
        }
    }
}

private extension BirthDateCalendar {
    var signupValue: String {
        switch self {
        case .solar: "SOLAR"
        case .lunar: "LUNAR"
        }
    }
}

private extension DailyRoutine {
    var signupValue: String {
        switch self {
        case .student: "STUDENT"
        case .jobSeeking: "JOBSEEKER"
        case .employed: "WORKER"
        case .selfEmployedOrFreelance: "FREELANCER"
        case .homemaker: "HOMEMAKER"
        case .leaveOrRetirement: "LEAVER"
        }
    }
}

private extension RomanticRelationshipStatus {
    var signupValue: String {
        switch self {
        case .single: "SOLO"
        case .dating: "DATING"
        case .married: "MARRY"
        case .divorced: "REMARRY"
        }
    }
}
