import ComposableArchitecture
import OnboardingFeature
import SwiftUI

struct ExampleContentView: View {
    private let store: StoreOf<OnboardingFeature>

    init() {
        store = Store(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        } withDependencies: {
            $0.authClient = .onboardingExample
            $0.notificationAuthorizationClient = .onboardingExample
            $0.socialLoginClient = .onboardingExample
            $0.tokenStore = .onboardingExample
        }
    }

    var body: some View {
        OnboardingView(store: store)
            .preferredColorScheme(.light)
    }
}

private extension AuthClient {
    static let onboardingExample = Self(
        login: { _ in
            .newMember(onboardingToken: "example-onboarding-token")
        },
        signup: { _ in
            SessionTokens(
                accessToken: "example-access-token",
                refreshToken: "example-refresh-token"
            )
        }
    )
}

private extension SocialLoginClient {
    static let onboardingExample = Self { provider in
        SocialCredential(
            provider: provider,
            oauthAccessToken: "example-oauth-access-token",
            authorizationCode: provider == .apple ? "example-authorization-code" : nil
        )
    }
}

private extension TokenStore {
    static let onboardingExample = Self { _ in }
}

private extension NotificationAuthorizationClient {
    static let onboardingExample = Self { false }
}
