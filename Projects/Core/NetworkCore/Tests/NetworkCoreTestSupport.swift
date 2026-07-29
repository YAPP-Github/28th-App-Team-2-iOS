import Foundation
import Testing

enum NetworkCoreTestSupport {
    static func makeHTTPResponse(
        for request: URLRequest,
        statusCode: Int,
        headerFields: [String: String]? = nil
    ) throws -> HTTPURLResponse {
        let url = try #require(request.url)

        return try #require(
            HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: headerFields
            )
        )
    }
}
