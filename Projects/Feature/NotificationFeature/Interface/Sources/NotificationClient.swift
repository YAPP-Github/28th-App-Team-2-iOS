import Foundation

public struct NotificationClient: Sendable {
    public var fetchNotifications: @Sendable () async throws -> NotificationList
    public var markAsRead: @Sendable (UUID) async throws -> Void

    public init(
        fetchNotifications: @escaping @Sendable () async throws -> NotificationList,
        markAsRead: @escaping @Sendable (UUID) async throws -> Void
    ) {
        self.fetchNotifications = fetchNotifications
        self.markAsRead = markAsRead
    }
}

public enum NotificationClientError: Error, Equatable, Sendable {
    case notConfigured
    case server(code: String, message: String?)
    case httpStatus(Int)
    case invalidResponse
    case unsupportedType(String)
    case transport

    public var userMessage: String {
        switch self {
        case .notConfigured:
            "알림 서비스를 사용할 수 없어요."
        case .server, .httpStatus, .invalidResponse, .unsupportedType:
            "알림을 불러오지 못했어요."
        case .transport:
            "네트워크 연결 상태를 확인해주세요."
        }
    }
}

public extension NotificationClient {
    static let unavailable = Self(
        fetchNotifications: { throw NotificationClientError.notConfigured },
        markAsRead: { _ in throw NotificationClientError.notConfigured }
    )
}
