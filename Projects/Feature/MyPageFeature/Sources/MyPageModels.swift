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

    public init(pillars: [MyPagePillar]) {
        self.pillars = pillars
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

    // swiftlint:disable:next identifier_name
    public var id: String { "\(type)-\(heavenlyStem)-\(earthlyBranch)" }

    public init(
        type: String,
        heavenlyStem: String,
        heavenlyReading: String,
        heavenlyElement: MyPageElement,
        earthlyBranch: String,
        earthlyReading: String,
        earthlyElement: MyPageElement
    ) {
        self.type = type
        self.heavenlyStem = heavenlyStem
        self.heavenlyReading = heavenlyReading
        self.heavenlyElement = heavenlyElement
        self.earthlyBranch = earthlyBranch
        self.earthlyReading = earthlyReading
        self.earthlyElement = earthlyElement
    }
}

public enum MyPageElement: String, Codable, Equatable, Sendable {
    case wood = "WOOD"
    case fire = "FIRE"
    case earth = "EARTH"
    case metal = "METAL"
    case water = "WATER"
    case unknown
}

public enum MyPageClientError: Error, Equatable, Sendable {
    case notConfigured
    case invalidResponse
    case requestFailed

    init(_ error: Error) {
        self = error as? Self ?? .requestFailed
    }
}
