import Foundation

public struct NotificationList: Equatable, Sendable {
    public let unreadCount: Int
    public let notifications: [InAppNotification]

    public init(unreadCount: Int, notifications: [InAppNotification]) {
        self.unreadCount = unreadCount
        self.notifications = notifications
    }
}

public struct InAppNotification: Equatable, Identifiable, Sendable {
    // SwiftUI Identifiable 계약의 고정 API를 유지한다.
    // swiftlint:disable:next identifier_name
    public let id: UUID
    public let type: NotificationType
    public let title: String
    public let content: String
    public let deepLink: URL?
    public let isRead: Bool
    public let createdAt: Date

    public init(
        identifier: UUID,
        type: NotificationType,
        title: String,
        content: String,
        deepLink: URL? = nil,
        isRead: Bool,
        createdAt: Date
    ) {
        self.id = identifier
        self.type = type
        self.title = title
        self.content = content
        self.deepLink = deepLink
        self.isRead = isRead
        self.createdAt = createdAt
    }

    public func markedAsRead() -> Self {
        Self(
            identifier: id,
            type: type,
            title: title,
            content: content,
            deepLink: deepLink,
            isRead: true,
            createdAt: createdAt
        )
    }
}

public enum NotificationDeepLink: Equatable, Sendable {
    case chatConversation(UUID)
    case luckyAction
    case todayFortune
    case notice(String)

    public init?(url: URL) {
        guard url.scheme == "todakun", let host = url.host else { return nil }
        let components = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "chat":
            guard components.count == 2, components[0] == "conversations",
                  let uuid = UUID(uuidString: components[1]) else { return nil }
            self = .chatConversation(uuid)
        case "lucky-action":
            self = .luckyAction
        case "fortune":
            guard components.isEmpty || components == ["today"] else { return nil }
            self = .todayFortune
        case "notice":
            guard let noticeID = components.first, components.count == 1 else { return nil }
            self = .notice(noticeID)
        default:
            return nil
        }
    }
}

public enum NotificationType: String, Equatable, Sendable {
    case notice = "NOTICE"
    case fortune = "FORTUNE"
    case luckyAction = "LUCKY_ACTION"
    case aiComplete = "AI_COMPLETE"

    public var label: String {
        switch self {
        case .notice:
            "공지"
        case .fortune:
            "운세"
        case .luckyAction:
            "행운액션"
        case .aiComplete:
            "토닥이"
        }
    }
}

public enum NotificationTimeFormatter {
    public static func string(
        createdAt: Date,
        now: Date,
        calendar: Calendar = .current
    ) -> String {
        let elapsed = max(0, now.timeIntervalSince(createdAt))

        if elapsed < 60 {
            return "방금 전"
        }
        if elapsed < 3_600 {
            return "\(Int(elapsed / 60))분 전"
        }
        if elapsed < 86_400 {
            return "\(Int(elapsed / 3_600))시간 전"
        }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: createdAt)
    }
}
