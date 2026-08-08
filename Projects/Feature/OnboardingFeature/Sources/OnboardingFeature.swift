import ComposableArchitecture

@Reducer
public struct OnboardingFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var route: Route = .login
        public var loginPhase: LoginPhase = .idle
        public var onboardingToken: String?
        public var onboardingStep: OnboardingStep = .terms
        public var terms = OnboardingTerm.defaultTerms
        public var selectedTermDetail: OnboardingTerm?
        public var isOnboardingExitConfirmationPresented = false
        public var onboardingName = ""

        public var isAllTermsAgreed: Bool {
            terms.allSatisfy(\.isAgreed)
        }

        public var areRequiredTermsAgreed: Bool {
            terms
                .filter(\.isRequired)
                .allSatisfy(\.isAgreed)
        }

        public var isOnboardingNameValid: Bool {
            onboardingName.count >= 1
                && onboardingName.count <= 10
                && onboardingName.unicodeScalars.allSatisfy { scalar in
                    (0xAC00...0xD7A3).contains(scalar.value)
                }
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
        case onboardingBackButtonTapped
        case debugPreviewButtonTapped(DebugPreview)
    }

    @Dependency(\.authClient) private var authClient
    @Dependency(\.socialLoginClient) private var socialLoginClient
    @Dependency(\.tokenStore) private var tokenStore

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
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

            case let .loginResponse(.success(.newMember(onboardingToken))):
                state.onboardingToken = onboardingToken
                state.route = .onboarding
                state.onboardingStep = .terms
                state.terms = OnboardingTerm.defaultTerms
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
                state.onboardingStep = .terms
                state.terms = OnboardingTerm.defaultTerms
                state.selectedTermDetail = nil
                state.onboardingName = ""
                state.isOnboardingExitConfirmationPresented = false
                return .none

            case let .onboardingNameChanged(name):
                state.onboardingName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                return .none

            case .onboardingNameNextButtonTapped:
                // 운세 정보 입력 단계는 #60의 후속 화면 구현과 함께 연결한다.
                return .none

            case .onboardingBackButtonTapped:
                switch state.onboardingStep {
                case .terms:
                    state.isOnboardingExitConfirmationPresented = true
                case .name:
                    state.onboardingStep = .terms
                }
                return .none

            case .debugPreviewButtonTapped(.newMember):
                state.onboardingToken = nil
                state.onboardingName = ""
                state.route = .onboarding
                state.onboardingStep = .terms
                state.terms = OnboardingTerm.defaultTerms
                state.selectedTermDetail = nil
                return .none

            case .debugPreviewButtonTapped(.existingMember):
                state.onboardingToken = nil
                state.route = .home
                return .none
            }
        }
    }
}

public enum Route: Equatable, Sendable {
    case login
    case onboarding
    case home
}

public enum LoginPhase: Equatable, Sendable {
    case idle
    case authenticating(SocialProvider)
    case authenticatingWithServer
    case savingSession
    case failed(LoginFailure)

    public var isLoading: Bool {
        switch self {
        case .authenticating, .authenticatingWithServer, .savingSession:
            true
        case .idle, .failed:
            false
        }
    }
}

public enum LoginFailure: Equatable, Sendable {
    case socialLogin(SocialLoginError)
    case serverLogin(AuthClientError)
    case tokenStorage(TokenStoreError)

    public var message: String {
        switch self {
        case .socialLogin(.notConfigured):
            "로그인 설정이 아직 준비되지 않았어요. 설정 후 다시 시도해 주세요."
        case .socialLogin(.cancelled):
            "로그인이 취소되었어요."
        case .socialLogin:
            "소셜 로그인을 완료하지 못했어요. 다시 시도해 주세요."
        case .serverLogin(.expired):
            "로그인 정보가 만료되었어요. 다시 로그인해 주세요."
        case .serverLogin(.notConfigured):
            "서버 주소 설정이 필요해요."
        case .serverLogin:
            "서버와 연결하지 못했어요. 잠시 후 다시 시도해 주세요."
        case .tokenStorage:
            "로그인 정보를 안전하게 저장하지 못했어요. 다시 시도해 주세요."
        }
    }
}

public enum DebugPreview: Equatable, Sendable {
    case newMember
    case existingMember
}

public enum OnboardingStep: Equatable, Sendable {
    case terms
    case name
}

public struct OnboardingTerm: Equatable, Identifiable, Sendable {
    // swiftlint:disable:next identifier_name
    public let id: String
    public let title: String
    public let detailURLString: String
    public let isRequired: Bool
    public var isAgreed: Bool

    public init(
        termID: String,
        title: String,
        detailURLString: String,
        isRequired: Bool,
        isAgreed: Bool = false
    ) {
        self.id = termID
        self.title = title
        self.detailURLString = detailURLString
        self.isRequired = isRequired
        self.isAgreed = isAgreed
    }

    // 서버의 약관 목록 API 계약이 확정되면 이 카탈로그를 TermsClient의 응답으로 교체한다.
    public static let defaultTerms = [
        OnboardingTerm(
            termID: "service",
            title: "서비스 이용약관 동의",
            detailURLString: "https://app.notion.com/p/3b081c67484680aca6e5ec1d463c670d?source=copy_link",
            isRequired: true
        ),
        OnboardingTerm(
            termID: "privacy",
            title: "개인정보 수집 및 이용",
            detailURLString: "https://app.notion.com/p/3b081c6748468045a408eb20d27e2342?source=copy_link",
            isRequired: true
        ),
        OnboardingTerm(
            termID: "ai-personal-information-transfer",
            title: "AI 사주 분석을 위한 개인정보 국외 이전 동의",
            detailURLString: "https://app.notion.com/p/AI-3b281c67484680aaad1bf2c384d016e1?source=copy_link",
            isRequired: true
        ),
        OnboardingTerm(
            termID: "marketing",
            title: "마케팅 정보 수신",
            detailURLString: "https://app.notion.com/p/3b281c67484680e1812acb94654fdc31?source=copy_link",
            isRequired: false
        )
    ]
}
