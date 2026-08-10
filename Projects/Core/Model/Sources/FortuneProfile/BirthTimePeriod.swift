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
}
