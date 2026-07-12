import SwiftUI

// MARK: - Core Badge Component
public struct DSBadge: View {
    public enum Layout {
        public static let verticalPadding: CGFloat = 3
        public static let horizontalPadding: CGFloat = 6
        public static let cornerRadius: CGFloat = 6
        public static let defaultGap: CGFloat = 10
    }
    
    public enum Theme {
        public static let fontStyle: FontStyle = .caption2SemiBold
    }

    private let title: String
    private let variant: DSBadgeVariant
    
    public init(_ title: String, variant: DSBadgeVariant) {
        self.title = title
        self.variant = variant
    }
    
    public var body: some View {
        Text(title)
            .dsFont(Theme.fontStyle)
            .lineLimit(1)
            .padding(.vertical, Layout.verticalPadding)
            .padding(.horizontal, Layout.horizontalPadding)
            .foregroundColor(variant.textAsset.swiftUIColor)
            .background(variant.bgAsset.swiftUIColor)
            .cornerRadius(Layout.cornerRadius)
    }
}
