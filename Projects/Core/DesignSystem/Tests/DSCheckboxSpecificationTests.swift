import XCTest
@testable import DesignSystem

final class DSCheckboxSpecificationTests: XCTestCase {
    func testSpecifications() {
        let unchecked = DSCheckbox.specification(isOn: false)
        XCTAssertEqual(unchecked.size, 20)
        XCTAssertEqual(unchecked.borderWidth, 1)
        XCTAssertNil(unchecked.iconSize)
        XCTAssertEqual(unchecked.shape, .roundedRectangle(cornerRadius: 6))
        XCTAssertColorEqual(unchecked.backgroundAsset, DesignSystemAsset.Colors.white)
        XCTAssertColorEqual(unchecked.borderAsset, DesignSystemAsset.Colors.coolGray300)
        XCTAssertNil(unchecked.iconAsset)
        XCTAssertNil(unchecked.iconTintAsset)

        let checked = DSCheckbox.specification(isOn: true)
        XCTAssertEqual(checked.size, 20)
        XCTAssertNil(checked.borderWidth)
        XCTAssertEqual(checked.iconSize, 16)
        XCTAssertEqual(checked.shape, .roundedRectangle(cornerRadius: 6))
        XCTAssertColorEqual(checked.backgroundAsset, DesignSystemAsset.Colors.primary600)
        XCTAssertNil(checked.borderAsset)
        XCTAssertEqual(checked.iconAsset?.name, DesignSystemAsset.Icons.checkLine.name)
        XCTAssertColorEqual(checked.iconTintAsset, DesignSystemAsset.Colors.white)
    }
}
