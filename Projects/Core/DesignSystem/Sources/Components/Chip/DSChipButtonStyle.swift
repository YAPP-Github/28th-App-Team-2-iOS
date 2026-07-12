import SwiftUI

// MARK: - DSChipButtonStyle
public struct DSChipButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    public init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lineLimit(1)
            .padding(.vertical, DSChip.Layout.verticalPadding)
            .padding(.horizontal, DSChip.Layout.horizontalPadding)
            .foregroundColor(foregroundColor())
            .background(backgroundColor())
            .clipShape(Capsule()) // 피그마 규격 Radius 100px 대응
    }
    
    private func backgroundColor() -> Color {
        DSChip.Theme.bgAsset(isSelected: isSelected).swiftUIColor
    }
    
    private func foregroundColor() -> Color {
        DSChip.Theme.textAsset(isSelected: isSelected).swiftUIColor
    }
}
