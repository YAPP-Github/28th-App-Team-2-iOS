import Foundation
import Model

public struct MyPageDashboard: Codable, Equatable, Sendable {
    public let profile: MyPageProfile
    public let chart: MyPageSajuChart

    public init(profile: MyPageProfile, chart: MyPageSajuChart) {
        self.profile = profile
        self.chart = chart
    }
}

public struct MyPageProfile: Codable, Equatable, Sendable {
    public let memberID: String
    public let name: String
    public let gender: String
    public let birthDate: String
    public let calendarType: String
    public let birthTime: String
    public let isTimeUnknown: Bool
    public let job: String
    public let relationshipStatus: String

    public init(
        memberID: String,
        name: String,
        gender: String,
        birthDate: String,
        calendarType: String,
        birthTime: String,
        isTimeUnknown: Bool,
        job: String,
        relationshipStatus: String
    ) {
        self.memberID = memberID
        self.name = name
        self.gender = gender
        self.birthDate = birthDate
        self.calendarType = calendarType
        self.birthTime = birthTime
        self.isTimeUnknown = isTimeUnknown
        self.job = job
        self.relationshipStatus = relationshipStatus
    }

    public var genderText: String { gender == "FEMALE" ? "여성" : "남성" }

    public var birthDateCalendarText: String {
        let calendar = calendarType == "LUNAR" ? "음력" : "양력"
        return "\(birthDate.replacingOccurrences(of: "-", with: ".")) \(calendar)"
    }

    public var birthTimeText: String? {
        guard !isTimeUnknown else { return nil }
        return BirthTimePeriod(apiValue: birthTime)?.displayText ?? birthTime
    }
}

public struct MyPageProfileUpdate: Equatable, Sendable {
    public let gender: String
    public let calendarType: String
    public let birthDate: String
    public let birthTime: String
    public let job: String
    public let relationshipStatus: String

    public init(
        gender: String,
        calendarType: String,
        birthDate: String,
        birthTime: String,
        job: String,
        relationshipStatus: String
    ) {
        self.gender = gender
        self.calendarType = calendarType
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.job = job
        self.relationshipStatus = relationshipStatus
    }
}

public struct MyPageSajuChart: Codable, Equatable, Sendable {
    public let pillars: [MyPagePillar]
    public let ohaengs: [MyPageOhaeng]

    public init(pillars: [MyPagePillar], ohaengs: [MyPageOhaeng] = []) {
        self.pillars = pillars
        self.ohaengs = ohaengs
    }

    public var displayPillars: [MyPagePillar] {
        let displayOrder = ["HOUR", "DAY", "MONTH", "YEAR"]

        return displayOrder.compactMap { type in
            pillars.first { $0.type == type }
        } + pillars.filter { !displayOrder.contains($0.type) }
    }
}

public struct MyPagePillar: Codable, Equatable, Identifiable, Sendable {
    public let type: String
    public let heavenlyStem: String
    public let heavenlyReading: String
    public let heavenlyElement: MyPageElement
    public let earthlyBranch: String
    public let earthlyReading: String
    public let earthlyElement: MyPageElement
    public let stemSipseong: String?
    public let branchSipseong: String?
    public let hiddenStems: [String]
    public let twelveLifeStage: String?
    public let twelveSpirit: String?

    // swiftlint:disable:next identifier_name
    public var id: String { "\(type)-\(heavenlyStem)-\(earthlyBranch)" }

    public init(
        type: String,
        heavenlyStem: String,
        heavenlyReading: String,
        heavenlyElement: MyPageElement,
        earthlyBranch: String,
        earthlyReading: String,
        earthlyElement: MyPageElement,
        stemSipseong: String? = nil,
        branchSipseong: String? = nil,
        hiddenStems: [String] = [],
        twelveLifeStage: String? = nil,
        twelveSpirit: String? = nil
    ) {
        self.type = type
        self.heavenlyStem = heavenlyStem
        self.heavenlyReading = heavenlyReading
        self.heavenlyElement = heavenlyElement
        self.earthlyBranch = earthlyBranch
        self.earthlyReading = earthlyReading
        self.earthlyElement = earthlyElement
        self.stemSipseong = stemSipseong
        self.branchSipseong = branchSipseong
        self.hiddenStems = hiddenStems
        self.twelveLifeStage = twelveLifeStage
        self.twelveSpirit = twelveSpirit
    }
}

public struct MyPageOhaeng: Codable, Equatable, Identifiable, Sendable {
    public let element: MyPageElement
    public let count: Int
    public let percentage: Double

    // swiftlint:disable:next identifier_name
    public var id: MyPageElement { element }

    public init(element: MyPageElement, count: Int, percentage: Double) {
        self.element = element
        self.count = count
        self.percentage = percentage
    }
}

public enum MyPageElement: String, Codable, Equatable, Hashable, Sendable {
    case wood = "WOOD"
    case fire = "FIRE"
    case earth = "EARTH"
    case metal = "METAL"
    case water = "WATER"
    case unknown

    public var label: String {
        switch self {
        case .wood: "목"
        case .fire: "화"
        case .earth: "토"
        case .metal: "금"
        case .water: "수"
        case .unknown: "-"
        }
    }

    public var hanja: String {
        switch self {
        case .wood: "木"
        case .fire: "火"
        case .earth: "土"
        case .metal: "金"
        case .water: "水"
        case .unknown: "-"
        }
    }
}

public enum MyPageClientError: Error, Equatable, Sendable {
    case notConfigured
    case invalidResponse
    case requestFailed

    init(_ error: Error) {
        self = error as? Self ?? .requestFailed
    }
}
