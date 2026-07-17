import XCTest
@testable import DesignSystem

final class DSChipSpecificationTests: XCTestCase {
    func testSpecifications() {
        let unselected = DSChip.specification(isSelected: false)
        XCTAssertEqual(unselected.verticalPadding, 12)
        XCTAssertEqual(unselected.horizontalPadding, 20)
        XCTAssertEqual(unselected.shape, .capsule)
        XCTAssertEqual(unselected.fontStyle, .body2Medium)
        XCTAssertColorEqual(unselected.backgroundAsset, DesignSystemAsset.Colors.gray25)
        XCTAssertColorEqual(unselected.foregroundAsset, DesignSystemAsset.Colors.coolGray700)

        let selected = DSChip.specification(isSelected: true)
        XCTAssertEqual(selected.verticalPadding, 12)
        XCTAssertEqual(selected.horizontalPadding, 20)
        XCTAssertEqual(selected.shape, .capsule)
        XCTAssertEqual(selected.fontStyle, .body2SemiBold)
        XCTAssertColorEqual(selected.backgroundAsset, DesignSystemAsset.Colors.primary500)
        XCTAssertColorEqual(selected.foregroundAsset, DesignSystemAsset.Colors.white)
    }
}
