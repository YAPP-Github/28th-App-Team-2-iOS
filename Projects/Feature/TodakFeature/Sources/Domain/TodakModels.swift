import Foundation

// `Identifiable`이 요구하는 표준 프로퍼티 이름이다.
// swiftlint:disable identifier_name

public struct TodakEntry: Equatable, Sendable {
    public let greeting: String
    public let suggestions: [TodakSuggestion]
    public let quota: TodakQuota

    public init(greeting: String, suggestions: [TodakSuggestion], quota: TodakQuota) {
        self.greeting = greeting
        self.suggestions = suggestions
        self.quota = quota
    }

    public static let initial = Self(
        greeting: "오늘은 어떤 게 궁금해?",
        suggestions: [
            .init(
                emoji: "🤝",
                label: "관계운에 관하여 궁금해",
                seedPrompt: "요즘 관계운이 궁금해.",
                category: .relationship
            ),
            .init(
                emoji: "💌",
                label: "연애운에 관하여 궁금해",
                seedPrompt: "요즘 연애운이 궁금해.",
                category: .love
            ),
            .init(
                emoji: "💼",
                label: "성취운에 관하여 궁금해",
                seedPrompt: "요즘 성취운이 궁금해.",
                category: .achievement
            ),
            .init(
                emoji: "🧧",
                label: "금전운에 관하여 궁금해",
                seedPrompt: "요즘 금전운이 궁금해.",
                category: .money
            ),
            .init(
                emoji: "💪",
                label: "건강운에 관하여 궁금해",
                seedPrompt: "요즘 건강운이 궁금해.",
                category: .health
            ),
            .init(
                emoji: "💬",
                label: "그 외에 다른 운이 궁금해",
                seedPrompt: "요즘 궁금한 게 있어.",
                category: nil
            )
        ],
        quota: .init(used: 0, limit: 3)
    )
}

public struct TodakSuggestion: Equatable, Identifiable, Sendable {
    public let emoji: String
    public let label: String
    public let seedPrompt: String
    public let category: TodakCategory?

    public var id: String { "\(category?.rawValue ?? "OTHER")|\(seedPrompt)" }

    public init(emoji: String, label: String, seedPrompt: String, category: TodakCategory?) {
        self.emoji = emoji
        self.label = label
        self.seedPrompt = seedPrompt
        self.category = category
    }

    public var displayText: String {
        label.hasPrefix(emoji) ? label : "\(emoji) \(label)"
    }
}

public struct TodakQuota: Equatable, Sendable {
    public let used: Int
    public let limit: Int

    public init(used: Int, limit: Int) {
        self.used = used
        self.limit = limit
    }

    public var remaining: Int { max(0, limit - used) }
}

public enum TodakCategory: String, Equatable, Sendable {
    case relationship = "RELATIONSHIP"
    case love = "LOVE"
    case achievement = "ACHIEVEMENT"
    case money = "MONEY"
    case health = "HEALTH"
    case other = "OTHER"
}

public enum TodakInitialReply {
    // 기획 확정 전까지 모든 추천 질문은 성취운 고정 답변을 공통으로 사용한다.
    // 카테고리별 답변이 전달되면 각 case의 값만 교체한다.
    public static func content(for category: TodakCategory) -> String {
        switch category {
        case .relationship:
            return relationshipContent
        case .love:
            return loveContent
        case .achievement:
            return achievementContent
        case .money:
            return moneyContent
        case .health:
            return healthContent
        case .other:
            return otherContent
        }
    }

    private static let relationshipContent = """
    인간관계에서 궁금한 걸 물어봐! 가족, 친구, 동료와의 관계 등 뭐든 괜찮아.
    """

    private static let loveContent = """
    그 사람과의 연애, 궁금한 걸 물어봐! 짝사랑, 재회, 갈등 등 뭐든 괜찮아.
    """

    private static let achievementContent = """
    커리어에서 궁금한 걸 물어봐! 이직, 승진, 목표 달성 등 뭐든 괜찮아.
    """

    private static let moneyContent = """
    돈 관리에서 궁금한 걸 물어봐! 저축, 지출, 투자 등 뭐든 괜찮아.
    """

    private static let healthContent = """
    요즘 컨디션에서 궁금한 걸 물어봐! 스트레스, 생활 습관 등 뭐든 괜찮아.
    """

    private static let otherContent = """
    그 외에 궁금한 게 있으면 물어봐! 사소한 것부터 마음속 얘기까지 다 괜찮아.
    """

}

public struct TodakConversationSummary: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let lastMessageAt: Date?
    public let unread: Bool

    public init(id: UUID, title: String, lastMessageAt: Date?, unread: Bool) {
        self.id = id
        self.title = title
        self.lastMessageAt = lastMessageAt
        self.unread = unread
    }
}

public struct TodakConversation: Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let messages: [TodakMessage]

    public init(id: UUID, title: String, messages: [TodakMessage]) {
        self.id = id
        self.title = title
        self.messages = messages
    }
}

public struct TodakMessage: Equatable, Identifiable, Sendable {
    public enum Role: Equatable, Sendable {
        case user
        case assistant
        case unknown(String)
    }

    public enum Status: Equatable, Sendable {
        case streaming
        case completed
        case failed
        case unknown(String)
    }

    public let id: UUID
    public let role: Role
    public var content: String
    public var status: Status
    public var action: TodakMessageAction?
    public let createdAt: Date?

    public init(
        id: UUID,
        role: Role,
        content: String,
        status: Status,
        action: TodakMessageAction? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.status = status
        self.action = action
        self.createdAt = createdAt
    }
}

public struct TodakMessageAction: Equatable, Sendable {
    public let type: String
    public let label: String
    public let category: TodakCategory
    public let date: Date

    public init(type: String, label: String, category: TodakCategory, date: Date) {
        self.type = type
        self.label = label
        self.category = category
        self.date = date
    }
}

public enum TodakStreamEvent: Equatable, Sendable {
    case start(
        conversationID: UUID,
        userMessageID: UUID,
        assistantMessageID: UUID,
        quota: TodakQuota
    )
    case delta(String)
    case action(TodakMessageAction)
    case done(assistantMessageID: UUID)
    case error(code: String, message: String)
}

// swiftlint:enable identifier_name
