import Foundation

public struct OAuthConfiguration: Sendable {
    public let kakaoNativeAppKey: String?
    public let googleIOSClientID: String?
    public let apiBaseURL: URL?

    public init(bundle: Bundle = .main) {
        kakaoNativeAppKey = Self.value(for: "KAKAO_NATIVE_APP_KEY", in: bundle)
        googleIOSClientID = Self.value(for: "GOOGLE_IOS_CLIENT_ID", in: bundle)
        apiBaseURL = Self.value(for: "API_BASE_URL", in: bundle).flatMap(URL.init(string:))
    }

    public static let current = OAuthConfiguration()

    private static func value(for key: String, in bundle: Bundle) -> String? {
        guard let value = bundle.object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedValue.isEmpty, !trimmedValue.hasPrefix("$(") else { return nil }
        return trimmedValue
    }
}
