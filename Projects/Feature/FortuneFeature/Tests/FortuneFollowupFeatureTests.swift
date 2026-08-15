import ComposableArchitecture
import Foundation
import Model
import Testing
@testable import FortuneFeature
@MainActor
// swiftlint:disable file_length
struct FortuneFollowupFeatureTests { // swiftlint:disable:this type_body_length
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

    @Test("내 정보 수정 후에는 궁합 화면의 내 사주를 다시 불러온다")
    func compatibilityRefreshesMySajuAfterProfileUpdate() async {
        let previousChart = makeSajuChart(id: UUID(22), name: "이전 정보")
        let refreshedChart = makeSajuChart(id: UUID(23), name: "수정된 정보")
        var state = CompatibilityFeature.State()
        state.viewState = .loaded
        state.mySaju = previousChart

        let store = TestStore(initialState: state) {
            CompatibilityFeature()
        } withDependencies: {
            $0.fortuneClient.fetchMySaju = { refreshedChart }
        }

        await store.send(.mySajuRefreshRequested)
        await store.receive(.mySajuRefreshResponse(.success(refreshedChart))) {
            $0.mySaju = refreshedChart
        }
    }

    @Test("내 사주 갱신 실패 시 기존 정보는 유지하고 오류를 표시한다")
    func compatibilityShowsErrorWhenMySajuRefreshFails() async {
        let previousChart = makeSajuChart(id: UUID(24), name: "이전 정보")
        var state = CompatibilityFeature.State()
        state.viewState = .loaded
        state.mySaju = previousChart

        let store = TestStore(initialState: state) {
            CompatibilityFeature()
        } withDependencies: {
            $0.fortuneClient.fetchMySaju = { throw FortuneClientError.transport }
        }

        await store.send(.mySajuRefreshRequested)
        await store.receive(.mySajuRefreshResponse(.failure(.transport))) {
            $0.errorMessage = FortuneClientError.transport.userMessage
        }
        #expect(store.state.mySaju == previousChart)
    }

    @Test("택일 운세 생성 시 점수 순으로 상위 3개를 선별하여 저장한다")
    func dayFortuneCreatesAndSelectsTop3Results() async {
        let now = Date(timeIntervalSince1970: 1_788_969_600)
        let firstResult = DayFortuneResult(
            id: UUID(), purpose: .travel, targetDate: now, score: 60,
            title: "보통", content: "내용1", categories: []
        )
        let secondResult = DayFortuneResult(
            id: UUID(), purpose: .travel, targetDate: now.addingTimeInterval(86_400), score: 95,
            title: "대길", content: "내용2", categories: []
        )
        let thirdResult = DayFortuneResult(
            id: UUID(), purpose: .travel, targetDate: now.addingTimeInterval(172_800), score: 80,
            title: "길", content: "내용3", categories: []
        )
        let fourthResult = DayFortuneResult(
            id: UUID(), purpose: .travel, targetDate: now.addingTimeInterval(259_200), score: 40,
            title: "소흉", content: "내용4", categories: []
        )
        let results = [firstResult, secondResult, thirdResult, fourthResult]

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
            $0.results = [secondResult, thirdResult, firstResult] // 95, 80, 60
            $0.selectedResultID = secondResult.id
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

    @Test("궁합 화면에서 상대방 사주를 성공적으로 등록하면 폼을닫고 목록을 새로고침한다")
    func compatibilityRegistersPartnerSuccessfully() async {
        let partnerID = UUID(30)
        let partner = FortunePartner(id: partnerID, name: "영희", relationship: .partner)
        let chart = makeSajuChart(id: partnerID, name: "영희")

        var state = CompatibilityFeature.State()
        state.isRegistrationPresented = true
        state.name = "영희"
        state.gender = .female
        state.calendarType = .solar
        state.birthDate = BirthDate(year: 2000, month: 1, day: 1)
        state.birthTime = .inTime
        state.isBirthTimeUnknown = false
        state.relationship = .partner

        #expect(state.canRegister)

        let store = TestStore(initialState: state) {
            CompatibilityFeature()
        } withDependencies: {
            $0.fortuneClient.registerPartner = { _ in partnerID }
            $0.fortuneClient.fetchPartners = { [partner] }
            $0.fortuneClient.fetchPartnerSaju = { _ in chart }
        }

        await store.send(.registerTapped) {
            $0.isSubmitting = true
            $0.errorMessage = nil
        }
        await store.receive(\.registrationResponse.success) {
            $0.isSubmitting = false
            $0.isRegistrationPresented = false
            $0.selectedPartnerID = partnerID
            $0.name = ""
            $0.gender = nil
            $0.calendarType = .solar
            $0.birthDate = nil
            $0.birthTime = nil
            $0.isBirthTimeUnknown = false
            $0.relationship = nil
            $0.errorMessage = nil
        }
        await store.receive(\.partnersResponse.success) {
            $0.partners = [partner]
            $0.viewState = .loaded
        }
        await store.receive(.partnerSajuResponse(partnerID, .success(chart))) {
            $0.selectedPartnerSaju = chart
        }
    }

    @Test("궁합 화면에서 궁합 보기 탭 시 궁합 결과를 생성하고 상태를 갱신한다")
    func compatibilityCreatesResultSuccessfully() async {
        let partnerID = UUID(31)
        let partner = FortunePartner(id: partnerID, name: "영희", relationship: .partner)
        let result = CompatibilityResult(
            id: UUID(32),
            partnerName: "영희",
            relationship: .partner,
            score: 90,
            headline: "천생연분",
            subheadline: "완벽한 조화",
            summary: "궁합 총평",
            totalAnalysis: "궁합 전체 분석 내용입니다.",
            analysisBasis: "오행 및 십신 분석 근거입니다.",
            elements: [
                FortuneElementScore(element: .wood, percentage: 30),
                FortuneElementScore(element: .fire, percentage: 25),
                FortuneElementScore(element: .earth, percentage: 20),
                FortuneElementScore(element: .metal, percentage: 15),
                FortuneElementScore(element: .water, percentage: 10)
            ]
        )

        var state = CompatibilityFeature.State()
        state.partners = [partner]
        state.selectedPartnerID = partnerID

        let store = TestStore(initialState: state) {
            CompatibilityFeature()
        } withDependencies: {
            $0.fortuneClient.createCompatibility = { _, _ in result }
        }

        await store.send(.compatibilityTapped) {
            $0.isSubmitting = true
            $0.errorMessage = nil
        }
        await store.receive(\.compatibilityResponse.success) {
            $0.isSubmitting = false
            $0.result = result
        }
    }

    @Test("궁합 생성 실패 시 에러 메시지를 표시하고 제출 상태를 해제한다")
    func compatibilityHandlesCreationFailure() async {
        let partnerID = UUID(33)
        let partner = FortunePartner(id: partnerID, name: "영희", relationship: .partner)

        var state = CompatibilityFeature.State()
        state.partners = [partner]
        state.selectedPartnerID = partnerID

        let store = TestStore(initialState: state) {
            CompatibilityFeature()
        } withDependencies: {
            $0.fortuneClient.createCompatibility = { _, _ in throw FortuneClientError.transport }
        }

        await store.send(.compatibilityTapped) {
            $0.isSubmitting = true
            $0.errorMessage = nil
        }
        await store.receive(\.compatibilityResponse.failure) {
            $0.isSubmitting = false
            $0.errorMessage = FortuneClientError.transport.userMessage
        }
    }

    @Test("상대방 변경 시 이전 사주를 초기화하고 새로운 상대방 사주를 조회한다")
    func compatibilityPartnerSelectionUpdatesSaju() async {
        let firstPartner = FortunePartner(id: UUID(34), name: "영희", relationship: .partner)
        let secondPartner = FortunePartner(id: UUID(35), name: "철수", relationship: .friend)
        let secondChart = makeSajuChart(id: secondPartner.id, name: "철수")

        var state = CompatibilityFeature.State()
        state.partners = [firstPartner, secondPartner]
        state.selectedPartnerID = firstPartner.id
        state.selectedPartnerSaju = makeSajuChart(id: firstPartner.id, name: "영희")
        state.isPartnerPickerPresented = true

        let store = TestStore(initialState: state) {
            CompatibilityFeature()
        } withDependencies: {
            $0.fortuneClient.fetchPartnerSaju = { _ in secondChart }
        }

        await store.send(.partnerSelected(secondPartner.id)) {
            $0.selectedPartnerID = secondPartner.id
            $0.selectedPartnerSaju = nil
            $0.isPartnerPickerPresented = false
        }
        await store.receive(.partnerSajuResponse(secondPartner.id, .success(secondChart))) {
            $0.selectedPartnerSaju = secondChart
            $0.errorMessage = nil
        }
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
