import Testing
@testable import DesignSystem

struct DSSajuPillarCellSpecificationTests {
    private static let expectedAssets: [DSSajuElement: DesignSystemColors] = [
        .wood: DesignSystemAsset.Colors.teal200,
        .fire: DesignSystemAsset.Colors.red200,
        .earth: DesignSystemAsset.Colors.orange200,
        .metal: DesignSystemAsset.Colors.coolGray300,
        .water: DesignSystemAsset.Colors.sky200,
        .unknown: DesignSystemAsset.Colors.gray100
    ]

    @Test("SajuPillarCell 스펙 매핑 검증", arguments: [DSSajuElement.wood, .fire, .earth, .metal, .water, .unknown])
    func testSpecifications(element: DSSajuElement) throws {
        let specification = DSSajuPillarCell.specification(element: element)
        let expectedBackground = try #require(Self.expectedAssets[element])

        #expect(specification.size == 48)
        #expect(specification.shape == .roundedRectangle(cornerRadius: 12))
        expectColorEqual(specification.backgroundAsset, expectedBackground)
        expectColorEqual(specification.foregroundAsset, DesignSystemAsset.Colors.gray975)
    }

    @Test("Hanja로부터 오행 파싱 검증")
    func testHanjaElementParsing() {
        #expect(DSSajuElement.from(hanja: "甲") == .wood)
        #expect(DSSajuElement.from(hanja: "丙") == .fire)
        #expect(DSSajuElement.from(hanja: "戊") == .earth)
        #expect(DSSajuElement.from(hanja: "庚") == .metal)
        #expect(DSSajuElement.from(hanja: "壬") == .water)
    }
}
