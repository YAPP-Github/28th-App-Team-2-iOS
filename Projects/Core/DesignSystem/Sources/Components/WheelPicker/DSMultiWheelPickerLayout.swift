public enum DSMultiWheelPickerLayout: CaseIterable, Sendable {
    case time
    case date
}

extension DSMultiWheelPickerLayout {
    var allowsDirectInput: Bool {
        switch self {
        case .time: false
        case .date: true
        }
    }
}
