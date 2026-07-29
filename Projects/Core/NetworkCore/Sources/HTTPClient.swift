import Foundation

/// 앱의 HTTP 요청 생성, 전송, 상태 코드 검증과 응답 디코딩을 담당합니다.
///
/// `HTTPClient`는 Feature의 도메인 동작을 정의하지 않습니다.
/// App에서 한 번 구성한 인스턴스를 각 Feature의 도메인 Client에 주입하여 사용합니다.
public struct HTTPClient: Sendable {
    /// 완성된 URL 요청을 전송하고 원본 응답을 반환하는 전송 경계입니다.
    ///
    /// 운영 환경에서는 `URLSession`을 연결하고, 테스트에서는 응답을 직접 반환하는
    /// 테스트 더블 클로저를 주입할 수 있습니다.
    public typealias Transport = @Sendable (URLRequest) async throws -> (Data, URLResponse)

    private let requestBuilder: URLRequestBuilder
    private let transport: Transport
    private let makeDecoder: @Sendable () -> JSONDecoder

    /// 커스텀 Transport를 사용하는 HTTP Client를 생성합니다.
    ///
    /// - Parameters:
    ///   - baseURL: 모든 Endpoint의 상대 경로가 결합될 기준 URL입니다.
    ///   - transport: 완성된 URL 요청을 전송하고 원본 응답을 반환하는 클로저입니다.
    ///   - makeDecoder: 응답을 디코딩할 때마다 사용할 `JSONDecoder` 생성 클로저입니다.
    ///   - defaultHeaders: 요청마다 동적으로 계산할 공통 HTTP 헤더입니다.
    ///     Endpoint 헤더가 같은 필드를 덮어씁니다.
    public init(
        baseURL: URL,
        transport: @escaping Transport,
        makeDecoder: @escaping @Sendable () -> JSONDecoder = { JSONDecoder() },
        defaultHeaders: @escaping @Sendable () async -> [String: String] = { [:] }
    ) {
        self.requestBuilder = URLRequestBuilder(
            baseURL: baseURL,
            defaultHeaders: defaultHeaders
        )
        self.transport = transport
        self.makeDecoder = makeDecoder
    }

    /// `URLSession`을 사용하는 HTTP Client를 생성합니다.
    ///
    /// - Parameters:
    ///   - baseURL: 모든 Endpoint의 상대 경로가 결합될 기준 URL입니다.
    ///   - session: HTTP 요청을 전송할 URL 세션입니다.
    ///   - makeDecoder: 응답을 디코딩할 때마다 사용할 `JSONDecoder` 생성 클로저입니다.
    ///   - defaultHeaders: 요청마다 동적으로 계산할 공통 HTTP 헤더입니다.
    ///     Endpoint 헤더가 같은 필드를 덮어씁니다.
    public init(
        baseURL: URL,
        session: URLSession = .shared,
        makeDecoder: @escaping @Sendable () -> JSONDecoder = { JSONDecoder() },
        defaultHeaders: @escaping @Sendable () async -> [String: String] = { [:] }
    ) {
        self.init(
            baseURL: baseURL,
            transport: { request in
                try await session.data(for: request)
            },
            makeDecoder: makeDecoder,
            defaultHeaders: defaultHeaders
        )
    }

    /// Endpoint를 전송하고 응답 본문을 지정된 타입으로 디코딩합니다.
    ///
    /// - Parameters:
    ///   - endpoint: 전송할 HTTP 요청 정보입니다.
    ///   - responseType: 응답 본문을 디코딩할 타입입니다.
    ///     문맥에서 추론할 수 있으면 생략할 수 있습니다.
    /// - Returns: 디코딩된 응답 값입니다.
    /// - Throws: 요청 생성, 전송, 상태 코드 검증 또는 디코딩에 실패하면
    ///   `HTTPClientError`를 던집니다.
    ///   작업이 취소되면 `CancellationError`를 그대로 전달합니다.
    public func request<Response: Decodable & Sendable>(
        _ endpoint: Endpoint,
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        let data = try await data(for: endpoint)
        try Task.checkCancellation()

        guard !data.isEmpty else {
            throw HTTPClientError.emptyResponse
        }

        do {
            let response = try makeDecoder().decode(responseType, from: data)
            try Task.checkCancellation()
            return response
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            try Task.checkCancellation()
            throw HTTPClientError.decodingFailed(
                description: String(describing: error)
            )
        }
    }

    /// 응답 본문이 필요 없는 Endpoint를 전송합니다.
    ///
    /// - Parameter endpoint: 전송할 HTTP 요청 정보입니다.
    /// - Throws: 요청 생성, 전송 또는 상태 코드 검증에 실패하면 `HTTPClientError`를 던집니다.
    ///   작업이 취소되면 `CancellationError`를 그대로 전달합니다.
    public func send(_ endpoint: Endpoint) async throws {
        _ = try await data(for: endpoint)
    }

    /// Endpoint를 전송하고 검증된 원본 응답 데이터를 반환합니다.
    ///
    /// - Parameter endpoint: 전송할 HTTP 요청 정보입니다.
    /// - Returns: 200 이상 300 미만 상태 코드에서 반환된 원본 응답 데이터입니다.
    /// - Throws: 요청 생성, 전송 또는 상태 코드 검증에 실패하면 `HTTPClientError`를 던집니다.
    ///   작업이 취소되면 `CancellationError`를 그대로 전달합니다.
    public func data(for endpoint: Endpoint) async throws -> Data {
        let request = try await requestBuilder.makeRequest(for: endpoint)

        do {
            let (data, response) = try await transport(request)
            try Task.checkCancellation()

            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPClientError.invalidResponse
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                throw HTTPClientError.unacceptableStatusCode(
                    code: httpResponse.statusCode,
                    data: data
                )
            }

            return data
        } catch let clientError as HTTPClientError {
            throw clientError
        } catch is CancellationError {
            throw CancellationError()
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw CancellationError()
        } catch let urlError as URLError {
            throw HTTPClientError.transportFailed(
                code: urlError.code,
                description: urlError.localizedDescription
            )
        } catch {
            throw HTTPClientError.transportFailed(
                code: nil,
                description: error.localizedDescription
            )
        }
    }
}
