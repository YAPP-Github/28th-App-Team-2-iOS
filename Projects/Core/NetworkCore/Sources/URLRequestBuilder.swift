import Foundation

struct URLRequestBuilder: Sendable {
    private let baseURL: URL
    private let defaultHeaders: @Sendable () async -> [String: String]

    init(
        baseURL: URL,
        defaultHeaders: @escaping @Sendable () async -> [String: String]
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
    }

    func makeRequest(for endpoint: Endpoint) async throws -> URLRequest {
        try Task.checkCancellation()
        let headers = await defaultHeaders()
        try Task.checkCancellation()

        return try endpoint.urlRequest(
            baseURL: baseURL,
            defaultHeaders: headers
        )
    }
}
