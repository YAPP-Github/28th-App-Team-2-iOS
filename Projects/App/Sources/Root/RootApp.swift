import AuthSession
import ComposableArchitecture
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKCommon
import NetworkCore
import OnboardingFeature
import SwiftUI

@main
struct TodakunApp: App {
    private let store: StoreOf<RootFeature>

    init() {
        let configuration = OAuthConfiguration.current

        if let kakaoNativeAppKey = configuration.kakaoNativeAppKey {
            KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
        }

        let authClient = configuration.apiBaseURL.map { baseURL in
            AuthClient.live(httpClient: HTTPClient(baseURL: baseURL))
        } ?? .unavailable

        store = Store(initialState: RootFeature.State()) {
            RootFeature()
        } withDependencies: {
            $0.authClient = authClient
            $0.authSession = .live
            $0.socialLoginClient = .live(configuration: configuration)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .onOpenURL { callbackURL in
                    _ = GIDSignIn.sharedInstance.handle(callbackURL)
                    // 외부 SDK의 고정 API 표기(`Url`)를 그대로 호출한다.
                    // swiftlint:disable:next acronym_casing
                    _ = AuthController.handleOpenUrl(url: callbackURL)
                }
        }
    }
}

private struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>

    var body: some View {
        Group {
            switch store.route {
            case .launching:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)

            case .authenticated:
                VStack(spacing: 12) {
                    Text("홈")
                        .font(.title.bold())
                    Text("로그인이 완료되었어요")
                        .foregroundStyle(.secondary)
                }
            case .unauthenticated:
                OnboardingView(
                    store: store.scope(state: \.onboarding, action: \.onboarding)
                )
            }
        }
        .task { store.send(.task) }
    }
}
