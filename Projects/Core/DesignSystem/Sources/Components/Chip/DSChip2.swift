import SwiftUI

// MARK: - Core Chip2 Component
public struct DSChip2: View {
    public enum Layout {
        public static let verticalPadding: CGFloat = 5
        public static let horizontalPadding: CGFloat = 10
        public static let cornerRadius: CGFloat = 100
        public static let defaultGap: CGFloat = 10
    }
    
    public enum Theme {
        public static let bgAsset: DesignSystemColors = DesignSystemAsset.Colors.primary700
        public static let textAsset: DesignSystemColors = DesignSystemAsset.Colors.white
        public static let fontStyle: FontStyle = .body3Medium
    }

    private let title: String
    private let action: () -> Void
    
    public init(
        _ title: String,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .dsFont(Theme.fontStyle)
        }
        .buttonStyle(DSChip2Style())
    }
}
