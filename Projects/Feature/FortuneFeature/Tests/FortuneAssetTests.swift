import CoreGraphics
import Testing
@testable import FortuneFeature

struct FortuneAssetTests {
    @Test("Fortune 에셋이 Figma 표시 크기로 번들된다")
    func assetsAreBundledAtFigmaPointSizes() {
        #expect(
            FortuneFeatureAsset.Images.fortuneCategoryAchievement.image.size
                == CGSize(width: 45, height: 48)
        )
        #expect(
            FortuneFeatureAsset.Images.fortuneCategoryHealth.image.size
                == CGSize(width: 48, height: 48)
        )
        #expect(
            FortuneFeatureAsset.Images.fortuneCategoryLove.image.size
                == CGSize(width: 48, height: 48)
        )
        #expect(
            FortuneFeatureAsset.Images.fortuneCategoryMoney.image.size
                == CGSize(width: 48, height: 48)
        )
        #expect(
            FortuneFeatureAsset.Images.fortuneCategoryRelationship.image.size
                == CGSize(width: 48, height: 48)
        )
        #expect(
            FortuneFeatureAsset.Images.fortuneLuckyActionBanner.image.size
                == CGSize(width: 353, height: 100)
        )
        #expect(
            FortuneFeatureAsset.Images.fortuneReadingCompatibility.image.size
                == CGSize(width: 24, height: 24)
        )
        #expect(
            FortuneFeatureAsset.Images.fortuneReadingDateSelection.image.size
                == CGSize(width: 24, height: 24)
        )
        #expect(
            FortuneFeatureAsset.Images.fortuneReadingYearly.image.size
                == CGSize(width: 24, height: 24)
        )
    }
}
