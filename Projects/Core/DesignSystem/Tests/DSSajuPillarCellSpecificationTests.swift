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

    @Test("10천간 12지지 전체 22자 오행 파싱 검증")
    func testAll22HanjaElementParsing() {
        // 목 (Wood): 甲, 乙, 寅, 卯
        #expect(DSSajuElement.from(hanja: "甲") == .wood)
        #expect(DSSajuElement.from(hanja: "乙") == .wood)
        #expect(DSSajuElement.from(hanja: "寅") == .wood)
        #expect(DSSajuElement.from(hanja: "卯") == .wood)

        // 화 (Fire): 丙, 丁, 巳, 午
        #expect(DSSajuElement.from(hanja: "丙") == .fire)
        #expect(DSSajuElement.from(hanja: "丁") == .fire)
        #expect(DSSajuElement.from(hanja: "巳") == .fire)
        #expect(DSSajuElement.from(hanja: "午") == .fire)

        // 토 (Earth): 戊, 己, 辰, 戌, 丑, 未
        #expect(DSSajuElement.from(hanja: "戊") == .earth)
        #expect(DSSajuElement.from(hanja: "己") == .earth)
        #expect(DSSajuElement.from(hanja: "辰") == .earth)
        #expect(DSSajuElement.from(hanja: "戌") == .earth)
        #expect(DSSajuElement.from(hanja: "丑") == .earth)
        #expect(DSSajuElement.from(hanja: "未") == .earth)

        // 금 (Metal): 庚, 辛, 申, 酉
        #expect(DSSajuElement.from(hanja: "庚") == .metal)
        #expect(DSSajuElement.from(hanja: "辛") == .metal)
        #expect(DSSajuElement.from(hanja: "申") == .metal)
        #expect(DSSajuElement.from(hanja: "酉") == .metal)

        // 수 (Water): 壬, 癸, 亥, 子
        #expect(DSSajuElement.from(hanja: "壬") == .water)
        #expect(DSSajuElement.from(hanja: "癸") == .water)
        #expect(DSSajuElement.from(hanja: "亥") == .water)
        #expect(DSSajuElement.from(hanja: "子") == .water)

        // 알 수 없는 한자 fallback
        #expect(DSSajuElement.from(hanja: "天") == .unknown)
        #expect(DSSajuElement.from(hanja: "") == .unknown)
    }

    @Test("텍스트 오행 코드 파싱 검증")
    func testTextElementParsing() {
        #expect(DSSajuElement.from(text: "WOOD") == .wood)
        #expect(DSSajuElement.from(text: "목") == .wood)
        #expect(DSSajuElement.from(text: "FIRE") == .fire)
        #expect(DSSajuElement.from(text: "화") == .fire)
        #expect(DSSajuElement.from(text: "EARTH") == .earth)
        #expect(DSSajuElement.from(text: "토") == .earth)
        #expect(DSSajuElement.from(text: "METAL") == .metal)
        #expect(DSSajuElement.from(text: "금") == .metal)
        #expect(DSSajuElement.from(text: "WATER") == .water)
        #expect(DSSajuElement.from(text: "수") == .water)
        #expect(DSSajuElement.from(text: "UNKNOWN") == .unknown)
    }

    @Test("음양 기호 계산 검증")
    func testYinYangSign() {
        #expect(DSSajuPillarCell.yinYangSign(for: "甲") == "+")
        #expect(DSSajuPillarCell.yinYangSign(for: "乙") == "-")
        #expect(DSSajuPillarCell.yinYangSign(for: "子") == "+")
        #expect(DSSajuPillarCell.yinYangSign(for: "丑") == "-")
    }
}
