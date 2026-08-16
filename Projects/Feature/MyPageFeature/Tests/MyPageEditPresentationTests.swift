import ComposableArchitecture
import Model
import Testing
@testable import MyPageFeature

@Suite
@MainActor
struct MyPageEditPresentationTests {
    @Test("편집 대기 취소 뒤 늦은 대시보드 응답은 편집 화면을 다시 표시하지 않는다")
    func discardedPendingEditPresentationDoesNotReopenEdit() async {
        let dashboard = MyPageDashboard(
            profile: MyPageProfile(
                memberID: "member-id",
                name: "토닥이",
                gender: "FEMALE",
                birthDate: "1999-02-13",
                calendarType: "SOLAR",
                birthTime: "JASI",
                isTimeUnknown: false,
                job: "WORKER",
                relationshipStatus: "SOLO"
            ),
            chart: MyPageSajuChart(pillars: [])
        )
        var initialState = MyPageFeature.State()
        initialState.phase = .loading
        initialState.isPendingEditPresentation = true
        initialState.isEditDashboardLoading = true

        let store = TestStore(initialState: initialState) {
            MyPageFeature()
        }

        await store.send(.discardPendingEditPresentation) {
            $0.phase = .idle
            $0.isPendingEditPresentation = false
            $0.isEditDashboardLoading = false
        }

        await store.send(.dashboardResponse(.success(dashboard))) {
            $0.dashboard = dashboard
            $0.phase = .loaded
        }
        #expect(store.state.edit == nil)
    }
}
