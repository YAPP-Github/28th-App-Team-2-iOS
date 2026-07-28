import Testing
@testable import DesignSystem

struct DSWheelPickerSelectionResolverTests {
    private let items = [1900, 1950, 2000, 2026].map {
        DSWheelPickerItem(value: $0, title: String($0))
    }

    @Test("정확히 일치하는 값은 그대로 선택")
    func testExactValue() {
        #expect(
            DSWheelPickerSelectionResolver.nearestValue(
                to: 1950,
                in: items
            ) == 1950
        )
    }

    @Test("최솟값보다 작은 입력은 최솟값으로 보정")
    func testLowerBound() {
        #expect(
            DSWheelPickerSelectionResolver.nearestValue(
                to: 1899,
                in: items
            ) == 1900
        )
    }

    @Test("최댓값보다 큰 입력은 최댓값으로 보정")
    func testUpperBound() {
        #expect(
            DSWheelPickerSelectionResolver.nearestValue(
                to: 2030,
                in: items
            ) == 2026
        )
    }

    @Test("두 후보와 거리가 같으면 더 작은 값을 선택")
    func testTieBreaksTowardLowerValue() {
        #expect(
            DSWheelPickerSelectionResolver.nearestValue(
                to: 1975,
                in: items
            ) == 1950
        )
    }

    @Test("빈 목록에는 선택값이 없음")
    func testEmptyItems() {
        #expect(
            DSWheelPickerSelectionResolver.nearestValue(
                to: 2000,
                in: []
            ) == nil
        )
    }

    @Test("Int 전체 범위에서도 overflow 없이 최근접 값 선택")
    func testExtremeValues() {
        let extremeItems = [Int.min, 0, Int.max].map {
            DSWheelPickerItem(value: $0, title: String($0))
        }

        #expect(
            DSWheelPickerSelectionResolver.nearestValue(
                to: Int.min + 1,
                in: extremeItems
            ) == Int.min
        )
        #expect(
            DSWheelPickerSelectionResolver.nearestValue(
                to: Int.max - 1,
                in: extremeItems
            ) == Int.max
        )
    }
}
