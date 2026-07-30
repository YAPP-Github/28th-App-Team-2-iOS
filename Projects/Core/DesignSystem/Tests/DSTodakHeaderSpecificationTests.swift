import Testing
import Foundation
import SwiftUI
@testable import DesignSystem

struct DSTodakHeaderSpecificationTests {
    @Test("TodakHeader 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSTodakHeader.specification()

        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.white)
        #expect(specification.contentHeight == 48)
        #expect(specification.horizontalPadding == 20)
        #expect(specification.iconSize == CGSize(width: 20, height: 20))
        #expect(specification.leftIconAsset == .deleteLine)
        expectColorEqual(specification.leftIconTintAsset, DesignSystemAsset.Colors.gray925)
        expectColorEqual(specification.leftIconPressedOverlay.asset, DesignSystemAsset.Colors.gray975)
        #expect(specification.leftIconPressedOverlay.opacity == 0.16)
        #expect(specification.rightIconGap == 12)
        expectColorEqual(specification.rightIconTintAsset, DesignSystemAsset.Colors.coolGray975)
        expectColorEqual(specification.rightIconPressedOverlay.asset, DesignSystemAsset.Colors.gray975)
        #expect(specification.rightIconPressedOverlay.opacity == 0.16)
        #expect(specification.titleFontStyle == .body2SemiBold)
        expectColorEqual(specification.titleTextAsset, DesignSystemAsset.Colors.black)
        #expect(specification.subtitleFontStyle == .body3Regular)
        expectColorEqual(specification.subtitleTextAsset, DesignSystemAsset.Colors.gray500)
        #expect(specification.remainingCountFontStyle == .body3Medium)
        expectColorEqual(specification.remainingCountTextAsset, DesignSystemAsset.Colors.gray800)
        #expect(specification.titleGroupGap == 4)
        #expect(specification.freeChatLimit == 3)
    }
}
