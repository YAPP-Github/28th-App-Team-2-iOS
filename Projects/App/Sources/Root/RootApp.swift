import AuthSession
import ComposableArchitecture
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKCommon
import NetworkCore
import OnboardingFeature
import MyPageFeature
import SwiftUI

@main
struct TodakunApp: App {
    @UIApplicationDelegateAdaptor(PushNotificationAppDelegate.self)
    private var pushNotificationAppDelegate
    private let store: StoreOf<RootFeature>

    init() {
        let configuration = OAuthConfiguration.current

        if let kakaoNativeAppKey = configuration.kakaoNativeAppKey {
            KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
        }

        let authSession = AuthSessionClient.live
        let httpClient = configuration.apiBaseURL.map { baseURL in
            HTTPClient(
                baseURL: baseURL,
                defaultHeaders: { await authSession.authorizationHeaders() }
            )
        }
        let authClient = httpClient.map(AuthClient.live) ?? .unavailable
        let myPageClient = httpClient.map(MyPageClient.live) ?? .unavailable

        Task { @MainActor in
            PushNotificationTokenStore.shared.setUpload { token in
                try await myPageClient.registerDeviceToken(token)
            }
        }

        store = Store(initialState: RootFeature.State()) {
            RootFeature()
        } withDependencies: {
            $0.authClient = authClient
            $0.authSession = authSession
            $0.socialLoginClient = .live(configuration: configuration)
            $0.myPageClient = myPageClient
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                store: store,
                onAuthenticated: {
                    Task { @MainActor in
                        PushNotificationTokenStore.shared.uploadCurrentToken()
                    }
                }
            )
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
    let onAuthenticated: () -> Void

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
//                .ignoresSafeArea(edges: .bottom)
            case .unauthenticated:
                OnboardingView(
                    store: store.scope(state: \.onboarding, action: \.onboarding)
                )
            }
        }
        .task { store.send(.task) }
        .onChange(of: store.route) { _, route in
            if route == .authenticated {
                onAuthenticated()
            }
        }
    }
}
