import ComposableArchitecture
@preconcurrency import UserNotifications

public struct NotificationAuthorizationClient: Sendable {
    public var requestAuthorization: @Sendable () async -> Bool

    public init(requestAuthorization: @escaping @Sendable () async -> Bool) {
        self.requestAuthorization = requestAuthorization
    }
}

extension NotificationAuthorizationClient: DependencyKey {
    public static let liveValue = Self {
        (try? await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        )) ?? false
    }

    public static let testValue = Self { false }
}

public extension DependencyValues {
    var notificationAuthorizationClient: NotificationAuthorizationClient {
        get { self[NotificationAuthorizationClient.self] }
        set { self[NotificationAuthorizationClient.self] = newValue }
    }
}
