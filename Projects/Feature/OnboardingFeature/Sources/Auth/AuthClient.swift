import ComposableArchitecture
import Foundation
import NetworkCore

public struct AuthClient: Sendable {
    public var login: @Sendable (SocialCredential) async throws -> AuthLoginResult
    public var signup: @Sendable (SignupInput) async throws -> SessionTokens

    public init(
        login: @escaping @Sendable (SocialCredential) async throws -> AuthLoginResult,
        signup: @escaping @Sendable (SignupInput) async throws -> SessionTokens = { _ in
            throw AuthClientError.notConfigured
        }
    ) {
        self.login = login
        self.signup = signup
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
        Self(
            login: { try await performLogin(httpClient: httpClient, credential: $0) },
            signup: { try await performSignup(httpClient: httpClient, input: $0) }
        )
    }
}

private func performLogin(
    httpClient: HTTPClient,
    credential: SocialCredential
) async throws -> AuthLoginResult {
    authDebugLog(
        "로그인 요청 시작 | provider=\(credential.provider.rawValue) | "
            + "OAuth credential 수신=\(!credential.oauthAccessToken.isEmpty) | "
            + "authorization code 수신=\(credential.authorizationCode != nil)"
    )

    let endpoint = try Endpoint.post("/api/v1/auth/login", body: LoginRequestDTO(credential: credential))

    do {
        let response: CommonResponseDTO<LoginResponseDTO> = try await httpClient.request(endpoint)

        guard response.success, let data = response.data else {
            authDebugLog("로그인 응답 형식 확인 실패 | success=\(response.success) | data 존재=\(response.data != nil)")
            throw AuthClientError.invalidResponse
        }

        let result = try data.toDomain()
        authDebugLog("로그인 응답 수신 | \(result.debugDescription)")
        return result
    } catch {
        throw mapAuthRequestError(error, operation: "로그인")
    }
}

private func performSignup(
    httpClient: HTTPClient,
    input: SignupInput
) async throws -> SessionTokens {
    authDebugLog("회원가입 요청 시작")

    let endpoint = try Endpoint.post("/api/v1/auth/signup", body: SignupRequestDTO(input: input))

    do {
        let response: CommonResponseDTO<SignupResponseDTO> = try await httpClient.request(endpoint)

        guard response.success,
              let data = response.data,
              !data.accessToken.isEmpty,
              !data.refreshToken.isEmpty else {
            authDebugLog("회원가입 응답 형식 확인 실패")
            throw AuthClientError.invalidResponse
        }

        authDebugLog("회원가입 응답 수신 | access/refresh token 수신=true")
        return SessionTokens(accessToken: data.accessToken, refreshToken: data.refreshToken)
    } catch {
        throw mapAuthRequestError(error, operation: "회원가입")
    }
}

private func mapAuthRequestError(_ error: Error, operation: String) -> AuthClientError {
    switch error {
    case let error as HTTPClientError:
        if case let .unacceptableStatusCode(code, _) = error {
            authDebugLog("\(operation) 요청 실패 | HTTP status=\(code)")
        } else {
            authDebugLog("\(operation) 요청 실패 | 네트워크 또는 응답 디코딩 오류")
        }
    case let error as AuthClientError:
        authDebugLog("\(operation) 요청 실패 | 인증 응답 검증 오류=\(String(describing: error))")
        return error
    case is CancellationError:
        authDebugLog("\(operation) 요청 취소")
        return .cancelled
    default:
        authDebugLog("\(operation) 요청 실패 | 알 수 없는 오류")
    }

    return AuthClientError(error)
}

public enum AuthLoginResult: Equatable, Sendable {
    case newMember(onboardingToken: String)
    case existingMember(SessionTokens)
}

private extension AuthLoginResult {
    var debugDescription: String {
        switch self {
        case .newMember:
            "신규 회원 | onboardingToken 수신=true"
        case .existingMember:
            "기존 회원 | access/refresh token 수신=true"
        }
    }
}

public struct SessionTokens: Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String

    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

public struct SignupInput: Equatable, Sendable {
    public let onboardingToken: String
    public let name: String
    public let birthDate: String
    public let birthTime: String
    public let calendarType: String
    public let gender: String
    public let job: String
    public let relationshipStatus: String

    public init(
        onboardingToken: String,
        name: String,
        birthDate: String,
        birthTime: String,
        calendarType: String,
        gender: String,
        job: String,
        relationshipStatus: String
    ) {
        self.onboardingToken = onboardingToken
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.calendarType = calendarType
        self.gender = gender
        self.job = job
        self.relationshipStatus = relationshipStatus
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

private struct SignupRequestDTO: Encodable {
    let onboardingToken: String
    let name: String
    let birthDate: String
    let birthTime: String
    let calendarType: String
    let gender: String
    let job: String
    let relationshipStatus: String

    init(input: SignupInput) {
        onboardingToken = input.onboardingToken
        name = input.name
        birthDate = input.birthDate
        birthTime = input.birthTime
        calendarType = input.calendarType
        gender = input.gender
        job = input.job
        relationshipStatus = input.relationshipStatus
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

private struct SignupResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

private func authDebugLog(_ message: String) {
#if DEBUG
    print("[Auth] \(message)")
#endif
}
