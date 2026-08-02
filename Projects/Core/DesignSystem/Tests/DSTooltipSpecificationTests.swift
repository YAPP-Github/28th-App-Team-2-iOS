import Testing
@testable import DesignSystem

struct DSTooltipSpecificationTests {
    @Test("Tooltip 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSTooltip.specification()

        #expect(specification.minimumBubbleHeight == 30)
        #expect(specification.horizontalPadding == 16)
        #expect(specification.verticalPadding == 6)
        #expect(specification.lineLimit == nil)
        #expect(specification.textAlignment == .center)
        #expect(specification.arrowFrameWidth == 8)
        #expect(specification.arrowWidth == 6.9282)
        #expect(specification.arrowHeight == 6)
        #expect(specification.arrowRotationDegrees == 180)
        #expect(specification.shape == .capsule)
        #expect(specification.fontStyle == .body3Medium)
        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.opacity80)
        expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.white)
        #expect(specification.arrowAsset == .tooltipArrow)
        expectColorEqual(specification.arrowTintAsset, DesignSystemAsset.Colors.opacity80)
    }
}
