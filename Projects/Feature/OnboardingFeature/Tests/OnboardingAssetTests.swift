import CoreGraphics
import XCTest
@testable import OnboardingFeature

final class OnboardingAssetTests: XCTestCase {
    func testOnboardingAssetsAreBundledAtFigmaPointSizes() {
        XCTAssertEqual(
            OnboardingFeatureAsset.Brand.onboardingCharacter.image.size,
            CGSize(width: 164, height: 160)
        )
        XCTAssertEqual(
            OnboardingFeatureAsset.Brand.typoLogoColor.image.size,
            CGSize(width: 226, height: 66)
        )
        XCTAssertEqual(
            OnboardingFeatureAsset.Brand.signupLoadingCharacter.image.size,
            CGSize(width: 378, height: 378)
        )
        XCTAssertEqual(
            OnboardingFeatureAsset.Icons.oauthKakao.image.size,
            CGSize(width: 21, height: 20)
        )
        XCTAssertEqual(
            OnboardingFeatureAsset.Icons.oauthGoogle.image.size,
            CGSize(width: 20, height: 20)
        )
        XCTAssertEqual(
            OnboardingFeatureAsset.Icons.oauthApple.image.size,
            CGSize(width: 24, height: 24)
        )
    }
}
