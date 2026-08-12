import ComposableArchitecture
@preconcurrency import UserNotifications

public enum NotificationAuthorizationStatus: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
}

public struct NotificationSettingsAuthorizationClient: Sendable {
    public var authorizationStatus: @Sendable () async -> NotificationAuthorizationStatus
    public var requestAuthorization: @Sendable () async -> NotificationAuthorizationStatus

    public init(
        authorizationStatus: @escaping @Sendable () async -> NotificationAuthorizationStatus,
        requestAuthorization: @escaping @Sendable () async -> NotificationAuthorizationStatus
    ) {
        self.authorizationStatus = authorizationStatus
        self.requestAuthorization = requestAuthorization
    }
}

extension NotificationSettingsAuthorizationClient: DependencyKey {
    public static let liveValue = Self(
        authorizationStatus: { await fetchNotificationAuthorizationStatus() },
        requestAuthorization: {
            _ = try? await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return await fetchNotificationAuthorizationStatus()
        }
    )

    public static let testValue = Self(
        authorizationStatus: { .denied },
        requestAuthorization: { .denied }
    )
}

public extension DependencyValues {
    var notificationSettingsAuthorizationClient: NotificationSettingsAuthorizationClient {
        get { self[NotificationSettingsAuthorizationClient.self] }
        set { self[NotificationSettingsAuthorizationClient.self] = newValue }
    }
}

private func fetchNotificationAuthorizationStatus() async -> NotificationAuthorizationStatus {
    let settings = await UNUserNotificationCenter.current().notificationSettings()

    switch settings.authorizationStatus {
    case .notDetermined:
        return .notDetermined
    case .denied:
        return .denied
    case .authorized, .provisional, .ephemeral:
        return .authorized
    @unknown default:
        return .denied
    }
}
