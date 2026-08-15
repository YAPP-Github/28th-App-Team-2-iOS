import ComposableArchitecture
import Foundation

public struct FortuneClient: Sendable {
    public var fetchToday: @Sendable () async throws -> FortuneHomeContent
    public var fetchDetail: @Sendable (UUID) async throws -> FortuneDetailContent
    public var fetchLuckAction: @Sendable (UUID) async throws -> LuckActionDetail
    public var fetchMySaju: @Sendable () async throws -> SajuChartDetail
    public var fetchPartners: @Sendable () async throws -> [FortunePartner]
    public var fetchPartnerSaju: @Sendable (UUID) async throws -> SajuChartDetail
    public var registerPartner: @Sendable (PartnerRegistrationInput) async throws -> UUID
    public var createCompatibility: @Sendable (UUID, String) async throws -> CompatibilityResult
    public var createDayFortunes: @Sendable (DayFortunePurpose, [Date]) async throws -> [DayFortuneResult]
    public var createYearFortune: @Sendable (Int) async throws -> YearFortuneResult

    public init(
        fetchToday: @escaping @Sendable () async throws -> FortuneHomeContent,
        fetchDetail: @escaping @Sendable (UUID) async throws -> FortuneDetailContent,
        fetchLuckAction: @escaping @Sendable (UUID) async throws -> LuckActionDetail,
        fetchMySaju: @escaping @Sendable () async throws -> SajuChartDetail,
        fetchPartners: @escaping @Sendable () async throws -> [FortunePartner],
        fetchPartnerSaju: @escaping @Sendable (UUID) async throws -> SajuChartDetail,
        registerPartner: @escaping @Sendable (PartnerRegistrationInput) async throws -> UUID,
        createCompatibility: @escaping @Sendable (UUID, String) async throws -> CompatibilityResult,
        createDayFortunes: @escaping @Sendable (DayFortunePurpose, [Date]) async throws -> [DayFortuneResult],
        createYearFortune: @escaping @Sendable (Int) async throws -> YearFortuneResult
    ) {
        self.fetchToday = fetchToday
        self.fetchDetail = fetchDetail
        self.fetchLuckAction = fetchLuckAction
        self.fetchMySaju = fetchMySaju
        self.fetchPartners = fetchPartners
        self.fetchPartnerSaju = fetchPartnerSaju
        self.registerPartner = registerPartner
        self.createCompatibility = createCompatibility
        self.createDayFortunes = createDayFortunes
        self.createYearFortune = createYearFortune
    }
}

public enum FortuneClientError: Error, Equatable, Sendable {
    case notConfigured
    case server(code: String, message: String?)
    case httpStatus(Int)
    case invalidResponse
    case unsupportedCategory(String)
    case transport

    public var userMessage: String {
        switch self {
        case .notConfigured:
            "운세 서비스를 사용할 수 없어요."
        case .server, .httpStatus, .invalidResponse, .unsupportedCategory:
            "운세 정보를 불러오지 못했어요."
        case .transport:
            "네트워크 연결 상태를 확인해주세요."
        }
    }
}

extension FortuneClient: DependencyKey {
    public static let liveValue = FortuneClient.unavailable
    public static let testValue = FortuneClient.unavailable
}

public extension DependencyValues {
    var fortuneClient: FortuneClient {
        get { self[FortuneClient.self] }
        set { self[FortuneClient.self] = newValue }
    }
}

public extension FortuneClient {
    static let unavailable = Self(
        fetchToday: {
            throw FortuneClientError.notConfigured
        },
        fetchDetail: { _ in
            throw FortuneClientError.notConfigured
        },
        fetchLuckAction: { _ in
            throw FortuneClientError.notConfigured
        },
        fetchMySaju: {
            throw FortuneClientError.notConfigured
        },
        fetchPartners: {
            throw FortuneClientError.notConfigured
        },
        fetchPartnerSaju: { _ in
            throw FortuneClientError.notConfigured
        },
        registerPartner: { _ in
            throw FortuneClientError.notConfigured
        },
        createCompatibility: { _, _ in
            throw FortuneClientError.notConfigured
        },
        createDayFortunes: { _, _ in
            throw FortuneClientError.notConfigured
        },
        createYearFortune: { _ in
            throw FortuneClientError.notConfigured
        }
    )
}
