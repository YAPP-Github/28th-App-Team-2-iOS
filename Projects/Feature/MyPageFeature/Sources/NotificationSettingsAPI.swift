import Foundation
import NetworkCore

func fetchNotificationSettings(httpClient: HTTPClient) async throws -> NotificationSettings {
    do {
        let response: NotificationSettingsResponseEnvelope<NotificationSettingResponseDTO> =
            try await httpClient.request(
            .get("/api/v1/notifications/settings")
        )
        guard response.success, let data = response.data else {
            throw MyPageClientError.invalidResponse
        }
        return data.toDomain()
    } catch {
        throw MyPageClientError(error)
    }
}

func patchNotificationSettings(
    _ settings: NotificationSettings,
    httpClient: HTTPClient
) async throws -> NotificationSettings {
    do {
        let body = try JSONEncoder().encode(UpdateNotificationSettingRequestDTO(settings))
        let endpoint = Endpoint(
            method: .patch,
            path: "/api/v1/notifications/settings",
            headers: ["Content-Type": "application/json"],
            body: body
        )
        let response: NotificationSettingsResponseEnvelope<NotificationSettingResponseDTO> =
            try await httpClient.request(
            endpoint
        )
        guard response.success, let data = response.data else {
            throw MyPageClientError.invalidResponse
        }
        return data.toDomain()
    } catch {
        throw MyPageClientError(error)
    }
}

func patchOSPushPermission(_ granted: Bool, httpClient: HTTPClient) async throws -> NotificationSettings {
    do {
        let endpoint = try Endpoint.post(
            "/api/v1/notifications/settings/os-permission",
            body: SyncOSPushPermissionRequestDTO(granted: granted)
        )
        let response: NotificationSettingsResponseEnvelope<NotificationSettingResponseDTO> =
            try await httpClient.request(
            endpoint
        )
        guard response.success, let data = response.data else {
            throw MyPageClientError.invalidResponse
        }
        return data.toDomain()
    } catch {
        throw MyPageClientError(error)
    }
}

func postDeviceToken(_ token: String, httpClient: HTTPClient) async throws {
    do {
        let endpoint = try Endpoint.post(
            "/api/v1/notifications/device-tokens",
            body: RegisterDeviceTokenRequestDTO(token: token)
        )
        let response: NotificationSettingsResponseEnvelope<EmptyNotificationResponseDTO> = try await httpClient.request(
            endpoint
        )
        guard response.success else { throw MyPageClientError.invalidResponse }
    } catch {
        throw MyPageClientError(error)
    }
}

private struct NotificationSettingsResponseEnvelope<DataType: Decodable & Sendable>: Decodable, Sendable {
    let success: Bool
    let data: DataType?
}

private struct NotificationSettingResponseDTO: Decodable, Sendable {
    let morningReportEnabled: Bool
    let morningReportTime: LocalTimeDTO
    let todakiEnabled: Bool
    let luckyActionReminderEnabled: Bool

    func toDomain() -> NotificationSettings {
        NotificationSettings(
            morningReportEnabled: morningReportEnabled,
            morningReportTime: NotificationTime(
                hour: morningReportTime.hour,
                minute: morningReportTime.minute
            ),
            todakiEnabled: todakiEnabled,
            luckyActionReminderEnabled: luckyActionReminderEnabled
        )
    }
}

private struct LocalTimeDTO: Decodable, Sendable {
    let hour: Int
    let minute: Int

    private enum CodingKeys: String, CodingKey {
        case hour
        case minute
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let value = try? container.decode(String.self) {
            let components = value.split(separator: ":", omittingEmptySubsequences: false)
            guard components.count >= 2,
                  let hour = Int(components[0]),
                  let minute = Int(components[1]) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Expected an HH:mm notification time string."
                )
            }
            self.hour = hour
            self.minute = minute
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        hour = try container.decode(Int.self, forKey: .hour)
        minute = try container.decode(Int.self, forKey: .minute)
    }
}

private struct UpdateNotificationSettingRequestDTO: Encodable, Sendable {
    let morningReportEnabled: Bool
    let morningReportTime: String
    let todakiEnabled: Bool
    let luckyActionReminderEnabled: Bool

    init(_ settings: NotificationSettings) {
        morningReportEnabled = settings.morningReportEnabled
        morningReportTime = settings.morningReportTime.apiValue
        todakiEnabled = settings.todakiEnabled
        luckyActionReminderEnabled = settings.luckyActionReminderEnabled
    }
}

private struct SyncOSPushPermissionRequestDTO: Encodable, Sendable {
    let granted: Bool
}

private struct RegisterDeviceTokenRequestDTO: Encodable, Sendable {
    let token: String
    let platform = "IOS"
}

private struct EmptyNotificationResponseDTO: Decodable, Sendable {}
