// `Identifiable` 준수를 위한 `id`는 SwiftLint 기본 식별자 규칙의 예외다.
// swiftlint:disable identifier_name

import Foundation

public struct CalendarEventDraft: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let date: Date
    public let isAllDay: Bool
    public let timeZoneIdentifier: String
    public let notes: String?

    public init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        isAllDay: Bool = true,
        timeZoneIdentifier: String = TimeZone.current.identifier,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.isAllDay = isAllDay
        self.timeZoneIdentifier = timeZoneIdentifier
        self.notes = notes
    }

    init(dayFortuneResult: DayFortuneResult) {
        self.init(
            id: dayFortuneResult.id,
            title: dayFortuneResult.purpose.title,
            date: dayFortuneResult.targetDate
        )
    }
}

public enum CalendarEventEditorResult: Equatable, Sendable {
    case saved
    case cancelled
}

// swiftlint:enable identifier_name
