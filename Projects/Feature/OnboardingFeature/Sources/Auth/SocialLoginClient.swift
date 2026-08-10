@preconcurrency import AuthenticationServices
import ComposableArchitecture
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
import UIKit

public struct SocialLoginClient: Sendable {
    public var signIn: @MainActor @Sendable (SocialProvider) async throws -> SocialCredential

    public init(
        signIn: @escaping @MainActor @Sendable (SocialProvider) async throws -> SocialCredential
    ) {
        self.signIn = signIn
    }
}

extension SocialLoginClient: DependencyKey {
    public static let liveValue = SocialLoginClient.unavailable
    public static let testValue = SocialLoginClient.unavailable
}

public extension DependencyValues {
    var socialLoginClient: SocialLoginClient {
        get { self[SocialLoginClient.self] }
        set { self[SocialLoginClient.self] = newValue }
    }
}

public extension SocialLoginClient {
    static let unavailable = Self { _ in
        throw SocialLoginError.notConfigured
    }

    static func live(configuration: OAuthConfiguration) -> Self {
        Self { provider in
            switch provider {
            case .kakao:
                guard configuration.kakaoNativeAppKey != nil else {
                    throw SocialLoginError.notConfigured
                }
                return try await KakaoLoginCoordinator.signIn()

            case .google:
                guard let clientID = configuration.googleIOSClientID else {
                    throw SocialLoginError.notConfigured
                }
                return try await GoogleLoginCoordinator.signIn(clientID: clientID)

            case .apple:
                return try await AppleLoginCoordinator.signIn()
            }
        }
    }
}

public enum SocialProvider: String, CaseIterable, Equatable, Sendable {
    case kakao = "KAKAO"
    case google = "GOOGLE"
    case apple = "APPLE"
}

public struct SocialCredential: Equatable, Sendable {
    public let provider: SocialProvider
    public let oauthAccessToken: String
    public let authorizationCode: String?

    public init(
        provider: SocialProvider,
        oauthAccessToken: String,
        authorizationCode: String? = nil
    ) {
        self.provider = provider
        self.oauthAccessToken = oauthAccessToken
        self.authorizationCode = authorizationCode
    }
}

public enum SocialLoginError: Error, Equatable, Sendable {
    case notConfigured
    case cancelled
    case failed

    init(_ error: Error) {
        if let error = error as? SocialLoginError {
            self = error
        } else if let error = error as? ASAuthorizationError, error.code == .canceled {
            self = .cancelled
        } else {
            self = .failed
        }
    }
}

@MainActor
private enum KakaoLoginCoordinator {
    static func signIn() async throws -> SocialCredential {
        try await withCheckedThrowingContinuation { continuation in
            let completion: (OAuthToken?, Error?) -> Void = { token, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let token {
                    continuation.resume(
                        returning: SocialCredential(
                            provider: .kakao,
                            oauthAccessToken: token.accessToken
                        )
                    )
                } else {
                    continuation.resume(throwing: SocialLoginError.failed)
                }
            }

            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(completion: completion)
            } else {
                UserApi.shared.loginWithKakaoAccount(completion: completion)
            }
        }
    }
}

@MainActor
private enum GoogleLoginCoordinator {
    static func signIn(clientID: String) async throws -> SocialCredential {
        guard let presentingViewController = UIApplication.shared.todakunTopViewController else {
            throw SocialLoginError.failed
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                throw SocialLoginError.failed
            }

            return SocialCredential(provider: .google, oauthAccessToken: idToken)
        } catch let error as GIDSignInError where error.code == .canceled {
            throw SocialLoginError.cancelled
        }
    }
}

@MainActor
private final class AppleLoginCoordinator: NSObject,
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {
    private var continuation: CheckedContinuation<SocialCredential, Error>?

    static func signIn() async throws -> SocialCredential {
        let coordinator = AppleLoginCoordinator()
        return try await coordinator.performRequest()
    }

    private func performRequest() async throws -> SocialCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }),
              let authorizationCode = credential.authorizationCode.flatMap({ String(data: $0, encoding: .utf8) }) else {
            continuation?.resume(throwing: SocialLoginError.failed)
            continuation = nil
            return
        }

        continuation?.resume(
            returning: SocialCredential(
                provider: .apple,
                oauthAccessToken: identityToken,
                authorizationCode: authorizationCode
            )
        )
        continuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.todakunTopViewController?.view.window
            ?? ASPresentationAnchor()
    }
}

private extension UIApplication {
    var todakunTopViewController: UIViewController? {
        let keyWindow = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow })

        guard let rootViewController = keyWindow?.rootViewController else {
            return nil
        }

        var topViewController = rootViewController
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}
