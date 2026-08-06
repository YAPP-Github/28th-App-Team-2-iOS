import DesignSystem
import Model

enum WheelPickerExampleData {
    static let fortuneTimeItems = BirthTimePeriod.allCases.map { period in
        DSWheelPickerItem(
            value: period.rawValue,
            title: DSEnterTimeOfBirth.pickerTitle(for: period)
        )
    }
}
