import SwiftUI

// MARK: - DSBadge Variant
public enum DSBadgeVariant: String, CaseIterable {
    case purple, pink, green, yellow, blue, gray
    
    public var bgAsset: DesignSystemColors {
        switch self {
        case .purple: return DesignSystemAsset.Colors.primary100
        case .pink: return DesignSystemAsset.Colors.pink100
        case .green: return DesignSystemAsset.Colors.teal100
        case .yellow: return DesignSystemAsset.Colors.orange100
        case .blue: return DesignSystemAsset.Colors.sky100
        case .gray: return DesignSystemAsset.Colors.coolGray100
        }
    }
    
    public var textAsset: DesignSystemColors {
        switch self {
        case .purple: return DesignSystemAsset.Colors.primary800
        case .pink: return DesignSystemAsset.Colors.pink800
        case .green: return DesignSystemAsset.Colors.teal800
        case .yellow: return DesignSystemAsset.Colors.orange800
        case .blue: return DesignSystemAsset.Colors.sky800
        case .gray: return DesignSystemAsset.Colors.coolGray500
        }
    }
}
