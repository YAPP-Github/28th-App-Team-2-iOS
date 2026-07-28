enum DSWheelPickerSelectionResolver {
    static func nearestValue(
        to proposedValue: Int,
        in items: [DSWheelPickerItem]
    ) -> Int? {
        items.min { lhs, rhs in
            let lhsDistance = abs(lhs.value - proposedValue)
            let rhsDistance = abs(rhs.value - proposedValue)

            if lhsDistance == rhsDistance {
                return lhs.value < rhs.value
            }

            return lhsDistance < rhsDistance
        }?.value
    }
}
