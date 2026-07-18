import Foundation
import XCTest

enum NetworkCoreTestSupport {
    static func makeHTTPResponse(
        for request: URLRequest,
        statusCode: Int,
        headerFields: [String: String]? = nil
    ) throws -> HTTPURLResponse {
        try XCTUnwrap(
            HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: headerFields
            )
        )
    }
}
