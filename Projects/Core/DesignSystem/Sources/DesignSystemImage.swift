import SwiftUI

public enum DSImageAsset: String, CaseIterable, Hashable, Sendable {
    case fortuneLogo
    case fortuneSpaceBackground
    case fortuneCharacter
    case fortuneCategoryRelationship
    case fortuneCategoryLove
    case fortuneCategoryAchievement
    case fortuneCategoryHealth
    case fortuneCategoryMoney
    case fortuneReadingCompatibility
    case fortuneReadingDateSelection
    case fortuneReadingYearly
    case fortuneLuckyActionBanner

    public var name: String { rawValue }

    public var image: Image {
        switch self {
        case .fortuneLogo:
            DesignSystemAsset.Images.fortuneLogo.swiftUIImage
        case .fortuneSpaceBackground:
            DesignSystemAsset.Images.fortuneSpaceBackground.swiftUIImage
        case .fortuneCharacter:
            DesignSystemAsset.Images.fortuneCharacter.swiftUIImage
        case .fortuneCategoryRelationship:
            DesignSystemAsset.Images.fortuneCategoryRelationship.swiftUIImage
        case .fortuneCategoryLove:
            DesignSystemAsset.Images.fortuneCategoryLove.swiftUIImage
        case .fortuneCategoryAchievement:
            DesignSystemAsset.Images.fortuneCategoryAchievement.swiftUIImage
        case .fortuneCategoryHealth:
            DesignSystemAsset.Images.fortuneCategoryHealth.swiftUIImage
        case .fortuneCategoryMoney:
            DesignSystemAsset.Images.fortuneCategoryMoney.swiftUIImage
        case .fortuneReadingCompatibility:
            DesignSystemAsset.Images.fortuneReadingCompatibility.swiftUIImage
        case .fortuneReadingDateSelection:
            DesignSystemAsset.Images.fortuneReadingDateSelection.swiftUIImage
        case .fortuneReadingYearly:
            DesignSystemAsset.Images.fortuneReadingYearly.swiftUIImage
        case .fortuneLuckyActionBanner:
            DesignSystemAsset.Images.fortuneLuckyActionBanner.swiftUIImage
        }
    }
}
