import Foundation
import LuckyActionFeatureInterface
import NetworkCore

public extension LuckyActionClient {
    static func live(httpClient: HTTPClient) -> Self {
        Self(
            fetchToday: {
                try await performRequest {
                    let response: CommonResponseDTO<[LuckyActionResponseDTO]> = try await httpClient.request(
                        .get("/api/v1/luck-actions/today")
                    )
                    return try validateAndExtractData(response).map { try $0.toDomain() }
                }
            },
            fetchByDate: { date in
                try await performRequest {
                    let endpoint = Endpoint.get(
                        "/api/v1/luck-actions",
                        queryItems: [URLQueryItem(name: "fortuneDate", value: apiDateString(date))]
                    )
                    let response: CommonResponseDTO<[LuckyActionResponseDTO]> = try await httpClient.request(endpoint)
                    return try validateAndExtractData(response).map { try $0.toDomain() }
                }
            },
            toggleAchievement: { actionID in
                try await performRequest {
                    let endpoint = Endpoint(
                        method: .patch,
                        path: "/api/v1/luck-actions/\(actionID.uuidString.lowercased())/achievement"
                    )
                    let response: CommonResponseDTO<LuckyActionResponseDTO> = try await httpClient.request(endpoint)
                    return try validateAndExtractData(response).toDomain()
                }
            }
        )
    }
}

private func apiDateString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

private func performRequest<Value>(_ operation: () async throws -> Value) async throws -> Value {
    do {
        return try await operation()
    } catch is CancellationError {
        throw CancellationError()
    } catch {
        throw mapHTTPClientError(error)
    }
}

private func validateAndExtractData<T>(_ response: CommonResponseDTO<T>) throws -> T {
    guard response.success else {
        guard let code = response.code else { throw LuckyActionClientError.invalidResponse }
        throw LuckyActionClientError.server(code: code, message: response.message)
    }
    guard let data = response.data else { throw LuckyActionClientError.invalidResponse }
    return data
}

private func mapHTTPClientError(_ error: Error) -> LuckyActionClientError {
    switch error {
    case let error as LuckyActionClientError:
        return error
    case let error as HTTPClientError:
        switch error {
        case let .unacceptableStatusCode(code, _): return .httpStatus(code)
        case .decodingFailed, .emptyResponse, .invalidURL, .invalidResponse: return .invalidResponse
        case .transportFailed: return .transport
        }
    default:
        return .transport
    }
}

private struct CommonResponseDTO<Data: Decodable>: Decodable {
    let success: Bool
    let code: String?
    let message: String?
    let data: Data?
}

private struct LuckyActionResponseDTO: Decodable {
    // OpenAPI 응답 키와 맞추기 위해 원본 필드명을 유지한다.
    // swiftlint:disable:next identifier_name
    let id: UUID
    let fortuneCategory: String
    let score: Int
    let title: String
    let achieved: Bool

    func toDomain() throws -> LuckyAction {
        LuckyAction(
            id: id,
            category: try LuckyActionCategory(apiValue: fortuneCategory),
            score: score,
            title: title,
            isAchieved: achieved
        )
    }
}
