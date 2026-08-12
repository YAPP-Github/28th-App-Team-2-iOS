import CoreGraphics
import Testing
@testable import DesignSystem

struct DSWheelSheetSpacingTests {
    @Test("기본 WheelPicker는 기존 화면 하단 간격을 유지")
    func testDefaultSpacing() {
        #expect(
            DSWheelPickerSheetBottomSpacingResolver.resolvedSpacing(
                defaultSpacing: 40,
                keyboardSpacing: 12,
                safeAreaBottom: 34,
                safeAreaSpacing: nil,
                isKeyboardPresented: false
            ) == 40
        )
    }

    @Test("safe-area 기준 간격은 bottom inset과 호출부 간격을 더함")
    func testSafeAreaSpacing() {
        #expect(
            DSWheelPickerSheetBottomSpacingResolver.resolvedSpacing(
                defaultSpacing: 40,
                keyboardSpacing: 12,
                safeAreaBottom: 34,
                safeAreaSpacing: 30,
                isKeyboardPresented: false
            ) == 64
        )
    }

    @Test("키보드 표시 중에는 기존 키보드 간격을 우선")
    func testKeyboardSpacingTakesPrecedence() {
        #expect(
            DSWheelPickerSheetBottomSpacingResolver.resolvedSpacing(
                defaultSpacing: 40,
                keyboardSpacing: 12,
                safeAreaBottom: 34,
                safeAreaSpacing: 30,
                isKeyboardPresented: true
            ) == 12
        )
    }
}
