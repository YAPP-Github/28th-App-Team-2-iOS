import Testing
import Foundation
import SwiftUI
@testable import DesignSystem

struct DSTabSpecificationTests {
    @Test("Tab On 스펙 매핑 검증")
    func testOnSpecification() {
        let specification = DSTab.specification(isOn: true)

        #expect(specification.shape == .capsule)
        #expect(specification.padding == EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        expectColorEqual(specification.pressedOverlay.asset, DesignSystemAsset.Colors.gray975)
        #expect(specification.pressedOverlay.opacity == 0.16)

        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray975)
        #expect(specification.textFont == .body2Medium)
        expectColorEqual(specification.textColor, DesignSystemAsset.Colors.white)
    }

    @Test("Tab Off 스펙 매핑 검증")
    func testOffSpecification() {
        let specification = DSTab.specification(isOn: false)

        #expect(specification.shape == .capsule)
        #expect(specification.padding == EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        expectColorEqual(specification.pressedOverlay.asset, DesignSystemAsset.Colors.gray975)
        #expect(specification.pressedOverlay.opacity == 0.16)

        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.coolGray100)
        #expect(specification.textFont == .body2Regular)
        expectColorEqual(specification.textColor, DesignSystemAsset.Colors.coolGray500)
    }
}
