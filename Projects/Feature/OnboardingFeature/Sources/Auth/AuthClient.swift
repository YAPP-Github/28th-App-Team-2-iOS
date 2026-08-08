import ComposableArchitecture
import Foundation
import NetworkCore

public struct AuthClient: Sendable {
    public var login: @Sendable (SocialCredential) async throws -> AuthLoginResult

    public init(login: @escaping @Sendable (SocialCredential) async throws -> AuthLoginResult) {
        self.login = login
    }
}

extension AuthClient: DependencyKey {
    public static let liveValue = AuthClient.unavailable
    public static let testValue = AuthClient.unavailable
}

public extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

public extension AuthClient {
    static let unavailable = Self { _ in
        throw AuthClientError.notConfigured
    }

    static func live(httpClient: HTTPClient) -> Self {
        Self { credential in
            authDebugLog(
                "로그인 요청 시작 | provider=\(credential.provider.rawValue) | "
                    + "OAuth credential 수신=\(!credential.oauthAccessToken.isEmpty) | "
                    + "authorization code 수신=\(credential.authorizationCode != nil)"
            )

            let endpoint = try Endpoint.post(
                "/api/v1/auth/login",
                body: LoginRequestDTO(credential: credential)
            )

            do {
                let response: CommonResponseDTO<LoginResponseDTO> = try await httpClient.request(endpoint)

                guard response.success, let data = response.data else {
                    authDebugLog(
                        "로그인 응답 형식 확인 실패 | success=\(response.success) | data 존재=\(response.data != nil)"
                    )
                    throw AuthClientError.invalidResponse
                }

                let result = try data.toDomain()
                switch result {
                case .newMember:
                    authDebugLog("로그인 응답 수신 | 신규 회원 | onboardingToken 수신=true")
                case .existingMember:
                    authDebugLog("로그인 응답 수신 | 기존 회원 | access/refresh token 수신=true")
                }

                return result
            } catch let error as HTTPClientError {
                if case let .unacceptableStatusCode(code, _) = error {
                    authDebugLog("로그인 요청 실패 | HTTP status=\(code)")
                } else {
                    authDebugLog("로그인 요청 실패 | 네트워크 또는 응답 디코딩 오류")
                }
                throw AuthClientError(error)
            } catch let error as AuthClientError {
                authDebugLog("로그인 요청 실패 | 인증 응답 검증 오류=\(String(describing: error))")
                throw error
            } catch is CancellationError {
                authDebugLog("로그인 요청 취소")
                throw AuthClientError.cancelled
            } catch {
                authDebugLog("로그인 요청 실패 | 알 수 없는 오류")
                throw AuthClientError.requestFailed
            }
        }
    }
}

public enum AuthLoginResult: Equatable, Sendable {
    case newMember(onboardingToken: String)
    case existingMember(SessionTokens)
}

public struct SessionTokens: Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String

    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

public enum AuthClientError: Error, Equatable, Sendable {
    case notConfigured
    case expired
    case invalidResponse
    case requestFailed
    case cancelled

    init(_ error: Error) {
        if let error = error as? AuthClientError {
            self = error
            return
        }

        if case let HTTPClientError.unacceptableStatusCode(code, _) = error, code == 401 {
            self = .expired
            return
        }

        self = .requestFailed
    }
}

private struct LoginRequestDTO: Encodable {
    let provider: String
    let oauthAccessToken: String
    let authorizationCode: String?

    init(credential: SocialCredential) {
        provider = credential.provider.rawValue
        oauthAccessToken = credential.oauthAccessToken
        authorizationCode = credential.authorizationCode
    }
}

private struct CommonResponseDTO<Data: Decodable>: Decodable {
    let success: Bool
    let data: Data?
}

private struct LoginResponseDTO: Decodable {
    let isNewMember: Bool
    let accessToken: String?
    let refreshToken: String?
    let onboardingToken: String?

    func toDomain() throws -> AuthLoginResult {
        if isNewMember, let onboardingToken, !onboardingToken.isEmpty {
            return .newMember(onboardingToken: onboardingToken)
        }

        if !isNewMember,
           let accessToken,
           let refreshToken,
           !accessToken.isEmpty,
           !refreshToken.isEmpty {
            return .existingMember(
                SessionTokens(accessToken: accessToken, refreshToken: refreshToken)
            )
        }

        throw AuthClientError.invalidResponse
    }
}

private func authDebugLog(_ message: String) {
#if DEBUG
    print("[Auth] \(message)")
#endif
}
