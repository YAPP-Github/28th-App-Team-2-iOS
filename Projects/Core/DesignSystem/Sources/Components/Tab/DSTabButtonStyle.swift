import SwiftUI

struct DSTabButtonStyle: ButtonStyle {
    let specification: DSTab.Specification

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .dsPressedOverlay(
                isPressed: configuration.isPressed,
                shape: specification.shape,
                specification: specification.pressedOverlay
            )
            .clipShape(specification.shape.swiftUIShape)
    }
}
