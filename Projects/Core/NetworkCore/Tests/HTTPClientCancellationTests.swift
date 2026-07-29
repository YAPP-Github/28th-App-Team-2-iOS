import Foundation
import Testing
@testable import NetworkCore

struct HTTPClientCancellationTests {
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
        private let started: AsyncStream<Void>.Continuation
        private let resumeSemaphore = DispatchSemaphore(value: 0)

        init(started: AsyncStream<Void>.Continuation) {
            self.started = started
        }

        func startAndWait() {
            started.yield()
            resumeSemaphore.wait()
        }

        func resume() {
            resumeSemaphore.signal()
        }
    }

    @Test("Task 취소를 전송 오류로 변환하지 않는다")
    func requestPreservesTaskCancellation() async throws {
        let client = makeClient { _ in
            throw CancellationError()
        }

        await #expect(throws: CancellationError.self) {
            let _: ResponseBody = try await client.request(.get("/cancelled"))
        }
    }

    @Test("URLSession 취소를 Task 취소로 변환한다")
    func requestMapsURLSessionCancellationToTaskCancellation() async throws {
        let client = makeClient { _ in
            throw URLError(.cancelled)
        }

        await #expect(throws: CancellationError.self) {
            let _: ResponseBody = try await client.request(.get("/cancelled"))
        }
    }

    @Test("취소를 무시하는 Transport의 늦은 응답을 전달하지 않는다", .timeLimit(.minutes(1)))
    func dataStopsCancelledTaskWhenTransportIgnoresCancellation() async throws {
        let transportSignal = AsyncStream.makeStream(of: Void.self)
        var signalIterator = transportSignal.stream.makeAsyncIterator()
        let responseData = try JSONEncoder().encode(["message": "늦은 응답"])
        let client = makeClient { request in
            transportSignal.continuation.yield()
            try? await Task.sleep(for: .seconds(10))
            return (
                responseData,
                try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 200)
            )
        }
        let task = Task {
            try await client.data(for: .get("/slow"))
        }

        _ = await signalIterator.next()
        task.cancel()

        await #expect(throws: CancellationError.self) {
            _ = try await task.value
        }
    }

    @Test("디코딩 중 취소된 Task가 성공 응답을 전달하지 않는다", .timeLimit(.minutes(1)))
    func requestStopsWhenTaskIsCancelledDuringDecoding() async throws {
        let decodingSignal = AsyncStream.makeStream(of: Void.self)
        var signalIterator = decodingSignal.stream.makeAsyncIterator()
        let gate = DecodingGate(started: decodingSignal.continuation)
        let client = makeClient(
            makeDecoder: {
                let decoder = JSONDecoder()
                decoder.userInfo[.decodingGate] = gate
                return decoder
            },
            transport: { request in
                (
                    Data(#"{"value":true}"#.utf8),
                    try NetworkCoreTestSupport.makeHTTPResponse(for: request, statusCode: 200)
                )
            }
        )
        let task = Task {
            try await client.request(.get("/slow-decoding"), as: BlockingResponse.self)
        }

        _ = await signalIterator.next()
        task.cancel()
        gate.resume()

        await #expect(throws: CancellationError.self) {
            _ = try await task.value
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
}

private extension CodingUserInfoKey {
    static let decodingGate = CodingUserInfoKey(
        rawValue: "HTTPClientCancellationTests.decodingGate"
    )!
}
