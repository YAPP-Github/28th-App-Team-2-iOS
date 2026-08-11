import ComposableArchitecture
import XCTest
@testable import MyPageFeature

@MainActor
final class MyPageFeatureTests: XCTestCase {
    func testTaskLoadsDashboard() async {
        let dashboard = MyPageDashboard(
            profile: MyPageProfile(
                memberID: "member-id",
                name: "토닥이",
                gender: "FEMALE",
                birthDate: "1999-02-13",
                calendarType: "SOLAR",
                birthTime: "15:00",
                isTimeUnknown: false
            ),
            chart: MyPageSajuChart(pillars: [])
        )
        let store = TestStore(initialState: MyPageFeature.State()) {
            MyPageFeature()
        } withDependencies: {
            $0.myPageClient.loadDashboard = { dashboard }
        }

        await store.send(.task) {
            $0.phase = .loading
        }
        await store.receive(.dashboardResponse(.success(dashboard))) {
            $0.dashboard = dashboard
            $0.phase = .loaded
        }

        await store.send(.task)
    }

    func testTaskFailureShowsFailedPhase() async {
        let store = TestStore(initialState: MyPageFeature.State()) {
            MyPageFeature()
        } withDependencies: {
            $0.myPageClient.loadDashboard = { throw MyPageClientError.requestFailed }
        }

        await store.send(.task) {
            $0.phase = .loading
        }
        await store.receive(.dashboardResponse(.failure(.requestFailed))) {
            $0.phase = .failed(.requestFailed)
        }
    }
}
