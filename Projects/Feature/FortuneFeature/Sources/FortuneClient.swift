import ComposableArchitecture
import Foundation

public struct FortuneClient: Sendable {
    public var fetchToday: @Sendable () async throws -> FortuneHomeContent
    public var fetchDetail: @Sendable (UUID) async throws -> FortuneDetailContent

    public init(
        fetchToday: @escaping @Sendable () async throws -> FortuneHomeContent,
        fetchDetail: @escaping @Sendable (UUID) async throws -> FortuneDetailContent
    ) {
        self.fetchToday = fetchToday
        self.fetchDetail = fetchDetail
    }
}

public enum FortuneClientError: Error, Equatable, Sendable {
    case notConfigured
    case server(code: String, message: String?)
    case httpStatus(Int)
    case invalidResponse
    case unsupportedCategory(String)
    case transport
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
        }
    )
}
