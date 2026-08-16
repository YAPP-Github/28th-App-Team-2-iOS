import Foundation

public struct LuckyActionClient: Sendable {
    public var fetchToday: @Sendable () async throws -> [LuckyAction]
    public var fetchByDate: @Sendable (Date) async throws -> [LuckyAction]
    public var toggleAchievement: @Sendable (UUID) async throws -> LuckyAction

    public init(
        fetchToday: @escaping @Sendable () async throws -> [LuckyAction],
        fetchByDate: @escaping @Sendable (Date) async throws -> [LuckyAction],
        toggleAchievement: @escaping @Sendable (UUID) async throws -> LuckyAction
    ) {
        self.fetchToday = fetchToday
        self.fetchByDate = fetchByDate
        self.toggleAchievement = toggleAchievement
    }
}

public enum LuckyActionClientError: Error, Equatable, Sendable {
    case notConfigured
    case server(code: String, message: String?)
    case httpStatus(Int)
    case invalidResponse
    case unsupportedCategory(String)
    case transport

    public var userMessage: String {
        switch self {
        case .notConfigured:
            "행운 액션 서비스를 사용할 수 없어요."
        case .server, .httpStatus, .invalidResponse, .unsupportedCategory:
            "행운 액션 정보를 불러오지 못했어요."
        case .transport:
            "네트워크 연결 상태를 확인해주세요."
        }
    }
}

public extension LuckyActionClient {
    static let unavailable = Self(
        fetchToday: { throw LuckyActionClientError.notConfigured },
        fetchByDate: { _ in throw LuckyActionClientError.notConfigured },
        toggleAchievement: { _ in throw LuckyActionClientError.notConfigured }
    )
}
