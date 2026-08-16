// `Identifiable` 및 서버 계약의 `id` 명명은 SwiftLint 기본 식별자 규칙의 예외다.
// swiftlint:disable identifier_name

import Foundation

public struct LuckyAction: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let category: LuckyActionCategory
    public let score: Int
    public let title: String
    public let isAchieved: Bool

    public init(
        id: UUID,
        category: LuckyActionCategory,
        score: Int,
        title: String,
        isAchieved: Bool
    ) {
        self.id = id
        self.category = category
        self.score = score
        self.title = title
        self.isAchieved = isAchieved
    }
}

public enum LuckyActionCategory: String, CaseIterable, Equatable, Hashable, Sendable {
    case relationship
    case love
    case achievement
    case health
    case money

    public init(apiValue: String) throws {
        switch apiValue {
        case "RELATIONSHIP": self = .relationship
        case "LOVE": self = .love
        case "ACHIEVEMENT": self = .achievement
        case "HEALTH": self = .health
        case "MONEY": self = .money
        default: throw LuckyActionClientError.unsupportedCategory(apiValue)
        }
    }

    public var sortOrder: Int {
        switch self {
        case .relationship: 0
        case .love: 1
        case .achievement: 2
        case .health: 3
        case .money: 4
        }
    }

    public var summaryTitle: String {
        switch self {
        case .relationship: "관계운"
        case .love: "연애운"
        case .achievement: "직장운"
        case .health: "건강운"
        case .money: "금전운"
        }
    }

    public var badgeTitle: String {
        switch self {
        case .relationship: "관계"
        case .love: "연애"
        case .achievement: "직장"
        case .health: "건강"
        case .money: "금전"
        }
    }
}

// swiftlint:enable identifier_name
