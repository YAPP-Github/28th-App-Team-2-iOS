import ComposableArchitecture
import Foundation
import Model
import NetworkCore
import XCTest
@testable import MyPageFeature

// swiftlint:disable file_length
@MainActor
// swiftlint:disable:next type_body_length
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

    func testSajuManagementLoadsPartners() async {
        let partner = makePartner()
        let store = TestStore(initialState: MyPageFeature.State()) {
            MyPageFeature()
        } withDependencies: {
            $0.myPageClient.loadPartners = { [partner] }
        }

        await store.send(.sajuManagementButtonTapped) {
            $0.sajuManagement = MyPageFeature.SajuManagementState()
        }
        await store.send(.sajuManagementTask)
        await store.receive(.sajuManagementResponse(.success([partner]))) {
            $0.sajuManagement?.partners = [partner]
            $0.sajuManagement?.isLoading = false
        }
    }

    func testPartnerLimitShowsFigmaToastMessage() async {
        var initialState = MyPageFeature.State()
        initialState.sajuManagement = MyPageFeature.SajuManagementState()
        initialState.sajuManagement?.isLoading = false
        initialState.sajuManagement?.partners = (0 ..< 10).map {
            makePartner(linkID: "link-\($0)")
        }
        let store = TestStore(initialState: initialState) {
            MyPageFeature()
        }

        await store.send(.partnerAddButtonTapped) {
            $0.sajuManagement?.toastMessage = "상대방 사주 정보는 최대 10개까지 저장할 수 있어요."
        }
    }

    func testPartnerFormUsesOnboardingNameAndPastDateValidation() {
        var form = MyPageFeature.PartnerFormState()
        form.name = "Todakun"
        XCTAssertEqual(form.nameValidationMessage, "이름은 한글만 가능해요.")

        form.name = String(repeating: "가", count: 11)
        XCTAssertEqual(form.nameValidationMessage, "이름은 최대 10글자까지 가능해요.")

        let referenceDate = Date(timeIntervalSince1970: 1_730_000_000)
        let today = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: referenceDate)
        let birthDate = BirthDate(year: today.year ?? 2024, month: today.month ?? 1, day: today.day ?? 1)
        let futureReferenceDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: referenceDate)!
        XCTAssertEqual(
            BirthDatePolicy.validateNotInFuture(for: birthDate, asOf: futureReferenceDate),
            BirthDatePolicy.futureDateMessage
        )
    }

    func testPartnerFormSupportsColleagueRelationship() {
        var form = MyPageFeature.PartnerFormState()

        form.relationship = .colleague

        XCTAssertEqual(form.relationshipCode, "COLLEAGUE")
        XCTAssertEqual(form.relationship, .colleague)
    }

    func testEditStateValidationPolicies() {
        let profile = MyPageProfile(
            name: "토닥이",
            gender: "FEMALE",
            birthDate: "1999-05-15",
            calendarType: "SOLAR",
            birthTime: "09:30",
            isTimeUnknown: false,
            job: "STUDENT",
            relationshipStatus: "SINGLE"
        )
        var edit = MyPageFeature.EditState(profile: profile)
        XCTAssertTrue(edit.isValid)

        // Under 14 years old
        edit.birthDate = BirthDate(year: 2020, month: 1, day: 1)
        XCTAssertFalse(edit.isValid)

        // Future date
        edit.birthDate = BirthDate(year: 2030, month: 1, day: 1)
        XCTAssertFalse(edit.isValid)

        // Valid date
        edit.birthDate = BirthDate(year: 1999, month: 5, day: 15)
        XCTAssertTrue(edit.isValid)

        // Missing job
        edit.job = nil
        XCTAssertFalse(edit.isValid)
        edit.job = .student

        // Unknown birth time
        edit.birthTime = nil
        edit.isBirthTimeUnknown = true
        XCTAssertTrue(edit.isValid)

        edit.isBirthTimeUnknown = false
        XCTAssertFalse(edit.isValid)
    }

    func testPartnerFormLifecycleAndValidation() {
        var form = MyPageFeature.PartnerFormState()
        form.name = "홍길동"
        form.gender = .male
        form.calendar = .solar
        form.birthDate = BirthDate(year: 1995, month: 3, day: 20)
        form.birthTime = .inTime
        form.relationship = .friend
        XCTAssertTrue(form.isValid)

        // Unknown time resets birthTime
        form.isBirthTimeUnknown = true
        form.birthTime = nil
        XCTAssertTrue(form.isValid)

        // Future date is invalid
        form.birthDate = BirthDate(year: 2030, month: 1, day: 1)
        XCTAssertFalse(form.isValid)
    }

    func testLivePartnerClientUsesSwaggerCRUDContract() async throws {
        let recorder = PartnerRequestRecorder()
        let httpClient = HTTPClient(
            baseURL: try XCTUnwrap(URL(string: "https://api-dev.todakun.com")),
            transport: { request in
                await recorder.append(request)
                let responseBody: String
                switch request.httpMethod {
                case "GET":
                    responseBody = """
                    {
                      "success": true,
                      "data": [{
                        "linkId": "link-1",
                        "relationshipType": { "code": "LOVER", "label": "연인" },
                        "name": "홍길동",
                        "gender": "MALE",
                        "birthDate": "1999-02-13",
                        "calendarType": "SOLAR",
                        "birthTime": "JASI",
                        "isTimeUnknown": false
                      }]
                    }
                    """
                case "POST":
                    responseBody = "{\"success\":true,\"data\":{\"linkId\":\"link-1\"}}"
                default:
                    responseBody = "{\"success\":true,\"data\":{}}"
                }
                let response = HTTPURLResponse(
                    url: request.url ?? URL(fileURLWithPath: "/"),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (Data(responseBody.utf8), response)
            }
        )
        let client = MyPageClient.live(httpClient: httpClient)
        let input = MyPagePartnerSajuInput(
            name: "홍길동",
            gender: "MALE",
            calendarType: "SOLAR",
            birthDate: "1999-02-13",
            birthTime: "JASI",
            relationshipType: "LOVER"
        )

        let partners = try await client.loadPartners()
        try await client.registerPartner(input)
        try await client.updatePartner("link-1", input)
        try await client.deletePartner("link-1")

        XCTAssertEqual(partners, [makePartner()])
        let requests = await recorder.value()
        XCTAssertEqual(requests.map { $0.url?.path }, [
            "/api/v1/saju/partners",
            "/api/v1/saju/partners",
            "/api/v1/saju/partners/link-1",
            "/api/v1/saju/partners/link-1"
        ])
        XCTAssertEqual(requests.map(\.httpMethod), ["GET", "POST", "PATCH", "DELETE"])
        XCTAssertEqual(requests[1].value(forHTTPHeaderField: "Content-Type"), "application/json")
        let postBody = try JSONDecoder().decode(
            PartnerRequestBody.self,
            from: try XCTUnwrap(requests[1].httpBody)
        )
        let patchBody = try JSONDecoder().decode(
            PartnerRequestBody.self,
            from: try XCTUnwrap(requests[2].httpBody)
        )
        XCTAssertEqual(postBody, PartnerRequestBody(input))
        XCTAssertEqual(patchBody, PartnerRequestBody(input))
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

    private func makePartner(linkID: String = "link-1") -> MyPagePartnerSaju {
        MyPagePartnerSaju(
            linkID: linkID,
            relationshipCode: "LOVER",
            relationshipLabel: "연인",
            name: "홍길동",
            gender: "MALE",
            birthDate: "1999-02-13",
            calendarType: "SOLAR",
            birthTime: "JASI",
            isTimeUnknown: false
        )
    }
}

private actor PartnerRequestRecorder {
    private var requests: [URLRequest] = []

    func append(_ request: URLRequest) {
        requests.append(request)
    }

    func value() -> [URLRequest] { requests }
}

private struct PartnerRequestBody: Decodable, Equatable {
    let name: String
    let gender: String
    let calendarType: String
    let birthDate: String
    let birthTime: String
    let relationshipType: String

    init(_ input: MyPagePartnerSajuInput) {
        name = input.name
        gender = input.gender
        calendarType = input.calendarType
        birthDate = input.birthDate
        birthTime = input.birthTime
        relationshipType = input.relationshipType
    }
}
