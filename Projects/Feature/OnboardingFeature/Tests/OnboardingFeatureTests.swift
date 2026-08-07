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
}
