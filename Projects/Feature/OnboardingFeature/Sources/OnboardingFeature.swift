import ComposableArchitecture

@Reducer
public struct OnboardingFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var route: Route = .login
        public var loginPhase: LoginPhase = .idle
        public var onboardingToken: String?

        public init() {}
    }

    public enum Action: Equatable {
        case socialLoginButtonTapped(SocialProvider)
        case socialLoginResponse(Result<SocialCredential, SocialLoginError>)
        case loginResponse(Result<AuthLoginResult, AuthClientError>)
        case tokenStorageSucceeded
        case tokenStorageFailed(TokenStoreError)
        case retryButtonTapped
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

            case .debugPreviewButtonTapped(.newMember):
                state.onboardingToken = nil
                state.route = .onboarding
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
