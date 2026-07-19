#if DEBUG
import UIKit
import Testing
@testable import DesignSystem

@Suite(.serialized)
@MainActor
struct DSLayoutElementCollectorTests {
    @Test("수집 시 보이는 뷰 및 접근성 요소 포함 검증")
    func testCollectIncludesVisibleViewAndAccessibilityElement() {
        let window = makeWindow()
        let view = UIView(frame: CGRect(x: 20, y: 30, width: 80, height: 40))
        view.accessibilityLabel = "측정 대상"
        window.addSubview(view)

        let accessibilityElement = UIAccessibilityElement(accessibilityContainer: window)
        accessibilityElement.accessibilityLabel = "접근성 대상"
        accessibilityElement.accessibilityFrame = CGRect(
            x: 120,
            y: 30,
            width: 80,
            height: 40
        )
        window.accessibilityElements = [accessibilityElement]

        let regions = DSLayoutElementCollector.collect(in: window)

        #expect(regions.contains {
            $0.source == .view && $0.name.contains("측정 대상")
        })
        #expect(regions.contains {
            $0.source == .accessibility && $0.name == "접근성 대상"
        })
    }

    @Test("수집 시 숨겨진 뷰 및 검사기 뷰 제외 검증")
    func testCollectExcludesHiddenAndInspectorViews() {
        let window = makeWindow()

        let hiddenView = UIView(frame: CGRect(x: 20, y: 30, width: 80, height: 40))
        hiddenView.accessibilityLabel = "숨김 대상"
        hiddenView.isHidden = true

        let inspectorView = UIView(frame: CGRect(x: 120, y: 30, width: 80, height: 40))
        inspectorView.accessibilityIdentifier =
            "\(DSLayoutInspectorConstants.accessibilityPrefix).control"

        window.addSubview(hiddenView)
        window.addSubview(inspectorView)

        let regions = DSLayoutElementCollector.collect(in: window)

        #expect(!regions.contains { $0.name.contains("숨김 대상") })
        #expect(!regions.contains {
            $0.regionID == "view-\(ObjectIdentifier(inspectorView))"
        })
    }

    private func makeWindow() -> UIWindow {
        let window = UIWindow(
            frame: CGRect(x: 0, y: 0, width: 320, height: 640)
        )
        window.isHidden = false
        return window
    }
}
#endif
