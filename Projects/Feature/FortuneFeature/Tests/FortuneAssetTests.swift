import CoreGraphics
import XCTest
@testable import FortuneFeature

final class FortuneAssetTests: XCTestCase {
    func testFortuneAssetsAreBundledAtFigmaPointSizes() {
        XCTAssertEqual(
            FortuneFeatureAsset.Images.fortuneCharacter.image.size,
            CGSize(width: 109, height: 102)
        )
        XCTAssertEqual(
            FortuneFeatureAsset.Images.fortuneCategoryAchievement.image.size,
            CGSize(width: 45, height: 48)
        )
        XCTAssertEqual(
            FortuneFeatureAsset.Images.fortuneCategoryHealth.image.size,
            CGSize(width: 48, height: 48)
        )
        XCTAssertEqual(
            FortuneFeatureAsset.Images.fortuneCategoryLove.image.size,
            CGSize(width: 48, height: 48)
        )
        XCTAssertEqual(
            FortuneFeatureAsset.Images.fortuneCategoryMoney.image.size,
            CGSize(width: 48, height: 48)
        )
        XCTAssertEqual(
            FortuneFeatureAsset.Images.fortuneCategoryRelationship.image.size,
            CGSize(width: 48, height: 48)
        )
        XCTAssertEqual(
            FortuneFeatureAsset.Images.fortuneLuckyActionBanner.image.size,
            CGSize(width: 353, height: 100)
        )
        XCTAssertEqual(
            FortuneFeatureAsset.Images.fortuneReadingCompatibility.image.size,
            CGSize(width: 24, height: 24)
        )
        XCTAssertEqual(
            FortuneFeatureAsset.Images.fortuneReadingDateSelection.image.size,
            CGSize(width: 24, height: 24)
        )
        XCTAssertEqual(
            FortuneFeatureAsset.Images.fortuneReadingYearly.image.size,
            CGSize(width: 24, height: 24)
        )
    }
}
