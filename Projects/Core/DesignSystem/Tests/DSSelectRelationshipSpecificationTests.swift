import Testing
import Model
@testable import DesignSystem

struct DSSelectRelationshipSpecificationTests {
    @Test("Select Relationship 스펙 매핑 검증")
    func testSpecification() {
        let specification = DSSelectRelationship.specification()

        #expect(specification.contentSpacing == 16)
        #expect(specification.optionSpacing == 12)
        #expect(specification.labelFontStyle == .body1Bold)
        expectColorEqual(
            specification.labelForegroundAsset,
            DesignSystemAsset.Colors.black
        )
    }

    @Test("Select Relationship 단일 선택과 재탭 유지 검증")
    func testSelectionResolution() {
        #expect(
            DSSelectRelationship.resolvedSelection(
                current: nil,
                option: .partner,
                isSelected: true
            ) == .partner
        )
        #expect(
            DSSelectRelationship.resolvedSelection(
                current: .partner,
                option: .friend,
                isSelected: true
            ) == .friend
        )
        #expect(
            DSSelectRelationship.resolvedSelection(
                current: .colleague,
                option: .colleague,
                isSelected: false
            ) == .colleague
        )
        #expect(Relationship.partner.dsRelationshipTitle == "연인")
        #expect(Relationship.friend.dsRelationshipTitle == "친구")
        #expect(Relationship.colleague.dsRelationshipTitle == "동료")
    }
}
