import Foundation
import Testing
@testable import AuthSession

struct AuthSessionClientTests {
    @Test("세션을 저장하고 Authorization 헤더로 제공한다")
    func savesAndProvidesAuthorizationHeader() async throws {
        let storage = InMemorySessionStorage()
        let client = AuthSessionClient.live(storage: storage.client)
        let tokens = SessionTokens(accessToken: "access-token", refreshToken: "refresh-token")

        try await client.save(tokens)

        #expect(await client.authorizationHeaders() == ["Authorization": "Bearer access-token"])
        #expect(try storage.load() == tokens)
    }

    @Test("저장된 세션을 복원하고 삭제한다")
    func restoresAndClearsStoredSession() async throws {
        let tokens = SessionTokens(accessToken: "access-token", refreshToken: "refresh-token")
        let storage = InMemorySessionStorage(tokens: tokens)
        let client = AuthSessionClient.live(storage: storage.client)

        #expect(try await client.restore())
        #expect(await client.authorizationHeaders() == ["Authorization": "Bearer access-token"])

        try await client.clear()

        #expect(await client.authorizationHeaders().isEmpty)
        #expect(try storage.load() == nil)
    }

    @Test("빈 token으로 구성된 저장 세션은 복원하지 않는다")
    func rejectsStoredSessionWithEmptyToken() async throws {
        let storage = InMemorySessionStorage(
            tokens: SessionTokens(accessToken: "", refreshToken: "refresh-token")
        )
        let client = AuthSessionClient.live(storage: storage.client)

        await #expect(throws: AuthSessionError.invalidStoredSession) {
            try await client.restore()
        }
        #expect(try storage.load() == nil)
    }

    @Test("빈 token 세션을 저장하지 않는다")
    func rejectsSavingSessionWithEmptyToken() async throws {
        let storage = InMemorySessionStorage()
        let client = AuthSessionClient.live(storage: storage.client)

        await #expect(throws: AuthSessionError.invalidStoredSession) {
            try await client.save(SessionTokens(accessToken: "access-token", refreshToken: ""))
        }
        #expect(try storage.load() == nil)
    }

    @Test("동시 refresh 요청은 하나의 작업과 결과를 공유한다")
    func sharesConcurrentRefreshOperation() async throws {
        let storage = InMemorySessionStorage(
            tokens: SessionTokens(accessToken: "old-access", refreshToken: "old-refresh")
        )
        let client = AuthSessionClient.live(storage: storage.client)
        let counter = RefreshCounter()
        let operation: @Sendable (String) async throws -> SessionTokens = { refreshToken in
            await counter.increment()
            #expect(refreshToken == "old-refresh")
            try await Task.sleep(for: .milliseconds(50))
            return SessionTokens(accessToken: "new-access", refreshToken: "new-refresh")
        }

        async let first = client.refresh(using: operation)
        async let second = client.refresh(using: operation)

        let results = try await [first, second]

        #expect(results == [
            SessionTokens(accessToken: "new-access", refreshToken: "new-refresh"),
            SessionTokens(accessToken: "new-access", refreshToken: "new-refresh")
        ])
        #expect(await counter.value == 1)
        #expect(await client.authorizationHeaders() == ["Authorization": "Bearer new-access"])
    }

    @Test("세션 없이 refresh하면 명시적인 오류를 반환한다")
    func refreshWithoutSessionFails() async {
        let client = AuthSessionClient.live(storage: InMemorySessionStorage().client)

        await #expect(throws: AuthSessionError.sessionNotFound) {
            try await client.refresh(using: { _ in
                SessionTokens(accessToken: "access", refreshToken: "refresh")
            })
        }
    }
}

private final class InMemorySessionStorage: @unchecked Sendable {
    private let lock = NSLock()
    private var tokens: SessionTokens?

    init(tokens: SessionTokens? = nil) {
        self.tokens = tokens
    }

    var client: SessionTokenStorage {
        SessionTokenStorage(
            load: { try self.load() },
            save: { self.save($0) },
            clear: { self.clear() }
        )
    }

    func load() throws -> SessionTokens? {
        lock.withLock { tokens }
    }

    private func save(_ tokens: SessionTokens) {
        lock.withLock { self.tokens = tokens }
    }

    private func clear() {
        lock.withLock { tokens = nil }
    }
}

private actor RefreshCounter {
    private(set) var value = 0

    func increment() {
        value += 1
    }
}
