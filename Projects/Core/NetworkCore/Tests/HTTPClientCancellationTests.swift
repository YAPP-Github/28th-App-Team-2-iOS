import Foundation
import XCTest
@testable import NetworkCore

final class HTTPClientCancellationTests: XCTestCase {
    private struct ResponseBody: Decodable, Sendable {
        let message: String
    }

    private struct BlockingResponse: Decodable, Sendable {
        init(from decoder: Decoder) throws {
            guard let gate = decoder.userInfo[.decodingGate] as? DecodingGate else {
                throw DecodingProbeError.missingGate
            }

            gate.startAndWait()
        }
    }

    private enum DecodingProbeError: Error {
        case missingGate
    }

    private final class DecodingGate: @unchecked Sendable {
        private let started: XCTestExpectation
        private let resumeSemaphore = DispatchSemaphore(value: 0)

        init(started: XCTestExpectation) {
            self.started = started
        }

        func startAndWait() {
            started.fulfill()
            resumeSemaphore.wait()
        }

        func resume() {
            resumeSemaphore.signal()
        }
    }

    func testRequestPreservesTaskCancellation() async throws {
        let client = makeClient { _ in
            throw CancellationError()
        }

        do {
            let _: ResponseBody = try await client.request(.get("/cancelled"))
            XCTFail("작업 취소는 transport error로 변환되면 안 됩니다.")
        } catch is CancellationError {
            // Expected
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }

    func testRequestMapsURLSessionCancellationToTaskCancellation() async throws {
        let client = makeClient { _ in
            throw URLError(.cancelled)
        }

        do {
            let _: ResponseBody = try await client.request(.get("/cancelled"))
            XCTFail("URLSession 취소는 CancellationError로 전달되어야 합니다.")
        } catch is CancellationError {
            // Expected
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }

    func testDataStopsCancelledTaskWhenTransportIgnoresCancellation() async throws {
        let transportStarted = expectation(description: "Transport started")
        let responseData = try JSONEncoder().encode(["message": "늦은 응답"])
        let client = makeClient { request in
            transportStarted.fulfill()
            try? await Task.sleep(for: .seconds(10))
            return (
                responseData,
                try Self.makeHTTPResponse(for: request, statusCode: 200)
            )
        }
        let task = Task {
            try await client.data(for: .get("/slow"))
        }

        await fulfillment(of: [transportStarted], timeout: 1)
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("취소된 작업은 늦은 성공 응답을 전달하면 안 됩니다.")
        } catch is CancellationError {
            // Expected
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }

    func testRequestStopsWhenTaskIsCancelledDuringDecoding() async throws {
        let decodingStarted = expectation(description: "Decoding started")
        let gate = DecodingGate(started: decodingStarted)
        let client = makeClient(
            makeDecoder: {
                let decoder = JSONDecoder()
                decoder.userInfo[.decodingGate] = gate
                return decoder
            },
            transport: { request in
                (
                    Data(#"{"value":true}"#.utf8),
                    try Self.makeHTTPResponse(for: request, statusCode: 200)
                )
            }
        )
        let task = Task {
            try await client.request(.get("/slow-decoding"), as: BlockingResponse.self)
        }

        await fulfillment(of: [decodingStarted], timeout: 1)
        task.cancel()
        gate.resume()

        do {
            _ = try await task.value
            XCTFail("디코딩 중 취소된 작업은 성공 응답을 전달하면 안 됩니다.")
        } catch is CancellationError {
            // Expected
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }

    private func makeClient(
        makeDecoder: @escaping @Sendable () -> JSONDecoder = { JSONDecoder() },
        transport: @escaping HTTPClient.Transport
    ) -> HTTPClient {
        HTTPClient(
            baseURL: URL(string: "https://api.todakun.com")!,
            transport: transport,
            makeDecoder: makeDecoder
        )
    }

    private static func makeHTTPResponse(
        for request: URLRequest,
        statusCode: Int
    ) throws -> HTTPURLResponse {
        try XCTUnwrap(
            HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )
        )
    }
}

private extension CodingUserInfoKey {
    static let decodingGate = CodingUserInfoKey(
        rawValue: "HTTPClientCancellationTests.decodingGate"
    )!
}
