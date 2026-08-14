// 도메인 결과 타입은 프로토콜 필수 프로퍼티 이름이 `id`인 Identifiable을 준수한다.
// swiftlint:disable identifier_name

import Foundation
import Model

public struct LuckActionDetail: Equatable, Sendable {
    public let id: UUID
    public let category: FortuneCategory
    public let score: Int
    public let title: String
    public let content: String
    public let isAchieved: Bool

    public init(
        id: UUID,
        category: FortuneCategory,
        score: Int,
        title: String,
        content: String,
        isAchieved: Bool
    ) {
        self.id = id
        self.category = category
        self.score = score
        self.title = title
        self.content = content
        self.isAchieved = isAchieved
    }
}

public struct FortunePartner: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let relationship: FortuneRelationship
    public let gender: Gender?
    public let birthDate: Date?
    public let calendarType: BirthDateCalendar?
    public let birthTime: BirthTimePeriod?
    public let isBirthTimeUnknown: Bool

    public init(
        id: UUID,
        name: String,
        relationship: FortuneRelationship,
        gender: Gender? = nil,
        birthDate: Date? = nil,
        calendarType: BirthDateCalendar? = nil,
        birthTime: BirthTimePeriod? = nil,
        isBirthTimeUnknown: Bool = false
    ) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.gender = gender
        self.birthDate = birthDate
        self.calendarType = calendarType
        self.birthTime = birthTime
        self.isBirthTimeUnknown = isBirthTimeUnknown
    }
}

public enum FortuneRelationship: String, Equatable, Sendable {
    case partner
    case friend
    case colleague
    case family
    case other

    public var title: String {
        switch self {
        case .partner: "연인"
        case .friend: "친구"
        case .colleague: "동료"
        case .family: "가족"
        case .other: "기타"
        }
    }
}

public struct PartnerRegistrationInput: Equatable, Sendable {
    public let name: String
    public let gender: Gender
    public let calendarType: BirthDateCalendar
    public let birthDate: Date
    public let birthTime: BirthTimePeriod?
    public let isBirthTimeUnknown: Bool
    public let relationship: Relationship

    public init(
        name: String,
        gender: Gender,
        calendarType: BirthDateCalendar,
        birthDate: Date,
        birthTime: BirthTimePeriod?,
        isBirthTimeUnknown: Bool,
        relationship: Relationship
    ) {
        self.name = name
        self.gender = gender
        self.calendarType = calendarType
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.isBirthTimeUnknown = isBirthTimeUnknown
        self.relationship = relationship
    }
}

public struct SajuChartDetail: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let name: String?
    public let gender: Gender?
    public let birthDate: Date
    public let calendarType: BirthDateCalendar?
    public let birthTime: BirthTimePeriod?
    public let isBirthTimeUnknown: Bool
    public let pillars: [SajuPillar]

    public init(
        id: UUID,
        name: String?,
        gender: Gender?,
        birthDate: Date,
        calendarType: BirthDateCalendar?,
        birthTime: BirthTimePeriod?,
        isBirthTimeUnknown: Bool,
        pillars: [SajuPillar]
    ) {
        self.id = id
        self.name = name
        self.gender = gender
        self.birthDate = birthDate
        self.calendarType = calendarType
        self.birthTime = birthTime
        self.isBirthTimeUnknown = isBirthTimeUnknown
        self.pillars = pillars
    }
}

public struct SajuPillar: Equatable, Identifiable, Sendable {
    public var id: SajuPillarType { type }
    public let type: SajuPillarType
    public let heavenlyStem: SajuSymbol
    public let earthlyBranch: SajuSymbol
    public let stemTenGod: String?
    public let branchTenGod: String
    public let twelveLifeStage: String?

    public init(
        type: SajuPillarType,
        heavenlyStem: SajuSymbol,
        earthlyBranch: SajuSymbol,
        stemTenGod: String?,
        branchTenGod: String,
        twelveLifeStage: String? = nil
    ) {
        self.type = type
        self.heavenlyStem = heavenlyStem
        self.earthlyBranch = earthlyBranch
        self.stemTenGod = stemTenGod
        self.branchTenGod = branchTenGod
        self.twelveLifeStage = twelveLifeStage
    }
}

public enum SajuPillarType: String, Equatable, Sendable {
    case hour = "HOUR"
    case day = "DAY"
    case month = "MONTH"
    case year = "YEAR"

    public var title: String {
        switch self {
        case .hour: "시주"
        case .day: "일주"
        case .month: "월주"
        case .year: "년주"
        }
    }

    public var sortOrder: Int {
        switch self {
        case .hour: 0
        case .day: 1
        case .month: 2
        case .year: 3
        }
    }
}

public struct SajuSymbol: Equatable, Sendable {
    public let hanja: String
    public let reading: String
    public let elementLabel: String
    public let elementHanja: String

    public init(
        hanja: String,
        reading: String,
        elementLabel: String,
        elementHanja: String
    ) {
        self.hanja = hanja
        self.reading = reading
        self.elementLabel = elementLabel
        self.elementHanja = elementHanja
    }
}

public enum FortuneElement: String, CaseIterable, Equatable, Sendable {
    case wood
    case fire
    case earth
    case metal
    case water

    public var title: String {
        switch self {
        case .wood: "목"
        case .fire: "화"
        case .earth: "토"
        case .metal: "금"
        case .water: "수"
        }
    }
}

public struct FortuneElementScore: Equatable, Identifiable, Sendable {
    public var id: FortuneElement { element }
    public let element: FortuneElement
    public let percentage: Int

    public init(element: FortuneElement, percentage: Int) {
        self.element = element
        self.percentage = percentage
    }
}

public struct CompatibilityResult: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let partnerName: String
    public let relationship: FortuneRelationship
    public let score: Int
    public let headline: String
    public let subheadline: String
    public let summary: String
    public let totalAnalysis: String
    public let analysisBasis: String
    public let elements: [FortuneElementScore]

    public init(
        id: UUID,
        partnerName: String,
        relationship: FortuneRelationship,
        score: Int,
        headline: String,
        subheadline: String,
        summary: String,
        totalAnalysis: String,
        analysisBasis: String,
        elements: [FortuneElementScore]
    ) {
        self.id = id
        self.partnerName = partnerName
        self.relationship = relationship
        self.score = score
        self.headline = headline
        self.subheadline = subheadline
        self.summary = summary
        self.totalAnalysis = totalAnalysis
        self.analysisBasis = analysisBasis
        self.elements = elements
    }
}

public enum DayFortunePurpose: String, CaseIterable, Equatable, Sendable {
    case contractMoving = "CONTRACT_MOVING"
    case businessOpening = "BUSINESS_OPENING"
    case travel = "TRAVEL"
    case confessionDating = "CONFESSION_DATING"
    case examInterview = "EXAM_INTERVIEW"

    public var title: String {
        switch self {
        case .contractMoving: "계약 ∙ 이사"
        case .businessOpening: "개업"
        case .travel: "여행"
        case .confessionDating: "고백 ∙ 소개팅"
        case .examInterview: "시험 ∙ 면접"
        }
    }
}

public struct FortuneCategoryStar: Equatable, Identifiable, Sendable {
    public var id: FortuneCategory { category }
    public let category: FortuneCategory
    public let star: Int

    public init(category: FortuneCategory, star: Int) {
        self.category = category
        self.star = star
    }
}

public struct DayFortuneResult: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let purpose: DayFortunePurpose
    public let targetDate: Date
    public let score: Int
    public let title: String
    public let content: String
    public let categories: [FortuneCategoryStar]

    public init(
        id: UUID,
        purpose: DayFortunePurpose,
        targetDate: Date,
        score: Int,
        title: String,
        content: String,
        categories: [FortuneCategoryStar]
    ) {
        self.id = id
        self.purpose = purpose
        self.targetDate = targetDate
        self.score = score
        self.title = title
        self.content = content
        self.categories = categories
    }
}

public struct YearFortuneResult: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let year: Int
    public let score: Int
    public let title: String
    public let content: String
    public let categories: [FortuneCategoryStar]

    public init(
        id: UUID,
        year: Int,
        score: Int,
        title: String,
        content: String,
        categories: [FortuneCategoryStar]
    ) {
        self.id = id
        self.year = year
        self.score = score
        self.title = title
        self.content = content
        self.categories = categories
    }
}

// swiftlint:enable identifier_name
