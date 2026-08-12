import Combine
import FirebaseCore
import FirebaseMessaging
import UIKit
import UserNotifications

@MainActor
final class PushNotificationTokenStore: ObservableObject {
    static let shared = PushNotificationTokenStore()

    private var registrationToken: String?
    private var upload: (@Sendable (String) async throws -> Void)?
    private var isAuthenticated = false

#if DEBUG
    @Published private(set) var debugStatus: PushNotificationDebugStatus = .waitingForToken
    @Published private(set) var apnsDebugStatus: PushNotificationAPNsDebugStatus = .waiting
#endif

    func setUpload(_ upload: @escaping @Sendable (String) async throws -> Void) {
        self.upload = upload
        if isAuthenticated {
            uploadCurrentToken()
        }
    }

    func receive(_ registrationToken: String) {
        self.registrationToken = registrationToken
        guard isAuthenticated else {
#if DEBUG
            debugStatus = .waitingForAuthentication
#endif
            return
        }
        uploadCurrentToken()
    }

    func uploadCurrentToken() {
        isAuthenticated = true
        guard let registrationToken, let upload else {
#if DEBUG
            debugStatus = .waitingForToken
#endif
            return
        }

#if DEBUG
        debugStatus = .uploading
#endif

        Task {
            do {
                try await upload(registrationToken)
#if DEBUG
                debugStatus = .registered
#endif
            } catch {
#if DEBUG
                debugStatus = .failed(String(describing: error))
#endif
            }
        }
    }

    func receiveAPNsRegistration() {
#if DEBUG
        apnsDebugStatus = .registered
#endif
    }

    func receiveAPNsRegistrationFailure(_ error: Error) {
#if DEBUG
        apnsDebugStatus = .failed(String(describing: error))
#endif
    }

#if DEBUG
    func copyRegistrationToken() -> Bool {
        guard let registrationToken else { return false }
        UIPasteboard.general.string = registrationToken
        return true
    }
#endif
}

#if DEBUG
enum PushNotificationAPNsDebugStatus: Equatable {
    case waiting
    case registered
    case failed(String)

    var title: String {
        switch self {
        case .waiting:
            "APNs 등록 대기 중"
        case .registered:
            "APNs 기기 등록 성공"
        case let .failed(error):
            "APNs 기기 등록 실패: \(error)"
        }
    }
}
#endif

#if DEBUG
enum PushNotificationDebugStatus: Equatable {
    case waitingForToken
    case waitingForAuthentication
    case uploading
    case registered
    case failed(String)

    var title: String {
        switch self {
        case .waitingForToken:
            "FCM 토큰 대기 중"
        case .waitingForAuthentication:
            "로그인 후 토큰 등록 대기"
        case .uploading:
            "서버에 토큰 등록 중"
        case .registered:
            "서버 등록 성공 (HTTP 2xx)"
        case let .failed(error):
            "서버 등록 실패: \(error)"
        }
    }
}
#endif

final class PushNotificationAppDelegate: NSObject,
    UIApplicationDelegate,
    MessagingDelegate,
    UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        Task { @MainActor in
            PushNotificationTokenStore.shared.receiveAPNsRegistration()
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task { @MainActor in
            PushNotificationTokenStore.shared.receiveAPNsRegistrationFailure(error)
        }
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken, !fcmToken.isEmpty else { return }

        Task { @MainActor in
            PushNotificationTokenStore.shared.receive(fcmToken)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.badge, .banner, .sound])
    }
}
