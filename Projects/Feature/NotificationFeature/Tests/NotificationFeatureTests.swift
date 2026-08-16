// swiftlint:disable file_length
import ComposableArchitecture
import Foundation
import NotificationFeatureInterface
import NotificationFeatureTesting
import Testing
@testable import NotificationFeature

// swiftlint:disable type_body_length
@Suite
@MainActor
struct NotificationFeatureTests {
    private let notification = InAppNotification(
        identifier: UUID(1),
        type: .aiComplete,
        title: "토닥이 답변",
        content: "토닥이 답변이 도착했어요.",
        isRead: false,
        createdAt: Date(timeIntervalSince1970: 1_786_838_400)
    )

    @Test("초기 진입은 목록과 unread count를 함께 조회한다")
    func initialTaskLoadsNotifications() async {
        let list = NotificationList(unreadCount: 1, notifications: [notification])
        let store = TestStore(initialState: NotificationFeature.State()) {
            NotificationFeature()
        } withDependencies: {
            $0.notificationClient.fetchNotifications = { list }
        }

        await store.send(.view(.task)) {
            $0.viewState = .loading
            $0.latestFetchGeneration = 1
            $0.isFetchInFlight = true
        }
        await store.receive(.notificationsResponse(1, .success(list))) {
            $0.viewState = .loaded([self.notification])
            $0.unreadCount = 1
            $0.isFetchInFlight = false
        }
        await store.receive(.delegate(.unreadCountUpdated(1)))
    }

    @Test("실패 상태는 재시도로 다시 조회한다")
    func retryReloadsAfterFailure() async {
        let store = TestStore(
            initialState: NotificationFeature.State(viewState: .failed(message: "알림을 불러오지 못했어요."))
        ) {
            NotificationFeature()
        } withDependencies: {
            $0.notificationClient.fetchNotifications = {
                NotificationList(unreadCount: 0, notifications: [])
            }
        }

        await store.send(.view(.retryButtonTapped)) {
            $0.viewState = .loading
            $0.latestFetchGeneration = 1
            $0.isFetchInFlight = true
        }
        await store.receive(.notificationsResponse(1, .success(.init(unreadCount: 0, notifications: [])))) {
            $0.viewState = .loaded([])
            $0.isFetchInFlight = false
        }
        await store.receive(.delegate(.unreadCountUpdated(0)))
    }

    @Test("이미 조회한 목록은 화면 재표시 task로 중복 요청하지 않는다")
    func taskDoesNotReloadAnExistingList() async {
        let store = TestStore(
            initialState: NotificationFeature.State(
                viewState: .loaded([notification]),
                unreadCount: 1
            )
        ) {
            NotificationFeature()
        }

        await store.send(.view(.task))
    }

    @Test("진행 중인 목록 조회는 일반 refresh로 중복 요청하지 않는다")
    func refreshDoesNotRestartAnInFlightFetch() async {
        let started = AsyncStream.makeStream(of: Void.self)
        let result = AsyncStream.makeStream(of: NotificationList.self)
        let callCount = LockIsolated(0)
        let list = NotificationList(unreadCount: 0, notifications: [])
        let store = TestStore(initialState: NotificationFeature.State()) {
            NotificationFeature()
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

        await store.send(.view(.task)) {
            $0.viewState = .loading
            $0.latestFetchGeneration = 1
            $0.isFetchInFlight = true
        }
        for await _ in started.stream {
            break
        }

        await store.send(.view(.refresh))
        #expect(callCount.value == 1)

        result.continuation.yield(list)
        await store.receive(.notificationsResponse(1, .success(list))) {
            $0.viewState = .loaded([])
            $0.isFetchInFlight = false
        }
        await store.receive(.delegate(.unreadCountUpdated(0)))
    }

    @Test("뒤로가기 탭은 App 조립을 위한 의미 기반 delegate를 전달한다")
    func backButtonRequestsDismissal() async {
        let store = TestStore(initialState: NotificationFeature.State()) {
            NotificationFeature()
        }

        await store.send(.view(.backButtonTapped))
        await store.receive(.delegate(.dismissRequested))
    }

    @Test("읽지 않은 알림을 탭하면 성공 후에만 count를 줄인다")
    func markAsReadUpdatesListAndUnreadCount() async {
        let store = TestStore(
            initialState: NotificationFeature.State(
                viewState: .loaded([notification]),
                unreadCount: 1
            )
        ) {
            NotificationFeature()
        } withDependencies: {
            $0.notificationClient.markAsRead = { _ in }
            $0.notificationClient.fetchNotifications = {
                .init(unreadCount: 0, notifications: [self.notification.markedAsRead()])
            }
        }

        await store.send(.view(.notificationTapped(notification.id))) {
            $0.pendingReadIDs = [self.notification.id]
        }
        await store.receive(.markAsReadResponse(notification.id, nil)) {
            $0.pendingReadIDs = []
            $0.viewState = .loaded([self.notification.markedAsRead()])
            $0.unreadCount = 0
            $0.latestFetchGeneration = 1
            $0.isFetchInFlight = true
        }
        await store.receive(.delegate(.unreadCountUpdated(0)))

        await store.receive(
            .notificationsResponse(
                1,
                .success(.init(unreadCount: 0, notifications: [self.notification.markedAsRead()]))
            )
        ) {
            $0.isFetchInFlight = false
        }
        await store.receive(.delegate(.unreadCountUpdated(0)))
    }

    @Test("읽음 처리 실패는 기존 count와 행 상태를 유지한다")
    func markAsReadFailurePreservesState() async {
        let store = TestStore(
            initialState: NotificationFeature.State(
                viewState: .loaded([notification]),
                unreadCount: 1
            )
        ) {
            NotificationFeature()
        } withDependencies: {
            $0.notificationClient.markAsRead = { _ in throw NotificationClientError.transport }
        }

        await store.send(.view(.notificationTapped(notification.id))) {
            $0.pendingReadIDs = [self.notification.id]
        }
        await store.receive(.markAsReadResponse(notification.id, .transport)) {
            $0.pendingReadIDs = []
        }
    }

    @Test("PATCH 이후 늦게 도착한 이전 목록 응답은 읽음 상태를 되돌리지 않는다")
    func staleFetchAfterMarkAsReadIsIgnored() async {
        let freshList = NotificationList(
            unreadCount: 0,
            notifications: [notification.markedAsRead()]
        )
        let stream = AsyncStream.makeStream(of: NotificationList.self)
        let store = TestStore(
            initialState: NotificationFeature.State(
                viewState: .loaded([notification]),
                unreadCount: 1,
                pendingReadIDs: [notification.id],
                latestFetchGeneration: 1,
                isFetchInFlight: true
            )
        ) {
            NotificationFeature()
        } withDependencies: {
            $0.notificationClient.fetchNotifications = {
                for await list in stream.stream {
                    return list
                }
                throw CancellationError()
            }
        }

        await store.send(.markAsReadResponse(notification.id, nil)) {
            $0.pendingReadIDs = []
            $0.viewState = .loaded([self.notification.markedAsRead()])
            $0.unreadCount = 0
            $0.latestFetchGeneration = 2
            $0.isFetchInFlight = true
        }
        await store.receive(.delegate(.unreadCountUpdated(0)))

        await store.send(
            .notificationsResponse(
                1,
                .success(.init(unreadCount: 1, notifications: [notification]))
            )
        )

        stream.continuation.yield(freshList)
        await store.receive(.notificationsResponse(2, .success(freshList))) {
            $0.isFetchInFlight = false
        }
        await store.receive(.delegate(.unreadCountUpdated(0)))
    }

    @Test("재조회 실패 뒤에도 PATCH 성공은 count를 반영하고 최신 목록을 다시 요청한다")
    func markAsReadSucceedsAfterRefreshFailure() async {
        let freshList = NotificationList(
            unreadCount: 0,
            notifications: [notification.markedAsRead()]
        )
        let stream = AsyncStream.makeStream(of: NotificationList.self)
        let store = TestStore(
            initialState: NotificationFeature.State(
                viewState: .failed(message: "네트워크 연결 상태를 확인해주세요."),
                unreadCount: 1,
                pendingReadIDs: [notification.id],
                latestFetchGeneration: 1,
                isFetchInFlight: true
            )
        ) {
            NotificationFeature()
        } withDependencies: {
            $0.notificationClient.fetchNotifications = {
                for await list in stream.stream {
                    return list
                }
                throw CancellationError()
            }
        }

        await store.send(.markAsReadResponse(notification.id, nil)) {
            $0.pendingReadIDs = []
            $0.unreadCount = 0
            $0.latestFetchGeneration = 2
            $0.isFetchInFlight = true
        }
        await store.receive(.delegate(.unreadCountUpdated(0)))

        stream.continuation.yield(freshList)
        await store.receive(.notificationsResponse(2, .success(freshList))) {
            $0.viewState = .loaded([self.notification.markedAsRead()])
            $0.isFetchInFlight = false
        }
        await store.receive(.delegate(.unreadCountUpdated(0)))
    }
    @Test("딥링크가 있는 미읽은 알림을 탭하면 delegate를 방출하고 읽음 처리를 병행한다")
    func notificationWithDeepLinkEmitsDelegateAndMarksAsRead() async {
        let conversationID = UUID()
        let deepLinkedNotification = NotificationFixture.notification(
            deepLink: URL(string: "todakun://chat/conversations/\(conversationID.uuidString.lowercased())"),
            isRead: false
        )
        let store = TestStore(
            initialState: NotificationFeature.State(
                viewState: .loaded([deepLinkedNotification]),
                unreadCount: 1
            )
        ) {
            NotificationFeature()
        } withDependencies: {
            $0.notificationClient.markAsRead = { _ in }
            $0.notificationClient.fetchNotifications = {
                .init(unreadCount: 0, notifications: [deepLinkedNotification.markedAsRead()])
            }
        }

        await store.send(.view(.notificationTapped(deepLinkedNotification.id))) {
            $0.pendingReadIDs = [deepLinkedNotification.id]
        }
        await store.receive(.delegate(.deepLinkRequested(.chatConversation(conversationID))))
        await store.receive(.markAsReadResponse(deepLinkedNotification.id, nil)) {
            $0.pendingReadIDs = []
            $0.viewState = .loaded([deepLinkedNotification.markedAsRead()])
            $0.unreadCount = 0
            $0.latestFetchGeneration = 1
            $0.isFetchInFlight = true
        }
        await store.receive(.delegate(.unreadCountUpdated(0)))
        await store.receive(
            .notificationsResponse(
                1,
                .success(.init(unreadCount: 0, notifications: [deepLinkedNotification.markedAsRead()]))
            )
        ) {
            $0.isFetchInFlight = false
        }
        await store.receive(.delegate(.unreadCountUpdated(0)))
    }

    @Test("이미 읽은 알림을 탭해도 딥링크가 있으면 delegate를 방출한다")
    func alreadyReadNotificationWithDeepLinkEmitsDelegate() async {
        let deepLinkedNotification = NotificationFixture.notification(
            deepLink: URL(string: "todakun://lucky-action"),
            isRead: true
        )
        let store = TestStore(
            initialState: NotificationFeature.State(
                viewState: .loaded([deepLinkedNotification]),
                unreadCount: 0
            )
        ) {
            NotificationFeature()
        }

        await store.send(.view(.notificationTapped(deepLinkedNotification.id)))
        await store.receive(.delegate(.deepLinkRequested(.luckyAction)))
    }
}
// swiftlint:enable type_body_length

@Suite
struct NotificationDeepLinkTests {
    @Test("토닥이 대화 딥링크 URL을 정상 파싱한다")
    func parsesChatConversationDeepLink() {
        let uuid = UUID()
        let url = URL(string: "todakun://chat/conversations/\(uuid.uuidString.lowercased())")!
        #expect(NotificationDeepLink(url: url) == .chatConversation(uuid))
    }

    @Test("행운액션 딥링크 URL을 정상 파싱한다")
    func parsesLuckyActionDeepLink() {
        let url = URL(string: "todakun://lucky-action")!
        #expect(NotificationDeepLink(url: url) == .luckyAction)

        let invalidURL = URL(string: "todakun://lucky-action/invalid")!
        #expect(NotificationDeepLink(url: invalidURL) == nil)
    }

    @Test("운세 딥링크 URL을 정상 파싱한다")
    func parsesTodayFortuneDeepLink() {
        let todayURL = URL(string: "todakun://fortune/today")!
        #expect(NotificationDeepLink(url: todayURL) == .todayFortune)

        let fortuneURL = URL(string: "todakun://fortune")!
        #expect(NotificationDeepLink(url: fortuneURL) == .todayFortune)
    }

    @Test("공지 딥링크 URL을 정상 파싱한다")
    func parsesNoticeDeepLink() {
        let url = URL(string: "todakun://notice/123")!
        #expect(NotificationDeepLink(url: url) == .notice("123"))
    }

    @Test("지원하지 않는 scheme이나 잘못된 포맷은 nil을 반환한다")
    func returnsNilForInvalidDeepLinks() {
        #expect(NotificationDeepLink(url: URL(string: "https://todakun.app")!) == nil)
        #expect(NotificationDeepLink(url: URL(string: "todakun://chat/conversations/invalid-uuid")!) == nil)
        #expect(NotificationDeepLink(url: URL(string: "todakun://unknown/action")!) == nil)
    }
}

@Suite
struct NotificationTimeFormatterTests {
    private let now = Date(timeIntervalSince1970: 1_786_838_400)

    @Test("24시간 이내는 상대 시간을 표시한다")
    func formatsRecentTimes() {
        let cases: [(TimeInterval, String)] = [
            (59, "방금 전"),
            (60, "1분 전"),
            (1_800, "30분 전"),
            (3_599, "59분 전"),
            (3_600, "1시간 전"),
            (10_800, "3시간 전"),
            (86_399, "23시간 전")
        ]

        for (offset, expected) in cases {
            #expect(
                NotificationTimeFormatter.string(
                    createdAt: now.addingTimeInterval(-offset),
                    now: now
                ) == expected
            )
        }
    }

    @Test("24시간부터 절대 날짜를 표시한다")
    func formatsTwentyFourHoursAsDate() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        #expect(
            NotificationTimeFormatter.string(
                createdAt: now.addingTimeInterval(-86_400),
                now: now,
                calendar: calendar
            ) == "2026.08.15"
        )
    }
}
