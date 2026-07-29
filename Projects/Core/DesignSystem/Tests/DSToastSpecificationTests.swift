import CoreGraphics
import Testing
@testable import DesignSystem

struct DSToastSpecificationTests {
    @Test("Standard Toast 스펙 매핑 검증")
    func testStandardSpecification() throws {
        let specification = DSToast.specification(variant: .standard)

        expectCommonSpecification(
            specification,
            expected: CommonExpected(
                minimumHeight: 36,
                leadingPadding: 8,
                trailingPadding: 8,
                verticalPadding: 8,
                fillsAvailableWidth: false
            )
        )
        #expect(specification.contentSpacing == 8)
        expectSolidBackground(specification, DesignSystemAsset.Colors.opacity80)

        let closeButton = try #require(specification.closeButton)
        expectCloseButton(
            closeButton,
            color: DesignSystemAsset.Colors.gray50
        )
        #expect(specification.intrinsicShadow == nil)
    }

    @Test("Compact Toast 스펙 매핑 검증")
    func testCompactSpecification() {
        let specification = DSToast.specification(variant: .compact)

        expectCommonSpecification(
            specification,
            expected: CommonExpected(
                minimumHeight: 36,
                leadingPadding: 8,
                trailingPadding: 8,
                verticalPadding: 8,
                fillsAvailableWidth: false
            )
        )
        #expect(specification.contentSpacing == 0)
        expectSolidBackground(specification, DesignSystemAsset.Colors.opacity80)
        #expect(specification.closeButton == nil)
        #expect(specification.intrinsicShadow == nil)
    }

    @Test("Lucky Action Toast 스펙 매핑 검증")
    func testLuckyActionSpecification() throws {
        let specification = DSToast.specification(variant: .luckyAction)

        expectCommonSpecification(
            specification,
            expected: CommonExpected(
                minimumHeight: 44,
                leadingPadding: 18,
                trailingPadding: 16,
                verticalPadding: 12,
                fillsAvailableWidth: true
            )
        )
        #expect(specification.contentSpacing == 8)
        expectGradientBackground(
            specification,
            assets: [
                DesignSystemAsset.Colors.primary600,
                DesignSystemAsset.Colors.primary800,
                DesignSystemAsset.Colors.sky600
            ],
            locations: [0, 0.5, 1]
        )

        let closeButton = try #require(specification.closeButton)
        expectCloseButton(
            closeButton,
            color: DesignSystemAsset.Colors.whiteOpacity60
        )

        let shadow = try #require(specification.intrinsicShadow)
        #expect(shadow.colorHex == 0x9C8AF6)
        #expect(shadow.opacity == 0.5)
        #expect(shadow.radius == 10)
        #expect(shadow.offsetX == 0)
        #expect(shadow.offsetY == 0)
    }

    private struct CommonExpected {
        let minimumHeight: CGFloat
        let leadingPadding: CGFloat
        let trailingPadding: CGFloat
        let verticalPadding: CGFloat
        let fillsAvailableWidth: Bool
    }

    private func expectCommonSpecification(
        _ specification: DSToast.Specification,
        expected: CommonExpected
    ) {
        #expect(specification.minimumHeight == expected.minimumHeight)
        #expect(specification.leadingPadding == expected.leadingPadding)
        #expect(specification.trailingPadding == expected.trailingPadding)
        #expect(specification.verticalPadding == expected.verticalPadding)
        #expect(specification.fillsAvailableWidth == expected.fillsAvailableWidth)
        #expect(specification.shape == .roundedRectangle(cornerRadius: 8))
        #expect(specification.fontStyle == .body3Regular)
        expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.gray50)
    }

    private func expectSolidBackground(
        _ specification: DSToast.Specification,
        _ expected: DesignSystemColors
    ) {
        guard case let .color(asset) = specification.background else {
            Issue.record("단색 배경 Specification이 필요합니다.")
            return
        }

        expectColorEqual(asset, expected)
    }

    private func expectGradientBackground(
        _ specification: DSToast.Specification,
        assets expectedAssets: [DesignSystemColors],
        locations expectedLocations: [CGFloat]
    ) {
        guard case let .horizontalGradient(assets, locations) = specification.background else {
            Issue.record("수평 그라디언트 Specification이 필요합니다.")
            return
        }

        #expect(assets.map(\.name) == expectedAssets.map(\.name))
        #expect(locations == expectedLocations)
    }

    private func expectCloseButton(
        _ specification: DSToast.CloseButtonSpecification,
        color: DesignSystemColors
    ) {
        #expect(specification.buttonSize == 20)
        #expect(specification.iconFrameSize == 16)
        #expect(specification.iconSize == 13.3333)
        #expect(specification.iconAsset == .closeLine)
        expectColorEqual(specification.iconColorAsset, color)
        expectColorEqual(specification.pressedOverlay.asset, DesignSystemAsset.Colors.gray975)
        #expect(specification.pressedOverlay.opacity == 0.16)
    }
}
