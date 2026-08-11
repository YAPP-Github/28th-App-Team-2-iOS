import Foundation

public enum BirthTimePeriod: Int, CaseIterable, Hashable, Sendable {
    case jaTime
    case chukTime
    case inTime
    case myoTime
    case jinTime
    case saTime
    case oTime
    case miTime
    case sinTime
    case yuTime
    case sulTime
    case haeTime

    public var startHour: Int {
        (23 + rawValue * 2) % 24
    }

    public var startMinute: Int {
        30
    }

    public var endHour: Int {
        (startHour + 2) % 24
    }

    public var endMinute: Int {
        29
    }

    public var apiValue: String {
        switch self {
        case .jaTime: "JASI"
        case .chukTime: "CHUKSI"
        case .inTime: "INSI"
        case .myoTime: "MYOSI"
        case .jinTime: "JINSI"
        case .saTime: "SASI"
        case .oTime: "OSI"
        case .miTime: "MISI"
        case .sinTime: "SINSI"
        case .yuTime: "YUSI"
        case .sulTime: "SULSI"
        case .haeTime: "HAESI"
        }
    }

    public init?(apiValue: String) {
        guard let period = Self.allCases.first(where: { $0.apiValue == apiValue }) else { return nil }
        self = period
    }

    public var displayText: String {
        String(
            format: "%02d:%02d~%02d:%02d(%@)",
            startHour,
            startMinute,
            endHour,
            endMinute,
            koreanName
        )
    }

    private var koreanName: String {
        switch self {
        case .jaTime: "자시"
        case .chukTime: "축시"
        case .inTime: "인시"
        case .myoTime: "묘시"
        case .jinTime: "진시"
        case .saTime: "사시"
        case .oTime: "오시"
        case .miTime: "미시"
        case .sinTime: "신시"
        case .yuTime: "유시"
        case .sulTime: "술시"
        case .haeTime: "해시"
        }
    }
}
