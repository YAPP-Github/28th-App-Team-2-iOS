import ComposableArchitecture
import Foundation
import Testing
@testable import LuckyActionFeature
import LuckyActionFeatureInterface
import LuckyActionFeatureTesting

@Suite
@MainActor
struct LuckyActionFeatureTests {
    @Test("당일 행운 액션을 카테고리 순서로 표시한다")
    func loadsTodayActions() async {
        let now = Date(timeIntervalSince1970: 1_786_762_800)
        let relationship = LuckyActionFixture.today[0]
        let money = LuckyActionFixture.today[4]
        let repository = LuckyActionMock(actions: [money, relationship])
        let store = TestStore(initialState: LuckyActionFeature.State(today: now)) {
            LuckyActionFeature()
        } withDependencies: {
            $0.date.now = now
            $0.luckyActionClient = .mock(repository: repository)
        }

        await store.send(.view(.task))
        await store.receive(.actionsResponse(store.state.today, .success([money, relationship]))) {
            $0.viewState = .loaded([relationship, money])
        }
    }

    @Test("재진입하면 이미 표시 중인 당일 액션도 다시 조회한다")
    func reloadsTodayActionsOnReentry() async {
        let now = Date(timeIntervalSince1970: 1_786_762_800)
        let existingAction = LuckyActionFixture.today[0]
        let refreshedAction = LuckyActionFixture.action(
            identifier: existingAction.id.uuidString,
            category: .relationship,
            score: 91
        )
        let repository = LuckyActionMock(actions: [refreshedAction])
        let store = TestStore(
            initialState: LuckyActionFeature.State(
                today: now,
                viewState: .loaded([existingAction])
            )
        ) {
            LuckyActionFeature()
        } withDependencies: {
            $0.date.now = now
            $0.luckyActionClient = .mock(repository: repository)
        }

        await store.send(.view(.task)) {
            $0.viewState = .loading
        }
        await store.receive(.actionsResponse(store.state.today, .success([refreshedAction]))) {
            $0.viewState = .loaded([refreshedAction])
        }
    }

    @Test("재진입하면 과거 선택을 최신 액션일로 초기화한다")
    func reentryResetsSelectedPastDateToToday() async {
        let now = Date(timeIntervalSince1970: 1_786_762_800)
        let action = LuckyActionFixture.today[0]
        var initialState = LuckyActionFeature.State(
            today: now,
            viewState: .loaded([action])
        )
        initialState.selectedDate = initialState.today.addingTimeInterval(-86_400)
        let store = TestStore(initialState: initialState) {
            LuckyActionFeature()
        } withDependencies: {
            $0.date.now = now
            $0.luckyActionClient = .mock(repository: LuckyActionMock(actions: [action]))
        }

        await store.send(.view(.task)) {
            $0.selectedDate = $0.today
            $0.viewState = .loading
        }
        await store.receive(.actionsResponse(store.state.today, .success([action]))) {
            $0.viewState = .loaded([action])
        }
    }

    @Test("06시 경계를 넘은 재진입은 최신 액션일을 사용한다")
    func reentryAfterSixUsesNewActionDay() async {
        let beforeSix = Date(timeIntervalSince1970: 1_786_741_140)
        let afterSix = Date(timeIntervalSince1970: 1_786_741_260)
        let action = LuckyActionFixture.today[0]
        let store = TestStore(
            initialState: LuckyActionFeature.State(today: beforeSix)
        ) {
            LuckyActionFeature()
        } withDependencies: {
            $0.date.now = afterSix
            $0.luckyActionClient = .mock(repository: LuckyActionMock(actions: [action]))
        }

        await store.send(.view(.task)) {
            $0.today = $0.today.addingTimeInterval(86_400)
            $0.selectedDate = $0.today
        }
        await store.receive(.actionsResponse(store.state.today, .success([action]))) {
            $0.viewState = .loaded([action])
        }
    }

    @Test("이전 날짜를 선택하면 날짜별 액션을 조회하고 체크를 막는다")
    func loadsPreviousDateAsReadOnly() async {
        let today = Date(timeIntervalSince1970: 1_786_762_800)
        let action = LuckyActionFixture.today[0]
        let initialState = LuckyActionFeature.State(today: today)
        let previousDate = initialState.today.addingTimeInterval(-86_400)
        let store = TestStore(
            initialState: initialState
        ) {
            LuckyActionFeature()
        } withDependencies: {
            $0.date.now = today
            $0.luckyActionClient = LuckyActionClient(
                fetchToday: { [] },
                fetchByDate: { date in
                    #expect(date == previousDate)
                    return [action]
                },
                toggleAchievement: { _ in
                    Issue.record("과거 날짜의 액션은 체크 요청을 보내면 안 됩니다.")
                    return action
                }
            )
        }

        await store.send(.view(.previousDateTapped)) {
            $0.selectedDate = previousDate
        }
        await store.receive(.actionsResponse(previousDate, .success([action]))) {
            $0.viewState = .loaded([action])
        }
        #expect(store.state.canMoveToNextDate)
        #expect(!store.state.canToggleActions)

        await store.send(.view(.actionToggled(action.id)))
    }

    @Test("당일에는 다음 날짜 이동을 허용하지 않는다")
    func preventsFutureDateNavigation() async {
        let now = Date(timeIntervalSince1970: 1_786_762_800)
        let store = TestStore(initialState: LuckyActionFeature.State(today: now)) {
            LuckyActionFeature()
        } withDependencies: {
            $0.date.now = now
        }

        await store.send(.view(.nextDateTapped))
    }

    @Test("미완료 액션을 체크하면 서버 응답으로 갱신하고 완료 안내를 표시한다")
    func completingActionShowsCompletion() async {
        let clock = TestClock()
        let now = Date(timeIntervalSince1970: 1_786_762_800)
        let action = LuckyActionFixture.today[1]
        let completedAction = LuckyActionFixture.action(
            identifier: action.id.uuidString,
            category: .love,
            score: 26,
            title: action.title,
            isAchieved: true
        )
        let repository = LuckyActionMock(actions: [action])
        let store = TestStore(
            initialState: LuckyActionFeature.State(
                today: now,
                viewState: .loaded([action])
            )
        ) {
            LuckyActionFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.date.now = now
            $0.luckyActionClient = .mock(repository: repository)
        }

        await store.send(.view(.actionToggled(action.id))) {
            $0.pendingActionIDs = [action.id]
        }
        await store.receive(.achievementResponse(action.id, .success(completedAction))) {
            $0.pendingActionIDs = []
            $0.viewState = .loaded([completedAction])
            $0.completion = LuckyActionCompletion(category: .love)
        }
        await clock.advance(by: .seconds(2))
        await store.receive(.view(.completionAutoDismissed)) {
            $0.completion = nil
        }
    }

    @Test("완료된 액션을 해제할 때는 완료 안내를 표시하지 않는다")
    func uncompletingActionDoesNotShowCompletion() async {
        let now = Date(timeIntervalSince1970: 1_786_762_800)
        let completedAction = LuckyActionFixture.action(
            identifier: LuckyActionFixture.today[3].id.uuidString,
            category: .health,
            score: 60,
            isAchieved: true
        )
        let revertedAction = LuckyActionFixture.action(
            identifier: completedAction.id.uuidString,
            category: .health,
            score: 55,
            isAchieved: false
        )
        let repository = LuckyActionMock(actions: [completedAction])
        let store = TestStore(
            initialState: LuckyActionFeature.State(
                today: now,
                viewState: .loaded([completedAction])
            )
        ) {
            LuckyActionFeature()
        } withDependencies: {
            $0.date.now = now
            $0.luckyActionClient = .mock(repository: repository)
        }

        await store.send(.view(.actionToggled(completedAction.id))) {
            $0.pendingActionIDs = [completedAction.id]
        }
        await store.receive(.achievementResponse(completedAction.id, .success(revertedAction))) {
            $0.pendingActionIDs = []
            $0.viewState = .loaded([revertedAction])
        }
        #expect(store.state.completion == nil)
    }

}
