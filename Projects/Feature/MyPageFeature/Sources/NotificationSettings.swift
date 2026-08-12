import Foundation

public struct NotificationSettings: Equatable, Sendable {
    public var morningReportEnabled: Bool
    public var morningReportTime: NotificationTime
    public var todakiEnabled: Bool
    public var luckyActionReminderEnabled: Bool

    public init(
        morningReportEnabled: Bool,
        morningReportTime: NotificationTime,
        todakiEnabled: Bool,
        luckyActionReminderEnabled: Bool
    ) {
        self.morningReportEnabled = morningReportEnabled
        self.morningReportTime = morningReportTime
        self.todakiEnabled = todakiEnabled
        self.luckyActionReminderEnabled = luckyActionReminderEnabled
    }

    public static let `default` = Self(
        morningReportEnabled: false,
        morningReportTime: NotificationTime(hour: 8, minute: 0),
        todakiEnabled: false,
        luckyActionReminderEnabled: false
    )
}

public struct NotificationTime: Equatable, Sendable {
    public let hour: Int
    public let minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = min(max(hour, 0), 23)
        self.minute = min(max(minute, 0), 59)
    }

    public var apiValue: String {
        String(format: "%02d:%02d", hour, minute)
    }

    public var displayText: String {
        let period = hour < 12 ? "오전" : "오후"
        let displayHour = hour % 12 == 0 ? 12 : hour % 12
        return "\(period) \(displayHour):\(String(format: "%02d", minute))"
    }
}

public enum NotificationSettingToggle: Equatable, Sendable {
    case morningReport
    case todaki
    case luckyActionReminder
}

extension NotificationSettings {
    mutating func set(_ toggle: NotificationSettingToggle, enabled: Bool) {
        switch toggle {
        case .morningReport:
            morningReportEnabled = enabled
        case .todaki:
            todakiEnabled = enabled
        case .luckyActionReminder:
            luckyActionReminderEnabled = enabled
        }
    }
}
