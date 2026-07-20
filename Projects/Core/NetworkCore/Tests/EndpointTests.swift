import Foundation
import Testing
@testable import NetworkCore

struct EndpointTests {
    @Test("URLRequest에 메서드, 쿼리와 병합된 헤더를 적용한다")
    func urlRequestContainsMethodQueryAndHeaders() async throws {
        let endpoint = Endpoint.get(
            "/fortune/today",
            queryItems: [
                URLQueryItem(name: "date", value: "2026-07-01")
            ],
            headers: [
                "Authorization": "Bearer endpoint-token",
                "X-Trace-ID": "test-trace"
            ]
        )
        let builder = URLRequestBuilder(
            baseURL: try #require(URL(string: "https://api.todakun.com")),
            defaultHeaders: {
                ["Authorization": "Bearer default-token"]
            }
        )

        let request = try await builder.makeRequest(for: endpoint)

        #expect(request.httpMethod == "GET")
        #expect(
            request.url?.absoluteString
                == "https://api.todakun.com/fortune/today?date=2026-07-01"
        )
        #expect(
            request.value(forHTTPHeaderField: "Authorization")
                == "Bearer endpoint-token"
        )
        #expect(request.value(forHTTPHeaderField: "X-Trace-ID") == "test-trace")
    }

    @Test("기준 URL의 기존 쿼리 항목을 보존한다")
    func urlRequestPreservesBaseURLQueryItems() async throws {
        let endpoint = Endpoint.get(
            "/fortune/today",
            queryItems: [
                URLQueryItem(name: "date", value: "2026-07-15")
            ]
        )
        let builder = URLRequestBuilder(
            baseURL: try #require(
                URL(string: "https://api.todakun.com/v1?tenant=alpha")
            ),
            defaultHeaders: { [:] }
        )

        let request = try await builder.makeRequest(for: endpoint)

        #expect(
            request.url?.absoluteString
                == "https://api.todakun.com/v1/fortune/today?tenant=alpha&date=2026-07-15"
        )
    }

    @Test("POST Endpoint가 JSON 본문과 Content-Type을 구성한다")
    func postEndpointEncodesJSONBodyAndContentType() async throws {
        struct RequestBody: Encodable {
            let nickname: String
        }

        let endpoint = try Endpoint.post(
            "/profile",
            body: RequestBody(nickname: "토닥")
        )
        let builder = URLRequestBuilder(
            baseURL: try #require(URL(string: "https://api.todakun.com")),
            defaultHeaders: { [:] }
        )

        let request = try await builder.makeRequest(for: endpoint)

        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(
            try JSONSerialization.jsonObject(
                with: #require(request.httpBody)
            ) as? [String: String] == ["nickname": "토닥"]
        )
    }

    @Test("대소문자가 다른 사용자 Content-Type을 보존한다")
    func postEndpointPreservesCaseInsensitiveContentType() async throws {
        let endpoint = try Endpoint.post(
            "/problem",
            body: ["message": "잘못된 요청"],
            headers: ["content-type": "application/problem+json"]
        )
        let builder = URLRequestBuilder(
            baseURL: try #require(URL(string: "https://api.todakun.com")),
            defaultHeaders: { [:] }
        )

        let request = try await builder.makeRequest(for: endpoint)

        #expect(
            request.value(forHTTPHeaderField: "Content-Type")
                == "application/problem+json"
        )
    }
}
