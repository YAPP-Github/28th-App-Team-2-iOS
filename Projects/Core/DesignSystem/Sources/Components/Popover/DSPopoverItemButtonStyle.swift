import SwiftUI

struct DSPopoverItemButtonStyle: ButtonStyle {
    let specification: DSPopover.Specification

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(specification.foregroundAsset.swiftUIColor)
            .frame(
                minWidth: specification.minimumItemWidth,
                minHeight: specification.itemHeight,
                alignment: .leading
            )
            .background(specification.backgroundAsset.swiftUIColor)
            .dsPressedOverlay(
                isPressed: configuration.isPressed,
                shape: specification.itemShape,
                specification: specification.pressedOverlay
            )
            .clipShape(specification.itemShape.swiftUIShape)
    }
}
