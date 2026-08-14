// OpenAPI 전송 DTO는 `id`처럼 서버에서 정의한 필드 이름을 그대로 유지한다.
// swiftlint:disable file_length identifier_name cyclomatic_complexity

import Foundation
import Model
import NetworkCore

public extension FortuneClient {
    static func live(httpClient: HTTPClient) -> Self {
        Self(
            fetchToday: {
                try await performFetchToday(httpClient: httpClient)
            },
            fetchDetail: { dailyFortuneID in
                try await performFetchDetail(httpClient: httpClient, id: dailyFortuneID)
            },
            fetchLuckAction: { luckActionID in
                try await performFetchLuckAction(httpClient: httpClient, id: luckActionID)
            },
            fetchMySaju: {
                try await performFetchMySaju(httpClient: httpClient)
            },
            fetchPartners: {
                try await performFetchPartners(httpClient: httpClient)
            },
            fetchPartnerSaju: { partnerID in
                try await performFetchPartnerSaju(httpClient: httpClient, partnerID: partnerID)
            },
            registerPartner: { input in
                try await performRegisterPartner(httpClient: httpClient, input: input)
            },
            createCompatibility: { partnerID, partnerName in
                try await performCreateCompatibility(
                    httpClient: httpClient,
                    partnerID: partnerID,
                    partnerName: partnerName
                )
            },
            createDayFortunes: { purpose, dates in
                try await performCreateDayFortunes(httpClient: httpClient, purpose: purpose, dates: dates)
            },
            createYearFortune: { year in
                try await performCreateYearFortune(httpClient: httpClient, year: year)
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

private func performFetchLuckAction(httpClient: HTTPClient, id: UUID) async throws -> LuckActionDetail {
    try await performRequest {
        let endpoint = Endpoint.get("/api/v1/luck-actions/\(id.uuidString.lowercased())")
        let response: CommonResponseDTO<LuckActionResponseDTO> = try await httpClient.request(endpoint)
        return try validateAndExtractData(response).toDomain()
    }
}

private func performFetchPartners(httpClient: HTTPClient) async throws -> [FortunePartner] {
    try await performRequest {
        let endpoint = Endpoint.get("/api/v1/saju/partners")
        let response: CommonResponseDTO<[PartnerSajuSummaryResponseDTO]> = try await httpClient.request(endpoint)
        return try validateAndExtractData(response).map { try $0.toDomain() }
    }
}

private func performFetchMySaju(httpClient: HTTPClient) async throws -> SajuChartDetail {
    try await performRequest {
        let endpoint = Endpoint.get("/api/v1/saju/me")
        let response: CommonResponseDTO<SajuChartDetailResponseDTO> = try await httpClient.request(endpoint)
        return try validateAndExtractData(response).toDomain()
    }
}

private func performFetchPartnerSaju(
    httpClient: HTTPClient,
    partnerID: UUID
) async throws -> SajuChartDetail {
    try await performRequest {
        let endpoint = Endpoint.get("/api/v1/saju/partners/\(partnerID.uuidString.lowercased())")
        let response: CommonResponseDTO<SajuChartDetailResponseDTO> = try await httpClient.request(endpoint)
        return try validateAndExtractData(response).toDomain()
    }
}

private func performRegisterPartner(
    httpClient: HTTPClient,
    input: PartnerRegistrationInput
) async throws -> UUID {
    try await performRequest {
        let endpoint = try Endpoint.post(
            "/api/v1/saju/partners",
            body: RegisterPartnerSajuRequestDTO(input: input)
        )
        let response: CommonResponseDTO<RegisterPartnerSajuResponseDTO> = try await httpClient.request(endpoint)
        return try validateAndExtractData(response).linkID
    }
}

private func performCreateCompatibility(
    httpClient: HTTPClient,
    partnerID: UUID,
    partnerName: String
) async throws -> CompatibilityResult {
    try await performRequest {
        let endpoint = Endpoint(
            method: .post,
            path: "/api/v1/compatibilities/\(partnerID.uuidString.lowercased())"
        )
        let response: CommonResponseDTO<CompatibilityResponseDTO> = try await httpClient.request(endpoint)
        return try validateAndExtractData(response).toDomain(fallbackPartnerName: partnerName)
    }
}

private func performCreateDayFortunes(
    httpClient: HTTPClient,
    purpose: DayFortunePurpose,
    dates: [Date]
) async throws -> [DayFortuneResult] {
    guard (1...5).contains(dates.count) else {
        throw FortuneClientError.invalidResponse
    }

    return try await performRequest {
        let body = CreateDaySelectionFortuneRequestDTO(
            purpose: purpose.rawValue,
            targetDates: dates.map(formatFortuneDate)
        )
        let endpoint = try Endpoint.post("/api/v1/day-fortunes", body: body)
        let response: CommonResponseDTO<[DaySelectionFortuneResponseDTO]> = try await httpClient.request(endpoint)
        return try validateAndExtractData(response).map { try $0.toDomain() }
    }
}

private func performCreateYearFortune(
    httpClient: HTTPClient,
    year: Int
) async throws -> YearFortuneResult {
    try await performRequest {
        let endpoint = Endpoint(method: .post, path: "/api/v1/year-fortunes/\(year)")
        let response: CommonResponseDTO<YearSelectionFortuneResponseDTO> = try await httpClient.request(endpoint)
        return try validateAndExtractData(response).toDomain()
    }
}

private func performRequest<Value>(
    _ operation: () async throws -> Value
) async throws -> Value {
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
    let score: Double
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
            return FortuneCategoryScore(
                luckActionID: scoreDTO.id,
                category: category,
                score: scoreDTO.score
            )
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
            return FortuneCategoryScore(
                luckActionID: scoreDTO.id,
                category: category,
                score: scoreDTO.score
            )
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
    let id: UUID
    let fortuneCategory: String
    let score: Int
}

private struct LuckActionResponseDTO: Decodable {
    let id: UUID
    let fortuneCategory: String
    let score: Int
    let title: String
    let content: String
    let achieved: Bool

    func toDomain() throws -> LuckActionDetail {
        LuckActionDetail(
            id: id,
            category: try mapCategory(fortuneCategory),
            score: score,
            title: title,
            content: content,
            isAchieved: achieved
        )
    }
}

private struct PartnerSajuSummaryResponseDTO: Decodable {
    let linkID: UUID
    let relationshipType: CodeLabelResponseDTO?
    let name: String?
    let gender: String
    let birthDate: String
    let calendarType: String
    let birthTime: String
    let isTimeUnknown: Bool

    enum CodingKeys: String, CodingKey {
        case linkID = "linkId"
        case relationshipType
        case name
        case gender
        case birthDate
        case calendarType
        case birthTime
        case isTimeUnknown
    }

    func toDomain() throws -> FortunePartner {
        let resolvedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName: String
        if let resolvedName, !resolvedName.isEmpty {
            displayName = resolvedName
        } else {
            displayName = "상대방"
        }
        let relationship = try relationshipType.map { try mapRelationship($0.code) } ?? .other

        return FortunePartner(
            id: linkID,
            name: displayName,
            relationship: relationship,
            gender: mapGender(gender),
            birthDate: parseFortuneDate(birthDate),
            calendarType: mapCalendarType(calendarType),
            birthTime: mapBirthTime(birthTime),
            isBirthTimeUnknown: isTimeUnknown
        )
    }
}

private struct CodeLabelResponseDTO: Decodable {
    let code: String
    let label: String
}

private struct SajuChartDetailResponseDTO: Decodable {
    let linkID: UUID
    let name: String?
    let gender: String
    let birthDate: String
    let calendarType: String
    let birthTime: String
    let isTimeUnknown: Bool
    let pillars: [PillarResponseDTO]

    enum CodingKeys: String, CodingKey {
        case linkID = "linkId"
        case name
        case gender
        case birthDate
        case calendarType
        case birthTime
        case isTimeUnknown
        case pillars
    }

    func toDomain() throws -> SajuChartDetail {
        guard let mappedBirthDate = parseFortuneDate(birthDate) else {
            throw FortuneClientError.invalidResponse
        }

        return SajuChartDetail(
            id: linkID,
            name: name,
            gender: mapGender(gender),
            birthDate: mappedBirthDate,
            calendarType: mapCalendarType(calendarType),
            birthTime: mapBirthTime(birthTime),
            isBirthTimeUnknown: isTimeUnknown,
            pillars: try pillars.map { try $0.toDomain() }.sorted { $0.type.sortOrder < $1.type.sortOrder }
        )
    }
}

private struct PillarResponseDTO: Decodable {
    let pillarType: String
    let heavenlyStem: SymbolResponseDTO
    let earthlyBranch: SymbolResponseDTO
    let stemSipseong: CodeLabelResponseDTO?
    let branchSipseong: CodeLabelResponseDTO
    let sibiunseong: CodeLabelResponseDTO?

    func toDomain() throws -> SajuPillar {
        guard let type = SajuPillarType(rawValue: pillarType) else {
            throw FortuneClientError.invalidResponse
        }

        return SajuPillar(
            type: type,
            heavenlyStem: heavenlyStem.toDomain(),
            earthlyBranch: earthlyBranch.toDomain(),
            stemTenGod: stemSipseong?.label,
            branchTenGod: branchSipseong.label,
            twelveLifeStage: sibiunseong?.label
        )
    }
}

private struct SymbolResponseDTO: Decodable {
    let hanja: String
    let reading: String
    let element: ElementResponseDTO

    func toDomain() -> SajuSymbol {
        SajuSymbol(
            hanja: hanja,
            reading: reading,
            elementLabel: element.label,
            elementHanja: element.hanja
        )
    }
}

private struct RegisterPartnerSajuRequestDTO: Encodable {
    let name: String
    let gender: String
    let calendarType: String
    let birthDate: String
    let birthTime: String
    let relationshipType: String

    init(input: PartnerRegistrationInput) {
        name = input.name
        gender = input.gender.serverValue
        calendarType = input.calendarType.serverValue
        birthDate = formatFortuneDate(input.birthDate)
        birthTime = input.isBirthTimeUnknown ? "UNKNOWN" : (input.birthTime?.serverValue ?? "UNKNOWN")
        relationshipType = input.relationship.serverValue
    }
}

private struct RegisterPartnerSajuResponseDTO: Decodable {
    let linkID: UUID

    enum CodingKeys: String, CodingKey {
        case linkID = "linkId"
    }
}

private struct CompatibilityResponseDTO: Decodable {
    let id: UUID
    let partnerName: String?
    let relationshipType: CodeLabelResponseDTO
    let score: Int
    let headline: String
    let subheadline: String
    let summary: String
    let totalAnalysis: String
    let analysisBasis: String
    let ohaengs: [CompatibilityOhaengResponseDTO]

    func toDomain(fallbackPartnerName: String) throws -> CompatibilityResult {
        return CompatibilityResult(
            id: id,
            partnerName: partnerName.flatMap { $0.isEmpty ? nil : $0 } ?? fallbackPartnerName,
            relationship: try mapRelationship(relationshipType.code),
            score: score,
            headline: headline,
            subheadline: subheadline,
            summary: summary,
            totalAnalysis: totalAnalysis,
            analysisBasis: analysisBasis,
            elements: try ohaengs.map { try $0.toDomain() }
        )
    }
}

private struct CompatibilityOhaengResponseDTO: Decodable {
    let element: ElementResponseDTO
    let percentage: Int

    func toDomain() throws -> FortuneElementScore {
        FortuneElementScore(
            element: try mapElement(element.code),
            percentage: percentage
        )
    }
}

private struct ElementResponseDTO: Decodable {
    let code: String
    let label: String
    let hanja: String
}

private struct CreateDaySelectionFortuneRequestDTO: Encodable {
    let purpose: String
    let targetDates: [String]
}

private struct DaySelectionFortuneResponseDTO: Decodable {
    let id: UUID
    let purpose: String
    let targetDate: String
    let score: Int
    let title: String
    let content: String
    let fortuneCategories: [FortuneCategoryStarResponseDTO]

    func toDomain() throws -> DayFortuneResult {
        guard
            let mappedPurpose = DayFortunePurpose(rawValue: purpose),
            let mappedDate = parseFortuneDate(targetDate)
        else {
            throw FortuneClientError.invalidResponse
        }

        return DayFortuneResult(
            id: id,
            purpose: mappedPurpose,
            targetDate: mappedDate,
            score: score,
            title: title,
            content: content,
            categories: try fortuneCategories.map { try $0.toDomain() }
        )
    }
}

private struct YearSelectionFortuneResponseDTO: Decodable {
    let id: UUID
    let year: Int
    let score: Int
    let title: String
    let content: String
    let fortuneCategories: [FortuneCategoryStarResponseDTO]

    func toDomain() throws -> YearFortuneResult {
        YearFortuneResult(
            id: id,
            year: year,
            score: score,
            title: title,
            content: content,
            categories: try fortuneCategories.map { try $0.toDomain() }
        )
    }
}

private struct FortuneCategoryStarResponseDTO: Decodable {
    let fortuneCategory: String
    let star: Int

    func toDomain() throws -> FortuneCategoryStar {
        FortuneCategoryStar(
            category: try mapCategory(fortuneCategory),
            star: star
        )
    }
}

private func parseFortuneDate(_ string: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    // API 값은 시간대가 없는 달력 날짜다. 사용자 시간대로 파싱해
    // 화면 표시와 요청 포맷이 같은 날짜를 유지하도록 한다.
    formatter.timeZone = .current
    formatter.isLenient = false
    return formatter.date(from: string)
}

private func formatFortuneDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = .current
    return formatter.string(from: date)
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

private func mapRelationship(_ value: String) throws -> FortuneRelationship {
    switch value {
    case "LOVER": .partner
    case "FRIEND": .friend
    case "COLLEAGUE", "COWORKER": .colleague
    case "FAMILY": .family
    case "ETC": .other
    default: throw FortuneClientError.invalidResponse
    }
}

private func mapGender(_ value: String) -> Gender? {
    switch value {
    case "MALE": .male
    case "FEMALE": .female
    default: nil
    }
}

private func mapCalendarType(_ value: String) -> BirthDateCalendar? {
    switch value {
    case "SOLAR": .solar
    case "LUNAR": .lunar
    default: nil
    }
}

private func mapBirthTime(_ value: String) -> BirthTimePeriod? {
    switch value {
    case "JASI": .jaTime
    case "CHUKSI": .chukTime
    case "INSI": .inTime
    case "MYOSI": .myoTime
    case "JINSI": .jinTime
    case "SASI": .saTime
    case "OSI": .oTime
    case "MISI": .miTime
    case "SINSI": .sinTime
    case "YUSI": .yuTime
    case "SULSI": .sulTime
    case "HAESI": .haeTime
    default: nil
    }
}

private func mapElement(_ value: String) throws -> FortuneElement {
    switch value.uppercased() {
    case "WOOD", "MOK": .wood
    case "FIRE", "HWA": .fire
    case "EARTH", "TO": .earth
    case "METAL", "GEUM": .metal
    case "WATER", "SU": .water
    default: throw FortuneClientError.invalidResponse
    }
}

private extension Gender {
    var serverValue: String {
        switch self {
        case .male: "MALE"
        case .female: "FEMALE"
        }
    }
}

private extension BirthDateCalendar {
    var serverValue: String {
        switch self {
        case .solar: "SOLAR"
        case .lunar: "LUNAR"
        }
    }
}

private extension Relationship {
    var serverValue: String {
        switch self {
        case .partner: "LOVER"
        case .friend: "FRIEND"
        case .colleague: "COLLEAGUE"
        }
    }
}

private extension BirthTimePeriod {
    var serverValue: String {
        switch self {
        case .jaTime: "JASI"
        case .chukTime: "CHUKSI"
        case .inTime: "INSI"
        case .myoTime: "MYOSI"
        case .jinTime: "JINSI"
        case .saTime: "SASI"
        case .oTime: "OSI"
        case .miTime: "MISI"
        case .sinTime: "SINSI"
        case .yuTime: "YUSI"
        case .sulTime: "SULSI"
        case .haeTime: "HAESI"
        }
    }
}

// swiftlint:enable file_length identifier_name cyclomatic_complexity
