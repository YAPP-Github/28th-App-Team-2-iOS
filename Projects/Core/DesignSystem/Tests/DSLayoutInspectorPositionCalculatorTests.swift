#if DEBUG
import UIKit
import Testing
@testable import DesignSystem

struct DSLayoutInspectorPositionCalculatorTests {
    private let safeAreaInsets = UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0)

    @Test("정보 패널 상단 한계점 오프셋 계산 검증")
    func testInformationPanelTopLimit() {
        let result = DSLayoutInspectorPositionCalculator.informationOffset(
            -1_000,
            availableHeight: 844,
            panelHeight: 80,
            safeAreaInsets: safeAreaInsets
        )

        #expect(result == -647)
    }

    @Test("메뉴 상하단 한계점 오프셋 계산 검증")
    func testActiveMenuLimits() {
        let top = DSLayoutInspectorPositionCalculator.menuOffset(
            -1_000,
            availableHeight: 844,
            safeAreaInsets: safeAreaInsets
        )
        let bottom = DSLayoutInspectorPositionCalculator.menuOffset(
            1_000,
            availableHeight: 844,
            safeAreaInsets: safeAreaInsets
        )

        #expect(top == -225)
        #expect(bottom == 250)
    }
}
#endif
