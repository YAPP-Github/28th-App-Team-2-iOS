import Testing
@testable import DesignSystem

struct DSImageAssetTests {
    @Test("이미지 에셋 이름 목록 매핑 검증")
    func testAssetNames() {
        #expect(
            DSImageAsset.allCases.map(\.name) ==
            [
                "fortuneLogo",
                "fortuneSpaceBackground",
                "fortuneCharacter",
                "fortuneCategoryRelationship",
                "fortuneCategoryLove",
                "fortuneCategoryAchievement",
                "fortuneCategoryHealth",
                "fortuneCategoryMoney",
                "fortuneReadingCompatibility",
                "fortuneReadingDateSelection",
                "fortuneReadingYearly",
                "fortuneLuckyActionBanner"
            ]
        )
    }
}
