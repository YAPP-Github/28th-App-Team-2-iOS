import ComposableArchitecture
import FortuneFeature
import Foundation
import LuckyActionFeature
import NotificationFeature
import NotificationFeatureInterface
import Testing
@testable import Todakun
import TodakFeature

// swiftlint:disable type_body_length
@Suite
@MainActor
struct MainTabNotificationFeatureTests {
    @Test
    func fortuneDelegateNotificationsRequestedPresentsNotificationScreen() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        } withDependencies: {
            $0.notificationClient.fetchNotifications = { .init(unreadCount: 0, notifications: []) }
        }

        await store.send(.fortune(.delegate(.notificationsRequested))) {
            $0.isNotificationPresented = true
        }
        await store.receive(.notifications(.view(.refresh))) {
            $0.notifications.viewState = .loading
            $0.notifications.latestFetchGeneration = 1
            $0.notifications.isFetchInFlight = true
        }
        await store.receive(
            .notifications(.notificationsResponse(1, .success(.init(unreadCount: 0, notifications: []))))
        ) {
            $0.notifications.viewState = .loaded([])
            $0.notifications.isFetchInFlight = false
        }
        await store.receive(.notifications(.delegate(.unreadCountUpdated(0))))
        await store.receive(.fortune(.unreadNotificationCountUpdated(0)))
    }

    @Test
    func notificationUnreadCountUpdatesFortuneHome() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }

        await store.send(.notifications(.delegate(.unreadCountUpdated(3))))
        await store.receive(.fortune(.unreadNotificationCountUpdated(3))) {
            $0.fortune.unreadNotificationCount = 3
        }
    }

    @Test
    func mainTabTaskFetchesUnreadCountForInitialFortuneHome() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        } withDependencies: {
            $0.notificationClient.fetchNotifications = { .init(unreadCount: 2, notifications: []) }
        }

        await store.send(.task)
        await store.receive(.notifications(.view(.refresh))) {
            $0.notifications.viewState = .loading
            $0.notifications.latestFetchGeneration = 1
            $0.notifications.isFetchInFlight = true
        }
        await store.receive(
            .notifications(.notificationsResponse(1, .success(.init(unreadCount: 2, notifications: []))))
        ) {
            $0.notifications.viewState = .loaded([])
            $0.notifications.unreadCount = 2
            $0.notifications.isFetchInFlight = false
        }
        await store.receive(.notifications(.delegate(.unreadCountUpdated(2))))
        await store.receive(.fortune(.unreadNotificationCountUpdated(2))) {
            $0.fortune.unreadNotificationCount = 2
        }
    }

    @Test
    func bellAndBackDuringInitialFetchDoNotStartAnotherNotificationRequest() async {
        let started = AsyncStream.makeStream(of: Void.self)
        let result = AsyncStream.makeStream(of: NotificationList.self)
        let callCount = LockIsolated(0)
        let list = NotificationList(unreadCount: 0, notifications: [])
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        } withDependencies: {
            $0.notificationClient.fetchNotifications = {
                callCount.withValue { $0 += 1 }
                started.continuation.yield()
                for await list in result.stream {
                    return list
                }
                throw CancellationError()
            }
        }

        await store.send(.task)
        await store.receive(.notifications(.view(.refresh))) {
            $0.notifications.viewState = .loading
            $0.notifications.latestFetchGeneration = 1
            $0.notifications.isFetchInFlight = true
        }
        for await _ in started.stream {
            break
        }

        await store.send(.fortune(.delegate(.notificationsRequested))) {
            $0.isNotificationPresented = true
        }
        await store.receive(.notifications(.view(.refresh)))

        await store.send(.notifications(.delegate(.dismissRequested))) {
            $0.isNotificationPresented = false
        }
        await store.receive(.notifications(.view(.refresh)))
        #expect(callCount.value == 1)

        result.continuation.yield(list)
        await store.receive(.notifications(.notificationsResponse(1, .success(list)))) {
            $0.notifications.viewState = .loaded([])
            $0.notifications.isFetchInFlight = false
        }
        await store.receive(.notifications(.delegate(.unreadCountUpdated(0))))
        await store.receive(.fortune(.unreadNotificationCountUpdated(0)))
    }

    @Test
    func closingNotificationScreenReturnsToFortuneAndRefreshesUnreadCount() async {
        let store = TestStore(
            initialState: MainTabFeature.State(isNotificationPresented: true)
        ) {
            MainTabFeature()
        } withDependencies: {
            $0.notificationClient.fetchNotifications = { .init(unreadCount: 1, notifications: []) }
        }

        await store.send(.notificationPresentationChanged(false)) {
            $0.isNotificationPresented = false
        }
        await store.receive(.notifications(.view(.refresh))) {
            $0.notifications.viewState = .loading
            $0.notifications.latestFetchGeneration = 1
            $0.notifications.isFetchInFlight = true
        }
        await store.receive(
            .notifications(.notificationsResponse(1, .success(.init(unreadCount: 1, notifications: []))))
        ) {
            $0.notifications.viewState = .loaded([])
            $0.notifications.unreadCount = 1
            $0.notifications.isFetchInFlight = false
        }
        await store.receive(.notifications(.delegate(.unreadCountUpdated(1))))
        await store.receive(.fortune(.unreadNotificationCountUpdated(1))) {
            $0.fortune.unreadNotificationCount = 1
        }
    }

    @Test
    func notificationDismissDelegateReturnsToFortuneAndRefreshesUnreadCount() async {
        let store = TestStore(
            initialState: MainTabFeature.State(isNotificationPresented: true)
        ) {
            MainTabFeature()
        } withDependencies: {
            $0.notificationClient.fetchNotifications = { .init(unreadCount: 0, notifications: []) }
        }

        await store.send(.notifications(.delegate(.dismissRequested))) {
            $0.isNotificationPresented = false
        }
        await store.receive(.notifications(.view(.refresh))) {
            $0.notifications.viewState = .loading
            $0.notifications.latestFetchGeneration = 1
            $0.notifications.isFetchInFlight = true
        }
        await store.receive(
            .notifications(.notificationsResponse(1, .success(.init(unreadCount: 0, notifications: []))))
        ) {
            $0.notifications.viewState = .loaded([])
            $0.notifications.isFetchInFlight = false
        }
        await store.receive(.notifications(.delegate(.unreadCountUpdated(0))))
        await store.receive(.fortune(.unreadNotificationCountUpdated(0)))
    }

    @Test("토닥이 딥링크를 수신하면 알림 화면을 유지한 채 토닥이 탭으로 전환하고, 토닥이를 닫으면 알림 화면으로 복귀한다")
    func chatConversationDeepLinkSwitchesToTodakTabAndOpensConversation() async {
        let conversationID = UUID(uuidString: "00000000-0000-0000-0000-000000000077")!
        let conversation = TodakConversation(
            id: conversationID,
            title: "딥링크 대화",
            messages: []
        )
        let entry = TodakEntry.initial
        let clock = TestClock()
        let store = TestStore(
            initialState: MainTabFeature.State(
                selectedTab: .fortune,
                isNotificationPresented: true
            )
        ) {
            MainTabFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.todakClient.fetchEntry = { entry }
            $0.todakClient.fetchConversation = { targetID in
                #expect(targetID == conversationID)
                return conversation
            }
        }

        await store.send(.notifications(.delegate(.deepLinkRequested(.chatConversation(conversationID))))) {
            $0.previousTab = .fortune
            $0.selectedTab = .todak
        }
        await store.receive(.todak(.openConversation(conversationID))) {
            $0.todak.screen = .chat
            $0.todak.isPendingDeepLinkConversation = true
            $0.todak.showsSplash = true
            $0.todak.didPresentSplash = true
            $0.todak.didCompleteSplashDelay = false
            $0.todak.isLoadingHistory = false
            $0.todak.isStreaming = false
            $0.todak.isLoadingEntry = true
        }
        await store.receive(.todak(.entryResponse(.success(entry)))) {
            $0.todak.isLoadingEntry = false
        }
        await store.receive(.todak(.conversationResponse(.success(conversation)))) {
            $0.todak.isPendingDeepLinkConversation = false
            $0.todak.conversationID = conversationID
            $0.todak.messages = conversation.messages
        }
        await clock.advance(by: .milliseconds(1_500))
        await store.receive(.todak(.splashElapsed)) {
            $0.todak.didCompleteSplashDelay = true
            $0.todak.showsSplash = false
        }

        // 토닥이 닫기(X) 시 이전 탭인 운세로 돌아오며, 알림 화면(isNotificationPresented = true)이 그대로 유지됨
        await store.send(.todak(.delegate(.closeRequested))) {
            $0.selectedTab = .fortune
        }
        #expect(store.state.isNotificationPresented == true)
    }

    @Test("행운액션 딥링크를 수신하면 알림 화면 위에 행운액션을 push하고, 뒤로가기를 누르면 알림 화면으로 복귀한다")
    func luckyActionDeepLinkPushesLuckyActionScreen() async {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let store = TestStore(
            initialState: MainTabFeature.State(
                selectedTab: .fortune,
                isNotificationPresented: true
            )
        ) {
            MainTabFeature()
        } withDependencies: {
            $0.date.now = now
        }

        await store.send(.notifications(.delegate(.deepLinkRequested(.luckyAction)))) {
            $0.pushedLuckyAction = LuckyActionFeature.State(
                presentationStyle: .pushed,
                today: now
            )
        }
        #expect(store.state.selectedTab == .fortune)
        #expect(store.state.isNotificationPresented == true)

        // 행운액션에서 뒤로가기(dismissRequested)를 누르면 알림 화면으로 복귀함
        await store.send(.pushedLuckyAction(.presented(.delegate(.dismissRequested)))) {
            $0.pushedLuckyAction = nil
        }
        #expect(store.state.isNotificationPresented == true)
    }

    @Test("오늘의 운세 딥링크를 수신하면 알림 화면을 닫고 운세 탭으로 전환하며 경로를 초기화한다")
    func todayFortuneDeepLinkResetsPathAndSwitchesToFortuneTab() async {
        var initialState = MainTabFeature.State(
            selectedTab: .myPage,
            isNotificationPresented: true
        )
        initialState.fortune.path.append(.report(.init(dailyFortuneID: UUID())))

        let store = TestStore(initialState: initialState) {
            MainTabFeature()
        }

        await store.send(.notifications(.delegate(.deepLinkRequested(.todayFortune)))) {
            $0.isNotificationPresented = false
            $0.fortune.path.removeAll()
            $0.selectedTab = .fortune
        }
    }

    @Test("공지 딥링크를 수신하면 화면 이동 없이 알림 화면을 유지한다")
    func noticeDeepLinkDoesNotNavigate() async {
        let store = TestStore(
            initialState: MainTabFeature.State(
                selectedTab: .fortune,
                isNotificationPresented: true
            )
        ) {
            MainTabFeature()
        }

        await store.send(.notifications(.delegate(.deepLinkRequested(.notice("123")))))
    }
}
// swiftlint:enable type_body_length
