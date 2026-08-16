import Foundation
import NotificationFeatureInterface

public enum NotificationFixture {
    public static func notification(
        identifier: UUID = UUID(),
        type: NotificationType = .aiComplete,
        title: String = "토닥이 답변",
        content: String = "토닥이 답변이 도착했어요.",
        deepLink: URL? = nil,
        isRead: Bool = false,
        createdAt: Date = .now
    ) -> InAppNotification {
        InAppNotification(
            identifier: identifier,
            type: type,
            title: title,
            content: content,
            deepLink: deepLink,
            isRead: isRead,
            createdAt: createdAt
        )
    }
}

public actor NotificationMock {
    private var list: NotificationList

    public init(list: NotificationList = .init(unreadCount: 0, notifications: [])) {
        self.list = list
    }

    public func fetchNotifications() -> NotificationList {
        list
    }

    public func markAsRead(notificationID: UUID) {
        guard let index = list.notifications.firstIndex(where: { $0.id == notificationID }) else { return }
        guard !list.notifications[index].isRead else { return }

        var notifications = list.notifications
        notifications[index] = notifications[index].markedAsRead()
        list = NotificationList(
            unreadCount: max(0, list.unreadCount - 1),
            notifications: notifications
        )
    }
}

public extension NotificationClient {
    static func mock(repository: NotificationMock) -> Self {
        Self(
            fetchNotifications: { await repository.fetchNotifications() },
            markAsRead: { notificationID in
                await repository.markAsRead(notificationID: notificationID)
            }
        )
    }
}
