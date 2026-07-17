import XCTest
@testable import DesignSystem

final class DSDividerSpecificationTests: XCTestCase {
    func testSpecifications() throws {
        let expected: [DSDividerSize: (CGFloat, DesignSystemColors)] = [
            .thin: (1, DesignSystemAsset.Colors.gray100),
            .thick: (10, DesignSystemAsset.Colors.gray25)
        ]

        for size in DSDividerSize.allCases {
            let specification = DSDivider.specification(size: size)
            let expectedSpecification = try XCTUnwrap(expected[size])

            XCTAssertEqual(specification.thickness, expectedSpecification.0)
            XCTAssertColorEqual(specification.colorAsset, expectedSpecification.1)
        }
    }
}
