import Testing
import Foundation
import SwiftUI
@testable import DesignSystem

struct DSProgressBarSpecificationTests {
    @Test("ProgressBar 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSProgressBar.specification()

        #expect(specification.height == 48)
        #expect(specification.leadingPadding == 20)
        #expect(specification.trailingPadding == 21)
        #expect(specification.contentGap == 24)
        #expect(specification.backIconAsset == .chevronLeftPlain)
        #expect(specification.backIconSize == CGSize(width: 12, height: 18))
        expectColorEqual(specification.backIconTintAsset, DesignSystemAsset.Colors.gray400)
        expectColorEqual(specification.backIconPressedOverlay.asset, DesignSystemAsset.Colors.gray975)
        #expect(specification.backIconPressedOverlay.opacity == 0.16)
        #expect(specification.trackHeight == 6)
        #expect(specification.trackShape == .roundedRectangle(cornerRadius: 10))
        expectColorEqual(specification.trackBackgroundGradient[0], DesignSystemAsset.Colors.gray50)
        expectColorEqual(specification.trackBackgroundGradient[1], DesignSystemAsset.Colors.gray200)
        #expect(specification.trackBackgroundOpacity == 0.5)
        expectColorEqual(specification.trackFillGradient[0], DesignSystemAsset.Colors.sky400)
        expectColorEqual(specification.trackFillGradient[1], DesignSystemAsset.Colors.primary600)
        expectColorEqual(specification.trackFillGradient[2], DesignSystemAsset.Colors.primary400)
        #expect(specification.trackFillGradientLocations == [0, 0.5, 1])
    }

    @Test("ProgressBar progress 입력값을 0...1 범위로 정규화")
    func testNormalizedProgress() {
        #expect(DSProgressBar.normalizedProgress(-0.1) == 0)
        #expect(DSProgressBar.normalizedProgress(0) == 0)
        #expect(DSProgressBar.normalizedProgress(0.5) == 0.5)
        #expect(DSProgressBar.normalizedProgress(1) == 1)
        #expect(DSProgressBar.normalizedProgress(1.1) == 1)
    }
}
