import SwiftUI

public enum DSImageAsset: String, CaseIterable, Hashable, Sendable {
    case fortuneLogo
    case fortuneSpaceBackground

    public var name: String { rawValue }

    public var image: Image {
        switch self {
        case .fortuneLogo:
            DesignSystemAsset.Images.fortuneLogo.swiftUIImage
        case .fortuneSpaceBackground:
            DesignSystemAsset.Images.fortuneSpaceBackground.swiftUIImage
        }
    }
}
