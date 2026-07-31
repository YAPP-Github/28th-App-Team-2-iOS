import SwiftUI

public struct DSWheelPickerColumn {
    public let items: [DSWheelPickerItem]
    public let selection: Binding<Int>
    public let accessibilityLabel: String
    public let isCircular: Bool

    public init(
        items: [DSWheelPickerItem],
        selection: Binding<Int>,
        accessibilityLabel: String,
        isCircular: Bool = false
    ) {
        precondition(
            Set(items.map(\.value)).count == items.count,
            "DSWheelPickerColumn item values must be unique."
        )

        self.items = items
        self.selection = selection
        self.accessibilityLabel = accessibilityLabel
        self.isCircular = isCircular
    }
}
