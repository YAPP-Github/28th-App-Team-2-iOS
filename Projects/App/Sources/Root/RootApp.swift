import AuthSession
import ComposableArchitecture
import DesignSystem
import FortuneFeature
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKCommon
import MyPageFeature
import NetworkCore
import OnboardingFeature
import SwiftUI
import TodakFeature

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
        let authClient: AuthClient
        let fortuneClient: FortuneClient
        let myPageClient: MyPageClient
        let todakClient: TodakClient

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
            myPageClient = MyPageClient.live(httpClient: authenticatedHTTPClient)
            let authenticatedSSEClient = SSEClient(
                baseURL: baseURL,
                defaultHeaders: {
                    await authSession.authorizationHeaders()
                }
            )
            todakClient = TodakClient.live(
                httpClient: authenticatedHTTPClient,
                sseClient: authenticatedSSEClient
            )
        } else {
            authClient = .unavailable
            fortuneClient = .unavailable
            myPageClient = .unavailable
            todakClient = .unavailable
        }

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
            $0.fortuneClient = fortuneClient
            $0.myPageClient = myPageClient
            $0.todakClient = todakClient
            $0.socialLoginClient = .live(configuration: configuration)
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
            #if DEBUG
            .dsDebugLayoutInspector()
            #endif
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
                mainTabView

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
        .onOpenURL { callbackURL in
            _ = GIDSignIn.sharedInstance.handle(callbackURL)
            // 외부 SDK의 고정 API 표기(`Url`)를 그대로 호출한다.
            // swiftlint:disable:next acronym_casing
            _ = AuthController.handleOpenUrl(url: callbackURL)
        }
    }

    @ViewBuilder
    private var mainTabView: some View {
        MainTabView(
            store: store.scope(state: \.mainTab, action: \.mainTab)
        )
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            PushNotificationDebugPanel()
                .padding(.top, 60)
                .padding(.trailing, 16)
        }
        #endif
    }
}
