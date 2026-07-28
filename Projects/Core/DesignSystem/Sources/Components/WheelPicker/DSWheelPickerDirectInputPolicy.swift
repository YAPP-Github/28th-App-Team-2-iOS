enum DSWheelPickerDirectInputPolicy {
    static func maximumDigits(
        for layout: DSMultiWheelPickerLayout,
        columnIndex: Int
    ) -> Int? {
        switch layout {
        case .time:
            nil
        case .date:
            columnIndex == 0 ? 4 : 2
        }
    }

    static func normalizedDigits(
        _ input: String,
        maximumDigits: Int
    ) -> String {
        String(input.filter(\.isNumber).prefix(maximumDigits))
    }

    static func shouldCommit(
        _ input: String,
        maximumDigits: Int
    ) -> Bool {
        input.count == maximumDigits
    }
}
