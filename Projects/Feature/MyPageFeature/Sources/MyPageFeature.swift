import ComposableArchitecture

@Reducer
public struct MyPageFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var dashboard: MyPageDashboard?
        public var phase: Phase = .idle

        public init() {}
    }

    public enum Phase: Equatable {
        case idle
        case loading
        case loaded
        case failed(MyPageClientError)
    }

    public enum Action: Equatable {
        case task
        case refreshButtonTapped
        case dashboardResponse(Result<MyPageDashboard, MyPageClientError>)
        case editButtonTapped
        case calendarButtonTapped
        case menuItemTapped(MenuItem)
    }

    public enum MenuItem: Equatable, CaseIterable {
        case sajuManagement
        case notificationSettings
        case appSettings
        case inquiry
        case logout
    }

    @Dependency(\.myPageClient) private var myPageClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task, .refreshButtonTapped:
                guard state.phase != .loading else { return .none }
                state.phase = .loading
                return .run { send in
                    await send(
                        .dashboardResponse(
                            Result { try await myPageClient.loadDashboard() }
                                .mapError(MyPageClientError.init)
                        )
                    )
                }
                .cancellable(id: CancelID.loadDashboard, cancelInFlight: true)

            case let .dashboardResponse(.success(dashboard)):
                state.dashboard = dashboard
                state.phase = .loaded
                return .none

            case let .dashboardResponse(.failure(error)):
                state.phase = .failed(error)
                return .none

            case .editButtonTapped, .calendarButtonTapped, .menuItemTapped:
                return .none
            }
        }
    }
}

private enum CancelID {
    case loadDashboard
}
