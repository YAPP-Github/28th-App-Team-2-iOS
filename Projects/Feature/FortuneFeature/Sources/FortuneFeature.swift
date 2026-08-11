import ComposableArchitecture
import Foundation

@Reducer
public struct FortuneFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable, Sendable {
        public enum ViewState: Equatable, Sendable {
            case loading
            case loaded(FortuneHomeContent)
            case failed(message: String)
        }

        public var viewState: ViewState

        public init(viewState: ViewState = .loading) {
            self.viewState = viewState
        }
    }

    public enum Action: Equatable, Sendable {
        case view(ViewAction)
        case delegate(Delegate)

        public enum ViewAction: Equatable, Sendable {
            case retryButtonTapped
            case notificationButtonTapped
            case fortuneReportButtonTapped
            case fortuneCategoryTapped(FortuneCategory)
            case fortuneReadingTapped(FortuneReading)
            case luckyActionBannerTapped
        }

        public enum Delegate: Equatable, Sendable {
            case notificationRequested
            case fortuneReportRequested(
                dailyFortuneID: UUID,
                selectedCategory: FortuneCategory?
            )
            case fortuneReadingRequested(FortuneReading)
            case luckyActionRequested
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.retryButtonTapped):
                state.viewState = .loading
                return .none

            case .view(.notificationButtonTapped):
                return .send(.delegate(.notificationRequested))

            case .view(.fortuneReportButtonTapped):
                return routeToFortuneReport(state: state, selectedCategory: nil)

            case let .view(.fortuneCategoryTapped(category)):
                return routeToFortuneReport(state: state, selectedCategory: category)

            case let .view(.fortuneReadingTapped(reading)):
                return .send(.delegate(.fortuneReadingRequested(reading)))

            case .view(.luckyActionBannerTapped):
                return .send(.delegate(.luckyActionRequested))

            case .delegate:
                return .none
            }
        }
    }

    private func routeToFortuneReport(
        state: State,
        selectedCategory: FortuneCategory?
    ) -> Effect<Action> {
        guard case let .loaded(content) = state.viewState else {
            return .none
        }

        return .send(
            .delegate(
                .fortuneReportRequested(
                    dailyFortuneID: content.dailyFortuneID,
                    selectedCategory: selectedCategory
                )
            )
        )
    }
}
