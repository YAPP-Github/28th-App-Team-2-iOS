import Testing
import Foundation
import SwiftUI
@testable import DesignSystem

struct DSToggleSpecificationTests {
    @Test("Toggle 스펙 매핑 검증", arguments: [false, true])
    func testSpecifications(isOn: Bool) {
        let specification = DSToggle.specification(isOn: isOn)

        #expect(specification.size == CGSize(width: 53, height: 30))
        #expect(specification.shape == .capsule)
        #expect(specification.padding == EdgeInsets(top: 3, leading: 4, bottom: 3, trailing: 4))
        #expect(specification.handleSize == 24)
        #expect(specification.handleShape == .capsule)
        expectColorEqual(specification.pressedOverlay.asset, DesignSystemAsset.Colors.gray975)
        #expect(specification.pressedOverlay.opacity == 0.16)

        expectColorEqual(specification.handleAsset, DesignSystemAsset.Colors.white)

        if isOn {
            expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.primary700)
        } else {
            expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray200)
        }
    }
}
