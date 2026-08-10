import Foundation
import NetworkCore

public extension FortuneClient {
    static func live(httpClient: HTTPClient) -> Self {
        Self(
            fetchToday: {
                try await performFetchToday(httpClient: httpClient)
            },
            fetchDetail: { dailyFortuneID in
                try await performFetchDetail(httpClient: httpClient, id: dailyFortuneID)
            }
        )
    }
}

private func performFetchToday(httpClient: HTTPClient) async throws -> FortuneHomeContent {
    let endpoint = Endpoint.get("/api/v1/daily-fortunes/today")
    do {
        let response: CommonResponseDTO<TodayFortuneResponseDTO> = try await httpClient.request(endpoint)
        let data = try validateAndExtractData(response)
        return try data.toDomain()
    } catch is CancellationError {
        throw CancellationError()
    } catch {
        throw mapHTTPClientError(error)
    }
}

private func performFetchDetail(httpClient: HTTPClient, id dailyFortuneID: UUID) async throws -> FortuneDetailContent {
    let endpoint = Endpoint.get("/api/v1/daily-fortunes/\(dailyFortuneID.uuidString.lowercased())")
    do {
        let response: CommonResponseDTO<DailyFortuneResponseDTO> = try await httpClient.request(endpoint)
        let data = try validateAndExtractData(response)
        return try data.toDomain()
    } catch is CancellationError {
        throw CancellationError()
    } catch {
        throw mapHTTPClientError(error)
    }
}

private func validateAndExtractData<T>(_ response: CommonResponseDTO<T>) throws -> T {
    guard response.success else {
        if let code = response.code {
            throw FortuneClientError.server(code: code, message: response.message)
        } else {
            throw FortuneClientError.invalidResponse
        }
    }
    guard let data = response.data else {
        throw FortuneClientError.invalidResponse
    }
    return data
}

private func mapHTTPClientError(_ error: Error) -> FortuneClientError {
    switch error {
    case let clientError as FortuneClientError:
        return clientError
    case let httpError as HTTPClientError:
        switch httpError {
        case let .unacceptableStatusCode(code, _):
            return .httpStatus(code)
        case .decodingFailed, .emptyResponse, .invalidURL, .invalidResponse:
            return .invalidResponse
        case .transportFailed:
            return .transport
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

private struct TodayFortuneResponseDTO: Decodable {
    let dailyFortuneID: UUID
    let fortuneDate: String
    let score: Int
    let title: String
    let luckActionScores: [LuckActionScoreResponseDTO]

    enum CodingKeys: String, CodingKey {
        case dailyFortuneID = "id"
        case fortuneDate
        case score
        case title
        case luckActionScores
    }

    func toDomain() throws -> FortuneHomeContent {
        guard let date = parseFortuneDate(fortuneDate) else {
            throw FortuneClientError.invalidResponse
        }
        let mappedCategoryScores = try luckActionScores.map { scoreDTO in
            let category = try mapCategory(scoreDTO.fortuneCategory)
            return FortuneCategoryScore(category: category, score: scoreDTO.score)
        }
        return FortuneHomeContent(
            dailyFortuneID: dailyFortuneID,
            fortuneDate: date,
            score: score,
            scoreDescription: nil,
            title: title,
            categoryScores: mappedCategoryScores
        )
    }
}

private struct DailyFortuneResponseDTO: Decodable {
    let dailyFortuneID: UUID
    let fortuneDate: String
    let score: Int
    let title: String
    let content: String
    let luckyItems: [String]
    let cautionaryItems: [String]
    let luckActionScores: [LuckActionScoreResponseDTO]

    enum CodingKeys: String, CodingKey {
        case dailyFortuneID = "id"
        case fortuneDate
        case score
        case title
        case content
        case luckyItems
        case cautionaryItems
        case luckActionScores
    }

    func toDomain() throws -> FortuneDetailContent {
        guard let date = parseFortuneDate(fortuneDate) else {
            throw FortuneClientError.invalidResponse
        }
        let mappedCategoryScores = try luckActionScores.map { scoreDTO in
            let category = try mapCategory(scoreDTO.fortuneCategory)
            return FortuneCategoryScore(category: category, score: scoreDTO.score)
        }
        return FortuneDetailContent(
            dailyFortuneID: dailyFortuneID,
            fortuneDate: date,
            score: score,
            title: title,
            content: content,
            luckyItems: luckyItems,
            cautionaryItems: cautionaryItems,
            categoryScores: mappedCategoryScores
        )
    }
}

private struct LuckActionScoreResponseDTO: Decodable {
    let fortuneCategory: String
    let score: Int
}

private func parseFortuneDate(_ string: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.isLenient = false
    return formatter.date(from: string)
}

private func mapCategory(_ categoryString: String) throws -> FortuneCategory {
    switch categoryString {
    case "RELATIONSHIP":
        return .relationship
    case "LOVE":
        return .love
    case "ACHIEVEMENT":
        return .achievement
    case "HEALTH":
        return .health
    case "MONEY":
        return .money
    default:
        throw FortuneClientError.unsupportedCategory(categoryString)
    }
}
