import ComposableArchitecture
import NotificationFeatureInterface

extension NotificationClient: @retroactive DependencyKey {
    public static let liveValue = NotificationClient.unavailable
    public static let testValue = NotificationClient.unavailable
}

public extension DependencyValues {
    var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
