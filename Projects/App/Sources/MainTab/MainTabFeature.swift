import ComposableArchitecture
import FortuneFeature
import Foundation
import LuckyActionFeature
import MyPageFeature
import NotificationFeature
import NotificationFeatureInterface
import TodakFeature

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
        var previousTab: Tab
        var fortune: FortuneFeature.State
        var todak: TodakFeature.State
        var luckyAction: LuckyActionFeature.State
        var notifications: NotificationFeature.State
        @Presents var pushedLuckyAction: LuckyActionFeature.State?
        var isNotificationPresented: Bool
        var myPage: MyPageFeature.State
        /// 궁합 화면에서 시작된 내 정보 편집 요청의 출처를 보관한다.
        /// 경로가 사라진 뒤 도착한 응답이 편집 화면을 표시하지 않도록 App에서 수명을 관리한다.
        var compatibilityEditSourceID: StackElementID?

        init(
            selectedTab: Tab = .fortune,
            previousTab: Tab = .fortune,
            fortune: FortuneFeature.State = .init(),
            todak: TodakFeature.State = .init(),
            luckyAction: LuckyActionFeature.State = .init(),
            notifications: NotificationFeature.State = .init(),
            pushedLuckyAction: LuckyActionFeature.State? = nil,
            isNotificationPresented: Bool = false,
            myPage: MyPageFeature.State = .init()
        ) {
            self.selectedTab = selectedTab
            self.previousTab = previousTab
            self.fortune = fortune
            self.todak = todak
            self.luckyAction = luckyAction
            self.notifications = notifications
            self.pushedLuckyAction = pushedLuckyAction
            self.isNotificationPresented = isNotificationPresented
            self.myPage = myPage
        }
    }

    enum Action: Equatable {
        case selectedTabChanged(Tab)
        case task
        case fortuneNavigationChanged
        case fortune(FortuneFeature.Action)
        case todak(TodakFeature.Action)
        case luckyAction(LuckyActionFeature.Action)
        case notifications(NotificationFeature.Action)
        case notificationPresentationChanged(Bool)
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

        Scope(state: \.todak, action: \.todak) {
            TodakFeature()
        }

        Scope(state: \.luckyAction, action: \.luckyAction) {
            LuckyActionFeature()
        }

        Scope(state: \.notifications, action: \.notifications) {
            NotificationFeature()
        }

        Reduce { state, action in
            switch action {
            case .task:
                return .send(.notifications(.view(.refresh)))

            case let .selectedTabChanged(tab):
                if tab == .todak, state.selectedTab != .todak {
                    state.previousTab = state.selectedTab
                }
                let shouldDiscardEditPresentation = tab != .fortune
                    && state.compatibilityEditSourceID != nil
                state.selectedTab = tab
                if tab == .fortune {
                    if shouldDiscardEditPresentation {
                        state.compatibilityEditSourceID = nil
                        return .merge(
                            .send(.notifications(.view(.refresh))),
                            .send(.myPage(.discardPendingEditPresentation))
                        )
                    }
                    return .send(.notifications(.view(.refresh)))
                }
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

            case .todak(.delegate(.closeRequested)):
                state.selectedTab = state.previousTab == .todak ? .fortune : state.previousTab
                return .none

            case .fortune(.delegate(.luckyActionPushRequested)):
                state.pushedLuckyAction = LuckyActionFeature.State(
                    presentationStyle: .pushed,
                    today: now
                )
                return .none

            case .fortune(.delegate(.notificationsRequested)):
                state.isNotificationPresented = true
                return .send(.notifications(.view(.refresh)))

            case .notificationPresentationChanged(false):
                state.isNotificationPresented = false
                return .send(.notifications(.view(.refresh)))

            case .notificationPresentationChanged(true):
                state.isNotificationPresented = true
                return .none

            case .notifications(.delegate(.dismissRequested)):
                state.isNotificationPresented = false
                return .send(.notifications(.view(.refresh)))

            case let .notifications(.delegate(.unreadCountUpdated(count))):
                return .send(.fortune(.unreadNotificationCountUpdated(count)))

            case let .notifications(.delegate(.deepLinkRequested(deepLink))):
                switch deepLink {
                case let .chatConversation(conversationID):
                    if state.selectedTab != .todak {
                        state.previousTab = state.selectedTab
                    }
                    state.selectedTab = .todak
                    return .send(.todak(.openConversation(conversationID)))

                case .luckyAction:
                    state.pushedLuckyAction = LuckyActionFeature.State(
                        presentationStyle: .pushed,
                        today: now
                    )
                    return .none

                case .todayFortune:
                    state.isNotificationPresented = false
                    state.fortune.path.removeAll()
                    state.selectedTab = .fortune
                    return .none

                case .notice:
                    return .none
                }

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

            case .fortune, .todak, .luckyAction, .notifications, .pushedLuckyAction,
                 .pushedLuckyActionPresentationChanged, .myPage:
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
