public enum FortuneReading: String, CaseIterable, Equatable, Hashable, Sendable {
    case compatibility
    case dateSelection
    case yearly

    public var title: String {
        switch self {
        case .compatibility:
            "상대랑 궁합"
        case .dateSelection:
            "택일 운세"
        case .yearly:
            "연도별 운세"
        }
    }

    public var subtitle: String {
        switch self {
        case .compatibility:
            "그 사람과 나, 잘 맞을까요?"
        case .dateSelection:
            "좋은 날을 골라드려요!"
        case .yearly:
            "올해의 큰 흐름 보기"
        }
    }
}
