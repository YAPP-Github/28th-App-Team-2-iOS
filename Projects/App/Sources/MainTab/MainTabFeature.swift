import ComposableArchitecture
import FortuneFeature
import Foundation
import LuckyActionFeature
import MyPageFeature

@Reducer
struct MainTabFeature {
    @Dependency(\.date.now) private var now

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
        var luckyAction: LuckyActionFeature.State
        @Presents var pushedLuckyAction: LuckyActionFeature.State?
        var myPage: MyPageFeature.State
        /// 궁합 화면에서 시작된 내 정보 편집 요청의 출처를 보관한다.
        /// 경로가 사라진 뒤 도착한 응답이 편집 화면을 표시하지 않도록 App에서 수명을 관리한다.
        var compatibilityEditSourceID: StackElementID?

        init(
            selectedTab: Tab = .fortune,
            fortune: FortuneFeature.State = .init(),
            luckyAction: LuckyActionFeature.State = .init(),
            pushedLuckyAction: LuckyActionFeature.State? = nil,
            myPage: MyPageFeature.State = .init()
        ) {
            self.selectedTab = selectedTab
            self.fortune = fortune
            self.luckyAction = luckyAction
            self.pushedLuckyAction = pushedLuckyAction
            self.myPage = myPage
        }
    }

    enum Action: Equatable {
        case selectedTabChanged(Tab)
        case fortuneNavigationChanged
        case fortune(FortuneFeature.Action)
        case luckyAction(LuckyActionFeature.Action)
        case pushedLuckyAction(PresentationAction<LuckyActionFeature.Action>)
        case pushedLuckyActionPresentationChanged(Bool)
        case myPage(MyPageFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.fortune, action: \.fortune) {
            FortuneFeature()
        }

        Scope(state: \.myPage, action: \.myPage) {
            MyPageFeature()
        }

        Scope(state: \.luckyAction, action: \.luckyAction) {
            LuckyActionFeature()
        }

        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab):
                let shouldDiscardEditPresentation = tab != .fortune
                    && state.compatibilityEditSourceID != nil
                state.selectedTab = tab
                if shouldDiscardEditPresentation {
                    state.compatibilityEditSourceID = nil
                    return .send(.myPage(.discardPendingEditPresentation))
                }
                return .none

            case .fortuneNavigationChanged:
                guard let sourceID = state.compatibilityEditSourceID,
                      sourceID != currentCompatibilityDestinationID(in: state)
                else {
                    return .none
                }
                state.compatibilityEditSourceID = nil
                return .send(.myPage(.discardPendingEditPresentation))

            case .fortune(.delegate(.luckyActionTabRequested)):
                state.selectedTab = .luckyAction
                return .none

            case .fortune(.delegate(.luckyActionPushRequested)):
                state.pushedLuckyAction = LuckyActionFeature.State(
                    presentationStyle: .pushed,
                    today: now
                )
                return .none

            case .pushedLuckyAction(.presented(.delegate(.dismissRequested))),
                 .pushedLuckyActionPresentationChanged(false):
                state.pushedLuckyAction = nil
                return .none

            case .fortune(.delegate(.todakRequested)):
                state.selectedTab = .todak
                return .none

            case .fortune(.delegate(.myPageRequested)):
                state.selectedTab = .myPage
                return .none

            case .fortune(.delegate(.myInfoEditRequested)):
                guard let destinationID = currentCompatibilityDestinationID(in: state) else {
                    return .none
                }
                state.compatibilityEditSourceID = destinationID
                return .send(.myPage(.presentEdit))

            case .myPage(.editDismissButtonTapped):
                state.compatibilityEditSourceID = nil
                return .none

            case .myPage(.delegate(.profileUpdated)):
                state.compatibilityEditSourceID = nil
                guard let destinationID = currentCompatibilityDestinationID(in: state) else {
                    return .none
                }
                return .send(
                    .fortune(
                        .path(
                            .element(
                                id: destinationID,
                                action: .compatibility(.mySajuRefreshRequested)
                            )
                        )
                    )
                )

            case .fortune, .luckyAction, .pushedLuckyAction, .pushedLuckyActionPresentationChanged, .myPage:
                return .none
            }
        }
        .ifLet(\.$pushedLuckyAction, action: \.pushedLuckyAction) {
            LuckyActionFeature()
        }
    }

    private func currentCompatibilityDestinationID(in state: State) -> StackElementID? {
        guard let destinationID = state.fortune.path.ids.last,
              case .compatibility = state.fortune.path[id: destinationID]
        else {
            return nil
        }
        return destinationID
    }
}
