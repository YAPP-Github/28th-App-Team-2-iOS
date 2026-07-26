import SwiftUI

struct DSButtonStyle: ButtonStyle {
    let specification: DSButton.Specification

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(specification.foregroundAsset.swiftUIColor)
            .padding(.horizontal, specification.horizontalPadding)
            .frame(maxWidth: .infinity)
            .frame(height: specification.height)
            .background(specification.backgroundAsset.swiftUIColor)
            .dsPressedOverlay(
                isPressed: configuration.isPressed,
                shape: specification.shape,
                specification: specification.pressedOverlay
            )
            .clipShape(specification.shape.swiftUIShape)
    }
}
