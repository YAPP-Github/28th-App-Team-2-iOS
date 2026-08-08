import ComposableArchitecture
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
            $0.tokenStore.save = { savedTokens in
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
    }
}
