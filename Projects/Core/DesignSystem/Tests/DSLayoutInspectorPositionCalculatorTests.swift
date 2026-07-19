#if DEBUG
import UIKit
import XCTest
@testable import DesignSystem

final class DSLayoutInspectorPositionCalculatorTests: XCTestCase {
    private let safeAreaInsets = UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0)

    func testInformationPanelTopLimit() {
        let result = DSLayoutInspectorPositionCalculator.informationOffset(
            -1_000,
            availableHeight: 844,
            panelHeight: 80,
            safeAreaInsets: safeAreaInsets
        )

        XCTAssertEqual(result, -647)
    }

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

        XCTAssertEqual(top, -225)
        XCTAssertEqual(bottom, 250)
    }
}
#endif
