import SwiftUI

// MARK: - DSChip2Style
public struct DSChip2Style: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lineLimit(1)
            .padding(.vertical, DSChip2.Layout.verticalPadding)
            .padding(.horizontal, DSChip2.Layout.horizontalPadding)
            .foregroundColor(DSChip2.Theme.textAsset.swiftUIColor)
            .background(DSChip2.Theme.bgAsset.swiftUIColor)
            .clipShape(Capsule())
    }
}
