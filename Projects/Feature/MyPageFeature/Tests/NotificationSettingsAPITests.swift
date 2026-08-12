import Foundation
import NetworkCore
import XCTest
@testable import MyPageFeature

final class NotificationSettingsAPITests: XCTestCase {
    func testFetchNotificationSettingsDecodesStringTimeFromServer() async throws {
        let responseData = Data(
            """
            {
              "success": true,
              "data": {
                "morningReportEnabled": false,
                "morningReportTime": "08:00",
                "todakiEnabled": false,
                "luckyActionReminderEnabled": false,
                "osPushPermission": false
              }
            }
            """.utf8
        )
        let httpClient = HTTPClient(
            baseURL: try XCTUnwrap(URL(string: "https://api-dev.todakun.com")),
            transport: { request in
                guard let url = request.url,
                      let response = HTTPURLResponse(
                          url: url,
                          statusCode: 200,
                          httpVersion: nil,
                          headerFields: nil
                      ) else {
                    throw URLError(.badURL)
                }
                return (responseData, response)
            }
        )

        let settings = try await fetchNotificationSettings(httpClient: httpClient)

        XCTAssertEqual(settings.morningReportTime, NotificationTime(hour: 8, minute: 0))
    }
}
