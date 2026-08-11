public enum FortuneCategory: String, CaseIterable, Equatable, Hashable, Sendable {
    case relationship
    case love
    case achievement
    case health
    case money

    public var title: String {
        switch self {
        case .relationship:
            "관계운"
        case .love:
            "연애운"
        case .achievement:
            "성취운"
        case .health:
            "건강운"
        case .money:
            "금전운"
        }
    }
}
