import Foundation
import NetworkCore
import Testing
@testable import TodakFeature

@Suite
struct TodakClientTests {
    @Test("SSE 오류 이벤트를 서버 안내 문구와 함께 매핑한다")
    func streamErrorMapping() throws {
        let event = try decodeStreamEvent(
            name: "error",
            data: #"{"code":"CHAT-500","message":"토닥이 답변 생성에 실패했습니다."}"#
        )

        #expect(event == .error(code: "CHAT-500", message: "토닥이 답변 생성에 실패했습니다."))
    }

    @Test("event 이름 없는 quota 오류 data를 서버 안내 문구와 함께 매핑한다")
    func dataOnlyQuotaErrorMapping() throws {
        let event = try decodeDataOnlyStreamError(
            data: #"{"code":"CHAT-429","message":"오늘 무료 채팅 횟수를 모두 사용했습니다."}"#
        )

        #expect(event == .error(code: "CHAT-429", message: "오늘 무료 채팅 횟수를 모두 사용했습니다."))
    }

    @Test("대화 상세의 메시지와 액션을 매핑한다")
    func fetchConversationMapping() async throws {
        let conversationID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let json = """
        {
          "success": true,
          "code": "200",
          "data": {
            "id": "11111111-1111-1111-1111-111111111111",
            "title": "오늘의 행운",
            "messages": [{
              "id": "22222222-2222-2222-2222-222222222222",
              "role": "ASSISTANT",
              "content": "좋은 날이에요.",
              "status": "COMPLETED",
              "createdAt": "2026-08-12T10:30:00+09:00",
              "action": {
                "type": "LUCKY_ACTION",
                "label": "행운 액션 보기",
                "category": "HEALTH",
                "date": "2026-08-12"
              }
            }]
          }
        }
        """
        let client = makeLiveClient { request in
            #expect(request.url?.path == "/api/v1/chat/conversations/\(conversationID.uuidString.lowercased())")
            return (Data(json.utf8), try response(for: request, statusCode: 200))
        }

        let conversation = try await client.fetchConversation(conversationID)
        #expect(conversation.id == conversationID)
        #expect(conversation.messages.first?.role == .assistant)
        #expect(conversation.messages.first?.status == .completed)
        #expect(conversation.messages.first?.action?.category == .health)
    }

    @Test("삭제 API의 success false를 서버 오류로 전달한다")
    func deleteFailureMapping() async throws {
        let conversationID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let json = """
        { "success": false, "code": "CHAT_404", "message": "대화를 찾을 수 없습니다.", "data": null }
        """
        let client = makeLiveClient { request in
            #expect(request.httpMethod == "DELETE")
            return (Data(json.utf8), try response(for: request, statusCode: 200))
        }

        await #expect(
            throws: TodakClientError.server(code: "CHAT_404", message: "대화를 찾을 수 없습니다.")
        ) {
            try await client.deleteConversation(conversationID)
        }
    }
}

private func makeLiveClient(transport: @escaping HTTPClient.Transport) -> TodakClient {
    let baseURL = URL(string: "https://api.todakun.com")!
    return TodakClient.live(
        httpClient: HTTPClient(baseURL: baseURL, transport: transport),
        sseClient: SSEClient(baseURL: baseURL)
    )
}

private func response(for request: URLRequest, statusCode: Int) throws -> HTTPURLResponse {
    try #require(
        HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
    )
}
