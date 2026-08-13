import ComposableArchitecture
import FortuneFeature
import Foundation
import MyPageFeature
import TodakFeature

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
        var previousTab: Tab
        var fortune: FortuneFeature.State
        var todak: TodakFeature.State
        var myPage: MyPageFeature.State

        init(
            selectedTab: Tab = .fortune,
            previousTab: Tab = .fortune,
            fortune: FortuneFeature.State = .init(),
            todak: TodakFeature.State = .init(),
            myPage: MyPageFeature.State = .init()
        ) {
            self.selectedTab = selectedTab
            self.previousTab = previousTab
            self.fortune = fortune
            self.todak = todak
            self.myPage = myPage
        }
    }

    enum Action: Equatable, Sendable {
        case selectedTabChanged(Tab)
        case fortune(FortuneFeature.Action)
        case todak(TodakFeature.Action)
        case myPage(MyPageFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.fortune, action: \.fortune) {
            FortuneFeature()
        }

        Scope(state: \.myPage, action: \.myPage) {
            MyPageFeature()
        }

        Scope(state: \.todak, action: \.todak) {
            TodakFeature()
        }

        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab):
                if tab == .todak, state.selectedTab != .todak {
                    state.previousTab = state.selectedTab
                }
                state.selectedTab = tab
                return .none

            case .fortune(.delegate(.luckyActionRequested)):
                state.selectedTab = .luckyAction
                return .none

            case .todak(.delegate(.closeRequested)):
                state.selectedTab = state.previousTab == .todak ? .fortune : state.previousTab
                return .none

            case .fortune, .todak, .myPage:
                return .none
            }
        }
    }
}
