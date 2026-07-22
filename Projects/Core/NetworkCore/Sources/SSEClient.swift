import Foundation

/// SSE 요청 전송, 응답 검증과 이벤트 스트림 생명주기를 담당합니다.
///
/// `SSEClient`는 이벤트의 `data` 값을 Feature DTO로 해석하거나 자동 재연결하지 않습니다.
public struct SSEClient: Sendable {
    /// SSE 원문 라인을 비동기로 전달하는 스트림입니다.
    typealias LineStream = AsyncThrowingStream<String, Error>

    /// 검증 전 HTTP 응답과 SSE 라인 스트림의 연결입니다.
    struct StreamConnection: Sendable {
        /// UTF-8로 디코딩된 SSE 원문 라인 스트림입니다.
        let lines: LineStream

        /// 서버가 반환한 원본 URL 응답입니다.
        let response: URLResponse

        private let cancellationRelay: CancellationRelay

        /// 테스트 가능한 SSE 스트림 연결을 생성합니다.
        ///
        /// - Parameters:
        ///   - lines: UTF-8로 디코딩된 SSE 원문 라인 스트림입니다.
        ///   - response: 서버가 반환한 원본 URL 응답입니다.
        ///   - cancel: 소비 종료 시 기반 전송 작업을 취소하는 클로저입니다.
        init(
            lines: LineStream,
            response: URLResponse,
            cancel: @escaping @Sendable () -> Void = {}
        ) {
            self.lines = lines
            self.response = response
            let cancellationRelay = CancellationRelay()
            cancellationRelay.install(cancel)
            self.cancellationRelay = cancellationRelay
        }

        func cancel() {
            cancellationRelay.cancel()
        }
    }

    /// 완성된 URL 요청으로 SSE 스트림 연결을 여는 전송 경계입니다.
    typealias StreamTransport = @Sendable (URLRequest) async throws -> StreamConnection

    private let requestBuilder: URLRequestBuilder
    private let transport: StreamTransport

    /// 커스텀 StreamTransport를 사용하는 SSE Client를 생성합니다.
    ///
    /// - Parameters:
    ///   - baseURL: 모든 Endpoint의 상대 경로가 결합될 기준 URL입니다.
    ///   - transport: 완성된 URL 요청으로 SSE 스트림 연결을 여는 클로저입니다.
    ///   - defaultHeaders: 요청마다 동적으로 계산할 공통 HTTP 헤더입니다.
    ///     Endpoint 헤더가 같은 필드를 덮어씁니다.
    init(
        baseURL: URL,
        transport: @escaping StreamTransport,
        defaultHeaders: @escaping @Sendable () async -> [String: String] = { [:] }
    ) {
        self.requestBuilder = URLRequestBuilder(
            baseURL: baseURL,
            defaultHeaders: defaultHeaders
        )
        self.transport = transport
    }

    /// `URLSession.bytes(for:)`를 사용하는 SSE Client를 생성합니다.
    ///
    /// - Parameters:
    ///   - baseURL: 모든 Endpoint의 상대 경로가 결합될 기준 URL입니다.
    ///   - session: SSE 요청을 전송할 URL 세션입니다.
    ///   - defaultHeaders: 요청마다 동적으로 계산할 공통 HTTP 헤더입니다.
    ///     Endpoint 헤더가 같은 필드를 덮어씁니다.
    public init(
        baseURL: URL,
        session: URLSession = .shared,
        defaultHeaders: @escaping @Sendable () async -> [String: String] = { [:] }
    ) {
        self.init(
            baseURL: baseURL,
            transport: Self.urlSessionTransport(session: session),
            defaultHeaders: defaultHeaders
        )
    }

    /// Endpoint로 SSE 연결을 열고 완성된 이벤트를 순서대로 전달합니다.
    ///
    /// 스트림이 해제·종료되거나 소비 Task가 취소되면 기반 전송 작업도 취소합니다.
    /// 스트림을 보관한 채 반복문만 중단하면 종료를 감지할 수 없으므로,
    /// 조기 종료 시에는 소비 Task를 취소하거나 스트림을 해제해야 합니다.
    /// HTTP 성공 상태와 `text/event-stream` 미디어 타입을 검증한 뒤 이벤트를 전달합니다.
    ///
    /// - Parameter endpoint: 전송할 HTTP 요청 정보입니다.
    /// - Returns: 서버가 빈 줄로 완성한 SSE 표준 필드 블록의 스트림입니다.
    public func events(for endpoint: Endpoint) -> AsyncThrowingStream<SSEEvent, Error> {
        let cancellationRelay = CancellationRelay()

        return AsyncThrowingStream { eventContinuation in
            let producerTask = Task {
                do {
                    let request = try await requestBuilder.makeRequest(for: endpoint)
                    let connection = try await transport(request)
                    cancellationRelay.install {
                        connection.cancel()
                    }
                    defer { connection.cancel() }

                    try Self.validate(connection.response)
                    try Task.checkCancellation()

                    var parser = SSEParser()
                    for try await line in connection.lines {
                        try Task.checkCancellation()

                        if let event = parser.consume(line) {
                            eventContinuation.yield(event)
                        }
                    }

                    try Task.checkCancellation()
                    eventContinuation.finish()
                } catch let clientError as SSEClientError {
                    eventContinuation.finish(throwing: clientError)
                } catch is CancellationError {
                    eventContinuation.finish(throwing: CancellationError())
                } catch let urlError as URLError where urlError.code == .cancelled {
                    eventContinuation.finish(throwing: CancellationError())
                } catch let urlError as URLError {
                    eventContinuation.finish(
                        throwing: SSEClientError.transportFailed(
                            code: urlError.code,
                            description: urlError.localizedDescription
                        )
                    )
                } catch {
                    eventContinuation.finish(
                        throwing: SSEClientError.transportFailed(
                            code: nil,
                            description: error.localizedDescription
                        )
                    )
                }
            }

            eventContinuation.onTermination = { @Sendable _ in
                producerTask.cancel()
                cancellationRelay.cancel()
            }
        }
    }
}

private extension SSEClient {
    static func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SSEClientError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw SSEClientError.unacceptableStatusCode(code: httpResponse.statusCode)
        }

        guard httpResponse.mimeType?.caseInsensitiveCompare("text/event-stream") == .orderedSame else {
            throw SSEClientError.invalidContentType(actual: httpResponse.mimeType)
        }
    }

    static func urlSessionTransport(session: URLSession) -> StreamTransport {
        { request in
            let (bytes, response) = try await session.bytes(for: request)
            let cancellationRelay = CancellationRelay()

            let lines = LineStream { lineContinuation in
                let forwardingTask = Task {
                    do {
                        for try await line in bytes.lines {
                            try Task.checkCancellation()
                            lineContinuation.yield(line)
                        }

                        try Task.checkCancellation()
                        lineContinuation.finish()
                    } catch is CancellationError {
                        lineContinuation.finish(throwing: CancellationError())
                    } catch let urlError as URLError where urlError.code == .cancelled {
                        lineContinuation.finish(throwing: CancellationError())
                    } catch {
                        lineContinuation.finish(throwing: error)
                    }
                }

                cancellationRelay.install {
                    forwardingTask.cancel()
                    bytes.task.cancel()
                }

                lineContinuation.onTermination = { @Sendable _ in
                    cancellationRelay.cancel()
                }
            }

            return StreamConnection(
                lines: lines,
                response: response,
                cancel: {
                    cancellationRelay.cancel()
                }
            )
        }
    }
}
