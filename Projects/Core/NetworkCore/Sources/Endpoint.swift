import Foundation

/// `HTTPClient`가 URL 요청으로 변환할 HTTP Endpoint 정보입니다.
public struct Endpoint: Sendable {
    /// 요청에 사용할 HTTP 메서드입니다.
    public var method: HTTPMethod

    /// 기준 URL에 결합할 상대 경로입니다.
    public var path: String

    /// URL에 추가할 쿼리 항목입니다.
    public var queryItems: [URLQueryItem]

    /// 공통 헤더를 덮어쓸 수 있는 Endpoint 전용 HTTP 헤더입니다.
    public var headers: [String: String]

    /// 요청에 포함할 원본 HTTP 본문입니다.
    public var body: Data?

    /// HTTP Endpoint를 생성합니다.
    ///
    /// - Parameters:
    ///   - method: 요청에 사용할 HTTP 메서드입니다.
    ///   - path: 기준 URL에 결합할 상대 경로입니다.
    ///   - queryItems: URL에 추가할 쿼리 항목입니다.
    ///   - headers: Endpoint 전용 HTTP 헤더입니다.
    ///   - body: 요청에 포함할 원본 HTTP 본문입니다.
    public init(
        method: HTTPMethod = .get,
        path: String,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }
}

public extension Endpoint {
    /// GET Endpoint를 생성합니다.
    ///
    /// - Parameters:
    ///   - path: 기준 URL에 결합할 상대 경로입니다.
    ///   - queryItems: URL에 추가할 쿼리 항목입니다.
    ///   - headers: Endpoint 전용 HTTP 헤더입니다.
    /// - Returns: GET 메서드로 구성된 Endpoint입니다.
    static func get(
        _ path: String,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:]
    ) -> Self {
        Self(
            method: .get,
            path: path,
            queryItems: queryItems,
            headers: headers
        )
    }

    /// Encodable 값을 JSON 본문으로 변환하여 POST Endpoint를 생성합니다.
    ///
    /// - Parameters:
    ///   - path: 기준 URL에 결합할 상대 경로입니다.
    ///   - body: JSON으로 인코딩할 요청 값입니다.
    ///   - encoder: 요청 값을 인코딩할 JSON 인코더입니다.
    ///   - headers: Endpoint 전용 HTTP 헤더입니다.
    ///     Content-Type이 없으면 `application/json`을 추가합니다.
    /// - Returns: JSON 본문을 포함한 POST Endpoint입니다.
    /// - Throws: `body`를 JSON으로 인코딩하지 못하면 인코딩 오류를 던집니다.
    static func post<Body: Encodable>(
        _ path: String,
        body: Body,
        encoder: JSONEncoder = JSONEncoder(),
        headers: [String: String] = [:]
    ) throws -> Self {
        var headers = headers
        headers["Content-Type"] = headers["Content-Type"] ?? "application/json"

        return Self(
            method: .post,
            path: path,
            headers: headers,
            body: try encoder.encode(body)
        )
    }
}

extension Endpoint {
    /// Endpoint와 기준 URL을 결합하여 URL 요청을 생성합니다.
    ///
    /// - Parameters:
    ///   - baseURL: Endpoint 상대 경로가 결합될 기준 URL입니다.
    ///   - defaultHeaders: 모든 요청에 먼저 적용할 공통 HTTP 헤더입니다.
    /// - Returns: 전송 가능한 URL 요청입니다.
    /// - Throws: 유효한 URL을 만들 수 없으면 `HTTPClientError.invalidURL`을 던집니다.
    func urlRequest(
        baseURL: URL,
        defaultHeaders: [String: String]
    ) throws -> URLRequest {
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let url = baseURL.appending(path: normalizedPath)

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw HTTPClientError.invalidURL
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let requestURL = components.url else {
            throw HTTPClientError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.httpBody = body

        defaultHeaders.forEach { field, value in
            request.setValue(value, forHTTPHeaderField: field)
        }

        headers.forEach { field, value in
            request.setValue(value, forHTTPHeaderField: field)
        }

        return request
    }
}
