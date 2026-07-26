import SwiftUI

struct DSChipButtonStyle: ButtonStyle {
    let specification: DSChip.Specification

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lineLimit(1)
            .padding(.vertical, specification.verticalPadding)
            .padding(.horizontal, specification.horizontalPadding)
            .foregroundColor(specification.foregroundAsset.swiftUIColor)
            .background(specification.backgroundAsset.swiftUIColor)
            .dsPressedOverlay(
                isPressed: configuration.isPressed,
                shape: specification.shape,
                specification: specification.pressedOverlay
            )
            .clipShape(specification.shape.swiftUIShape)
    }
}
