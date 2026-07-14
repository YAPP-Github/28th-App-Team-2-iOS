import ComposableArchitecture
import OnboardingFeatureInterface

@Reducer
public struct OnboardingFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case finishedButtonTapped
        case delegate(Delegate)

        public enum Delegate {
            case onboardingDidFinish
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .finishedButtonTapped:
                return .send(.delegate(.onboardingDidFinish))
            case .delegate:
                return .none
            }
        }
    }
}
