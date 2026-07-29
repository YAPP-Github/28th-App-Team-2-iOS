import Testing
@testable import DesignSystem

struct DSSelectFieldSpecificationTests {
    @Test("SelectField Default 스펙 매핑 검증")
    func testDefaultSpecification() {
        let specification = DSSelectField.specification(isFocused: false, hasSelection: false)

        expectBaseSpecification(specification)
        #expect(specification.strokeAsset == nil)
        #expect(specification.strokeWidth == 0.0)
        #expect(specification.showsClearButton == false)
        #expect(specification.clearButtonSize == nil)
        #expect(specification.clearButtonIcon == nil)
        #expect(specification.clearButtonColor == nil)
        #expect(specification.clearButtonLeadingPadding == nil)
        #expect(specification.clearIconPressedOverlay == nil)
        #expect(specification.chevronLeadingPadding == 0)
        expectColorEqual(specification.chevronColor, DesignSystemAsset.Colors.gray600)
        #expect(specification.chevronRotationDegrees == 0)
    }

    @Test("SelectField Focus 스펙 매핑 검증", arguments: [false, true])
    func testFocusSpecification(hasSelection: Bool) {
        let specification = DSSelectField.specification(isFocused: true, hasSelection: hasSelection)

        expectBaseSpecification(specification)
        expectColorEqual(specification.strokeAsset!, DesignSystemAsset.Colors.gray975)
        #expect(specification.strokeWidth == 1.0)
        #expect(specification.showsClearButton == false)
        #expect(specification.clearButtonSize == nil)
        #expect(specification.clearButtonIcon == nil)
        #expect(specification.clearButtonColor == nil)
        #expect(specification.clearButtonLeadingPadding == nil)
        #expect(specification.clearIconPressedOverlay == nil)
        #expect(specification.chevronLeadingPadding == 0)
        expectColorEqual(specification.chevronColor, DesignSystemAsset.Colors.gray975)
        #expect(specification.chevronRotationDegrees == 180)
    }

    @Test("SelectField Success 스펙 매핑 검증")
    func testSuccessSpecification() {
        let specification = DSSelectField.specification(isFocused: false, hasSelection: true)

        expectBaseSpecification(specification)
        #expect(specification.strokeAsset == nil)
        #expect(specification.strokeWidth == 0.0)
        #expect(specification.showsClearButton == true)
        #expect(specification.clearButtonSize == 20)
        #expect(specification.clearButtonIcon == .circleXFill)
        expectColorEqual(specification.clearButtonColor!, DesignSystemAsset.Colors.gray300)
        #expect(specification.clearButtonLeadingPadding == 10)
        expectColorEqual(specification.clearIconPressedOverlay?.asset, DesignSystemAsset.Colors.gray975)
        #expect(specification.clearIconPressedOverlay?.opacity == 0.16)
        #expect(specification.chevronLeadingPadding == 10)
        expectColorEqual(specification.chevronColor, DesignSystemAsset.Colors.gray600)
        #expect(specification.chevronRotationDegrees == 0)
    }

    private func expectBaseSpecification(_ specification: DSSelectField.Specification) {
        #expect(specification.containerHeight == 48)
        #expect(specification.containerShape == .roundedRectangle(cornerRadius: 12))
        expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.gray25)
        #expect(specification.contentSpacing == 0)
        #expect(specification.contentHorizontalPadding == 16)

        #expect(specification.placeholderFont == .body2Regular)
        expectColorEqual(specification.placeholderColor, DesignSystemAsset.Colors.gray600)
        #expect(specification.textFont == .body2Medium)
        expectColorEqual(specification.textColor, DesignSystemAsset.Colors.gray975)

        #expect(specification.chevronIcon == .chevronSmallBottom)
        #expect(specification.chevronSize == 20)
    }
}
