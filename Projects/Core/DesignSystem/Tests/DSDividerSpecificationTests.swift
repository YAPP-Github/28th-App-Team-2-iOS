import Testing
import CoreGraphics
@testable import DesignSystem

struct DSDividerSpecificationTests {
    private static let expected: [DSDividerSize: (CGFloat, DesignSystemColors)] = [
        .thin: (1, DesignSystemAsset.Colors.gray100),
        .thick: (10, DesignSystemAsset.Colors.gray25)
    ]

    @Test("Divider 스펙 매핑 검증", arguments: DSDividerSize.allCases)
    func testSpecifications(size: DSDividerSize) throws {
        let specification = DSDivider.specification(size: size)
        let expectedSpecification = try #require(Self.expected[size])

        #expect(specification.thickness == expectedSpecification.0)
        expectColorEqual(specification.colorAsset, expectedSpecification.1)
    }
}
