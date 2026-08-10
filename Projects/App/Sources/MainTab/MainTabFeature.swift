import ComposableArchitecture
import FortuneFeature
import Foundation

@Reducer
struct MainTabFeature: Sendable {
    init() {}

    enum Tab: Equatable, Sendable {
        case fortune
        case todak
        case luckyAction
        case myPage
    }

    @ObservableState
    struct State: Equatable, Sendable {
        var selectedTab: Tab
        var fortune: FortuneFeature.State

        init(
            selectedTab: Tab = .fortune,
            fortune: FortuneFeature.State = .init()
        ) {
            self.selectedTab = selectedTab
            self.fortune = fortune
        }
    }

    enum Action: Equatable, Sendable {
        case selectedTabChanged(Tab)
        case fortune(FortuneFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.fortune, action: \.fortune) {
            FortuneFeature()
        }

        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none

            case .fortune(.delegate(.luckyActionRequested)):
                state.selectedTab = .luckyAction
                return .none

            case .fortune:
                return .none
            }
        }
    }
}
