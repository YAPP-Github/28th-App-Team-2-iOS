import ComposableArchitecture
import Foundation
import Testing
@testable import FortuneFeature

@MainActor
struct FortuneFeatureTests {
    @Test("재시도하면 실패 상태에서 로딩 상태로 전환한다")
    func retryChangesFailureToLoading() async {
        let store = TestStore(
            initialState: FortuneFeature.State(
                viewState: .failed(message: "운세를 불러오지 못했어요")
            )
        ) {
            FortuneFeature()
        }

        await store.send(.view(.retryButtonTapped)) {
            $0.viewState = .loading
        }
    }

    @Test("알림 버튼 탭을 외부 이벤트로 전달한다")
    func notificationTapDelegates() async {
        let store = TestStore(initialState: FortuneFeature.State()) {
            FortuneFeature()
        }

        await store.send(.view(.notificationButtonTapped))
        await store.receive(.delegate(.notificationRequested))
    }

    @Test("운세 리포트 버튼 탭을 선택 카테고리 없이 전달한다")
    func reportTapDelegates() async {
        let dailyFortuneID = UUID(0)
        let store = TestStore(
            initialState: FortuneFeature.State(
                viewState: .loaded(.fixture(dailyFortuneID: dailyFortuneID))
            )
        ) {
            FortuneFeature()
        }

        await store.send(.view(.fortuneReportButtonTapped))
        await store.receive(
            .delegate(
                .fortuneReportRequested(
                    dailyFortuneID: dailyFortuneID,
                    selectedCategory: nil
                )
            )
        )
    }

    @Test("상세운 카드를 탭하면 선택 카테고리를 전달한다", arguments: FortuneCategory.allCases)
    func categoryTapDelegates(category: FortuneCategory) async {
        let dailyFortuneID = UUID(1)
        let store = TestStore(
            initialState: FortuneFeature.State(
                viewState: .loaded(.fixture(dailyFortuneID: dailyFortuneID))
            )
        ) {
            FortuneFeature()
        }

        await store.send(.view(.fortuneCategoryTapped(category)))
        await store.receive(
            .delegate(
                .fortuneReportRequested(
                    dailyFortuneID: dailyFortuneID,
                    selectedCategory: category
                )
            )
        )
    }

    @Test("사주 풀이 카드 탭을 외부 이벤트로 전달한다", arguments: FortuneReading.allCases)
    func readingTapDelegates(reading: FortuneReading) async {
        let store = TestStore(initialState: FortuneFeature.State()) {
            FortuneFeature()
        }

        await store.send(.view(.fortuneReadingTapped(reading)))
        await store.receive(.delegate(.fortuneReadingRequested(reading)))
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
