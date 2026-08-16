import Foundation
import NetworkCore
import NotificationFeatureInterface

public extension NotificationClient {
    static func live(httpClient: HTTPClient) -> Self {
        Self(
            fetchNotifications: {
                try await performFetchNotifications(httpClient: httpClient)
            },
            markAsRead: { notificationID in
                try await performMarkAsRead(notificationID: notificationID, httpClient: httpClient)
            }
        )
    }
}

private func performFetchNotifications(httpClient: HTTPClient) async throws -> NotificationList {
    try await performRequest {
        let response: CommonResponseDTO<NotificationListResponseDTO> = try await httpClient.request(
            .get("/api/v1/notifications")
        )
        return try validateAndExtractData(response).toDomain()
    }
}

private func performMarkAsRead(notificationID: UUID, httpClient: HTTPClient) async throws {
    try await performRequest {
        let endpoint = Endpoint(
            method: .patch,
            path: "/api/v1/notifications/\(notificationID.uuidString.lowercased())/read"
        )
        let response: CommonResponseDTO<EmptyResponseDTO> = try await httpClient.request(endpoint)
        guard response.success else {
            guard let code = response.code else { throw NotificationClientError.invalidResponse }
            throw NotificationClientError.server(code: code, message: response.message)
        }
    }
}

private func performRequest<Value>(_ operation: () async throws -> Value) async throws -> Value {
    do {
        return try await operation()
    } catch is CancellationError {
        throw CancellationError()
    } catch {
        throw mapHTTPClientError(error)
    }
}

private func validateAndExtractData<T>(_ response: CommonResponseDTO<T>) throws -> T {
    guard response.success else {
        guard let code = response.code else { throw NotificationClientError.invalidResponse }
        throw NotificationClientError.server(code: code, message: response.message)
    }
    guard let data = response.data else { throw NotificationClientError.invalidResponse }
    return data
}

private func mapHTTPClientError(_ error: Error) -> NotificationClientError {
    switch error {
    case let error as NotificationClientError:
        error
    case let error as HTTPClientError:
        switch error {
        case let .unacceptableStatusCode(code, _): .httpStatus(code)
        case .decodingFailed, .emptyResponse, .invalidURL, .invalidResponse: .invalidResponse
        case .transportFailed: .transport
        }
    default:
        .transport
    }
}

private struct CommonResponseDTO<DataType: Decodable>: Decodable {
    let success: Bool
    let code: String?
    let message: String?
    let data: DataType?
}

private struct NotificationListResponseDTO: Decodable {
    let unreadCount: Int
    let notifications: [NotificationResponseDTO]

    func toDomain() throws -> NotificationList {
        NotificationList(
            unreadCount: unreadCount,
            notifications: try notifications.map { try $0.toDomain() }
        )
    }
}

private struct NotificationResponseDTO: Decodable {
    // OpenAPI 응답 필드명을 그대로 유지한다.
    // swiftlint:disable:next identifier_name
    let id: UUID
    let type: String
    let title: String
    let content: String
    let deepLink: String?
    let isRead: Bool
    let createdAt: String

    func toDomain() throws -> InAppNotification {
        guard let type = NotificationType(rawValue: type) else {
            throw NotificationClientError.unsupportedType(type)
        }
        guard let createdAt = parseISO8601Date(createdAt) else {
            throw NotificationClientError.invalidResponse
        }
        return InAppNotification(
            identifier: id,
            type: type,
            title: title,
            content: content,
            deepLink: deepLink.flatMap(URL.init(string:)),
            isRead: isRead,
            createdAt: createdAt
        )
    }
}

private func parseISO8601Date(_ value: String) -> Date? {
    let fractionalSecondsFormatter = ISO8601DateFormatter()
    fractionalSecondsFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    if let date = fractionalSecondsFormatter.date(from: value) {
        return date
    }

    let secondsFormatter = ISO8601DateFormatter()
    secondsFormatter.formatOptions = [.withInternetDateTime]
    return secondsFormatter.date(from: value)
}

private struct EmptyResponseDTO: Decodable {}
