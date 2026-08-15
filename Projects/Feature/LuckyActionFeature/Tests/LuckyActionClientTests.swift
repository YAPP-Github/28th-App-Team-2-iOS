import Foundation
import NetworkCore
import Testing
@testable import LuckyActionFeature
import LuckyActionFeatureInterface

@Suite
struct LuckyActionClientTests {
    @Test("당일 행운 액션을 조회한다")
    func fetchesTodayActions() async throws {
        let client = makeClient { request in
            #expect(request.httpMethod == "GET")
            #expect(request.url?.path == "/api/v1/luck-actions/today")
            return (
                Data(
                    """
                    {
                      "success": true,
                      "data": [
                        {
                          "id": "00000000-0000-0000-0000-000000000001",
                          "fortuneCategory": "RELATIONSHIP",
                          "score": 84,
                          "title": "메시지 보내기",
                          "achieved": false
                        }
                      ]
                    }
                    """.utf8
                ),
                try makeHTTPResponse(url: try #require(request.url), statusCode: 200)
            )
        }

        let actions = try await client.fetchToday()

        #expect(actions == [
            LuckyAction(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                category: .relationship,
                score: 84,
                title: "메시지 보내기",
                isAchieved: false
            )
        ])
    }

    @Test("지정한 날짜의 행운 액션을 조회한다")
    func fetchesActionsByDate() async throws {
        let date = Date(timeIntervalSince1970: 1_786_676_400)
        let client = makeClient { request in
            #expect(request.httpMethod == "GET")
            #expect(request.url?.path == "/api/v1/luck-actions")
            #expect(URLComponents(url: try #require(request.url), resolvingAgainstBaseURL: false)?
                .queryItems?
                .contains(URLQueryItem(name: "fortuneDate", value: "2026-08-14")) == true)
            return (
                Data(
                    """
                    {
                      "success": true,
                      "data": []
                    }
                    """.utf8
                ),
                try makeHTTPResponse(url: try #require(request.url), statusCode: 200)
            )
        }

        let actions = try await client.fetchByDate(date)

        #expect(actions.isEmpty)
    }

    @Test("행운 액션의 달성 상태를 토글한다")
    func togglesAchievement() async throws {
        let actionID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let client = makeClient { request in
            #expect(request.httpMethod == "PATCH")
            let expectedPath = "/api/v1/luck-actions/\(actionID.uuidString.lowercased())/achievement"
            #expect(request.url?.path == expectedPath)
            return (
                Data(
                    """
                    {
                      "success": true,
                      "data": {
                        "id": "00000000-0000-0000-0000-000000000002",
                        "fortuneCategory": "LOVE",
                        "score": 30,
                        "title": "밝은 옷 입기",
                        "achieved": true
                      }
                    }
                    """.utf8
                ),
                try makeHTTPResponse(url: try #require(request.url), statusCode: 200)
            )
        }

        let action = try await client.toggleAchievement(actionID)

        #expect(action.category == .love)
        #expect(action.isAchieved)
        #expect(action.score == 30)
    }
}

private func makeClient(transport: @escaping HTTPClient.Transport) -> LuckyActionClient {
    LuckyActionClient.live(
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
