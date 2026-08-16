import ComposableArchitecture
import Foundation
import Testing
@testable import LuckyActionFeature
import LuckyActionFeatureInterface
import LuckyActionFeatureTesting

private actor LuckyActionQueryRecorder {
    enum Query: Equatable {
        case today
        case byDate(Date)
    }

    private(set) var queries: [Query] = []

    func record(_ query: Query) {
        queries.append(query)
    }
}

@Suite
@MainActor
struct LuckyActionActionDayTests {
    @Test("06시 이후 과거 날짜에서 다음으로 이동하면 날짜별 조회를 유지한다")
    func nextDateAfterSixKeepsIntermediateDateAsHistorical() async {
        let beforeSix = Date(timeIntervalSince1970: 1_786_741_140)
        let afterSix = Date(timeIntervalSince1970: 1_786_741_260)
        let action = LuckyActionFixture.today[0]
        var initialState = LuckyActionFeature.State(
            today: beforeSix,
            viewState: .loaded([action])
        )
        let previousActionDay = initialState.today
        let queryRecorder = LuckyActionQueryRecorder()
        initialState.selectedDate = previousActionDay.addingTimeInterval(-86_400)
        let store = TestStore(initialState: initialState) {
            LuckyActionFeature()
        } withDependencies: {
            $0.date.now = afterSix
            $0.luckyActionClient = LuckyActionClient(
                fetchToday: {
                    await queryRecorder.record(.today)
                    return [action]
                },
                fetchByDate: { date in
                    await queryRecorder.record(.byDate(date))
                    return [action]
                },
                toggleAchievement: { _ in action }
            )
        }

        await store.send(.view(.nextDateTapped)) {
            $0.today = $0.today.addingTimeInterval(86_400)
            $0.selectedDate = previousActionDay
            $0.viewState = .loading
        }
        await store.receive(.actionsResponse(previousActionDay, .success([action]))) {
            $0.viewState = .loaded([action])
        }

        await store.send(.view(.nextDateTapped)) {
            $0.selectedDate = $0.today
            $0.viewState = .loading
        }
        await store.receive(.actionsResponse(store.state.today, .success([action]))) {
            $0.viewState = .loaded([action])
        }

        let queries = await queryRecorder.queries
        #expect(queries == [.byDate(previousActionDay), .today])
    }

    @Test("06시 이후 기존 당일 재시도는 날짜별 조회를 사용한다")
    func retryAfterSixKeepsPreviousActionDayHistorical() async {
        let beforeSix = Date(timeIntervalSince1970: 1_786_741_140)
        let afterSix = Date(timeIntervalSince1970: 1_786_741_260)
        let action = LuckyActionFixture.today[0]
        let initialState = LuckyActionFeature.State(
            today: beforeSix,
            viewState: .failed(message: "네트워크 오류")
        )
        let previousActionDay = initialState.today
        let store = TestStore(initialState: initialState) {
            LuckyActionFeature()
        } withDependencies: {
            $0.date.now = afterSix
            $0.luckyActionClient = LuckyActionClient(
                fetchToday: {
                    Issue.record("기존 액션일 재시도는 당일 API를 호출하면 안 됩니다.")
                    return []
                },
                fetchByDate: { date in
                    #expect(date == previousActionDay)
                    return [action]
                },
                toggleAchievement: { _ in action }
            )
        }

        await store.send(.view(.retryButtonTapped)) {
            $0.today = $0.today.addingTimeInterval(86_400)
            $0.viewState = .loading
        }
        await store.receive(.actionsResponse(previousActionDay, .success([action]))) {
            $0.viewState = .loaded([action])
        }
    }

    @Test("06시 이후 기존 당일 액션은 체크할 수 없다")
    func togglingPreviousActionDayAfterSixDoesNotCallServer() async {
        let beforeSix = Date(timeIntervalSince1970: 1_786_741_140)
        let afterSix = Date(timeIntervalSince1970: 1_786_741_260)
        let action = LuckyActionFixture.today[0]
        let store = TestStore(
            initialState: LuckyActionFeature.State(
                today: beforeSix,
                viewState: .loaded([action])
            )
        ) {
            LuckyActionFeature()
        } withDependencies: {
            $0.date.now = afterSix
            $0.luckyActionClient = LuckyActionClient(
                fetchToday: { [] },
                fetchByDate: { _ in [] },
                toggleAchievement: { _ in
                    Issue.record("이전 액션일은 체크 요청을 보내면 안 됩니다.")
                    return action
                }
            )
        }

        await store.send(.view(.actionToggled(action.id))) {
            $0.today = $0.today.addingTimeInterval(86_400)
        }
    }
}
