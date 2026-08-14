import ComposableArchitecture
import FortuneFeature
import Foundation
import MyPageFeature

@Reducer
struct MainTabFeature {
    init() {}

    enum Tab: Equatable, Sendable {
        case fortune
        case todak
        case luckyAction
        case myPage
    }

    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab
        var fortune: FortuneFeature.State
        var myPage: MyPageFeature.State

        init(
            selectedTab: Tab = .fortune,
            fortune: FortuneFeature.State = .init(),
            myPage: MyPageFeature.State = .init()
        ) {
            self.selectedTab = selectedTab
            self.fortune = fortune
            self.myPage = myPage
        }
    }

    enum Action: Equatable {
        case selectedTabChanged(Tab)
        case fortune(FortuneFeature.Action)
        case myPage(MyPageFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.fortune, action: \.fortune) {
            FortuneFeature()
        }

        Scope(state: \.myPage, action: \.myPage) {
            MyPageFeature()
        }

        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none

            case .fortune(.delegate(.luckyActionRequested)):
                state.selectedTab = .luckyAction
                return .none

            case .fortune(.delegate(.todakRequested)):
                state.selectedTab = .todak
                return .none

            case .fortune(.delegate(.myPageRequested)):
                state.selectedTab = .myPage
                return .none

            case .fortune, .myPage:
                return .none
            }
        }
    }
}
