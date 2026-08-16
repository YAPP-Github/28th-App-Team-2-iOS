import ComposableArchitecture
import NotificationFeature
import NotificationFeatureInterface
import NotificationFeatureTesting
import SwiftUI

struct ExampleContentView: View {
    private enum Scenario: String, CaseIterable, Identifiable {
        case loading = "로딩"
        case loaded = "목록"
        case empty = "빈 목록"
        case failed = "실패"

        // SwiftUI Identifiable 계약의 고정 API를 유지한다.
        // swiftlint:disable:next identifier_name
        var id: Self { self }
    }

    @State private var scenario: Scenario = .loaded

    private let loadingStore = Store(
        initialState: NotificationFeature.State(viewState: .loading)
    ) {
        NotificationFeature()
    }
    private let loadedStore = Store(
        initialState: NotificationFeature.State(
            viewState: .loaded(NotificationExampleFixture.notifications),
            unreadCount: 2
        )
    ) {
        NotificationFeature()
    } withDependencies: {
        $0.notificationClient = .mock(
            repository: NotificationMock(
                list: NotificationList(
                    unreadCount: 2,
                    notifications: NotificationExampleFixture.notifications
                )
            )
        )
    }
    private let emptyStore = Store(
        initialState: NotificationFeature.State(viewState: .loaded([]))
    ) {
        NotificationFeature()
    } withDependencies: {
        $0.notificationClient = .mock(repository: NotificationMock())
    }
    private let failedStore = Store(
        initialState: NotificationFeature.State(viewState: .failed(message: "알림을 불러오지 못했어요."))
    ) {
        NotificationFeature()
    } withDependencies: {
        $0.notificationClient = .mock(
            repository: NotificationMock(
                list: NotificationList(
                    unreadCount: 2,
                    notifications: NotificationExampleFixture.notifications
                )
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Scenario", selection: $scenario) {
                ForEach(Scenario.allCases) { scenario in
                    Text(scenario.rawValue).tag(scenario)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            scenarioView
        }
    }

    @ViewBuilder
    private var scenarioView: some View {
        switch scenario {
        case .loading:
            NotificationView(store: loadingStore)
        case .loaded:
            NotificationView(store: loadedStore)
        case .empty:
            NotificationView(store: emptyStore)
        case .failed:
            NotificationView(store: failedStore)
        }
    }
}

private enum NotificationExampleFixture {
    static let now = Date()

    static let notifications = [
        InAppNotification(
            identifier: UUID(1),
            type: .aiComplete,
            title: "토닥이 답변",
            content: "토닥이 답변이 도착했어요.",
            isRead: false,
            createdAt: now.addingTimeInterval(-1_800)
        ),
        InAppNotification(
            identifier: UUID(2),
            type: .luckyAction,
            title: "오늘의 행운 액션",
            content: "오늘 행운 액션이 열렸어요.",
            isRead: false,
            createdAt: now.addingTimeInterval(-10_800)
        ),
        InAppNotification(
            identifier: UUID(3),
            type: .fortune,
            title: "궁합 결과",
            content: "토실이님과의 궁합이 도착했어요.",
            isRead: true,
            createdAt: now.addingTimeInterval(-172_800)
        )
    ]
}
