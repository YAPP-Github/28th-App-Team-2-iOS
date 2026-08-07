import ComposableArchitecture
import Foundation
import Security

public struct TokenStore: Sendable {
    public var save: @Sendable (SessionTokens) throws -> Void

    public init(save: @escaping @Sendable (SessionTokens) throws -> Void) {
        self.save = save
    }
}

extension TokenStore: DependencyKey {
    public static let liveValue = TokenStore.live
    public static let testValue = TokenStore.live
}

public extension DependencyValues {
    var tokenStore: TokenStore {
        get { self[TokenStore.self] }
        set { self[TokenStore.self] = newValue }
    }
}

public extension TokenStore {
    static let live = Self { tokens in
        try KeychainTokenStore.save(tokens.accessToken, account: "accessToken")
        try KeychainTokenStore.save(tokens.refreshToken, account: "refreshToken")
    }
}

public enum TokenStoreError: Error, Equatable, Sendable {
    case saveFailed

    init(_ error: Error) {
        self = .saveFailed
    }
}

private enum KeychainTokenStore {
    private static let service = "com.kikidan.todakun.auth"

    static func save(_ value: String, account: String) throws {
        let data = Data(value.utf8)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        let attributes: [CFString: Any] = [kSecValueData: data]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecSuccess { return }

        var addQuery = query
        addQuery[kSecValueData] = data
        addQuery[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        guard SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess else {
            throw TokenStoreError.saveFailed
        }
    }
}
