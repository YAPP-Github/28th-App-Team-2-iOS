import SwiftUI
import UIKit

struct FortuneMoodCharacterImage: View {
    let moodLevel: FortuneMoodLevel

    var body: some View {
        Image(uiImage: FortuneMoodCharacterAssetResolver.image(for: moodLevel))
            .resizable()
            .scaledToFit()
    }
}

enum FortuneMoodCharacterAssetResolver {
    static func image(
        for moodLevel: FortuneMoodLevel,
        load: (FortuneFeatureImages) -> UIImage? = loadImage
    ) -> UIImage {
        load(asset(for: moodLevel))
            ?? load(asset(for: .level03))
            ?? UIImage()
    }

    static func asset(for moodLevel: FortuneMoodLevel) -> FortuneFeatureImages {
        switch moodLevel {
        case .level01:
            FortuneFeatureAsset.Images.todakiMoodLevel01
        case .level02:
            FortuneFeatureAsset.Images.todakiMoodLevel02
        case .level03:
            FortuneFeatureAsset.Images.todakiMoodLevel03
        case .level04:
            FortuneFeatureAsset.Images.todakiMoodLevel04
        }
    }

    private static func loadImage(_ asset: FortuneFeatureImages) -> UIImage? {
        UIImage(named: asset.name, in: .module, compatibleWith: nil)
    }
}
