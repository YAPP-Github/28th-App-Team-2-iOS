import Foundation
import Testing
@testable import NetworkCore

struct SSEClientTests {
    @Test("POST Endpoint 요청을 조립하고 SSE 이벤트를 순서대로 전달한다")
    func streamsEventsForPostEndpoint() async throws {
        let client = makeClient(
            defaultHeaders: {
                [
                    "Authorization": "Bearer default-token",
                    "X-Default": "default-value"
                ]
            },
            transport: { request in
                #expect(request.httpMethod == "POST")
                #expect(request.url?.absoluteString == "https://api.todakun.com/chat")
                #expect(
                    request.value(forHTTPHeaderField: "Authorization")
                        == "Bearer endpoint-token"
                )
                #expect(request.value(forHTTPHeaderField: "X-Default") == "default-value")
                #expect(
                    try JSONSerialization.jsonObject(
                        with: #require(request.httpBody)
                    ) as? [String: String] == ["message": "안녕"]
                )

                return SSEClient.StreamConnection(
                    lines: makeLineStream([
                        "event: message",
                        "id: event-1",
                        "data: 첫 번째",
                        "data: 두 번째",
                        "",
                        "data: 다음 이벤트",
                        ""
                    ]),
                    response: try NetworkCoreTestSupport.makeHTTPResponse(
                        for: request,
                        statusCode: 200,
                        headerFields: ["Content-Type": "text/event-stream"]
                    )
                )
            }
        )
        let endpoint = try Endpoint.post(
            "/chat",
            body: ["message": "안녕"],
            headers: ["Authorization": "Bearer endpoint-token"]
        )

        let events = try await collect(client.events(for: endpoint))

        #expect(
            events == [
                SSEEvent(
                    data: "첫 번째\n두 번째",
                    event: "message",
                    id: "event-1"
                ),
                SSEEvent(data: "다음 이벤트")
            ]
        )
    }

    @Test("GET Endpoint와 파라미터가 포함된 SSE Content-Type을 허용한다")
    func acceptsGetEndpointAndParameterizedContentType() async throws {
        let client = makeClient { request in
            #expect(request.httpMethod == "GET")
            #expect(
                request.url?.absoluteString
                    == "https://api.todakun.com/chat?conversationID=10"
            )

            return SSEClient.StreamConnection(
                lines: makeLineStream(["data: payload", ""]),
                response: try NetworkCoreTestSupport.makeHTTPResponse(
                    for: request,
                    statusCode: 299,
                    headerFields: [
                        "Content-Type": "text/event-stream; charset=utf-8"
                    ]
                )
            )
        }
        let endpoint = Endpoint.get(
            "/chat",
            queryItems: [URLQueryItem(name: "conversationID", value: "10")]
        )

        let events = try await collect(client.events(for: endpoint))

        #expect(events == [SSEEvent(data: "payload")])
    }

    @Test("300 상태 코드의 스트림 연결을 거부한다")
    func rejectsUnacceptableStatusCode() async throws {
        let cancellationSpy = CancellationSpy()
        let client = makeClient { request in
            SSEClient.StreamConnection(
                lines: makeLineStream([]),
                response: try NetworkCoreTestSupport.makeHTTPResponse(
                    for: request,
                    statusCode: 300,
                    headerFields: ["Content-Type": "text/event-stream"]
                ),
                cancel: {
                    cancellationSpy.cancel()
                }
            )
        }

        do {
            _ = try await collect(client.events(for: .get("/redirect")))
            Issue.record("300 응답은 SSE 스트림으로 소비하면 안 됩니다.")
        } catch let SSEClientError.unacceptableStatusCode(code) {
            #expect(code == 300)
        } catch {
            Issue.record("예상하지 못한 에러: \(error)")
        }

        #expect(cancellationSpy.wasCancelled)
    }

    @Test("text/event-stream이 아닌 응답을 거부한다")
    func rejectsInvalidContentType() async throws {
        let client = makeClient { request in
            SSEClient.StreamConnection(
                lines: makeLineStream([]),
                response: try NetworkCoreTestSupport.makeHTTPResponse(
                    for: request,
                    statusCode: 200,
                    headerFields: ["Content-Type": "application/json"]
                )
            )
        }

        do {
            _ = try await collect(client.events(for: .get("/json")))
            Issue.record("SSE가 아닌 미디어 타입은 거부해야 합니다.")
        } catch let SSEClientError.invalidContentType(actual) {
            #expect(actual == "application/json")
        } catch {
            Issue.record("예상하지 못한 에러: \(error)")
        }
    }

    @Test("HTTP가 아닌 URLResponse를 거부한다")
    func rejectsNonHTTPResponse() async throws {
        let client = makeClient { request in
            SSEClient.StreamConnection(
                lines: makeLineStream([]),
                response: URLResponse(
                    url: try #require(request.url),
                    mimeType: "text/event-stream",
                    expectedContentLength: 0,
                    textEncodingName: "utf-8"
                )
            )
        }

        do {
            _ = try await collect(client.events(for: .get("/invalid-response")))
            Issue.record("HTTP 응답이 아니면 실패해야 합니다.")
        } catch SSEClientError.invalidResponse {
            // Expected
        } catch {
            Issue.record("예상하지 못한 에러: \(error)")
        }
    }

    @Test("URLError를 SSE 전송 오류로 변환한다")
    func mapsTransportError() async throws {
        let client = makeClient { _ in
            throw URLError(.notConnectedToInternet)
        }

        do {
            _ = try await collect(client.events(for: .get("/offline")))
            Issue.record("전송 오류는 SSEClientError로 변환되어야 합니다.")
        } catch let SSEClientError.transportFailed(code, _) {
            #expect(code == .notConnectedToInternet)
        } catch {
            Issue.record("예상하지 못한 에러: \(error)")
        }
    }

    @Test("소비 Task 취소가 연결을 취소하고 늦은 이벤트를 차단한다", .timeLimit(.minutes(1)))
    func cancellationStopsConnectionAndLateEvents() async throws {
        let lineController = LineStreamController()
        let cancellationSpy = CancellationSpy()
        let receivedSignal = AsyncStream.makeStream(of: Void.self)
        var receivedIterator = receivedSignal.stream.makeAsyncIterator()
        let cancellationSignal = AsyncStream.makeStream(of: Void.self)
        var cancellationIterator = cancellationSignal.stream.makeAsyncIterator()
        let recorder = EventRecorder()
        let client = makeClient { request in
            SSEClient.StreamConnection(
                lines: lineController.stream,
                response: try NetworkCoreTestSupport.makeHTTPResponse(
                    for: request,
                    statusCode: 200,
                    headerFields: ["Content-Type": "text/event-stream"]
                ),
                cancel: {
                    cancellationSpy.cancel()
                    lineController.finish(throwing: CancellationError())
                    cancellationSignal.continuation.yield()
                }
            )
        }
        let consumptionTask = Task {
            do {
                for try await event in client.events(for: .get("/slow")) {
                    await recorder.append(event)
                    receivedSignal.continuation.yield()
                }
            } catch is CancellationError {
                // Expected
            }
        }

        lineController.yield("data: first")
        lineController.yield("")
        _ = await receivedIterator.next()

        consumptionTask.cancel()
        _ = await cancellationIterator.next()
        try await consumptionTask.value

        lineController.yield("data: late")
        lineController.yield("")

        #expect(cancellationSpy.wasCancelled)
        #expect(await recorder.snapshot() == [SSEEvent(data: "first")])
    }

    @Test("조기 반복 종료 후 스트림이 해제되면 연결을 취소한다", .timeLimit(.minutes(1)))
    func releasingStreamAfterEarlyExitCancelsConnection() async throws {
        let lineController = LineStreamController()
        let cancellationSignal = AsyncStream.makeStream(of: Void.self)
        var cancellationIterator = cancellationSignal.stream.makeAsyncIterator()
        let client = makeClient { request in
            SSEClient.StreamConnection(
                lines: lineController.stream,
                response: try NetworkCoreTestSupport.makeHTTPResponse(
                    for: request,
                    statusCode: 200,
                    headerFields: ["Content-Type": "text/event-stream"]
                ),
                cancel: {
                    lineController.finish(throwing: CancellationError())
                    cancellationSignal.continuation.yield()
                }
            )
        }

        lineController.yield("data: first")
        lineController.yield("")
        try await consumeFirstEventAndReleaseStream(from: client)

        _ = await cancellationIterator.next()
    }
}

private extension SSEClientTests {
    func makeClient(
        defaultHeaders: @escaping @Sendable () async -> [String: String] = { [:] },
        transport: @escaping SSEClient.StreamTransport
    ) -> SSEClient {
        SSEClient(
            baseURL: URL(string: "https://api.todakun.com")!,
            transport: transport,
            defaultHeaders: defaultHeaders
        )
    }

    func collect(
        _ stream: AsyncThrowingStream<SSEEvent, Error>
    ) async throws -> [SSEEvent] {
        var events: [SSEEvent] = []

        for try await event in stream {
            events.append(event)
        }

        return events
    }

    func consumeFirstEventAndReleaseStream(from client: SSEClient) async throws {
        for try await _ in client.events(for: .get("/first-event")) {
            break
        }
    }
}

private func makeLineStream(_ lines: [String]) -> SSEClient.LineStream {
    SSEClient.LineStream { continuation in
        lines.forEach { continuation.yield($0) }
        continuation.finish()
    }
}

private final class CancellationSpy: @unchecked Sendable {
    private let lock = NSLock()
    private var isCancelled = false

    var wasCancelled: Bool {
        lock.withLock { isCancelled }
    }

    func cancel() {
        lock.withLock {
            isCancelled = true
        }
    }
}

private final class LineStreamController: @unchecked Sendable {
    let stream: SSEClient.LineStream
    private let continuation: SSEClient.LineStream.Continuation

    init() {
        let streamPair = SSEClient.LineStream.makeStream()
        self.stream = streamPair.stream
        self.continuation = streamPair.continuation
    }

    func yield(_ line: String) {
        continuation.yield(line)
    }

    func finish(throwing error: Error? = nil) {
        continuation.finish(throwing: error)
    }
}

private actor EventRecorder {
    private var events: [SSEEvent] = []

    func append(_ event: SSEEvent) {
        events.append(event)
    }

    func snapshot() -> [SSEEvent] {
        events
    }
}
