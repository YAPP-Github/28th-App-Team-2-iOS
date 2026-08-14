import Dependencies
import Foundation

public struct SessionRefreshOperation: Sendable {
    private let operation: @Sendable (String) async throws -> SessionTokens

    public init(_ operation: @escaping @Sendable (String) async throws -> SessionTokens) {
        self.operation = operation
    }

    public func callAsFunction(_ refreshToken: String) async throws -> SessionTokens {
        try await operation(refreshToken)
    }
}

/// 인증 token의 저장·복원과 refresh 동시성을 단일 경계에서 관리합니다.
public struct AuthSessionClient: Sendable {
    /// 저장된 세션을 메모리로 복원하고 세션 존재 여부를 반환합니다.
    public var restore: @Sendable () async throws -> Bool

    /// 새 access/refresh token 쌍을 저장합니다.
    public var save: @Sendable (SessionTokens) async throws -> Void

    /// 메모리와 영구 저장소의 세션을 모두 제거합니다.
    public var clear: @Sendable () async throws -> Void

    /// 현재 세션으로 구성한 HTTP Authorization 헤더를 반환합니다.
    ///
    /// 세션이 없으면 빈 dictionary를 반환하며 raw access token은 노출하지 않습니다.
    public var authorizationHeaders: @Sendable () async -> [String: String]

    /// 저장된 refresh token으로 token 쌍을 갱신합니다.
    ///
    /// 여러 호출이 동시에 들어오면 하나의 refresh 작업을 공유합니다.
    private var performRefresh: @Sendable (SessionRefreshOperation) async throws -> SessionTokens

    public init(
        restore: @escaping @Sendable () async throws -> Bool,
        save: @escaping @Sendable (SessionTokens) async throws -> Void,
        clear: @escaping @Sendable () async throws -> Void,
        authorizationHeaders: @escaping @Sendable () async -> [String: String],
        refresh: @escaping @Sendable (SessionRefreshOperation) async throws -> SessionTokens
    ) {
        self.restore = restore
        self.save = save
        self.clear = clear
        self.authorizationHeaders = authorizationHeaders
        self.performRefresh = refresh
    }

    public func refresh(
        using operation: @escaping @Sendable (String) async throws -> SessionTokens
    ) async throws -> SessionTokens {
        try await performRefresh(SessionRefreshOperation(operation))
    }
}

extension AuthSessionClient: DependencyKey {
    public static let liveValue = AuthSessionClient.live
    public static let testValue = AuthSessionClient.noSession
}

public extension DependencyValues {
    var authSession: AuthSessionClient {
        get { self[AuthSessionClient.self] }
        set { self[AuthSessionClient.self] = newValue }
    }
}

public extension AuthSessionClient {
    static let live = live(storage: .keychain)

    static let noSession = Self(
        restore: { false },
        save: { _ in },
        clear: {},
        authorizationHeaders: { [:] },
        refresh: { _ in throw AuthSessionError.sessionNotFound }
    )
}

extension AuthSessionClient {
    static func live(storage: SessionTokenStorage) -> Self {
        let session = AuthSession(storage: storage)

        return Self(
            restore: { try await session.restore() },
            save: { try await session.save($0) },
            clear: { try await session.clear() },
            authorizationHeaders: { await session.authorizationHeaders() },
            refresh: { try await session.refresh(using: $0) }
        )
    }
}

public enum AuthSessionError: Error, Equatable, Sendable {
    case sessionNotFound
    case invalidStoredSession
    case loadFailed
    case saveFailed
    case clearFailed

    public init(_ error: Error, fallback: AuthSessionError) {
        self = error as? AuthSessionError ?? fallback
    }
}

private actor AuthSession {
    private let storage: SessionTokenStorage
    private var cachedTokens: SessionTokens?
    private var didRestore = false
    private var refreshTask: Task<SessionTokens, Error>?

    init(storage: SessionTokenStorage) {
        self.storage = storage
    }

    func restore() throws -> Bool {
        if !didRestore {
            cachedTokens = try storage.load()
            didRestore = true
        }
        guard cachedTokens?.isValid ?? true else {
            try? storage.clear()
            cachedTokens = nil
            throw AuthSessionError.invalidStoredSession
        }
        return cachedTokens != nil
    }

    func save(_ tokens: SessionTokens) throws {
        guard tokens.isValid else {
            throw AuthSessionError.invalidStoredSession
        }
        try storage.save(tokens)
        cachedTokens = tokens
        didRestore = true
    }

    func clear() throws {
        try storage.clear()
        cachedTokens = nil
        didRestore = true
    }

    func authorizationHeaders() -> [String: String] {
        guard let accessToken = cachedTokens?.accessToken, !accessToken.isEmpty else {
            return [:]
        }
        return ["Authorization": "Bearer \(accessToken)"]
    }

    func refresh(using operation: SessionRefreshOperation) async throws -> SessionTokens {
        if let refreshTask {
            return try await refreshTask.value
        }

        if !didRestore {
            cachedTokens = try storage.load()
            didRestore = true
        }

        guard let refreshToken = cachedTokens?.refreshToken, !refreshToken.isEmpty else {
            throw AuthSessionError.sessionNotFound
        }

        let storage = storage
        let task = Task {
            let tokens = try await operation(refreshToken)
            guard tokens.isValid else {
                throw AuthSessionError.invalidStoredSession
            }

            do {
                try storage.save(tokens)
                return tokens
            } catch {
                try? storage.clear()
                throw AuthSessionError(error, fallback: .saveFailed)
            }
        }
        refreshTask = task

        do {
            let tokens = try await task.value
            cachedTokens = tokens
            refreshTask = nil
            return tokens
        } catch {
            if case .saveFailed = error as? AuthSessionError {
                cachedTokens = nil
                didRestore = true
            }
            refreshTask = nil
            throw error
        }
    }
}
