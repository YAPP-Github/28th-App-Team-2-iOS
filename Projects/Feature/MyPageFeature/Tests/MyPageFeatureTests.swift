import ComposableArchitecture
import XCTest
@testable import MyPageFeature

@MainActor
final class MyPageFeatureTests: XCTestCase {
    func testSajuChartProvidesPillarsInDisplayOrder() {
        let chart = MyPageSajuChart(
            pillars: [
                makePillar(type: "DAY"),
                makePillar(type: "MONTH"),
                makePillar(type: "YEAR"),
                makePillar(type: "HOUR")
            ]
        )

        XCTAssertEqual(chart.displayPillars.map(\.type), ["HOUR", "DAY", "MONTH", "YEAR"])
    }

    func testTaskLoadsDashboard() async {
        let dashboard = MyPageDashboard(
            profile: MyPageProfile(
                memberID: "member-id",
                name: "토닥이",
                gender: "FEMALE",
                birthDate: "1999-02-13",
                calendarType: "SOLAR",
                birthTime: "15:00",
                isTimeUnknown: false,
                job: "WORKER",
                relationshipStatus: "SOLO"
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

    func testEditSaveReplacesDashboardWithRecalculatedChart() async {
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
        initialState.dashboard = dashboard
        initialState.phase = .loaded
        initialState.edit = MyPageFeature.EditState(profile: dashboard.profile)

        let store = TestStore(initialState: initialState) {
            MyPageFeature()
        } withDependencies: {
            $0.myPageClient.updateProfile = { _ in dashboard }
        }

        await store.send(.editSaveButtonTapped) {
            $0.edit?.isSaving = true
        }
        await store.receive(.editResponse(.success(dashboard))) {
            $0.dashboard = dashboard
            $0.phase = .loaded
            $0.edit = nil
        }
    }

    func testCalendarButtonPresentsSajuDetail() async {
        var initialState = MyPageFeature.State()
        initialState.dashboard = dashboard
        initialState.phase = .loaded

        let store = TestStore(initialState: initialState) {
            MyPageFeature()
        }

        await store.send(.calendarButtonTapped) {
            $0.sajuDetail = MyPageFeature.SajuDetailState()
        }

        await store.send(.sajuDetailHelpButtonTapped(.ohaeng)) {
            $0.sajuDetail?.helpSheet = .ohaeng
        }

        await store.send(.sajuDetailHelpSheetDismissed) {
            $0.sajuDetail?.helpSheet = nil
        }

        await store.send(.sajuDetailDismissButtonTapped) {
            $0.sajuDetail = nil
        }
    }

    func testNotificationSettingsLoadsWhenMenuIsSelected() async {
        let settings = NotificationSettings(
            morningReportEnabled: false,
            morningReportTime: NotificationTime(hour: 8, minute: 0),
            todakiEnabled: false,
            luckyActionReminderEnabled: false
        )
        let store = TestStore(initialState: MyPageFeature.State()) {
            MyPageFeature()
        } withDependencies: {
            $0.myPageClient.loadNotificationSettings = { settings }
        }

        await store.send(.menuItemTapped(.notificationSettings)) {
            $0.notificationSettings = MyPageFeature.NotificationSettingsState()
        }
        await store.send(.notificationSettingsTask)
        await store.receive(.notificationSettingsResponse(.success(settings))) {
            $0.notificationSettings?.settings = settings
        }
    }

    func testEnablingNotificationRequestsPermissionThenPersistsSetting() async {
        let currentSettings = NotificationSettings(
            morningReportEnabled: false,
            morningReportTime: NotificationTime(hour: 8, minute: 0),
            todakiEnabled: false,
            luckyActionReminderEnabled: false
        )
        let updatedSettings = NotificationSettings(
            morningReportEnabled: false,
            morningReportTime: NotificationTime(hour: 8, minute: 0),
            todakiEnabled: true,
            luckyActionReminderEnabled: false
        )
        var initialState = MyPageFeature.State()
        initialState.notificationSettings = MyPageFeature.NotificationSettingsState()
        initialState.notificationSettings?.settings = currentSettings

        let store = TestStore(initialState: initialState) {
            MyPageFeature()
        } withDependencies: {
            $0.notificationSettingsAuthorizationClient.authorizationStatus = { .authorized }
            $0.myPageClient.syncOSPushPermission = { _ in currentSettings }
            $0.myPageClient.updateNotificationSettings = { settings in
                XCTAssertEqual(settings, updatedSettings)
                return updatedSettings
            }
        }

        await store.send(.notificationSettingToggleChanged(.todaki, true))
        await store.receive(.notificationToggleAuthorizationStatus(.todaki, .authorized))
        await store.receive(.notificationSettingsUpdateResponse(.success(updatedSettings))) {
            $0.notificationSettings?.settings = updatedSettings
        }
    }

    func testSavingMorningReportTimePersistsThirtyMinuteSelection() async {
        let currentSettings = NotificationSettings(
            morningReportEnabled: true,
            morningReportTime: NotificationTime(hour: 8, minute: 0),
            todakiEnabled: false,
            luckyActionReminderEnabled: false
        )
        let updatedSettings = NotificationSettings(
            morningReportEnabled: true,
            morningReportTime: NotificationTime(hour: 23, minute: 30),
            todakiEnabled: false,
            luckyActionReminderEnabled: false
        )
        var initialState = MyPageFeature.State()
        initialState.notificationSettings = MyPageFeature.NotificationSettingsState()
        initialState.notificationSettings?.settings = currentSettings

        let store = TestStore(initialState: initialState) {
            MyPageFeature()
        } withDependencies: {
            $0.myPageClient.updateNotificationSettings = { settings in
                XCTAssertEqual(settings, updatedSettings)
                return updatedSettings
            }
        }

        await store.send(.notificationSettingsTimeButtonTapped) {
            $0.notificationSettings?.isTimePickerPresented = true
        }
        await store.send(.notificationSettingsPickerHourChanged(99)) {
            $0.notificationSettings?.pickerHour = 23
        }
        await store.send(.notificationSettingsPickerMinuteChanged(30)) {
            $0.notificationSettings?.pickerMinute = 30
        }
        await store.send(.notificationSettingsTimeSaveButtonTapped) {
            $0.notificationSettings?.isTimePickerPresented = false
        }
        await store.receive(.notificationSettingsUpdateResponse(.success(updatedSettings))) {
            $0.notificationSettings?.settings = updatedSettings
            $0.notificationSettings?.pickerHour = 23
            $0.notificationSettings?.pickerMinute = 30
        }
    }

    func testNotificationTimeClampsInvalidValues() {
        let time = NotificationTime(hour: 24, minute: 60)

        XCTAssertEqual(time.hour, 23)
        XCTAssertEqual(time.minute, 59)
        XCTAssertEqual(time.apiValue, "23:59")
    }

    private var dashboard: MyPageDashboard {
        MyPageDashboard(
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
    }

    private func makePillar(type: String) -> MyPagePillar {
        MyPagePillar(
            type: type,
            heavenlyStem: "갑",
            heavenlyReading: "목",
            heavenlyElement: .wood,
            earthlyBranch: "자",
            earthlyReading: "수",
            earthlyElement: .water
        )
    }
}
