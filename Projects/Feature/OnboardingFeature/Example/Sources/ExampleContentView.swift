import AuthSession
import ComposableArchitecture
import OnboardingFeature
import SwiftUI

struct ExampleContentView: View {
    @Bindable private var store: StoreOf<OnboardingFeature>

    init() {
        store = Store(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        } withDependencies: {
            $0.authClient = .onboardingExample
            $0.socialLoginClient = .onboardingExample
            $0.authSession = .noSession
        }
    }

    var body: some View {
        Group {
            switch store.route {
            case .home:
                completionView
            case .login, .onboarding:
                OnboardingView(store: store)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .preferredColorScheme(.light)
    }

    private var completionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("데모 가입이 완료됐어요")
                .font(.title2.bold())
            Text("앱을 다시 실행하면 처음부터 반복할 수 있어요.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

private extension AuthClient {
    static let onboardingExample = Self(
        login: { _ in
            .newMember(onboardingToken: "example-onboarding-token")
        },
        signup: { _ in
            try await Task.sleep(for: .seconds(1))
            return SessionTokens(
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
