public enum Gender: CaseIterable, Hashable, Sendable {
    case male
    case female

    public var title: String {
        switch self {
        case .male: "남성"
        case .female: "여성"
        }
    }

    public var apiValue: String {
        switch self {
        case .male: "MALE"
        case .female: "FEMALE"
        }
    }
}
