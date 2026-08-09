import Foundation

/// 서버 인증에 사용하는 access/refresh token 쌍입니다.
public struct SessionTokens: Codable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String

    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
