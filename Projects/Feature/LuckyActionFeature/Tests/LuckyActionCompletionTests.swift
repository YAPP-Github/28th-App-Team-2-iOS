import ComposableArchitecture
import Foundation
import Testing
@testable import LuckyActionFeature
import LuckyActionFeatureInterface
import LuckyActionFeatureTesting

@Suite
@MainActor
struct LuckyActionCompletionTests {
    @Test("과거 날짜 조회가 실패해도 다음 날짜로 이동할 수 있다")
    func movesToNextDateAfterHistoricalFetchFailure() async {
        let today = Date(timeIntervalSince1970: 1_786_762_800)
        let action = LuckyActionFixture.today[0]
        let initialState = LuckyActionFeature.State(today: today, viewState: .loaded([action]))
        let previousDate = initialState.today.addingTimeInterval(-86_400)
        let store = TestStore(initialState: initialState) {
            LuckyActionFeature()
        } withDependencies: {
            $0.date.now = today
            $0.luckyActionClient = LuckyActionClient(
                fetchToday: { [action] },
                fetchByDate: { _ in throw LuckyActionClientError.transport },
                toggleAchievement: { _ in action }
            )
        }

        await store.send(.view(.previousDateTapped)) {
            $0.selectedDate = previousDate
            $0.viewState = .loading
        }
        await store.receive(.actionsResponse(previousDate, .failure(.transport))) {
            $0.viewState = .failed(message: "네트워크 연결 상태를 확인해주세요.")
        }
        await store.send(.view(.nextDateTapped)) {
            $0.selectedDate = $0.today
            $0.viewState = .loading
        }
        await store.receive(.actionsResponse(store.state.today, .success([action]))) {
            $0.viewState = .loaded([action])
        }
    }

    @Test("완료 안내는 순서대로 표시되고 다음 안내의 자동 종료를 다시 시작한다")
    func completionQueueRestartsAutoDismiss() async {
        let clock = TestClock()
        let now = Date(timeIntervalSince1970: 1_786_762_800)
        let first = LuckyActionFixture.today[0]
        let second = LuckyActionFixture.today[1]
        let completedFirst = LuckyActionFixture.action(
            identifier: first.id.uuidString,
            category: .relationship,
            score: 89,
            title: first.title,
            isAchieved: true
        )
        let completedSecond = LuckyActionFixture.action(
            identifier: second.id.uuidString,
            category: .love,
            score: 26,
            title: second.title,
            isAchieved: true
        )
        let store = TestStore(
            initialState: LuckyActionFeature.State(
                today: now,
                viewState: .loaded([first, second])
            )
        ) {
            LuckyActionFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.date.now = now
        }

        await store.send(.achievementResponse(first.id, .success(completedFirst))) {
            $0.viewState = .loaded([completedFirst, second])
            $0.completion = LuckyActionCompletion(category: .relationship)
        }
        await clock.advance(by: .seconds(1))
        await store.send(.achievementResponse(second.id, .success(completedSecond))) {
            $0.viewState = .loaded([completedFirst, completedSecond])
            $0.completionQueue = [LuckyActionCompletion(category: .love)]
        }
        await store.send(.view(.completionDismissButtonTapped)) {
            $0.completion = LuckyActionCompletion(category: .love)
            $0.completionQueue = []
        }
        // 첫 안내의 남은 1초가 지난 시점이다. 이전 타이머가 취소되지 않았다면
        // 아래 no-op 전송 전에 미처리 자동 종료 액션이 검출되어 테스트가 실패한다.
        await clock.advance(by: .seconds(1))
        await store.send(.view(.nextDateTapped))
        await clock.advance(by: .seconds(2))
        await store.receive(.view(.completionAutoDismissed)) {
            $0.completion = nil
        }
    }

    @Test("액션 완료 요청이 실패하면 대기 상태를 해제하고 기존 점수를 유지한다")
    func toggleFailureClearsPendingStateWithoutChangingAction() async {
        let now = Date(timeIntervalSince1970: 1_786_762_800)
        let action = LuckyActionFixture.today[0]
        let store = TestStore(
            initialState: LuckyActionFeature.State(
                today: now,
                viewState: .loaded([action])
            )
        ) {
            LuckyActionFeature()
        } withDependencies: {
            $0.date.now = now
            $0.luckyActionClient = LuckyActionClient(
                fetchToday: { [] },
                fetchByDate: { _ in [] },
                toggleAchievement: { _ in throw LuckyActionClientError.transport }
            )
        }

        await store.send(.view(.actionToggled(action.id))) {
            $0.pendingActionIDs = [action.id]
        }
        await store.receive(.achievementResponse(action.id, .failure(.transport))) {
            $0.pendingActionIDs = []
        }
        #expect(store.state.viewState == .loaded([action]))
    }
}
