import ComposableArchitecture
import XCTest
@testable import MyPageFeature

@MainActor
final class MyPageAccountSettingsTests: XCTestCase {
    func testWithdrawalRequiresReasonAndDetailOnlyForEtc() async {
        let store = TestStore(initialState: MyPageFeature.State()) {
            MyPageFeature()
        }

        await store.send(.menuItemTapped(.appSettings)) {
            $0.appSettings = MyPageFeature.AppSettingsState()
        }
        await store.send(.accountSettings(.withdrawalTapped)) {
            $0.withdrawal = MyPageFeature.WithdrawalState()
        }
        await store.send(.accountSettings(.reasonFieldTapped)) {
            $0.withdrawal?.draftReason = .contentInappropriate
            $0.withdrawal?.isReasonSheetPresented = true
        }
        await store.send(.accountSettings(.draftReasonSelected(.etc))) {
            $0.withdrawal?.draftReason = .etc
        }
        await store.send(.accountSettings(.saveReason)) {
            $0.withdrawal?.reason = .etc
            $0.withdrawal?.isReasonSheetPresented = false
        }
        await store.send(.accountSettings(.nextTapped))
        await store.send(.accountSettings(.detailChanged("개선되면 다시 이용할게요."))) {
            $0.withdrawal?.detail = "개선되면 다시 이용할게요."
        }
        await store.send(.accountSettings(.nextTapped)) {
            $0.withdrawal?.isAgreementPresented = true
        }
    }

    func testWithdrawalSendsRequestOnlyAfterConfirmation() async {
        var state = MyPageFeature.State()
        state.appSettings = MyPageFeature.AppSettingsState()
        state.withdrawal = MyPageFeature.WithdrawalState()
        state.withdrawal?.reason = .lowUsage
        state.withdrawal?.isAgreementPresented = true
        state.withdrawal?.isAgreed = true
        state.withdrawal?.isConfirmationPresented = true

        let store = TestStore(initialState: state) {
            MyPageFeature()
        } withDependencies: {
            $0.myPageClient.withdraw = { request in
                XCTAssertEqual(request.reason, .lowUsage)
                XCTAssertEqual(request.detail, "")
            }
        }

        await store.send(.accountSettings(.confirmWithdrawal)) {
            $0.withdrawal?.isConfirmationPresented = false
            $0.withdrawal?.isSubmitting = true
        }
        await store.receive(.accountSettings(.withdrawalResponse(.success(true)))) {
            $0.withdrawal?.isSubmitting = false
        }
        await store.receive(.delegate(.sessionEnded))
    }

    func testLogoutKeepsSessionFlowOnRequestFailure() async {
        let store = TestStore(initialState: MyPageFeature.State()) {
            MyPageFeature()
        } withDependencies: {
            $0.myPageClient.logout = { throw MyPageClientError.requestFailed }
        }

        await store.send(.menuItemTapped(.logout)) {
            $0.isLogoutConfirmationPresented = true
        }
        await store.send(.accountSettings(.confirmLogout)) {
            $0.isLogoutConfirmationPresented = false
        }
        await store.receive(.accountSettings(.logoutResponse(.failure(.requestFailed)))) {
            $0.logoutError = .requestFailed
        }
    }
}
