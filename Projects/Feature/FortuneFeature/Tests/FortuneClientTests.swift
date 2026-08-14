import ComposableArchitecture
// 공용 전송 fixture를 함께 사용하므로 통합 형태의 클라이언트 계약 테스트를 한 파일에 둔다.
// swiftlint:disable file_length type_body_length

import Foundation
import Model
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
                    { "id": "00000000-0000-0000-0000-000000000001", "fortuneCategory": "RELATIONSHIP", "score": 90 },
                    { "id": "00000000-0000-0000-0000-000000000002", "fortuneCategory": "LOVE", "score": 80 }
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
        #expect(fortune.categoryScores[0].luckActionID == UUID(uuidString: "00000000-0000-0000-0000-000000000001"))
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
                    { "id": "00000000-0000-0000-0000-000000000003", "fortuneCategory": "MONEY", "score": 100 }
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
                    {
                      "id": "00000000-0000-0000-0000-000000000004",
                      "fortuneCategory": "UNKNOWN_CATEGORY_XYZ",
                      "score": 70
                    }
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

    @Test("행운 액션 단건 응답을 카테고리 상세 도메인으로 매핑한다")
    func testFetchLuckActionMapping() async throws {
        let luckActionID = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
        let client = makeClient { request in
            #expect(request.url?.path == "/api/v1/luck-actions/\(luckActionID.uuidString.lowercased())")
            let json = """
            {
              "success": true,
              "code": "200",
              "data": {
                "id": "33333333-3333-3333-3333-333333333333",
                "fortuneCategory": "LOVE",
                "score": 84,
                "title": "마음을 전해보세요",
                "content": "솔직한 한마디가 관계를 가까이 만들어요.",
                "achieved": false
              }
            }
            """
            return (Data(json.utf8), try makeHTTPResponse(url: request.url!, statusCode: 200))
        }

        let detail = try await client.fetchLuckAction(luckActionID)
        #expect(detail.id == luckActionID)
        #expect(detail.category == .love)
        #expect(detail.title == "마음을 전해보세요")
    }

    @Test("상대방 목록의 코드 객체와 생년 정보를 매핑한다")
    func testFetchPartnersMapping() async throws {
        let client = makeClient { request in
            #expect(request.url?.path == "/api/v1/saju/partners")
            let json = """
            {
              "success": true,
              "code": "200",
              "data": [{
                "linkId": "44444444-4444-4444-4444-444444444444",
                "relationshipType": { "code": "LOVER", "label": "연인" },
                "name": "토실이",
                "gender": "FEMALE",
                "birthDate": "1999-02-13",
                "calendarType": "SOLAR",
                "birthTime": "SINSI",
                "isTimeUnknown": false
              }]
            }
            """
            return (Data(json.utf8), try makeHTTPResponse(url: request.url!, statusCode: 200))
        }

        let partners = try await client.fetchPartners()
        #expect(partners.count == 1)
        #expect(partners[0].name == "토실이")
        #expect(partners[0].relationship == .partner)
        #expect(partners[0].birthTime == .sinTime)
    }

    @Test("상대방 목록의 선택 필드가 누락되어도 목록 전체를 실패시키지 않는다")
    func testFetchPartnersMapsOptionalSummaryFields() async throws {
        let client = makeClient { request in
            let json = """
            {
              "success": true,
              "code": "200",
              "data": [{
                "linkId": "45454545-4545-4545-4545-454545454545",
                "gender": "MALE",
                "birthDate": "2000-01-01",
                "calendarType": "LUNAR",
                "birthTime": "UNKNOWN",
                "isTimeUnknown": true
              }]
            }
            """
            return (Data(json.utf8), try makeHTTPResponse(url: request.url!, statusCode: 200))
        }

        let partner = try #require(try await client.fetchPartners().first)
        #expect(partner.name == "상대방")
        #expect(partner.relationship == .other)
        #expect(partner.isBirthTimeUnknown)
    }

    @Test("내 사주 상세의 사주 기둥과 오행 정보를 매핑한다")
    func testFetchMySajuMapping() async throws {
        let client = makeClient { request in
            #expect(request.url?.path == "/api/v1/saju/me")
            let json = Self.sajuDetailJSON(
                linkID: "10101010-1010-1010-1010-101010101010",
                name: "토닥이"
            )
            return (Data(json.utf8), try makeHTTPResponse(url: request.url!, statusCode: 200))
        }

        let chart = try await client.fetchMySaju()
        #expect(chart.name == "토닥이")
        #expect(chart.gender == .female)
        #expect(chart.calendarType == .solar)
        #expect(chart.birthTime == .oTime)
        #expect(chart.pillars.map(\.type) == [.hour, .day, .month, .year])
        #expect(chart.pillars[0].heavenlyStem.hanja == "辛")
        #expect(chart.pillars[0].heavenlyStem.elementLabel == "금")
        #expect(chart.pillars[0].stemTenGod == "식신")
        #expect(chart.pillars[0].branchTenGod == "비견")
    }

    @Test("선택한 상대방 사주 상세 경로와 nullable 이름을 매핑한다")
    func testFetchPartnerSajuMapping() async throws {
        let partnerID = UUID(uuidString: "20202020-2020-2020-2020-202020202020")!
        let client = makeClient { request in
            #expect(request.url?.path == "/api/v1/saju/partners/\(partnerID.uuidString.lowercased())")
            let json = Self.sajuDetailJSON(linkID: partnerID.uuidString, name: nil)
            return (Data(json.utf8), try makeHTTPResponse(url: request.url!, statusCode: 200))
        }

        let chart = try await client.fetchPartnerSaju(partnerID)
        #expect(chart.id == partnerID)
        #expect(chart.name == nil)
        #expect(chart.pillars.count == 4)
    }

    @Test("상대방 등록 요청을 서버 enum과 날짜 형식으로 인코딩한다")
    func testRegisterPartnerRequest() async throws {
        let responseID = UUID(uuidString: "55555555-5555-5555-5555-555555555555")!
        let client = makeClient { request in
            #expect(request.httpMethod == "POST")
            #expect(request.url?.path == "/api/v1/saju/partners")
            let body = try #require(request.httpBody)
            let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
            #expect(json["gender"] as? String == "MALE")
            #expect(json["calendarType"] as? String == "LUNAR")
            #expect(json["birthTime"] as? String == "JASI")
            #expect(json["relationshipType"] as? String == "COWORKER")
            #expect(json["birthDate"] as? String == "2000-01-01")

            let response = """
            { "success": true, "code": "200", "data": { "linkId": "55555555-5555-5555-5555-555555555555" } }
            """
            return (Data(response.utf8), try makeHTTPResponse(url: request.url!, statusCode: 200))
        }

        let input = PartnerRegistrationInput(
            name: "동료1",
            gender: .male,
            calendarType: .lunar,
            birthDate: try #require(makeDate("2000-01-01")),
            birthTime: .jaTime,
            isBirthTimeUnknown: false,
            relationship: .colleague
        )
        #expect(try await client.registerPartner(input) == responseID)
    }

    @Test("궁합 생성은 선택 상대 이름을 nullable 응답의 안전한 fallback으로 사용한다")
    func testCreateCompatibilityUsesSelectedPartnerNameFallback() async throws {
        let partnerID = UUID(uuidString: "88888888-8888-8888-8888-888888888888")!
        let client = makeClient { request in
            #expect(request.httpMethod == "POST")
            #expect(request.url?.path == "/api/v1/compatibilities/\(partnerID.uuidString.lowercased())")
            let response = """
            {
              "success": true,
              "code": "200",
              "data": {
                "id": "99999999-9999-9999-9999-999999999999",
                "relationshipType": { "code": "FRIEND", "label": "친구" },
                "score": 82,
                "headline": "편안한 사이",
                "subheadline": "대화가 잘 통해요",
                "summary": "서로를 이해해요",
                "totalAnalysis": "서버 종합 분석",
                "analysisBasis": "서버 분석 근거",
                "ohaengs": [{
                  "element": { "code": "WOOD", "label": "목", "hanja": "木" },
                  "percentage": 25
                }]
              }
            }
            """
            return (Data(response.utf8), try makeHTTPResponse(url: request.url!, statusCode: 200))
        }

        let result = try await client.createCompatibility(partnerID, "토실이")
        #expect(result.partnerName == "토실이")
        #expect(result.relationship == .friend)
        #expect(result.elements == [.init(element: .wood, percentage: 25)])
    }

    @Test("택일 운세 요청과 복수 결과를 매핑한다")
    func testCreateDayFortunes() async throws {
        let client = makeClient { request in
            #expect(request.httpMethod == "POST")
            #expect(request.url?.path == "/api/v1/day-fortunes")
            let body = try #require(request.httpBody)
            let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
            #expect(json["purpose"] as? String == "TRAVEL")
            #expect(json["targetDates"] as? [String] == ["2026-08-15"])

            let response = """
            {
              "success": true,
              "code": "200",
              "data": [{
                "id": "66666666-6666-6666-6666-666666666666",
                "purpose": "TRAVEL",
                "targetDate": "2026-08-15",
                "score": 91,
                "title": "출발하기 좋은 날",
                "content": "새로운 풍경이 좋은 기운을 줘요.",
                "fortuneCategories": [{ "fortuneCategory": "HEALTH", "star": 4 }]
              }]
            }
            """
            return (Data(response.utf8), try makeHTTPResponse(url: request.url!, statusCode: 200))
        }

        let results = try await client.createDayFortunes(.travel, [try #require(makeDate("2026-08-15"))])
        #expect(results.count == 1)
        #expect(results[0].score == 91)
        #expect(results[0].categories == [.init(category: .health, star: 4)])
    }

    @Test("연도별 운세 생성 응답은 서버가 제공한 섹션만 매핑한다")
    func testCreateYearFortune() async throws {
        let client = makeClient { request in
            #expect(request.httpMethod == "POST")
            #expect(request.url?.path == "/api/v1/year-fortunes/2027")
            let response = """
            {
              "success": true,
              "code": "200",
              "data": {
                "id": "77777777-7777-7777-7777-777777777777",
                "year": 2027,
                "score": 85,
                "title": "도전이 결실을 맺는 해",
                "content": "차근차근 쌓은 노력이 드러나요.",
                "fortuneCategories": [{ "fortuneCategory": "ACHIEVEMENT", "star": 5 }]
              }
            }
            """
            return (Data(response.utf8), try makeHTTPResponse(url: request.url!, statusCode: 200))
        }

        let result = try await client.createYearFortune(2027)
        #expect(result.year == 2027)
        #expect(result.categories == [.init(category: .achievement, star: 5)])
    }

    private static func sajuDetailJSON(linkID: String, name: String?) -> String {
        let nameJSON = name.map { "\"\($0)\"" } ?? "null"
        return """
        {
          "success": true,
          "code": "200",
          "data": {
            "linkId": "\(linkID)",
            "name": \(nameJSON),
            "gender": "FEMALE",
            "birthDate": "2001-05-30",
            "calendarType": "SOLAR",
            "birthTime": "OSI",
            "isTimeUnknown": false,
            "pillars": [
              {
                "pillarType": "YEAR",
                "heavenlyStem": {
                  "hanja": "丁", "reading": "정",
                  "element": { "code": "FIRE", "label": "화", "hanja": "火" }
                },
                "earthlyBranch": {
                  "hanja": "丑", "reading": "축",
                  "element": { "code": "EARTH", "label": "토", "hanja": "土" }
                },
                "stemSipseong": { "code": "SIKSIN", "label": "식신" },
                "branchSipseong": { "code": "BIGYEON", "label": "비견" }
              },
              {
                "pillarType": "HOUR",
                "heavenlyStem": {
                  "hanja": "辛", "reading": "신",
                  "element": { "code": "METAL", "label": "금", "hanja": "金" }
                },
                "earthlyBranch": {
                  "hanja": "未", "reading": "미",
                  "element": { "code": "EARTH", "label": "토", "hanja": "土" }
                },
                "stemSipseong": { "code": "SIKSIN", "label": "식신" },
                "branchSipseong": { "code": "BIGYEON", "label": "비견" }
              },
              {
                "pillarType": "DAY",
                "heavenlyStem": {
                  "hanja": "己", "reading": "기",
                  "element": { "code": "EARTH", "label": "토", "hanja": "土" }
                },
                "earthlyBranch": {
                  "hanja": "巳", "reading": "사",
                  "element": { "code": "FIRE", "label": "화", "hanja": "火" }
                },
                "stemSipseong": null,
                "branchSipseong": { "code": "GWANDAE", "label": "관대" }
              },
              {
                "pillarType": "MONTH",
                "heavenlyStem": {
                  "hanja": "癸", "reading": "계",
                  "element": { "code": "WATER", "label": "수", "hanja": "水" }
                },
                "earthlyBranch": {
                  "hanja": "卯", "reading": "묘",
                  "element": { "code": "WOOD", "label": "목", "hanja": "木" }
                },
                "stemSipseong": { "code": "PYEONJAE", "label": "편재" },
                "branchSipseong": { "code": "GWANDAE", "label": "관대" }
              }
            ]
          }
        }
        """
    }
}

private func makeDate(_ value: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter.date(from: value)
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

// swiftlint:enable file_length type_body_length
