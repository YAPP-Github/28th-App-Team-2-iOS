import ComposableArchitecture
import Foundation
import NetworkCore
import Testing
@testable import FortuneFeature

struct FortuneClientTests {
    @Test("Today fortune API 응답을 성공적으로 매핑한다")
    func testFetchTodayMapping() async throws {
        let json = """
        {
            "success": true,
            "code": "200",
            "message": "성공",
            "data": {
                "id": "11111111-1111-1111-1111-111111111111",
                "fortuneDate": "2026-08-11",
                "score": 65.4,
                "title": "좋은 하루",
                "luckActionScores": [
                    { "fortuneCategory": "RELATIONSHIP", "score": 90 },
                    { "fortuneCategory": "LOVE", "score": 80 }
                ]
            }
        }
        """

        let client = makeClient { request in
            #expect(request.url?.path == "/api/v1/daily-fortunes/today")
            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
            return (
                Data(json.utf8),
                try makeHTTPResponse(url: request.url!, statusCode: 200)
            )
        }

        let fortune = try await client.fetchToday()
        #expect(fortune.dailyFortuneID == UUID(uuidString: "11111111-1111-1111-1111-111111111111"))
        #expect(fortune.score == 65.4)
        #expect(fortune.displayScore == 65)
        #expect(fortune.moodLevel == .level03)
        #expect(fortune.title == "좋은 하루")
        #expect(fortune.scoreDescription == nil)
        #expect(fortune.categoryScores.count == 2)
        #expect(fortune.categoryScores[0].category == .relationship)
        #expect(fortune.categoryScores[0].score == 90)
        #expect(fortune.categoryScores[1].category == .love)
        #expect(fortune.categoryScores[1].score == 80)
    }

    @Test("Detail fortune API 응답을 성공적으로 매핑한다")
    func testFetchDetailMapping() async throws {
        let targetID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        let json = """
        {
            "success": true,
            "code": "200",
            "message": "성공",
            "data": {
                "id": "22222222-2222-2222-2222-222222222222",
                "fortuneDate": "2026-08-11",
                "score": 95,
                "title": "최고의 하루",
                "content": "오늘은 모든 것이 잘 풀리는 날입니다.",
                "luckyItems": ["행운의 열쇠"],
                "cautionaryItems": ["지각"],
                "luckActionScores": [
                    { "fortuneCategory": "MONEY", "score": 100 }
                ]
            }
        }
        """

        let client = makeClient { request in
            #expect(request.url?.path == "/api/v1/daily-fortunes/22222222-2222-2222-2222-222222222222")
            return (
                Data(json.utf8),
                try makeHTTPResponse(url: request.url!, statusCode: 200)
            )
        }

        let detail = try await client.fetchDetail(targetID)
        #expect(detail.dailyFortuneID == targetID)
        #expect(detail.score == 95)
        #expect(detail.title == "최고의 하루")
        #expect(detail.content == "오늘은 모든 것이 잘 풀리는 날입니다.")
        #expect(detail.luckyItems == ["행운의 열쇠"])
        #expect(detail.cautionaryItems == ["지각"])
        #expect(detail.categoryScores.count == 1)
        #expect(detail.categoryScores[0].category == .money)
        #expect(detail.categoryScores[0].score == 100)
    }

    @Test("HTTP 200이어도 success가 false이면 server error를 반환한다")
    func testSuccessFalseThrowsServerError() async throws {
        let json = """
        {
            "success": false,
            "code": "FORTUNE_400",
            "message": "운세를 찾을 수 없습니다.",
            "data": null
        }
        """

        let client = makeClient { request in
            (
                Data(json.utf8),
                try makeHTTPResponse(url: request.url!, statusCode: 200)
            )
        }

        await #expect(throws: FortuneClientError.server(code: "FORTUNE_400", message: "운세를 찾을 수 없습니다.")) {
            try await client.fetchToday()
        }
    }

    @Test("HTTP 200이어도 data가 누락되면 invalidResponse를 반환한다")
    func testMissingDataThrowsInvalidResponse() async throws {
        let json = """
        {
            "success": true,
            "code": "200",
            "message": "성공",
            "data": null
        }
        """

        let client = makeClient { request in
            (
                Data(json.utf8),
                try makeHTTPResponse(url: request.url!, statusCode: 200)
            )
        }

        await #expect(throws: FortuneClientError.invalidResponse) {
            try await client.fetchToday()
        }
    }

    @Test("날짜 파싱 실패 시 invalidResponse를 반환한다")
    func testBadDateThrowsInvalidResponse() async throws {
        let json = """
        {
            "success": true,
            "code": "200",
            "message": "성공",
            "data": {
                "id": "11111111-1111-1111-1111-111111111111",
                "fortuneDate": "invalid-date-string",
                "score": 88,
                "title": "좋은 하루",
                "luckActionScores": []
            }
        }
        """

        let client = makeClient { request in
            (
                Data(json.utf8),
                try makeHTTPResponse(url: request.url!, statusCode: 200)
            )
        }

        await #expect(throws: FortuneClientError.invalidResponse) {
            try await client.fetchToday()
        }
    }

    @Test("알 수 없는 카테고리 포함 시 unsupportedCategory를 반환한다")
    func testUnknownCategoryThrowsUnsupportedCategory() async throws {
        let json = """
        {
            "success": true,
            "code": "200",
            "message": "성공",
            "data": {
                "id": "11111111-1111-1111-1111-111111111111",
                "fortuneDate": "2026-08-11",
                "score": 88,
                "title": "좋은 하루",
                "luckActionScores": [
                    { "fortuneCategory": "UNKNOWN_CATEGORY_XYZ", "score": 70 }
                ]
            }
        }
        """

        let client = makeClient { request in
            (
                Data(json.utf8),
                try makeHTTPResponse(url: request.url!, statusCode: 200)
            )
        }

        await #expect(throws: FortuneClientError.unsupportedCategory("UNKNOWN_CATEGORY_XYZ")) {
            try await client.fetchToday()
        }
    }

    @Test("HTTP 404 응답 시 httpStatus(404) 에러를 반환한다")
    func test404HttpStatusThrowsHttpStatusError() async throws {
        let client = makeClient { request in
            (
                Data("Not Found".utf8),
                try makeHTTPResponse(url: request.url!, statusCode: 404)
            )
        }

        await #expect(throws: FortuneClientError.httpStatus(404)) {
            try await client.fetchToday()
        }
    }

    @Test("전송 실패 시 transport 에러를 반환한다")
    func testTransportErrorMappedToTransport() async throws {
        let client = makeClient { _ in
            throw URLError(.notConnectedToInternet)
        }

        await #expect(throws: FortuneClientError.transport) {
            try await client.fetchToday()
        }
    }
}

private func makeClient(transport: @escaping HTTPClient.Transport) -> FortuneClient {
    let httpClient = HTTPClient(
        baseURL: URL(string: "https://api.todakun.com")!,
        transport: transport,
        defaultHeaders: {
            ["Authorization": "Bearer test-token"]
        }
    )
    return FortuneClient.live(httpClient: httpClient)
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
