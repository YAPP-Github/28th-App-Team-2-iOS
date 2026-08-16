import ComposableArchitecture
import FortuneFeature
import NotificationFeature
import NotificationFeatureInterface
import Testing
@testable import Todakun

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
}
