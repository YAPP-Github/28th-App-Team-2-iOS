import Foundation
import Testing
@testable import NetworkCore

struct HTTPClientTests {
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

    @Test("성공 응답을 디코딩한다")
    func requestDecodesSuccessfulResponse() async throws {
        let responseData = try JSONEncoder().encode(["message": "반가워요"])
        let client = makeClient { request in
            #expect(
                request.value(forHTTPHeaderField: "Authorization")
                    == "Bearer token"
            )
            return (
                responseData,
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 200)
            )
        }

        let response: ResponseBody = try await client.request(.get("/greeting"))

        #expect(response == ResponseBody(message: "반가워요"))
    }

    @Test("빈 응답의 디코딩을 거부한다")
    func requestThrowsForEmptyResponse() async throws {
        let client = makeClient { request in
            (
                Data(),
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 200)
            )
        }

        do {
            let _: ResponseBody = try await client.request(.get("/empty"))
            Issue.record("빈 응답은 디코딩할 수 없어야 합니다.")
        } catch HTTPClientError.emptyResponse {
            // Expected
        } catch {
            Issue.record("예상하지 못한 에러: \(error)")
        }
    }

    @Test("본문이 없는 성공 응답을 허용한다")
    func sendAcceptsSuccessfulEmptyResponse() async throws {
        let client = makeClient { request in
            (
                Data(),
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 204)
            )
        }

        try await client.send(.init(method: .delete, path: "/profile"))
    }

    @Test("실패 상태 코드와 응답 데이터를 보존한다")
    func requestPreservesStatusCodeAndResponseData() async throws {
        let responseData = Data("not found".utf8)
        let client = makeClient { request in
            (
                responseData,
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 404)
            )
        }

        do {
            let _: ResponseBody = try await client.request(.get("/missing"))
            Issue.record("성공 범위가 아닌 상태 코드는 실패해야 합니다.")
        } catch let HTTPClientError.unacceptableStatusCode(code, data) {
            #expect(code == 404)
            #expect(data == responseData)
        } catch {
            Issue.record("예상하지 못한 에러: \(error)")
        }
    }

    @Test("Decodable 형식 불일치를 공통 오류로 변환한다")
    func requestWrapsDecodingError() async throws {
        let client = makeClient { request in
            (
                Data(#"{"unexpected":true}"#.utf8),
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 200)
            )
        }

        do {
            let _: ResponseBody = try await client.request(.get("/invalid"))
            Issue.record("응답 형식이 다르면 디코딩에 실패해야 합니다.")
        } catch HTTPClientError.decodingFailed {
            // Expected
        } catch {
            Issue.record("예상하지 못한 에러: \(error)")
        }
    }

    @Test("커스텀 Decodable 오류를 공통 오류로 변환한다")
    func requestWrapsCustomDecodingError() async throws {
        let client = makeClient { request in
            (
                Data(#"{"value":true}"#.utf8),
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 200)
            )
        }

        do {
            let _: CustomFailureResponse = try await client.request(.get("/custom-error"))
            Issue.record("커스텀 디코딩 오류도 HTTPClientError로 변환되어야 합니다.")
        } catch let HTTPClientError.decodingFailed(description) {
            #expect(description.contains("invalidPayload"))
        } catch {
            Issue.record("예상하지 못한 에러: \(error)")
        }
    }

    @Test("URLError를 전송 오류로 변환한다")
    func requestMapsTransportError() async throws {
        let client = makeClient { _ in
            throw URLError(.notConnectedToInternet)
        }

        do {
            let _: ResponseBody = try await client.request(.get("/offline"))
            Issue.record("전송 실패는 HTTPClientError로 매핑되어야 합니다.")
        } catch let HTTPClientError.transportFailed(code, _) {
            #expect(code == .notConnectedToInternet)
        } catch {
            Issue.record("예상하지 못한 에러: \(error)")
        }
    }

    @Test("HTTP가 아닌 URLResponse를 거부한다")
    func requestRejectsNonHTTPResponse() async throws {
        let client = makeClient { request in
            (
                Data(),
                URLResponse(
                    url: try #require(request.url),
                    mimeType: nil,
                    expectedContentLength: 0,
                    textEncodingName: nil
                )
            )
        }

        do {
            let _: ResponseBody = try await client.request(.get("/invalid-response"))
            Issue.record("HTTP 응답이 아니면 실패해야 합니다.")
        } catch HTTPClientError.invalidResponse {
            // Expected
        } catch {
            Issue.record("예상하지 못한 에러: \(error)")
        }
    }

    @Test("299 상태 코드를 성공으로 허용한다")
    func dataAcceptsUpperSuccessfulStatusBoundary() async throws {
        let client = makeClient { request in
            (
                Data(),
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 299)
            )
        }

        _ = try await client.data(for: .get("/upper-success-boundary"))
    }

    @Test("300 상태 코드를 실패로 처리한다")
    func dataRejectsLowerRedirectStatusBoundary() async throws {
        let client = makeClient { request in
            (
                Data(),
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 300)
            )
        }

        do {
            _ = try await client.data(for: .get("/lower-redirect-boundary"))
            Issue.record("300 응답은 성공 범위에 포함되면 안 됩니다.")
        } catch let HTTPClientError.unacceptableStatusCode(code, _) {
            #expect(code == 300)
        } catch {
            Issue.record("예상하지 못한 에러: \(error)")
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

struct HTTPClientUnauthorizedTests {
    @Test("401 처리 성공 후 갱신된 헤더로 원 요청을 한 번 재시도한다")
    func retriesOnceAfterUnauthorizedHandlerRefreshesHeaders() async throws {
        let recorder = AuthorizationRetryRecorder()
        let client = HTTPClient(
            baseURL: URL(string: "https://api.todakun.com")!,
            transport: { request in
                let attempt = await recorder.record(
                    authorization: request.value(forHTTPHeaderField: "Authorization")
                )
                return (
                    Data("success".utf8),
                    try NetworkCoreTestSupport.makeHTTPResponse(
                        for: request,
                        statusCode: attempt == 1 ? 401 : 200
                    )
                )
            },
            defaultHeaders: { await recorder.authorizationHeaders },
            onUnauthorized: {
                await recorder.refreshAuthorization()
                return true
            }
        )

        let data = try await client.data(for: .get("/protected"))

        #expect(data == Data("success".utf8))
        #expect(await recorder.recordedAuthorizations == ["Bearer old", "Bearer new"])
    }

    @Test("401 처리기가 갱신하지 못하면 요청을 재시도하지 않는다")
    func doesNotRetryWhenUnauthorizedHandlerFails() async throws {
        let recorder = AuthorizationRetryRecorder()
        let client = HTTPClient(
            baseURL: URL(string: "https://api.todakun.com")!,
            transport: { request in
                _ = await recorder.record(
                    authorization: request.value(forHTTPHeaderField: "Authorization")
                )
                return (
                    Data("unauthorized".utf8),
                    try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 401)
                )
            },
            onUnauthorized: { false }
        )

        do {
            _ = try await client.data(for: .get("/protected"))
            Issue.record("인증 갱신 실패 뒤에는 기존 401을 반환해야 합니다.")
        } catch let HTTPClientError.unacceptableStatusCode(code, _) {
            #expect(code == 401)
        } catch {
            Issue.record("예상하지 못한 에러: \(error)")
        }

        #expect(await recorder.attemptCount == 1)
    }

    @Test("재시도 응답이 다시 401이어도 추가 갱신을 반복하지 않는다")
    func retriesUnauthorizedResponseAtMostOnce() async throws {
        let recorder = AuthorizationRetryRecorder()
        let client = HTTPClient(
            baseURL: URL(string: "https://api.todakun.com")!,
            transport: { request in
                _ = await recorder.record(
                    authorization: request.value(forHTTPHeaderField: "Authorization")
                )
                return (
                    Data(),
                    try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 401)
                )
            },
            onUnauthorized: {
                await recorder.refreshAuthorization()
                return true
            }
        )

        await #expect(throws: HTTPClientError.self) {
            try await client.data(for: .get("/protected"))
        }
        #expect(await recorder.attemptCount == 2)
        #expect(await recorder.refreshCount == 1)
    }

    @Test("인증 갱신 endpoint는 401 처리기를 호출하지 않는다")
    func doesNotRetryEndpointExcludedFromUnauthorizedHandling() async throws {
        let recorder = AuthorizationRetryRecorder()
        let client = HTTPClient(
            baseURL: URL(string: "https://api.todakun.com")!,
            transport: { request in
                _ = await recorder.record(
                    authorization: request.value(forHTTPHeaderField: "Authorization")
                )
                return (
                    Data(),
                    try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 401)
                )
            },
            onUnauthorized: {
                await recorder.refreshAuthorization()
                return true
            }
        )

        await #expect(throws: HTTPClientError.self) {
            try await client.data(for:
                .init(
                    method: .post,
                    path: "/api/v1/auth/refresh",
                    retriesAfterUnauthorized: false
                )
            )
        }
        #expect(await recorder.attemptCount == 1)
        #expect(await recorder.refreshCount == 0)
    }

    @Test("401 처리 도중 취소되면 원래 401을 반환하지 않는다")
    func propagatesCancellationAfterUnauthorizedHandler() async throws {
        let client = HTTPClient(
            baseURL: URL(string: "https://api.todakun.com")!,
            transport: { request in
                (
                    Data(),
                    try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 401)
                )
            },
            onUnauthorized: {
                withUnsafeCurrentTask { $0?.cancel() }
                return false
            }
        )

        await #expect(throws: CancellationError.self) {
            try await client.data(for: .get("/protected"))
        }
    }

}

private actor AuthorizationRetryRecorder {
    private var authorization = "Bearer old"
    private(set) var recordedAuthorizations: [String] = []
    private(set) var refreshCount = 0

    var authorizationHeaders: [String: String] {
        ["Authorization": authorization]
    }

    var attemptCount: Int {
        recordedAuthorizations.count
    }

    func record(authorization: String?) -> Int {
        recordedAuthorizations.append(authorization ?? "")
        return recordedAuthorizations.count
    }

    func refreshAuthorization() {
        refreshCount += 1
        authorization = "Bearer new"
    }
}
