import ComposableArchitecture
import Foundation
import Testing
@testable import FortuneFeature

@MainActor
struct FortuneFeatureTests {
    @Test("initial task는 loading 상태에서만 운세를 요청한다")
    func initialTaskFetchesWhenLoading() async {
        let expectedID = UUID(0)
        let store = TestStore(initialState: FortuneFeature.State(viewState: .loading)) {
            FortuneFeature()
        } withDependencies: {
            $0.fortuneClient.fetchToday = {
                .fixture(dailyFortuneID: expectedID)
            }
        }

        await store.send(.view(.task))
        await store.receive(.todayFortuneResponse(.success(.fixture(dailyFortuneID: expectedID)))) {
            $0.viewState = .loaded(.fixture(dailyFortuneID: expectedID))
        }
    }

    @Test("이미 loaded 상태인 경우 task 액션은 요청을 재호출하지 않는다")
    func initialTaskNoopWhenAlreadyLoaded() async {
        let initialID = UUID(1)
        let store = TestStore(
            initialState: FortuneFeature.State(
                viewState: .loaded(.fixture(dailyFortuneID: initialID))
            )
        ) {
            FortuneFeature()
        } withDependencies: {
            $0.fortuneClient.fetchToday = {
                Issue.record("already loaded 상태에서는 fetchToday가 호출되지 않아야 합니다.")
                throw FortuneClientError.invalidResponse
            }
        }

        await store.send(.view(.task))
    }

    @Test("운세 요청 실패 시 서버 raw 메세지를 노출하지 않고 failed 상태로 전환된다")
    func taskFailureSetsFailedState() async {
        let store = TestStore(initialState: FortuneFeature.State(viewState: .loading)) {
            FortuneFeature()
        } withDependencies: {
            $0.fortuneClient.fetchToday = {
                throw FortuneClientError.server(code: "FORTUNE-500", message: "서버 내부 DB 쿼리 원본 에러 메세지")
            }
        }

        await store.send(.view(.task))
        await store.receive(
            .todayFortuneResponse(.failure(.server(code: "FORTUNE-500", message: "서버 내부 DB 쿼리 원본 에러 메세지")))
        ) {
            $0.viewState = .failed(message: "운세 정보를 불러오지 못했어요.")
        }
    }

    @Test("재시도하면 실패 상태에서 로딩 상태로 전환 후 다시 요청한다")
    func retryChangesFailureToLoadingAndFetches() async {
        let expectedID = UUID(2)
        let store = TestStore(
            initialState: FortuneFeature.State(
                viewState: .failed(message: "운세를 불러오지 못했어요")
            )
        ) {
            FortuneFeature()
        } withDependencies: {
            $0.fortuneClient.fetchToday = {
                .fixture(dailyFortuneID: expectedID)
            }
        }

        await store.send(.view(.retryButtonTapped)) {
            $0.viewState = .loading
        }
        await store.receive(.todayFortuneResponse(.success(.fixture(dailyFortuneID: expectedID)))) {
            $0.viewState = .loaded(.fixture(dailyFortuneID: expectedID))
        }
    }

    @Test("refresh는 기존 loaded 컨텐츠를 유지하면서 isRefreshing 상태를 업데이트한다")
    func refreshRetainsLoadedContent() async {
        let oldID = UUID(3)
        let newID = UUID(4)
        let store = TestStore(
            initialState: FortuneFeature.State(
                viewState: .loaded(.fixture(dailyFortuneID: oldID))
            )
        ) {
            FortuneFeature()
        } withDependencies: {
            $0.fortuneClient.fetchToday = {
                .fixture(dailyFortuneID: newID)
            }
        }

        await store.send(.view(.refresh)) {
            $0.isRefreshing = true
        }
        await store.receive(.todayFortuneResponse(.success(.fixture(dailyFortuneID: newID)))) {
            $0.viewState = .loaded(.fixture(dailyFortuneID: newID))
            $0.isRefreshing = false
        }
    }

    @Test("refresh 실패 시 기존 loaded 컨텐츠를 유지하고 isRefreshing을 false로 변경한다")
    func refreshFailureRetainsLoadedContentAndResetsRefreshing() async {
        let initialID = UUID(5)
        let store = TestStore(
            initialState: FortuneFeature.State(
                viewState: .loaded(.fixture(dailyFortuneID: initialID))
            )
        ) {
            FortuneFeature()
        } withDependencies: {
            $0.fortuneClient.fetchToday = {
                throw FortuneClientError.transport
            }
        }

        await store.send(.view(.refresh)) {
            $0.isRefreshing = true
        }
        await store.receive(.todayFortuneResponse(.failure(.transport))) {
            $0.isRefreshing = false
        }
    }

    @Test("이미 refreshing 중이거나 loaded 상태가 아닐 때 refresh 액션은 noop이다")
    func duplicateOrInvalidRefreshIsNoop() async {
        let initialID = UUID(6)
        let store1 = TestStore(
            initialState: FortuneFeature.State(
                viewState: .loaded(.fixture(dailyFortuneID: initialID)),
                isRefreshing: true
            )
        ) {
            FortuneFeature()
        } withDependencies: {
            $0.fortuneClient.fetchToday = {
                Issue.record("이미 refreshing 중일 때는 fetchToday가 실행되면 안 됩니다.")
                throw FortuneClientError.invalidResponse
            }
        }

        await store1.send(.view(.refresh))

        let store2 = TestStore(
            initialState: FortuneFeature.State(viewState: .loading)
        ) {
            FortuneFeature()
        } withDependencies: {
            $0.fortuneClient.fetchToday = {
                Issue.record("loading 상태에서는 refresh가 실행되면 안 됩니다.")
                throw FortuneClientError.invalidResponse
            }
        }

        await store2.send(.view(.refresh))
    }

    @Test("요청 취소 시 isRefreshing이 false가 되며 실패 UI로 바꾸지 않는다")
    func requestCancellationResetsRefreshingWithoutFailureUI() async {
        let (startedStream, startedContinuation) = AsyncStream<Void>.makeStream()
        let (cancelledStream, cancelledContinuation) = AsyncStream<Void>.makeStream()

        enum ContinuationState {
            case pending
            case waiting(CheckedContinuation<FortuneHomeContent, Error>)
            case cancelled
        }
        let state = LockIsolated<ContinuationState>(.pending)

        let initialID = UUID(9)
        let store = TestStore(
            initialState: FortuneFeature.State(
                viewState: .loaded(.fixture(dailyFortuneID: initialID))
            )
        ) {
            FortuneFeature()
        } withDependencies: {
            $0.fortuneClient.fetchToday = {
                startedContinuation.yield()
                return try await withTaskCancellationHandler {
                    try await withCheckedThrowingContinuation { continuation in
                        state.withValue { current in
                            switch current {
                            case .pending:
                                current = .waiting(continuation)
                            case .cancelled:
                                continuation.resume(throwing: CancellationError())
                            case .waiting:
                                break
                            }
                        }
                    }
                } onCancel: {
                    cancelledContinuation.yield()
                    state.withValue { current in
                        switch current {
                        case let .waiting(continuation):
                            current = .cancelled
                            continuation.resume(throwing: CancellationError())
                        case .pending:
                            current = .cancelled
                        case .cancelled:
                            break
                        }
                    }
                }
            }
        }

        await store.send(.view(.refresh)) {
            $0.isRefreshing = true
        }

        for await _ in startedStream {
            break
        }

        await store.send(.view(.requestCancelled)) {
            $0.isRefreshing = false
        }

        var isCancelledReceived = false
        for await _ in cancelledStream {
            isCancelledReceived = true
            break
        }

        #expect(isCancelledReceived)
        await store.finish()
    }
}

extension FortuneFeatureTests {
    @Test("unavailable client는 notConfigured 오류를 발생시킨다")
    func unavailableClientThrowsNotConfigured() async {
        let client = FortuneClient.unavailable
        await #expect(throws: FortuneClientError.notConfigured) {
            try await client.fetchToday()
        }
        await #expect(throws: FortuneClientError.notConfigured) {
            try await client.fetchDetail(UUID(0))
        }
        await #expect(throws: FortuneClientError.notConfigured) {
            try await client.fetchLuckAction(UUID(1))
        }
        await #expect(throws: FortuneClientError.notConfigured) {
            try await client.fetchPartners()
        }
    }

    @Test("범위에서 제외된 알림 버튼은 화면 전환을 만들지 않는다")
    func notificationTapIsNoop() async {
        let store = TestStore(initialState: FortuneFeature.State()) {
            FortuneFeature()
        }

        await store.send(.view(.notificationButtonTapped))
    }

    @Test("운세 리포트 버튼 탭은 Fortune 내부 경로를 추가한다")
    func reportTapPushesInternalPath() async {
        let dailyFortuneID = UUID(7)
        let store = TestStore(
            initialState: FortuneFeature.State(
                viewState: .loaded(.fixture(dailyFortuneID: dailyFortuneID))
            )
        ) {
            FortuneFeature()
        }

        await store.send(.view(.fortuneReportButtonTapped)) {
            $0.path.append(
                .report(
                    .init(
                        dailyFortuneID: dailyFortuneID,
                        selectedCategory: nil
                    )
                )
            )
        }
    }

    @Test("상세운 카드는 선택 카테고리의 바텀시트를 연다")
    func categoryTapPushesSelectedReport() async {
        for category in FortuneCategory.allCases {
            let dailyFortuneID = UUID(8)
            let fixture = FortuneHomeContent.fixture(dailyFortuneID: dailyFortuneID)
            let store = TestStore(
                initialState: FortuneFeature.State(
                    viewState: .loaded(fixture)
                )
            ) {
                FortuneFeature()
            }

            let item = fixture.categoryScores.first(where: { $0.category == category })!
            await store.send(.view(.fortuneCategoryTapped(category))) {
                $0.categoryDetail = .init(
                    luckActionID: item.luckActionID,
                    category: item.category,
                    categoryScores: fixture.categoryScores
                )
            }
        }
    }

    @Test("모든 사주 풀이 카드는 대응하는 Fortune 내부 경로를 추가한다")
    func readingTapPushesInternalPath() async {
        for reading in FortuneReading.allCases {
            let store = TestStore(initialState: FortuneFeature.State()) {
                FortuneFeature()
            }

            await store.send(.view(.fortuneReadingTapped(reading))) {
                switch reading {
                case .compatibility:
                    $0.path.append(.compatibility(.init()))
                case .dateSelection:
                    $0.path.append(.dayFortune(.init()))
                case .yearly:
                    $0.path.append(.yearFortune(.init()))
                }
            }
        }
    }

    @Test("행운 액션 배너 탭을 외부 이벤트로 전달한다")
    func luckyActionTapDelegates() async {
        let store = TestStore(initialState: FortuneFeature.State()) {
            FortuneFeature()
        }

        await store.send(.view(.luckyActionBannerTapped))
        await store.receive(.delegate(.luckyActionRequested))
    }
}

private extension FortuneHomeContent {
    static func fixture(dailyFortuneID: UUID) -> Self {
        Self(
            dailyFortuneID: dailyFortuneID,
            fortuneDate: Date(timeIntervalSince1970: 0),
            score: 72,
            title: "오늘의 운세",
            categoryScores: []
        )
    }
}

private extension UUID {
    init(_ value: UInt8) {
        self.init(uuid: (value, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    }
}
