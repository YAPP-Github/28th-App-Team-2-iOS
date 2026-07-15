import Foundation
import XCTest
@testable import NetworkCore

final class EndpointTests: XCTestCase {
    func testURLRequestContainsMethodQueryAndHeaders() throws {
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

        let request = try endpoint.urlRequest(
            baseURL: try XCTUnwrap(URL(string: "https://api.todakun.com")),
            defaultHeaders: [
                "Authorization": "Bearer default-token"
            ]
        )

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://api.todakun.com/fortune/today?date=2026-07-01"
        )
        XCTAssertEqual(
            request.value(forHTTPHeaderField: "Authorization"),
            "Bearer endpoint-token"
        )
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Trace-ID"), "test-trace")
    }

    func testPostEndpointEncodesJSONBodyAndContentType() throws {
        struct RequestBody: Encodable {
            let nickname: String
        }

        let endpoint = try Endpoint.post(
            "/profile",
            body: RequestBody(nickname: "토닥")
        )
        let request = try endpoint.urlRequest(
            baseURL: try XCTUnwrap(URL(string: "https://api.todakun.com")),
            defaultHeaders: [:]
        )

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(
            try JSONSerialization.jsonObject(with: try XCTUnwrap(request.httpBody)) as? [String: String],
            ["nickname": "토닥"]
        )
    }

    func testPostEndpointPreservesCaseInsensitiveContentType() throws {
        let endpoint = try Endpoint.post(
            "/problem",
            body: ["message": "잘못된 요청"],
            headers: ["content-type": "application/problem+json"]
        )
        let request = try endpoint.urlRequest(
            baseURL: try XCTUnwrap(URL(string: "https://api.todakun.com")),
            defaultHeaders: [:]
        )

        XCTAssertEqual(
            request.value(forHTTPHeaderField: "Content-Type"),
            "application/problem+json"
        )
    }
}
