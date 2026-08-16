import Foundation
import NetworkCore

public extension TodakClient {
    static func live(httpClient: HTTPClient, sseClient: SSEClient) -> Self {
        Self(
            fetchEntry: {
                try await performFetchEntry(httpClient: httpClient)
            },
            fetchConversations: {
                try await performFetchConversations(httpClient: httpClient)
            },
            fetchConversation: { conversationID in
                try await performFetchConversation(httpClient: httpClient, conversationID: conversationID)
            },
            deleteConversation: { conversationID in
                try await performDeleteConversation(httpClient: httpClient, conversationID: conversationID)
            },
            sendMessage: { conversationID, content in
                messageEvents(
                    sseClient: sseClient,
                    conversationID: conversationID,
                    content: content
                )
            }
        )
    }
}

private func performFetchEntry(httpClient: HTTPClient) async throws -> TodakEntry {
    do {
        let response: CommonResponseDTO<EntryResponseDTO> = try await httpClient.request(
            .get("/api/v1/chat/entry")
        )
        return try extractData(response).toDomain()
    } catch is CancellationError {
        throw CancellationError()
    } catch {
        throw mapClientError(error)
    }
}

private func performFetchConversations(httpClient: HTTPClient) async throws -> [TodakConversationSummary] {
    do {
        let response: CommonResponseDTO<ConversationListResponseDTO> = try await httpClient.request(
            .get("/api/v1/chat/conversations")
        )
        return try extractData(response).conversations.map { try $0.toDomain() }
    } catch is CancellationError {
        throw CancellationError()
    } catch {
        throw mapClientError(error)
    }
}

private func performFetchConversation(httpClient: HTTPClient, conversationID: UUID) async throws -> TodakConversation {
    do {
        let response: CommonResponseDTO<ConversationDetailResponseDTO> = try await httpClient.request(
            .get("/api/v1/chat/conversations/\(conversationID.uuidString.lowercased())")
        )
        return try extractData(response).toDomain()
    } catch is CancellationError {
        throw CancellationError()
    } catch {
        throw mapClientError(error)
    }
}

private func performDeleteConversation(httpClient: HTTPClient, conversationID: UUID) async throws {
    do {
        let endpoint = Endpoint(
            method: .delete,
            path: "/api/v1/chat/conversations/\(conversationID.uuidString.lowercased())"
        )
        let response: CommonResponseDTO<EmptyResponseDTO> = try await httpClient.request(endpoint)
        try validateSuccess(response)
    } catch is CancellationError {
        throw CancellationError()
    } catch {
        throw mapClientError(error)
    }
}

private func messageEvents(
    sseClient: SSEClient,
    conversationID: UUID?,
    content: String
) -> AsyncThrowingStream<TodakStreamEvent, Error> {
    AsyncThrowingStream { continuation in
        let task = Task {
            do {
                let request = SendMessageRequestDTO(
                    conversationID: conversationID,
                    content: content
                )
                let endpoint = try Endpoint.post(
                    "/api/v1/chat/messages",
                    body: request,
                    headers: ["Accept": "text/event-stream"]
                )
                TodakSSEDebugLogger.sendRequested(
                    conversationID: conversationID,
                    contentLength: content.count
                )

                var receivedDone = false

                for try await event in sseClient.events(for: endpoint) {
                    TodakSSEDebugLogger.rawEventReceived(
                        name: event.event,
                        dataLength: event.data?.utf8.count
                    )
                    guard let data = event.data else {
                        TodakSSEDebugLogger.eventWithoutDataIgnored(name: event.event)
                        continue
                    }

                    let streamEvent: TodakStreamEvent
                    if let eventName = event.event {
                        streamEvent = try decodeStreamEvent(name: eventName, data: data)
                    } else {
                        streamEvent = try decodeDataOnlyStreamError(data: data)
                    }
                    if case .done = streamEvent { receivedDone = true }
                    TodakSSEDebugLogger.decoded(streamEvent)
                    continuation.yield(streamEvent)
                }
                TodakSSEDebugLogger.streamEnded(receivedDone: receivedDone)
                continuation.finish()
            } catch is CancellationError {
                TodakSSEDebugLogger.streamCancelled()
                continuation.finish(throwing: CancellationError())
            } catch let error as TodakClientError {
                TodakSSEDebugLogger.streamFailed(error)
                continuation.finish(throwing: error)
            } catch let error as SSEClientError {
                TodakSSEDebugLogger.streamFailed(error)
                continuation.finish(throwing: mapSSEClientError(error))
            } catch {
                TodakSSEDebugLogger.streamFailed(error)
                continuation.finish(throwing: TodakClientError.transport)
            }
        }

        continuation.onTermination = { @Sendable _ in task.cancel() }
    }
}

func decodeStreamEvent(name: String, data: String) throws -> TodakStreamEvent {
    let decoder = JSONDecoder()
    guard let dataValue = data.data(using: .utf8) else {
        throw TodakClientError.invalidResponse
    }

    switch name {
    case "start":
        let dto = try decoder.decode(StreamStartDTO.self, from: dataValue)
        return .start(
            conversationID: dto.conversationID,
            userMessageID: dto.userMessageID,
            assistantMessageID: dto.assistantMessageID,
            quota: TodakQuota(used: dto.quotaUsed, limit: dto.quotaLimit)
        )
    case "delta":
        return .delta(try decoder.decode(StreamDeltaDTO.self, from: dataValue).text)
    case "action":
        return .action(try decoder.decode(MessageActionDTO.self, from: dataValue).toDomain())
    case "done":
        return .done(
            assistantMessageID: try decoder.decode(StreamDoneDTO.self, from: dataValue).assistantMessageID
        )
    case "error":
        let dto = try decoder.decode(StreamErrorDTO.self, from: dataValue)
        return .error(code: dto.code, message: dto.message)
    default:
        throw TodakClientError.invalidResponse
    }
}

func decodeDataOnlyStreamError(data: String) throws -> TodakStreamEvent {
    let decoder = JSONDecoder()
    guard let dataValue = data.data(using: .utf8) else {
        throw TodakClientError.invalidResponse
    }

    let dto = try decoder.decode(StreamErrorDTO.self, from: dataValue)
    return .error(code: dto.code, message: dto.message)
}

private func extractData<T>(_ response: CommonResponseDTO<T>) throws -> T {
    try validateSuccess(response)
    guard let data = response.data else { throw TodakClientError.invalidResponse }
    return data
}

private func validateSuccess<T>(_ response: CommonResponseDTO<T>) throws {
    guard response.success else {
        guard let code = response.code else { throw TodakClientError.invalidResponse }
        throw TodakClientError.server(code: code, message: response.message)
    }
}

private func mapClientError(_ error: Error) -> TodakClientError {
    switch error {
    case let clientError as TodakClientError:
        return clientError
    case let httpError as HTTPClientError:
        switch httpError {
        case let .unacceptableStatusCode(code, _):
            return .httpStatus(code)
        case .decodingFailed, .emptyResponse, .invalidURL, .invalidResponse:
            return .invalidResponse
        case .transportFailed:
            return .transport
        }
    default:
        return .transport
    }
}

private func mapSSEClientError(_ error: SSEClientError) -> TodakClientError {
    switch error {
    case let .unacceptableStatusCode(code):
        return .httpStatus(code)
    case .invalidResponse, .invalidContentType, .invalidUTF8:
        return .invalidResponse
    case .transportFailed:
        return .transport
    }
}

private struct CommonResponseDTO<Data: Decodable & Sendable>: Decodable, Sendable {
    let success: Bool
    let code: String?
    let message: String?
    let data: Data?
}

private struct EmptyResponseDTO: Decodable, Sendable {}

private struct ConversationListResponseDTO: Decodable, Sendable {
    let conversations: [ConversationSummaryDTO]
}

private struct ConversationSummaryDTO: Decodable, Sendable {
    let conversationID: UUID
    let title: String
    let lastMessageAt: String?
    let unread: Bool

    func toDomain() throws -> TodakConversationSummary {
        let date = try lastMessageAt.map(parseDateTime)
        return TodakConversationSummary(
            id: conversationID,
            title: title,
            lastMessageAt: date,
            unread: unread
        )
    }

    enum CodingKeys: String, CodingKey {
        case conversationID = "id"
        case title
        case lastMessageAt
        case unread
    }
}

private struct ConversationDetailResponseDTO: Decodable, Sendable {
    let conversationID: UUID
    let title: String
    let messages: [MessageDTO]

    func toDomain() throws -> TodakConversation {
        TodakConversation(
            id: conversationID,
            title: title,
            messages: try messages.map { try $0.toDomain() }
        )
    }

    enum CodingKeys: String, CodingKey {
        case conversationID = "id"
        case title
        case messages
    }
}

private struct MessageDTO: Decodable, Sendable {
    let messageID: UUID
    let role: String
    let content: String
    let status: String
    let action: MessageActionDTO?
    let createdAt: String?

    func toDomain() throws -> TodakMessage {
        TodakMessage(
            id: messageID,
            role: mapRole(role),
            content: content,
            status: mapStatus(status),
            action: try action?.toDomain(),
            createdAt: try createdAt.map(parseDateTime)
        )
    }

    enum CodingKeys: String, CodingKey {
        case messageID = "id"
        case role
        case content
        case status
        case action
        case createdAt
    }
}

private struct MessageActionDTO: Decodable, Sendable {
    let type: String
    let label: String
    let category: String
    let date: String

    func toDomain() throws -> TodakMessageAction {
        TodakMessageAction(
            type: type,
            label: label,
            category: try mapCategory(category),
            date: try parseDate(date)
        )
    }
}

private struct SendMessageRequestDTO: Encodable, Sendable {
    let conversationID: UUID?
    let content: String

    enum CodingKeys: String, CodingKey {
        case conversationID = "conversationId"
        case content
    }
}

private struct StreamStartDTO: Decodable, Sendable {
    let conversationID: UUID
    let userMessageID: UUID
    let assistantMessageID: UUID
    let quotaUsed: Int
    let quotaLimit: Int

    enum CodingKeys: String, CodingKey {
        case conversationID = "conversationId"
        case userMessageID = "userMessageId"
        case assistantMessageID = "assistantMessageId"
        case quotaUsed
        case quotaLimit
    }
}

private struct StreamDeltaDTO: Decodable, Sendable { let text: String }

private struct StreamDoneDTO: Decodable, Sendable {
    let assistantMessageID: UUID

    enum CodingKeys: String, CodingKey {
        case assistantMessageID = "assistantMessageId"
    }
}

private struct StreamErrorDTO: Decodable, Sendable {
    let code: String
    let message: String
}

func mapCategory(_ value: String) throws -> TodakCategory {
    guard let category = TodakCategory(rawValue: value) else {
        throw TodakClientError.unsupportedCategory(value)
    }
    return category
}

private func mapRole(_ value: String) -> TodakMessage.Role {
    switch value.uppercased() {
    case "USER": .user
    case "ASSISTANT": .assistant
    default: .unknown(value)
    }
}

private func mapStatus(_ value: String) -> TodakMessage.Status {
    switch value.uppercased() {
    case "STREAMING", "IN_PROGRESS": .streaming
    case "COMPLETED", "DONE": .completed
    case "FAILED", "ERROR": .failed
    default: .unknown(value)
    }
}
