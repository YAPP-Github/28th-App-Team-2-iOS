import Testing
@testable import DesignSystem

struct DSIconAssetTests {
    @Test("아이콘 에셋 이름 목록 매핑 검증")
    func testAssetNames() {
        #expect(
            DSIconAsset.allCases.map(\.name) ==
            [
                "addUser",
                "arrowUpward",
                "bell",
                "chatAdd",
                "checkLine",
                "deleteLine",
                "edit",
                "circleInfoLine",
                "circleXFill",
                "chevronLeftPlain",
                "chevronLeftNarrow",
                "chevronSmallRight",
                "logout",
                "mail",
                "moreLine",
                "notes",
                "settings",
                "chevronSmallBottom",
                "tooltipArrow",
                "closeLine",
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
