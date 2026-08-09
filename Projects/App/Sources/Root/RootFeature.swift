import AuthSession
import ComposableArchitecture
import OnboardingFeature

@Reducer
struct RootFeature {
    @ObservableState
    struct State: Equatable {
        var route: Route = .launching
        var onboarding = OnboardingFeature.State()
    }

    enum Route: Equatable {
        case launching
        case unauthenticated
        case authenticated
    }

    enum Action: Equatable {
        case task
        case sessionRestored(Result<Bool, AuthSessionError>)
        case onboarding(OnboardingFeature.Action)
    }

    @Dependency(\.authSession) private var authSession

    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }

        Reduce { state, action in
            switch action {
            case .task:
                guard state.route == .launching else { return .none }
                return .run { send in
                    await send(
                        .sessionRestored(
                            Result { try await authSession.restore() }
                                .mapError { AuthSessionError($0, fallback: .loadFailed) }
                        )
                    )
                }

            case let .sessionRestored(.success(hasSession)):
                state.route = hasSession ? .authenticated : .unauthenticated
                return .none

            case .sessionRestored(.failure):
                state.route = .unauthenticated
                return .none

            case .onboarding(.delegate(.authenticationCompleted)):
                state.route = .authenticated
                return .none

            case .onboarding:
                return .none
            }
        }
    }
}
