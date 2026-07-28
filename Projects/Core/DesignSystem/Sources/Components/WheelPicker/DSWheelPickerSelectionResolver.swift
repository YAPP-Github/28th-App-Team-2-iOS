import SwiftUI

enum DSWheelPickerSelectionResolver {
    static func nearestValue(
        to proposedValue: Int,
        in items: [DSWheelPickerItem]
    ) -> Int? {
        items.min { lhs, rhs in
            let lhsDistance = distance(between: lhs.value, and: proposedValue)
            let rhsDistance = distance(between: rhs.value, and: proposedValue)

            if lhsDistance == rhsDistance {
                return lhs.value < rhs.value
            }

            return lhsDistance < rhsDistance
        }?.value
    }

    static func adjustedValue(
        from selection: Int,
        direction: AccessibilityAdjustmentDirection,
        in items: [DSWheelPickerItem],
        isCircular: Bool
    ) -> Int? {
        guard let currentIndex = items.firstIndex(where: { $0.value == selection }) else {
            return nil
        }

        let targetIndex: Int

        switch direction {
        case .increment:
            if isCircular, currentIndex == items.index(before: items.endIndex) {
                targetIndex = items.startIndex
            } else {
                targetIndex = min(items.index(before: items.endIndex), currentIndex + 1)
            }
        case .decrement:
            if isCircular, currentIndex == items.startIndex {
                targetIndex = items.index(before: items.endIndex)
            } else {
                targetIndex = max(items.startIndex, currentIndex - 1)
            }
        @unknown default:
            return selection
        }

        return items[targetIndex].value
    }

    private static func distance(between lhs: Int, and rhs: Int) -> UInt {
        if (lhs < 0) == (rhs < 0) {
            return lhs.magnitude >= rhs.magnitude
                ? lhs.magnitude - rhs.magnitude
                : rhs.magnitude - lhs.magnitude
        }

        return lhs.magnitude + rhs.magnitude
    }
}
