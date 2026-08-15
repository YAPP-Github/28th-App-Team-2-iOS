import SwiftUI
import Testing
@testable import DesignSystem

struct DSPressedOverlayTests {
    @Test("공통 pressed overlay 값 검증")
    func standardSpecification() {
        expectColorEqual(
            DSPressedOverlay.standard.asset,
            DesignSystemAsset.Colors.gray975
        )
        #expect(DSPressedOverlay.standard.opacity == 0.16)
    }

    @MainActor
    @Test("화면 조립용 surface와 icon pressed API 구성 검증")
    func publicAssemblyAPIs() {
        let button = Button(
            action: {},
            label: { Color.clear }
        )

        _ = button.dsSurfaceButtonStyle(shape: .roundedRectangle(cornerRadius: 16))
        _ = button.dsIconButtonStyle(.bell, width: 24, height: 24)
        _ = button.dsIconButtonStyle(width: 24, height: 24)
    }
}
