import Foundation
import XCTest
@testable import NetworkCore

final class HTTPClientTests: XCTestCase {
    private struct ResponseBody: Decodable, Equatable, Sendable {
        let message: String
    }

    private struct CustomFailureResponse: Decodable, Sendable {
        init(from decoder: Decoder) throws {
            throw DecodingProbeError.invalidPayload
        }
    }

    private enum DecodingProbeError: Error {
        case invalidPayload
    }

    func testRequestDecodesSuccessfulResponse() async throws {
        let responseData = try JSONEncoder().encode(["message": "반가워요"])
        let client = makeClient { request in
            XCTAssertEqual(
                request.value(forHTTPHeaderField: "Authorization"),
                "Bearer token"
            )
            return (
                responseData,
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 200)
            )
        }

        let response: ResponseBody = try await client.request(.get("/greeting"))

        XCTAssertEqual(response, ResponseBody(message: "반가워요"))
    }

    func testRequestThrowsForEmptyResponse() async throws {
        let client = makeClient { request in
            (
                Data(),
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 200)
            )
        }

        do {
            let _: ResponseBody = try await client.request(.get("/empty"))
            XCTFail("빈 응답은 디코딩할 수 없어야 합니다.")
        } catch HTTPClientError.emptyResponse {
            // Expected
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }

    func testSendAcceptsSuccessfulEmptyResponse() async throws {
        let client = makeClient { request in
            (
                Data(),
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 204)
            )
        }

        try await client.send(.init(method: .delete, path: "/profile"))
    }

    func testRequestPreservesStatusCodeAndResponseData() async throws {
        let responseData = Data("not found".utf8)
        let client = makeClient { request in
            (
                responseData,
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 404)
            )
        }

        do {
            let _: ResponseBody = try await client.request(.get("/missing"))
            XCTFail("성공 범위가 아닌 상태 코드는 실패해야 합니다.")
        } catch let HTTPClientError.unacceptableStatusCode(code, data) {
            XCTAssertEqual(code, 404)
            XCTAssertEqual(data, responseData)
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }

    func testRequestWrapsDecodingError() async throws {
        let client = makeClient { request in
            (
                Data(#"{"unexpected":true}"#.utf8),
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 200)
            )
        }

        do {
            let _: ResponseBody = try await client.request(.get("/invalid"))
            XCTFail("응답 형식이 다르면 디코딩에 실패해야 합니다.")
        } catch HTTPClientError.decodingFailed {
            // Expected
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }

    func testRequestWrapsCustomDecodingError() async throws {
        let client = makeClient { request in
            (
                Data(#"{"value":true}"#.utf8),
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 200)
            )
        }

        do {
            let _: CustomFailureResponse = try await client.request(.get("/custom-error"))
            XCTFail("커스텀 디코딩 오류도 HTTPClientError로 변환되어야 합니다.")
        } catch let HTTPClientError.decodingFailed(description) {
            XCTAssertTrue(description.contains("invalidPayload"))
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }

    func testRequestMapsTransportError() async throws {
        let client = makeClient { _ in
            throw URLError(.notConnectedToInternet)
        }

        do {
            let _: ResponseBody = try await client.request(.get("/offline"))
            XCTFail("전송 실패는 HTTPClientError로 매핑되어야 합니다.")
        } catch let HTTPClientError.transportFailed(code, _) {
            XCTAssertEqual(code, .notConnectedToInternet)
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }

    func testRequestRejectsNonHTTPResponse() async throws {
        let client = makeClient { request in
            (
                Data(),
                URLResponse(
                    url: try XCTUnwrap(request.url),
                    mimeType: nil,
                    expectedContentLength: 0,
                    textEncodingName: nil
                )
            )
        }

        do {
            let _: ResponseBody = try await client.request(.get("/invalid-response"))
            XCTFail("HTTP 응답이 아니면 실패해야 합니다.")
        } catch HTTPClientError.invalidResponse {
            // Expected
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }

    func testDataAcceptsUpperSuccessfulStatusBoundary() async throws {
        let client = makeClient { request in
            (
                Data(),
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 299)
            )
        }

        _ = try await client.data(for: .get("/upper-success-boundary"))
    }

    func testDataRejectsLowerRedirectStatusBoundary() async throws {
        let client = makeClient { request in
            (
                Data(),
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 300)
            )
        }

        do {
            _ = try await client.data(for: .get("/lower-redirect-boundary"))
            XCTFail("300 응답은 성공 범위에 포함되면 안 됩니다.")
        } catch let HTTPClientError.unacceptableStatusCode(code, _) {
            XCTAssertEqual(code, 300)
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }

    private func makeClient(transport: @escaping HTTPClient.Transport) -> HTTPClient {
        HTTPClient(
            baseURL: URL(string: "https://api.todakun.com")!,
            transport: transport,
            defaultHeaders: {
                ["Authorization": "Bearer token"]
            }
        )
    }
}
