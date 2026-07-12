import SwiftUI

// MARK: - Core Chip Component
public struct DSChip: View {
    public enum Layout {
        public static let verticalPadding: CGFloat = 12
        public static let horizontalPadding: CGFloat = 20
        public static let cornerRadius: CGFloat = 100
        public static let defaultGap: CGFloat = 10
    }
    
    public enum Theme {
        public static func bgAsset(isSelected: Bool) -> DesignSystemColors {
            return isSelected ? DesignSystemAsset.Colors.primary500 : DesignSystemAsset.Colors.gray25
        }
        
        public static func textAsset(isSelected: Bool) -> DesignSystemColors {
            return isSelected ? DesignSystemAsset.Colors.white : DesignSystemAsset.Colors.coolGray700
        }
        
        public static func fontStyle(isSelected: Bool) -> FontStyle {
            return isSelected ? .body2SemiBold : .body2Medium
        }
    }

    private let title: String
    private let isSelected: Bool
    private let action: () -> Void
    
    public init(
        _ title: String,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .dsFont(Theme.fontStyle(isSelected: isSelected))
        }
        .buttonStyle(DSChipButtonStyle(isSelected: isSelected))
    }
}
