import Testing
@testable import DesignSystem

struct DSTooltipSpecificationTests {
    @Test("Tooltip 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSTooltip.specification(variant: .standard)

        #expect(specification.maximumBubbleWidth == nil)
        #expect(specification.horizontalPadding == 16)
        #expect(specification.verticalPadding == 6)
        #expect(specification.lineLimit == nil)
        #expect(specification.textAlignment == .center)
        #expect(specification.arrowFrameWidth == 8)
        #expect(specification.arrowWidth == 6.9282)
        #expect(specification.arrowHeight == 6)
        #expect(specification.arrowRotationDegrees == 180)
        #expect(specification.arrowPlacement == .bottom)
        #expect(specification.arrowBubbleSpacing == -2)
        #expect(specification.shape == .capsule)
        #expect(specification.fontStyle == .body3Medium)
        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.opacity80)
        expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.white)
        #expect(specification.arrowAsset == .tooltipArrow)
        expectColorEqual(specification.arrowTintAsset, DesignSystemAsset.Colors.opacity80)
    }

    @Test("Tooltip white 스펙 매핑 검증")
    func testWhiteSpecification() {
        let specification = DSTooltip.specification(variant: .white)

        #expect(specification.maximumBubbleWidth == 200)
        #expect(specification.horizontalPadding == 16)
        #expect(specification.verticalPadding == 6)
        #expect(specification.lineLimit == nil)
        #expect(specification.textAlignment == .center)
        #expect(specification.arrowFrameWidth == 8)
        #expect(specification.arrowWidth == 6.9282)
        #expect(specification.arrowHeight == 6)
        #expect(specification.arrowRotationDegrees == 0)
        #expect(specification.arrowPlacement == .top)
        #expect(specification.arrowBubbleSpacing == -2)
        #expect(specification.shape == .roundedRectangle(cornerRadius: 12))
        #expect(specification.fontStyle == .body3Medium)
        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.whiteOpacity90)
        expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.black)
        #expect(specification.arrowAsset == .tooltipArrow)
        expectColorEqual(specification.arrowTintAsset, DesignSystemAsset.Colors.whiteOpacity90)
    }
}
