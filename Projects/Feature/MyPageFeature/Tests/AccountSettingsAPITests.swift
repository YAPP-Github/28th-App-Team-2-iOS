import Foundation
import NetworkCore
import XCTest
@testable import MyPageFeature

final class AccountSettingsAPITests: XCTestCase {
    func testLogoutPostsToLogoutEndpoint() async throws {
        let recorder = RequestRecorder()
        let httpClient = try makeHTTPClient(recorder: recorder)

        try await postLogout(httpClient: httpClient)

        let request = await recorder.lastRequest
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.url?.path, "/api/v1/auth/logout")
    }

    func testWithdrawDeletesMemberWithReasonAndDetail() async throws {
        let recorder = RequestRecorder()
        let httpClient = try makeHTTPClient(recorder: recorder)

        try await deleteMember(
            WithdrawalRequest(reason: .etc, detail: "상세 사유"),
            httpClient: httpClient
        )

        let request = await recorder.lastRequest
        XCTAssertEqual(request?.httpMethod, "DELETE")
        XCTAssertEqual(request?.url?.path, "/api/v1/members/me")
        let body = try XCTUnwrap(request?.httpBody)
        let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: String])
        XCTAssertEqual(payload["reason"], "ETC")
        XCTAssertEqual(payload["detail"], "상세 사유")
    }

    private func makeHTTPClient(recorder: RequestRecorder) throws -> HTTPClient {
        HTTPClient(
            baseURL: try XCTUnwrap(URL(string: "https://api-dev.todakun.com")),
            transport: { request in
                await recorder.record(request)
                let response = try XCTUnwrap(
                    HTTPURLResponse(
                        url: try XCTUnwrap(request.url),
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )
                )
                return (Data("{\"success\":true,\"data\":null}".utf8), response)
            }
        )
    }
}

private actor RequestRecorder {
    private(set) var lastRequest: URLRequest?

    func record(_ request: URLRequest) {
        lastRequest = request
    }
}
