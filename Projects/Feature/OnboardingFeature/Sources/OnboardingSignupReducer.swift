import ComposableArchitecture
import Foundation
import Model

extension OnboardingFeature {
    func reduceSignup(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .userStatusNextButtonTapped:
            guard !state.signupPhase.isLoading,
                  let input = state.signupInput else { return .none }

            state.signupPhase = .signingUp
            return signupEffect(input)

        case let .signupResponse(.success(tokens)):
            state.pendingSignupTokens = tokens
            state.signupPhase = .savingSession
            return saveSignupTokensEffect(tokens)

        case let .signupResponse(.failure(error)):
            state.signupPhase = .failed(.signup(error))
            return .none

        case .signupTokenStorageSucceeded:
            state.pendingSignupTokens = nil
            state.onboardingToken = nil
            state.signupPhase = .idle
            state.route = .home
            return .none

        case .signupTokenStorageFailed:
            state.signupPhase = .failed(.tokenStorage)
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
    }

    func saveSignupTokensEffect(_ tokens: SessionTokens) -> Effect<Action> {
        .run { send in
            do {
                try tokenStore.save(tokens)
                await send(.signupTokenStorageSucceeded)
            } catch {
                await send(.signupTokenStorageFailed(TokenStoreError(error)))
            }
        }
    }
}

extension OnboardingFeature.State {
    public var signupInput: SignupInput? {
        guard let onboardingToken,
              !onboardingToken.isEmpty,
              isOnboardingNameValid,
              let gender,
              let birthDateCalendar,
              let birthDate,
              let dailyRoutine,
              let romanticRelationshipStatus else {
            return nil
        }

        let birthTime = isBirthTimeUnknown ? "UNKNOWN" : birthTimePeriod?.signupValue
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

private extension BirthTimePeriod {
    var signupValue: String {
        switch self {
        case .jaTime: "JASI"
        case .chukTime: "CHUKSI"
        case .inTime: "INSI"
        case .myoTime: "MYOSI"
        case .jinTime: "JINSI"
        case .saTime: "SASI"
        case .oTime: "OSI"
        case .miTime: "MISI"
        case .sinTime: "SINSI"
        case .yuTime: "YUSI"
        case .sulTime: "SULSI"
        case .haeTime: "HAESI"
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
