import SwiftUI

struct DSButtonStyle: ButtonStyle {
    let variant: DSButtonVariant
    let size: DSButtonSize
    
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        let specification = DSButton.specification(
            variant: variant,
            size: size,
            isEnabled: isEnabled
        )

        configuration.label
            .dsFont(specification.fontStyle)
            .foregroundColor(specification.foregroundAsset.swiftUIColor)
            .frame(height: specification.height)
            .padding(.horizontal, specification.horizontalPadding)
            .background(specification.backgroundAsset.swiftUIColor)
            .clipShape(specification.shape.swiftUIShape)
    }
}
