import Testing
@testable import DesignSystem

struct DSCheckboxSpecificationTests {
    @Test("Checkbox 스펙 매핑 검증", arguments: [false, true])
    func testSpecifications(isOn: Bool) {
        let specification = DSCheckbox.specification(isOn: isOn)

        #expect(specification.size == 20)
        #expect(specification.shape == .roundedRectangle(cornerRadius: 6))

        if isOn {
            #expect(specification.borderWidth == nil)
            #expect(specification.iconSize == 16)
            expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.primary600)
            #expect(specification.borderAsset == nil)
            #expect(specification.iconAsset?.name == DesignSystemAsset.Icons.checkLine.name)
            expectColorEqual(specification.iconTintAsset, DesignSystemAsset.Colors.white)
        } else {
            #expect(specification.borderWidth == 1)
            #expect(specification.iconSize == nil)
            expectColorEqual(specification.backgroundAsset, DesignSystemAsset.Colors.white)
            expectColorEqual(specification.borderAsset, DesignSystemAsset.Colors.coolGray300)
            #expect(specification.iconAsset == nil)
            #expect(specification.iconTintAsset == nil)
        }
    }
}
