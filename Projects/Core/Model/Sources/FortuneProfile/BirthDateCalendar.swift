public enum BirthDateCalendar: CaseIterable, Hashable, Sendable {
    case solar
    case lunar

    public var title: String {
        switch self {
        case .solar: "양력"
        case .lunar: "음력"
        }
    }

    public var apiValue: String {
        switch self {
        case .solar: "SOLAR"
        case .lunar: "LUNAR"
        }
    }
}
