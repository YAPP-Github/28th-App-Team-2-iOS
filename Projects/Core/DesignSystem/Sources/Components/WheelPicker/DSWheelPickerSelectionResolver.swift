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

    private static func distance(between lhs: Int, and rhs: Int) -> UInt {
        if (lhs < 0) == (rhs < 0) {
            return lhs.magnitude >= rhs.magnitude
                ? lhs.magnitude - rhs.magnitude
                : rhs.magnitude - lhs.magnitude
        }

        return lhs.magnitude + rhs.magnitude
    }
}
