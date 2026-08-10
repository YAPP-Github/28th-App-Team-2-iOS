import Foundation
import Security

struct SessionTokenStorage: Sendable {
    var load: @Sendable () throws -> SessionTokens?
    var save: @Sendable (SessionTokens) throws -> Void
    var clear: @Sendable () throws -> Void
}

extension SessionTokenStorage {
    static let keychain = Self(
        load: { try KeychainSessionStorage.load() },
        save: { try KeychainSessionStorage.save($0) },
        clear: { try KeychainSessionStorage.clear() }
    )
}

private enum KeychainSessionStorage {
    private static let service = "com.kikidan.todakun.auth"
    private static let sessionAccount = "sessionTokens"
    private static let legacyAccessTokenAccount = "accessToken"
    private static let legacyRefreshTokenAccount = "refreshToken"

    static func load() throws -> SessionTokens? {
        if let data = try read(account: sessionAccount) {
            guard let tokens = try? JSONDecoder().decode(SessionTokens.self, from: data) else {
                throw AuthSessionError.invalidStoredSession
            }
            guard tokens.isValid else {
                try? clear()
                throw AuthSessionError.invalidStoredSession
            }
            return tokens
        }

        let legacyAccessToken = try read(account: legacyAccessTokenAccount)
            .flatMap { String(data: $0, encoding: .utf8) }
        let legacyRefreshToken = try read(account: legacyRefreshTokenAccount)
            .flatMap { String(data: $0, encoding: .utf8) }

        guard let legacyAccessToken, let legacyRefreshToken,
              !legacyAccessToken.isEmpty, !legacyRefreshToken.isEmpty else {
            if legacyAccessToken != nil || legacyRefreshToken != nil {
                try clearLegacyTokens()
            }
            return nil
        }

        let tokens = SessionTokens(
            accessToken: legacyAccessToken,
            refreshToken: legacyRefreshToken
        )
        try save(tokens)
        try clearLegacyTokens()
        return tokens
    }

    static func save(_ tokens: SessionTokens) throws {
        guard tokens.isValid else {
            throw AuthSessionError.invalidStoredSession
        }
        guard let data = try? JSONEncoder().encode(tokens) else {
            throw AuthSessionError.saveFailed
        }
        try write(data, account: sessionAccount)
    }

    static func clear() throws {
        do {
            try delete(account: sessionAccount)
            try clearLegacyTokens()
        } catch {
            throw AuthSessionError.clearFailed
        }
    }

    private static func clearLegacyTokens() throws {
        try delete(account: legacyAccessTokenAccount)
        try delete(account: legacyRefreshTokenAccount)
    }

    private static func read(account: String) throws -> Data? {
        var query = baseQuery(account: account)
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw AuthSessionError.invalidStoredSession
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw AuthSessionError.loadFailed
        }
    }

    private static func write(_ data: Data, account: String) throws {
        let query = baseQuery(account: account)
        let attributes: [CFString: Any] = [kSecValueData: data]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecSuccess { return }
        guard updateStatus == errSecItemNotFound else {
            throw AuthSessionError.saveFailed
        }

        var addQuery = query
        addQuery[kSecValueData] = data
        addQuery[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        guard SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess else {
            throw AuthSessionError.saveFailed
        }
    }

    private static func delete(account: String) throws {
        let status = SecItemDelete(baseQuery(account: account) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AuthSessionError.clearFailed
        }
    }

    private static func baseQuery(account: String) -> [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
    }
}
