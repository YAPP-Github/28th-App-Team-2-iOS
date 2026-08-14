import ComposableArchitecture
import Foundation
import Testing
@testable import FortuneFeature

@MainActor
struct FortuneFollowupFeatureTests {
    @Test("선택 카테고리로 리포트에 진입하면 상세 조회 후 바텀시트를 연다")
    func reportLoadsAndPresentsRequestedCategory() async {
        let dailyID = UUID(10)
        let actionID = UUID(11)
        let detail = FortuneDetailContent(
            dailyFortuneID: dailyID,
            fortuneDate: Date(timeIntervalSince1970: 0),
            score: 72,
            title: "좋은 하루",
            content: "서버 종합 운세",
            luckyItems: [],
            cautionaryItems: [],
            categoryScores: [
                .init(luckActionID: actionID, category: .love, score: 84)
            ]
        )
        let store = TestStore(
            initialState: FortuneReportFeature.State(
                dailyFortuneID: dailyID,
                selectedCategory: .love
            )
        ) {
            FortuneReportFeature()
        } withDependencies: {
            $0.fortuneClient.fetchDetail = { _ in detail }
        }

        await store.send(.task)
        await store.receive(.response(.success(detail))) {
            $0.viewState = .loaded(detail)
            $0.pendingCategory = nil
            $0.categoryDetail = .init(
                luckActionID: actionID,
                category: .love,
                categoryScores: detail.categoryScores
            )
        }
    }

    @Test("상세운의 행운 액션은 App 조립용 delegate로 변환된다")
    func categoryDetailLuckyActionDelegates() async {
        let store = TestStore(
            initialState: FortuneCategoryDetailFeature.State(
                luckActionID: UUID(12),
                category: .money
            )
        ) {
            FortuneCategoryDetailFeature()
        }

        await store.send(.luckyActionTapped)
        await store.receive(.delegate(.luckyActionRequested))
    }

    @Test("택일 후보 날짜는 최대 5개를 유지하고 초과 선택 시 토스트 경고를 표시한다")
    func dayFortuneLimitsCandidateDates() async {
        let now = Date(timeIntervalSince1970: 1_788_969_600)
        let clock = TestClock()
        let store = TestStore(initialState: DayFortuneFeature.State()) {
            DayFortuneFeature()
        } withDependencies: {
            $0.date.now = now
            $0.continuousClock = clock
        }

        for offset in 0..<5 {
            let date = now.addingTimeInterval(TimeInterval(offset * 86_400))
            await store.send(.dateTapped(date)) {
                $0.selectedDates.append(Calendar.current.startOfDay(for: date))
                $0.selectedDates.sort()
            }
        }

        await store.send(.dateTapped(now.addingTimeInterval(5 * 86_400))) {
            $0.showLimitToast = true
        }
        await clock.advance(by: .seconds(2))
        await store.receive(.hideToast) {
            $0.showLimitToast = false
        }
    }

    @Test("택일 후보 날짜 초기화 시 선택 목록이 초기화된다")
    func dayFortuneResetsCandidateDates() async {
        let now = Date(timeIntervalSince1970: 1_788_969_600)
        var state = DayFortuneFeature.State()
        state.selectedDates = [now]
        let store = TestStore(initialState: state) {
            DayFortuneFeature()
        }

        await store.send(.resetDatesTapped) {
            $0.selectedDates = []
        }
    }

    @Test("연도별 운세 응답은 로딩을 종료하고 서버 결과를 보존한다")
    func yearFortuneStoresServerResult() async {
        let result = YearFortuneResult(
            id: UUID(13),
            year: 2027,
            score: 85,
            title: "도전의 해",
            content: "서버 총평",
            categories: [.init(category: .achievement, star: 5)]
        )
        let store = TestStore(
            initialState: YearFortuneFeature.State(selectedYear: 2027)
        ) {
            YearFortuneFeature()
        } withDependencies: {
            $0.fortuneClient.createYearFortune = { _ in result }
        }

        await store.send(.createTapped) {
            $0.isSubmitting = true
        }
        await store.receive(.response(.success(result))) {
            $0.isSubmitting = false
            $0.result = result
        }
    }

    @Test("궁합 진입 시 내 사주와 상대방 목록 및 선택 상대 사주를 순서대로 불러온다")
    func compatibilityLoadsSajuCharts() async {
        let myChart = makeSajuChart(id: UUID(20), name: "나")
        let partnerID = UUID(21)
        let partner = FortunePartner(
            id: partnerID,
            name: "상대",
            relationship: .partner
        )
        let partnerChart = makeSajuChart(id: partnerID, name: "상대")
        let store = TestStore(initialState: CompatibilityFeature.State()) {
            CompatibilityFeature()
        } withDependencies: {
            $0.fortuneClient.fetchMySaju = { myChart }
            $0.fortuneClient.fetchPartners = { [partner] }
            $0.fortuneClient.fetchPartnerSaju = { _ in partnerChart }
        }

        await store.send(.task)
        await store.receive(
            .initialResponse(.success(.init(mySaju: myChart, partners: [partner])))
        ) {
            $0.mySaju = myChart
            $0.partners = [partner]
            $0.selectedPartnerID = partnerID
            $0.viewState = .loaded
        }
        await store.receive(.partnerSajuResponse(partnerID, .success(partnerChart))) {
            $0.selectedPartnerSaju = partnerChart
        }
    }

    @Test("택일 운세 생성 시 점수 순으로 상위 3개를 선별하여 저장한다")
    func dayFortuneCreatesAndSelectsTop3Results() async {
        let now = Date(timeIntervalSince1970: 1_788_969_600)
        let r1 = DayFortuneResult(id: UUID(), purpose: .travel, targetDate: now, score: 60, title: "보통", content: "내용1", categories: [])
        let r2 = DayFortuneResult(id: UUID(), purpose: .travel, targetDate: now.addingTimeInterval(86_400), score: 95, title: "대길", content: "내용2", categories: [])
        let r3 = DayFortuneResult(id: UUID(), purpose: .travel, targetDate: now.addingTimeInterval(172_800), score: 80, title: "길", content: "내용3", categories: [])
        let r4 = DayFortuneResult(id: UUID(), purpose: .travel, targetDate: now.addingTimeInterval(259_200), score: 40, title: "소흉", content: "내용4", categories: [])
        let results = [r1, r2, r3, r4]

        var state = DayFortuneFeature.State()
        state.selectedDates = [now, now.addingTimeInterval(86_400)]
        let store = TestStore(initialState: state) {
            DayFortuneFeature()
        } withDependencies: {
            $0.fortuneClient.createDayFortunes = { _, _ in results }
        }

        await store.send(.createTapped) {
            $0.isSubmitting = true
        }
        await store.receive(\.response.success) {
            $0.isSubmitting = false
            $0.results = [r2, r3, r1] // 95, 80, 60
            $0.selectedResultID = r2.id
        }
    }

    @Test("궁합 화면에서 내 정보 수정을 탭하면 myInfoEditRequested delegate가 전송된다")
    func compatibilityMyInfoEditDelegates() async {
        let store = TestStore(initialState: CompatibilityFeature.State()) {
            CompatibilityFeature()
        }

        await store.send(.myInfoEditTapped)
        await store.receive(.delegate(.myInfoEditRequested))
    }

    private func makeSajuChart(id chartID: UUID, name: String) -> SajuChartDetail {
        SajuChartDetail(
            id: chartID,
            name: name,
            gender: .female,
            birthDate: Date(timeIntervalSince1970: 0),
            calendarType: .solar,
            birthTime: .jaTime,
            isBirthTimeUnknown: false,
            pillars: []
        )
    }
}

private extension UUID {
    init(_ value: UInt8) {
        self.init(uuid: (value, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    }
}
