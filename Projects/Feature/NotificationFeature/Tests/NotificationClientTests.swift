import Foundation
import NetworkCore
import NotificationFeatureInterface
import Testing
@testable import NotificationFeature

@Suite
struct NotificationClientTests {
    @Test("알림 목록과 unread count를 조회한다")
    func fetchesNotifications() async throws {
        let client = makeClient { request in
            #expect(request.httpMethod == "GET")
            #expect(request.url?.path == "/api/v1/notifications")
            return (
                Data(
                    """
                    {
                      "success": true,
                      "data": {
                        "unreadCount": 2,
                        "notifications": [
                          {
                            "id": "00000000-0000-0000-0000-000000000001",
                            "type": "AI_COMPLETE",
                            "title": "토닥이 답변",
                            "content": "토닥이 답변이 도착했어요.",
                            "isRead": false,
                            "createdAt": "2026-08-16T00:00:00Z"
                          }
                        ]
                      }
                    }
                """.utf8
                ),
                try makeHTTPResponse(url: try #require(request.url), statusCode: 200)
            )
        }

        let list = try await client.fetchNotifications()

        #expect(list.unreadCount == 2)
        #expect(list.notifications.first?.type == .aiComplete)
        #expect(list.notifications.first?.isRead == false)
    }

    @Test("관리자 NOTICE 생성 응답과 같은 목록 payload를 디코딩한다")
    func decodesNoticePayloadWithFractionalSecondsAndDeepLink() async throws {
        let client = makeClient { request in
            let payload = """
            {
              "success": true,
              "code": "COMMON-200",
              "message": "조회가 완료되었습니다",
              "data": {
                "unreadCount": 1,
                "notifications": [
                  {
                    "id": "00000000-0000-0000-0000-000000000002",
                    "type": "NOTICE",
                    "title": "테스트",
                    "content": "테스트 입니다.",
                    "deepLink": "todakun://notice/1",
                    "isRead": false,
                    "createdAt": "2026-08-16T07:08:36.234694Z"
                  }
                ]
              },
              "timestamp": "2026-08-16T07:09:35.654549928"
            }
            """
            return (
                Data(payload.utf8),
                try makeHTTPResponse(url: try #require(request.url), statusCode: 200)
            )
        }

        let list = try await client.fetchNotifications()

        #expect(list.unreadCount == 1)
        #expect(list.notifications.first?.type == .notice)
        #expect(list.notifications.first?.title == "테스트")
        #expect(list.notifications.first?.deepLink == URL(string: "todakun://notice/1"))
    }

    @Test("탭한 알림만 PATCH 읽음 처리한다")
    func marksNotificationAsRead() async throws {
        let notificationID = UUID(1)
        let client = makeClient { request in
            #expect(request.httpMethod == "PATCH")
            #expect(
                request.url?.path
                    == "/api/v1/notifications/\(notificationID.uuidString.lowercased())/read"
            )
            return (
                Data("{ \"success\": true, \"data\": null }".utf8),
                try makeHTTPResponse(url: try #require(request.url), statusCode: 200)
            )
        }

        try await client.markAsRead(notificationID)
    }

    @Test("지원하지 않는 타입은 안전하게 오류로 변환한다")
    func mapsUnknownTypeToClientError() async {
        let client = makeClient { request in
            (
                Data(
                    """
                    {
                      "success": true,
                      "data": {
                        "unreadCount": 1,
                        "notifications": [
                          {
                            "id": "00000000-0000-0000-0000-000000000001",
                            "type": "UNKNOWN",
                            "title": "알림",
                            "content": "내용",
                            "isRead": false,
                            "createdAt": "2026-08-16T00:00:00Z"
                          }
                        ]
                      }
                    }
                    """.utf8
                ),
                try makeHTTPResponse(url: try #require(request.url), statusCode: 200)
            )
        }

        await #expect(throws: NotificationClientError.unsupportedType("UNKNOWN")) {
            try await client.fetchNotifications()
        }
    }
}

private func makeClient(transport: @escaping HTTPClient.Transport) -> NotificationClient {
    NotificationClient.live(
        httpClient: HTTPClient(
            baseURL: URL(string: "https://api.todakun.com")!,
            transport: transport
        )
    )
}

private func makeHTTPResponse(url: URL, statusCode: Int) throws -> HTTPURLResponse {
    try #require(
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
    )
}
