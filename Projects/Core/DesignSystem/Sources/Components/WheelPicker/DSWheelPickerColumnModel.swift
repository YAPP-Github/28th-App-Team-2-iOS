import SwiftUI

struct DSWheelPickerRenderingConfiguration {
    let viewportHeight: CGFloat
    let rowHeight: CGFloat
    let selectedFontStyle: FontStyle
    let adjacentFontStyle: FontStyle
    let outerFontStyle: FontStyle
    let selectedForegroundAsset: DesignSystemColors
    let adjacentForegroundAsset: DesignSystemColors
    let outerForegroundAsset: DesignSystemColors
}

struct DSWheelPickerDirectInputConfiguration {
    let maximumDigits: Int
    let columnIndex: Int
    let nextColumnIndex: Int?
    let activeColumnIndex: Binding<Int?>
}

struct DSWheelPickerPosition: Hashable {
    let value: Int
    let cycle: Int
}

struct DSWheelPickerDisplayItem: Identifiable {
    let item: DSWheelPickerItem
    let position: DSWheelPickerPosition

    // swiftlint:disable:next identifier_name
    var id: DSWheelPickerPosition {
        position
    }

    static func make(
        items: [DSWheelPickerItem],
        isCircular: Bool
    ) -> [Self] {
        let cycles = isCircular && items.count > 1 ? Array(0...2) : [0]

        return cycles.flatMap { cycle in
            items.map {
                Self(
                    item: $0,
                    position: DSWheelPickerPosition(value: $0.value, cycle: cycle)
                )
            }
        }
    }
}
