import XCTest
@testable import DesignSystem

final class DSChip2SpecificationTests: XCTestCase {
    func testSpecification() {
        let specification = DSChip2.specification

        XCTAssertEqual(specification.verticalPadding, 5)
        XCTAssertEqual(specification.horizontalPadding, 10)
        XCTAssertEqual(specification.shape, .capsule)
        XCTAssertEqual(specification.fontStyle, .body3Medium)
        XCTAssertColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.primary700)
        XCTAssertColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.white)
    }
}
