import XCTest
@testable import DesignSystem

final class DSBadgeSpecificationTests: XCTestCase {
    func testSpecifications() throws {
        let expectedAssets: [DSBadgeVariant: (DesignSystemColors, DesignSystemColors)] = [
            .purple: (DesignSystemAsset.Colors.primary100, DesignSystemAsset.Colors.primary800),
            .pink: (DesignSystemAsset.Colors.pink100, DesignSystemAsset.Colors.pink800),
            .green: (DesignSystemAsset.Colors.teal100, DesignSystemAsset.Colors.teal800),
            .yellow: (DesignSystemAsset.Colors.orange100, DesignSystemAsset.Colors.orange800),
            .blue: (DesignSystemAsset.Colors.sky100, DesignSystemAsset.Colors.sky800),
            .gray: (DesignSystemAsset.Colors.coolGray100, DesignSystemAsset.Colors.coolGray500)
        ]

        for variant in DSBadgeVariant.allCases {
            let specification = DSBadge.specification(variant: variant)
            let expected = try XCTUnwrap(expectedAssets[variant])

            XCTAssertEqual(specification.verticalPadding, 3)
            XCTAssertEqual(specification.horizontalPadding, 6)
            XCTAssertEqual(specification.shape, .roundedRectangle(cornerRadius: 6))
            XCTAssertEqual(specification.fontStyle, .caption2SemiBold)
            XCTAssertColorEqual(specification.backgroundAsset, expected.0)
            XCTAssertColorEqual(specification.foregroundAsset, expected.1)
        }
    }
}
