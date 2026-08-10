import AuthSession
import ComposableArchitecture
import DesignSystem
import FortuneFeature
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

        let authSession = AuthSessionClient.live

        let authClient: AuthClient
        let fortuneClient: FortuneClient

        if let baseURL = configuration.apiBaseURL {
            let authHTTPClient = HTTPClient(baseURL: baseURL)
            authClient = AuthClient.live(httpClient: authHTTPClient)

            let authenticatedHTTPClient = HTTPClient(
                baseURL: baseURL,
                defaultHeaders: {
                    await authSession.authorizationHeaders()
                },
                onUnauthorized: {
                    do {
                        _ = try await authSession.refresh(using: authClient.refresh)
                        return true
                    } catch {
                        return false
                    }
                }
            )
            fortuneClient = FortuneClient.live(httpClient: authenticatedHTTPClient)
        } else {
            authClient = .unavailable
            fortuneClient = .unavailable
        }

        store = Store(initialState: RootFeature.State()) {
            RootFeature()
        } withDependencies: {
            $0.authClient = authClient
            $0.authSession = authSession
            $0.fortuneClient = fortuneClient
            $0.socialLoginClient = .live(configuration: configuration)
        }
    }

    var body: some Scene {
        WindowGroup {
#if DEBUG
            RootView(store: store)
                .dsDebugLayoutInspector()
#else
            RootView(store: store)
#endif
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
                    .background(Color("LaunchBackground").ignoresSafeArea())

            case .authenticated:
                MainTabView(
                    store: store.scope(state: \.mainTab, action: \.mainTab)
                )
            case .unauthenticated:
                OnboardingView(
                    store: store.scope(state: \.onboarding, action: \.onboarding)
                )
            }
        }
        .task { store.send(.task) }
        .onOpenURL { callbackURL in
            _ = GIDSignIn.sharedInstance.handle(callbackURL)
            // 외부 SDK의 고정 API 표기(`Url`)를 그대로 호출한다.
            // swiftlint:disable:next acronym_casing
            _ = AuthController.handleOpenUrl(url: callbackURL)
        }
    }
}
