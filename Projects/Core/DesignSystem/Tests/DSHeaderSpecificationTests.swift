import Testing
import Foundation
import SwiftUI
@testable import DesignSystem

struct DSHeaderMainSpecificationTests {
    @Test("Header Main 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSHeaderMain.specification()

        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.white)
        #expect(specification.contentHeight == 60)
        #expect(specification.horizontalPadding == 20)
        #expect(specification.titleGroupGap == 12)
        #expect(specification.titleFontStyle == .heading4Bold)
        expectColorEqual(specification.titleTextAsset, DesignSystemAsset.Colors.black)
        #expect(specification.subtitleFontStyle == .body3Regular)
        expectColorEqual(specification.subtitleTextAsset, DesignSystemAsset.Colors.gray500)
        #expect(specification.actionIconSize == CGSize(width: 24, height: 24))
        expectColorEqual(specification.actionIconTintAsset, DesignSystemAsset.Colors.gray975)
        expectColorEqual(
            specification.actionIconPressedOverlay.asset,
            DesignSystemAsset.Colors.gray975
        )
        #expect(specification.actionIconPressedOverlay.opacity == 0.16)
    }
}

struct DSHeaderSubSpecificationTests {
    @Test("Header Sub 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSHeaderSub.specification()

        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.white)
        #expect(specification.contentHeight == 48)
        #expect(specification.horizontalPadding == 20)
        #expect(specification.titleFontStyle == .body2SemiBold)
        expectColorEqual(specification.titleTextAsset, DesignSystemAsset.Colors.black)
        #expect(specification.actionIconSize == CGSize(width: 20, height: 20))
        expectColorEqual(specification.actionIconTintAsset, DesignSystemAsset.Colors.gray975)
        expectColorEqual(
            specification.actionIconPressedOverlay.asset,
            DesignSystemAsset.Colors.gray975
        )
        #expect(specification.actionIconPressedOverlay.opacity == 0.16)
    }
}
