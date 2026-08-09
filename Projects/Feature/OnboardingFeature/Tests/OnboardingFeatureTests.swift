import AuthSession
import ComposableArchitecture
import Foundation
import Model
import XCTest
@testable import OnboardingFeature

@MainActor
final class OnboardingFeatureTests: XCTestCase {
    func testNewMemberMovesToOnboardingWithToken() async {
        let credential = SocialCredential(provider: .kakao, oauthAccessToken: "oauth-token")
        let store = TestStore(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        } withDependencies: {
            $0.socialLoginClient.signIn = { _ in credential }
            $0.authClient.login = { _ in .newMember(onboardingToken: "onboarding-token") }
        }

        await store.send(.socialLoginButtonTapped(.kakao)) {
            $0.loginPhase = .authenticating(.kakao)
        }
        await store.receive(.socialLoginResponse(.success(credential))) {
            $0.loginPhase = .authenticatingWithServer
        }
        await store.receive(.loginResponse(.success(.newMember(onboardingToken: "onboarding-token")))) {
            $0.route = .onboarding
            $0.loginPhase = .idle
            $0.onboardingToken = "onboarding-token"
            $0.onboardingStep = .terms
        }
    }

    func testExistingMemberStoresTokensBeforeMovingHome() async {
        let credential = SocialCredential(provider: .google, oauthAccessToken: "id-token")
        let tokens = SessionTokens(accessToken: "access-token", refreshToken: "refresh-token")
        let store = TestStore(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        } withDependencies: {
            $0.socialLoginClient.signIn = { _ in credential }
            $0.authClient.login = { _ in .existingMember(tokens) }
            $0.authSession.save = { savedTokens in
                XCTAssertEqual(savedTokens, tokens)
            }
        }

        await store.send(.socialLoginButtonTapped(.google)) {
            $0.loginPhase = .authenticating(.google)
        }
        await store.receive(.socialLoginResponse(.success(credential))) {
            $0.loginPhase = .authenticatingWithServer
        }
        await store.receive(.loginResponse(.success(.existingMember(tokens)))) {
            $0.loginPhase = .savingSession
        }
        await store.receive(.tokenStorageSucceeded) {
            $0.loginPhase = .idle
            $0.route = .home
        }
        await store.receive(.delegate(.authenticationCompleted))
    }

    func testCancelledSocialLoginReturnsToIdleWithoutError() async {
        let store = TestStore(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        } withDependencies: {
            $0.socialLoginClient.signIn = { _ in throw SocialLoginError.cancelled }
        }

        await store.send(.socialLoginButtonTapped(.apple)) {
            $0.loginPhase = .authenticating(.apple)
        }
        await store.receive(.socialLoginResponse(.failure(.cancelled))) {
            $0.loginPhase = .idle
        }
    }

    func testRetryClearsLoginFailure() async {
        var state = OnboardingFeature.State()
        state.loginPhase = .failed(.serverLogin(.expired))
        let store = TestStore(initialState: state) {
            OnboardingFeature()
        }

        await store.send(.retryButtonTapped) {
            $0.loginPhase = .idle
        }
    }

    func testRequiredTermsEnableNextAndMoveToName() async {
        let store = TestStore(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }

        await store.send(.allTermsAgreementToggled(true)) {
            $0.terms = $0.terms.map { term in
                var updatedTerm = term
                updatedTerm.isAgreed = true
                return updatedTerm
            }
        }
        XCTAssertTrue(store.state.areRequiredTermsAgreed)

        await store.send(.termsNextButtonTapped) {
            $0.onboardingStep = .name
        }
    }

    func testIndividualTermsKeepAllAgreementInSync() async {
        let store = TestStore(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }

        await store.send(.allTermsAgreementToggled(true)) {
            $0.terms = $0.terms.map { term in
                var updatedTerm = term
                updatedTerm.isAgreed = true
                return updatedTerm
            }
        }
        await store.send(.termAgreementToggled("marketing", false)) {
            $0.terms[3].isAgreed = false
        }
        XCTAssertFalse(store.state.isAllTermsAgreed)
        XCTAssertTrue(store.state.areRequiredTermsAgreed)
    }

    func testTermDetailPresentsAndDismissesSelectedTerm() async {
        let store = TestStore(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }

        await store.send(.termDetailButtonTapped("privacy")) {
            $0.selectedTermDetail = OnboardingTerm.defaultTerms[1]
        }
        await store.send(.termDetailDismissed) {
            $0.selectedTermDetail = nil
        }
    }

    func testExitConfirmationDiscardsLocalOnboardingState() async {
        var initialState = OnboardingFeature.State()
        initialState.route = .onboarding
        initialState.onboardingToken = "temporary-onboarding-token"
        initialState.onboardingName = "홍길동"
        initialState.terms[0].isAgreed = true
        let store = TestStore(initialState: initialState) {
            OnboardingFeature()
        }

        await store.send(.onboardingExitButtonTapped) {
            $0.isOnboardingExitConfirmationPresented = true
        }
        await store.send(.onboardingExitConfirmed) {
            $0.route = .login
            $0.onboardingToken = nil
            $0.onboardingName = ""
            $0.terms = OnboardingTerm.defaultTerms
            $0.isOnboardingExitConfirmationPresented = false
        }
    }

    func testOnboardingNameTrimsAndRequiresKoreanCharacters() async {
        let store = TestStore(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }

        await store.send(.onboardingNameChanged("  홍길동  ")) {
            $0.onboardingName = "홍길동"
        }
        XCTAssertTrue(store.state.isOnboardingNameValid)

        await store.send(.onboardingNameChanged("Todakun")) {
            $0.onboardingName = "Todakun"
        }
        XCTAssertFalse(store.state.isOnboardingNameValid)
        XCTAssertEqual(store.state.onboardingNameValidationMessage, "이름은 한글만 가능해요.")

        await store.send(.onboardingNameChanged("가나다라마바사아자차카")) {
            $0.onboardingName = "가나다라마바사아자차카"
        }
        XCTAssertFalse(store.state.isOnboardingNameValid)
        XCTAssertEqual(store.state.onboardingNameValidationMessage, "이름은 최대 10글자까지 가능해요.")

        await store.send(.onboardingNameChanged("홍길동!")) {
            $0.onboardingName = "홍길동!"
        }
        XCTAssertFalse(store.state.isOnboardingNameValid)
        XCTAssertEqual(store.state.onboardingNameValidationMessage, "이름은 한글만 가능해요.")
    }

    func testNameNextMovesToFortuneInformation() async {
        var initialState = OnboardingFeature.State()
        initialState.onboardingStep = .name
        initialState.onboardingName = "홍길동"
        let store = TestStore(initialState: initialState) {
            OnboardingFeature()
        }

        await store.send(.onboardingNameNextButtonTapped) {
            $0.onboardingStep = .fortuneInformation
        }
    }

    func testFortuneInformationRequiresTimeOrUnknownTime() async {
        var initialState = OnboardingFeature.State()
        initialState.onboardingStep = .fortuneInformation
        let store = TestStore(initialState: initialState) {
            OnboardingFeature()
        } withDependencies: {
            $0.date.now = Date(timeIntervalSince1970: 1_800_000_000)
        }

        await store.send(.genderChanged(.female)) {
            $0.gender = .female
        }
        await store.send(.birthDateCalendarChanged(.solar)) {
            $0.birthDateCalendar = .solar
        }
        await store.send(.birthDateChanged(BirthDate(year: 1999, month: 2, day: 13))) {
            $0.birthDate = BirthDate(year: 1999, month: 2, day: 13)
        }
        XCTAssertFalse(store.state.isFortuneInformationValid)

        await store.send(.birthTimeUnknownChanged(true)) {
            $0.isBirthTimeUnknown = true
        }
        XCTAssertTrue(store.state.isFortuneInformationValid)

        await store.send(.fortuneInformationNextButtonTapped) {
            $0.onboardingStep = .userStatus
        }
    }

    func testUserStatusRequiresBothAnswers() async {
        var initialState = OnboardingFeature.State()
        initialState.onboardingStep = .userStatus
        let store = TestStore(initialState: initialState) {
            OnboardingFeature()
        }

        await store.send(.dailyRoutineChanged(.employed)) {
            $0.dailyRoutine = .employed
        }
        XCTAssertFalse(store.state.isUserStatusValid)

        await store.send(.romanticRelationshipStatusChanged(.single)) {
            $0.romanticRelationshipStatus = .single
        }
        XCTAssertTrue(store.state.isUserStatusValid)
    }

    func testDebugSignupLoadingPreviewUsesProductionLoadingState() async {
        let store = TestStore(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }

        await store.send(.debugPreviewButtonTapped(.signupLoading)) {
            $0.route = .onboarding
            $0.onboardingStep = .userStatus
            $0.signupPhase = .signingUp
        }
    }
}
