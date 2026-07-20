import Testing
@testable import DesignSystem

struct DSBadgeSpecificationTests {
    private static let expectedAssets: [DSBadgeVariant: (DesignSystemColors, DesignSystemColors)] = [
        .purple: (DesignSystemAsset.Colors.primary100, DesignSystemAsset.Colors.primary800),
        .pink: (DesignSystemAsset.Colors.pink100, DesignSystemAsset.Colors.pink800),
        .green: (DesignSystemAsset.Colors.teal100, DesignSystemAsset.Colors.teal800),
        .yellow: (DesignSystemAsset.Colors.orange100, DesignSystemAsset.Colors.orange800),
        .blue: (DesignSystemAsset.Colors.sky100, DesignSystemAsset.Colors.sky800),
        .gray: (DesignSystemAsset.Colors.coolGray100, DesignSystemAsset.Colors.coolGray500)
    ]

    @Test("Badge 스펙 매핑 검증", arguments: DSBadgeVariant.allCases)
    func testSpecifications(variant: DSBadgeVariant) throws {
        let specification = DSBadge.specification(variant: variant)
        let expected = try #require(Self.expectedAssets[variant])

        #expect(specification.verticalPadding == 3)
        #expect(specification.horizontalPadding == 6)
        #expect(specification.shape == .roundedRectangle(cornerRadius: 6))
        #expect(specification.fontStyle == .caption2SemiBold)
        expectColorEqual(specification.backgroundAsset, expected.0)
        expectColorEqual(specification.foregroundAsset, expected.1)
    }
}
