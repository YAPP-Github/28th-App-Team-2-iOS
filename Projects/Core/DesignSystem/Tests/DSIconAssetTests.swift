import Testing
@testable import DesignSystem

struct DSIconAssetTests {
    @Test("아이콘 에셋 이름 목록 매핑 검증")
    func testAssetNames() {
        #expect(
            DSIconAsset.allCases.map(\.name) ==
            [
                "bell",
                "chatAdd",
                "checkLine",
                "deleteLine",
                "edit",
                "circleXFill",
                "chevronLeftPlain",
                "chevronLeftNarrow",
                "notes",
                "chevronSmallBottom",
                "tooltipArrow",
                "closeLine",
                "arrowUpward",
                "delete",
                "naviLuckyOn",
                "naviLuckyOff",
                "naviAiOn",
                "naviAiOff",
                "naviActionOn",
                "naviActionOff",
                "naviMyOn",
                "naviMyOff"
            ]
        )
    }
}
