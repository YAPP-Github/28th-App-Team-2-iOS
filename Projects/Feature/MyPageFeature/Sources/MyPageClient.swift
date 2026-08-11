import ComposableArchitecture
import Foundation
import NetworkCore

public struct MyPageClient: Sendable {
    public var loadDashboard: @Sendable () async throws -> MyPageDashboard

    public init(loadDashboard: @escaping @Sendable () async throws -> MyPageDashboard) {
        self.loadDashboard = loadDashboard
    }
}

extension MyPageClient: DependencyKey {
    public static let liveValue = MyPageClient.unavailable
    public static let testValue = MyPageClient.unavailable
}

public extension DependencyValues {
    var myPageClient: MyPageClient {
        get { self[MyPageClient.self] }
        set { self[MyPageClient.self] = newValue }
    }
}

public extension MyPageClient {
    static let unavailable = Self {
        throw MyPageClientError.notConfigured
    }

    static func live(httpClient: HTTPClient) -> Self {
        Self {
            async let profile = fetchProfile(httpClient: httpClient)
            async let chart = fetchSajuChart(httpClient: httpClient)
            return try await MyPageDashboard(profile: profile, chart: chart)
        }
    }
}

private func fetchProfile(httpClient: HTTPClient) async throws -> MyPageProfile {
    do {
        let response: CommonResponseDTO<GetMyProfileResponseDTO> = try await httpClient.request(
            .get("/api/v1/members/me")
        )
        guard response.success, let data = response.data else {
            throw MyPageClientError.invalidResponse
        }
        return data.toDomain()
    } catch {
        throw MyPageClientError(error)
    }
}

private func fetchSajuChart(httpClient: HTTPClient) async throws -> MyPageSajuChart {
    do {
        let response: CommonResponseDTO<SajuChartDetailResponseDTO> = try await httpClient.request(
            .get("/api/v1/saju/me")
        )
        guard response.success, let data = response.data else {
            throw MyPageClientError.invalidResponse
        }
        return data.toDomain()
    } catch {
        throw MyPageClientError(error)
    }
}

private struct CommonResponseDTO<DataType: Decodable & Sendable>: Decodable, Sendable {
    let success: Bool
    let data: DataType?
}

private struct GetMyProfileResponseDTO: Decodable, Sendable {
    let name: String
    let gender: String
    let birthDate: String
    let birthTime: String
    let isTimeUnknown: Bool
    let calendarType: String

    func toDomain() -> MyPageProfile {
        MyPageProfile(
            name: name,
            gender: gender,
            birthDate: birthDate,
            calendarType: calendarType,
            birthTime: birthTime,
            isTimeUnknown: isTimeUnknown
        )
    }
}

private struct SajuChartDetailResponseDTO: Decodable, Sendable {
    let pillars: [PillarResponseDTO]

    func toDomain() -> MyPageSajuChart {
        MyPageSajuChart(
            pillars: pillars
                .map { $0.toDomain() }
                .sorted { $0.type.displayOrder < $1.type.displayOrder }
        )
    }
}

private struct PillarResponseDTO: Decodable, Sendable {
    let pillarType: String
    let heavenlyStem: StemResponseDTO
    let earthlyBranch: BranchResponseDTO

    func toDomain() -> MyPagePillar {
        MyPagePillar(
            type: pillarType,
            heavenlyStem: heavenlyStem.hanja,
            heavenlyReading: "\(heavenlyStem.reading), \(heavenlyStem.element.displayName)",
            heavenlyElement: heavenlyStem.element.toDomain(),
            earthlyBranch: earthlyBranch.hanja,
            earthlyReading: "\(earthlyBranch.reading), \(earthlyBranch.element.displayName)",
            earthlyElement: earthlyBranch.element.toDomain()
        )
    }
}

private struct StemResponseDTO: Decodable, Sendable {
    let hanja: String
    let reading: String
    let element: ElementResponseDTO
}

private struct BranchResponseDTO: Decodable, Sendable {
    let hanja: String
    let reading: String
    let element: ElementResponseDTO
}

private struct ElementResponseDTO: Decodable, Sendable {
    let code: String
    let label: String?

    func toDomain() -> MyPageElement {
        MyPageElement(rawValue: code) ?? .unknown
    }

    var displayName: String { label ?? code }
}

private extension String {
    var displayOrder: Int {
        switch self {
        case "TIME": 0
        case "DAY": 1
        case "MONTH": 2
        case "YEAR": 3
        default: 4
        }
    }
}
