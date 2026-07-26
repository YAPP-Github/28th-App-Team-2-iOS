import Testing
import Foundation
import SwiftUI
@testable import DesignSystem

struct DSTextFieldSpecificationTests {
    @Test("TextField Default 스펙 매핑 검증")
    func testDefaultSpecification() {
        let specification = DSTextField.specification(isFocused: false, hasText: false, validationState: .none)

        #expect(specification.containerHeight == 48)
        #expect(specification.containerShape == .roundedRectangle(cornerRadius: 12))
        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray25)
        #expect(specification.strokeAsset == nil)
        #expect(specification.strokeWidth == 0.0)
        #expect(specification.contentSpacing == 0)
        #expect(specification.contentHorizontalPadding == 16)

        #expect(specification.textFont == .body2Medium)
        expectColorEqual(specification.textColor, DesignSystemAsset.Colors.gray975)

        #expect(specification.placeholderFont == .body2Regular)
        expectColorEqual(specification.placeholderColor, DesignSystemAsset.Colors.gray600)
        #expect(specification.cursorColorHex == "#0040FF")

        #expect(specification.showsClearButton == false)
        #expect(specification.clearIconPressedOverlay?.opacity == nil)
        #expect(specification.errorMessage == nil)
        #expect(specification.errorMessageTopSpacing == 8)
        #expect(specification.errorMessageHorizontalPadding == 4)
    }

    @Test("TextField Focus 스펙 매핑 검증")
    func testFocusSpecification() {
        let specification = DSTextField.specification(isFocused: true, hasText: false, validationState: .none)

        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray25)
        expectColorEqual(specification.strokeAsset!, DesignSystemAsset.Colors.gray975)
        #expect(specification.strokeWidth == 1.0)

        #expect(specification.textFont == .body2Medium)
        expectColorEqual(specification.textColor, DesignSystemAsset.Colors.gray975)

        #expect(specification.showsClearButton == false)
        #expect(specification.clearIconPressedOverlay?.opacity == nil)
    }

    @Test("TextField Insert 스펙 매핑 검증")
    func testInsertSpecification() {
        let specification = DSTextField.specification(isFocused: true, hasText: true, validationState: .none)

        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray25)
        expectColorEqual(specification.strokeAsset!, DesignSystemAsset.Colors.gray975)
        #expect(specification.strokeWidth == 1.0)

        #expect(specification.textFont == .body2Medium)
        expectColorEqual(specification.textColor, DesignSystemAsset.Colors.gray975)

        #expect(specification.showsClearButton == true)
        #expect(specification.clearButtonSize == 20)
        #expect(specification.clearButtonIcon == .circleXFill)
        expectColorEqual(specification.clearButtonColor, DesignSystemAsset.Colors.gray300)
        #expect(specification.clearButtonLeadingPadding == 10)
        expectColorEqual(specification.clearIconPressedOverlay?.asset, DesignSystemAsset.Colors.gray975)
        #expect(specification.clearIconPressedOverlay?.opacity == 0.16)
    }

    @Test("TextField Success 스펙 매핑 검증 (포커스 미이탈 시)")
    func testSuccessSpecification() {
        let specification = DSTextField.specification(isFocused: false, hasText: true, validationState: .success)

        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray25)
        #expect(specification.strokeAsset == nil)
        #expect(specification.strokeWidth == 0.0)

        #expect(specification.textFont == .body2Medium)
        expectColorEqual(specification.textColor, DesignSystemAsset.Colors.gray975)

        #expect(specification.showsClearButton == false)
        #expect(specification.clearIconPressedOverlay?.opacity == nil)
    }

    @Test("TextField 편집 중에는 success 피드백보다 insert 상태가 우선")
    func testSuccessFocusedSpecification() {
        let specification = DSTextField.specification(isFocused: true, hasText: true, validationState: .success)

        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray25)
        expectColorEqual(specification.strokeAsset!, DesignSystemAsset.Colors.gray975)
        #expect(specification.strokeWidth == 1.0)

        #expect(specification.textFont == .body2Medium)
        expectColorEqual(specification.textColor, DesignSystemAsset.Colors.gray975)

        #expect(specification.showsClearButton == true)
        expectColorEqual(specification.clearIconPressedOverlay?.asset, DesignSystemAsset.Colors.gray975)
        #expect(specification.clearIconPressedOverlay?.opacity == 0.16)
    }

    @Test("TextField 편집 중에는 error 피드백보다 insert 상태가 우선")
    func testErrorFocusedSpecification() {
        let specification = DSTextField.specification(
            isFocused: true,
            hasText: true,
            validationState: .error(message: "에러 메시지")
        )

        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray25)
        expectColorEqual(specification.strokeAsset!, DesignSystemAsset.Colors.gray975)
        #expect(specification.strokeWidth == 1.0)
        #expect(specification.showsClearButton == true)
        #expect(specification.clearButtonIcon == .circleXFill)
        #expect(specification.errorMessage == nil)
        #expect(specification.errorMessageFont == nil)
        #expect(specification.errorMessageColor == nil)
    }

    @Test("TextField Error 스펙 매핑 검증")
    func testErrorSpecification() {
        let specification = DSTextField.specification(
            isFocused: false,
            hasText: true,
            validationState: .error(message: "에러 메시지")
        )

        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.red50)
        #expect(specification.strokeAsset == nil)
        #expect(specification.strokeWidth == 0.0)

        #expect(specification.textFont == .body2Medium)
        expectColorEqual(specification.textColor, DesignSystemAsset.Colors.gray975)

        #expect(specification.showsClearButton == false)
        #expect(specification.clearIconPressedOverlay?.opacity == nil)
        #expect(specification.errorMessage == "에러 메시지")
        #expect(specification.errorMessageFont == .caption1Regular)
        expectColorEqual(specification.errorMessageColor!, DesignSystemAsset.Colors.red500)
    }
}
