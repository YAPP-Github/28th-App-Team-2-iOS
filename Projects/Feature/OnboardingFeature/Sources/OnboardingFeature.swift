import ComposableArchitecture
import Model

@Reducer
public struct OnboardingFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var route: Route = .login
        public var loginPhase: LoginPhase = .idle
        public var signupPhase: SignupPhase = .idle
        public var onboardingToken: String?
        public var pendingSignupTokens: SessionTokens?
        public var onboardingStep: OnboardingStep = .terms
        public var terms = OnboardingTerm.defaultTerms
        public var selectedTermDetail: OnboardingTerm?
        public var isOnboardingExitConfirmationPresented = false
        public var onboardingName = ""
        public var gender: Gender?
        public var birthDateCalendar: BirthDateCalendar?
        public var birthDate: BirthDate?
        public var birthDateAgeValidationMessage: String?
        public var birthTimePeriod: BirthTimePeriod?
        public var isBirthTimeUnknown = false
        public var dailyRoutine: DailyRoutine?
        public var romanticRelationshipStatus: RomanticRelationshipStatus?

        public var isAllTermsAgreed: Bool {
            terms.allSatisfy(\.isAgreed)
        }

        public var areRequiredTermsAgreed: Bool {
            terms
                .filter(\.isRequired)
                .allSatisfy(\.isAgreed)
        }

        public var isOnboardingNameValid: Bool {
            !onboardingName.isEmpty && onboardingNameValidationMessage == nil
        }

        public var onboardingNameValidationMessage: String? {
            guard onboardingName.count <= 10 else {
                return "이름은 최대 10글자까지 가능해요."
            }
            guard onboardingName.unicodeScalars.allSatisfy({ scalar in
                (0xAC00 ... 0xD7A3).contains(scalar.value)
            }) else {
                return "이름은 한글만 가능해요."
            }
            return nil
        }

        public var isFortuneInformationValid: Bool {
            gender != nil && birthDateCalendar != nil && birthDate != nil
                && birthDateAgeValidationMessage == nil && (birthTimePeriod != nil || isBirthTimeUnknown)
        }

        public var isUserStatusValid: Bool {
            dailyRoutine != nil && romanticRelationshipStatus != nil
        }

        public var isSignupReady: Bool {
            signupInput != nil
        }

        public init() {}
    }

    public enum Action: Equatable {
        case socialLoginButtonTapped(SocialProvider)
        case socialLoginResponse(Result<SocialCredential, SocialLoginError>)
        case loginResponse(Result<AuthLoginResult, AuthClientError>)
        case tokenStorageSucceeded
        case tokenStorageFailed(TokenStoreError)
        case retryButtonTapped
        case allTermsAgreementToggled(Bool)
        case termAgreementToggled(OnboardingTerm.ID, Bool)
        case termDetailButtonTapped(OnboardingTerm.ID)
        case termDetailDismissed
        case termsNextButtonTapped
        case onboardingExitButtonTapped
        case onboardingExitConfirmationDismissed
        case onboardingExitConfirmed
        case onboardingNameChanged(String)
        case onboardingNameNextButtonTapped
        case genderChanged(Gender?)
        case birthDateCalendarChanged(BirthDateCalendar?)
        case birthDateChanged(BirthDate?)
        case birthTimePeriodChanged(BirthTimePeriod?)
        case birthTimeUnknownChanged(Bool)
        case fortuneInformationNextButtonTapped
        case dailyRoutineChanged(DailyRoutine)
        case romanticRelationshipStatusChanged(RomanticRelationshipStatus)
        case userStatusNextButtonTapped
        case signupResponse(Result<SessionTokens, AuthClientError>)
        case signupTokenStorageSucceeded
        case signupTokenStorageFailed(TokenStoreError)
        case notificationAuthorizationResponse(Bool)
        case signupRetryButtonTapped
        case onboardingBackButtonTapped
        case debugPreviewButtonTapped(DebugPreview)
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.date.now) var now
    @Dependency(\.notificationAuthorizationClient) var notificationAuthorizationClient
    @Dependency(\.socialLoginClient) private var socialLoginClient
    @Dependency(\.tokenStore) var tokenStore

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            reduceSocialLogin(into: &state, action: action)
        }
        Reduce { state, action in
            reduceServerSession(into: &state, action: action)
        }
        Reduce { state, action in
            reduceTerms(into: &state, action: action)
        }
        Reduce { state, action in
            reduceName(into: &state, action: action)
        }
        Reduce { state, action in
            reduceFortuneInformation(into: &state, action: action)
        }
        Reduce { state, action in
            reduceUserStatus(into: &state, action: action)
        }
        Reduce { state, action in
            reduceSignup(into: &state, action: action)
        }
        Reduce { state, action in
            reduceSignupRetry(into: &state, action: action)
        }
        Reduce { state, action in
            reduceNavigation(into: &state, action: action)
        }
        Reduce { state, action in
            reduceBackNavigation(into: &state, action: action)
        }
    }
}

private extension OnboardingFeature {
    func reduceSocialLogin(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .socialLoginButtonTapped(provider):
            state.loginPhase = .authenticating(provider)

            return .run { send in
                await send(
                    .socialLoginResponse(
                        Result { try await socialLoginClient.signIn(provider) }
                            .mapError(SocialLoginError.init)
                    )
                )
            }

        case let .socialLoginResponse(.success(credential)):
            state.loginPhase = .authenticatingWithServer

            return .run { send in
                await send(
                    .loginResponse(
                        Result { try await authClient.login(credential) }
                            .mapError(AuthClientError.init)
                    )
                )
            }

        case .socialLoginResponse(.failure(.cancelled)):
            state.loginPhase = .idle
            return .none

        case let .socialLoginResponse(.failure(error)):
            state.loginPhase = .failed(.socialLogin(error))
            return .none

        default:
            return .none
        }
    }

    func reduceServerSession(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .loginResponse(.success(.newMember(onboardingToken))):
            state.onboardingToken = onboardingToken
            state.pendingSignupTokens = nil
            state.signupPhase = .idle
            state.route = .onboarding
            state.onboardingStep = .terms
            state.terms = OnboardingTerm.defaultTerms
            state.selectedTermDetail = nil
            state.onboardingName = ""
            state.gender = nil
            state.birthDateCalendar = nil
            state.birthDate = nil
            state.birthDateAgeValidationMessage = nil
            state.birthTimePeriod = nil
            state.isBirthTimeUnknown = false
            state.dailyRoutine = nil
            state.romanticRelationshipStatus = nil
            state.loginPhase = .idle
            return .none

        case let .loginResponse(.success(.existingMember(tokens))):
            state.loginPhase = .savingSession

            return .run { send in
                do {
                    try tokenStore.save(tokens)
                    await send(.tokenStorageSucceeded)
                } catch {
                    await send(.tokenStorageFailed(TokenStoreError(error)))
                }
            }

        case let .loginResponse(.failure(error)):
            state.loginPhase = .failed(.serverLogin(error))
            return .none

        case .tokenStorageSucceeded:
            state.route = .home
            state.loginPhase = .idle
            return .none

        case let .tokenStorageFailed(error):
            state.loginPhase = .failed(.tokenStorage(error))
            return .none

        case .retryButtonTapped:
            state.loginPhase = .idle
            return .none

        default:
            return .none
        }
    }

    func reduceTerms(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .allTermsAgreementToggled(isAgreed):
            state.terms = state.terms.map { term in
                var updatedTerm = term
                updatedTerm.isAgreed = isAgreed
                return updatedTerm
            }
            return .none

        case let .termAgreementToggled(termID, isAgreed):
            guard let index = state.terms.firstIndex(where: { $0.id == termID }) else {
                return .none
            }
            state.terms[index].isAgreed = isAgreed
            return .none

        case let .termDetailButtonTapped(termID):
            state.selectedTermDetail = state.terms.first(where: { $0.id == termID })
            return .none

        case .termDetailDismissed:
            state.selectedTermDetail = nil
            return .none

        case .termsNextButtonTapped:
            guard state.areRequiredTermsAgreed else { return .none }
            state.onboardingStep = .name
            return .none

        default:
            return .none
        }
    }

    func reduceName(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .onboardingNameChanged(name):
            state.onboardingName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            return .none

        case .onboardingNameNextButtonTapped:
            guard state.isOnboardingNameValid else { return .none }
            state.onboardingStep = .fortuneInformation
            return .none

        default:
            return .none
        }
    }

    func reduceUserStatus(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .dailyRoutineChanged(routine):
            state.dailyRoutine = routine
            return .none

        case let .romanticRelationshipStatusChanged(status):
            state.romanticRelationshipStatus = status
            return .none

        default:
            return .none
        }
    }

    func reduceNavigation(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onboardingExitButtonTapped:
            state.isOnboardingExitConfirmationPresented = true
            return .none

        case .onboardingExitConfirmationDismissed:
            state.isOnboardingExitConfirmationPresented = false
            return .none

        case .onboardingExitConfirmed:
            // 임시 회원 삭제 API와 소셜 제공자 세션 해제 정책은 서버 계약 확인 후 연결한다.
            // 여기서는 앱에만 보관된 온보딩 상태를 폐기한다.
            state.route = .login
            state.onboardingToken = nil
            state.pendingSignupTokens = nil
            state.signupPhase = .idle
            state.onboardingStep = .terms
            state.terms = OnboardingTerm.defaultTerms
            state.selectedTermDetail = nil
            state.onboardingName = ""
            state.gender = nil
            state.birthDateCalendar = nil
            state.birthDate = nil
            state.birthDateAgeValidationMessage = nil
            state.birthTimePeriod = nil
            state.isBirthTimeUnknown = false
            state.dailyRoutine = nil
            state.romanticRelationshipStatus = nil
            state.isOnboardingExitConfirmationPresented = false
            return .none

        case .debugPreviewButtonTapped(.newMember):
            state.onboardingToken = nil
            state.pendingSignupTokens = nil
            state.signupPhase = .idle
            state.onboardingName = ""
            state.gender = nil
            state.birthDateCalendar = nil
            state.birthDate = nil
            state.birthDateAgeValidationMessage = nil
            state.birthTimePeriod = nil
            state.isBirthTimeUnknown = false
            state.dailyRoutine = nil
            state.romanticRelationshipStatus = nil
            state.route = .onboarding
            state.onboardingStep = .terms
            state.terms = OnboardingTerm.defaultTerms
            state.selectedTermDetail = nil
            return .none

        case .debugPreviewButtonTapped(.existingMember):
            state.onboardingToken = nil
            state.route = .home
            return .none

        case .debugPreviewButtonTapped(.signupLoading):
            state.pendingSignupTokens = nil
            state.route = .onboarding
            state.onboardingStep = .userStatus
            state.signupPhase = .signingUp
            return .none

        default:
            return .none
        }
    }

    func reduceBackNavigation(into state: inout State, action: Action) -> Effect<Action> {
        guard case .onboardingBackButtonTapped = action else { return .none }

        switch state.onboardingStep {
        case .terms:
            state.isOnboardingExitConfirmationPresented = true
        case .name:
            state.onboardingStep = .terms
        case .fortuneInformation:
            state.onboardingStep = .name
        case .userStatus:
            state.onboardingStep = .fortuneInformation
        }
        return .none
    }

}
