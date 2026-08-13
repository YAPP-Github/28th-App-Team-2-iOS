import ComposableArchitecture
import Foundation

public struct TodakClient: Sendable {
    public var fetchConversations: @Sendable () async throws -> [TodakConversationSummary]
    public var fetchConversation: @Sendable (UUID) async throws -> TodakConversation
    public var deleteConversation: @Sendable (UUID) async throws -> Void
    public var sendMessage: @Sendable (UUID?, String) -> AsyncThrowingStream<TodakStreamEvent, Error>

    public init(
        fetchConversations: @escaping @Sendable () async throws -> [TodakConversationSummary],
        fetchConversation: @escaping @Sendable (UUID) async throws -> TodakConversation,
        deleteConversation: @escaping @Sendable (UUID) async throws -> Void,
        sendMessage: @escaping @Sendable (UUID?, String) -> AsyncThrowingStream<TodakStreamEvent, Error>
    ) {
        self.fetchConversations = fetchConversations
        self.fetchConversation = fetchConversation
        self.deleteConversation = deleteConversation
        self.sendMessage = sendMessage
    }
}

public enum TodakClientError: Error, Equatable, Sendable {
    case notConfigured
    case server(code: String, message: String?)
    case httpStatus(Int)
    case invalidResponse
    case unsupportedCategory(String)
    case transport
}

extension TodakClient: DependencyKey {
    public static let liveValue = TodakClient.unavailable
    public static let testValue = TodakClient.unavailable
}

public extension DependencyValues {
    var todakClient: TodakClient {
        get { self[TodakClient.self] }
        set { self[TodakClient.self] = newValue }
    }
}

public extension TodakClient {
    static let unavailable = Self(
        fetchConversations: { throw TodakClientError.notConfigured },
        fetchConversation: { _ in throw TodakClientError.notConfigured },
        deleteConversation: { _ in throw TodakClientError.notConfigured },
        sendMessage: { _, _ in
            AsyncThrowingStream { continuation in
                continuation.finish(throwing: TodakClientError.notConfigured)
            }
        }
    )
}
