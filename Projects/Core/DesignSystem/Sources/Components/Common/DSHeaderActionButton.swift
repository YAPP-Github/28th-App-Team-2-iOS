import SwiftUI

struct DSHeaderActionButton: View {
    let icon: DSIconAsset
    let action: () -> Void
    let iconSize: CGSize
    let tintAsset: DesignSystemColors
    let pressedOverlay: DSPressedOverlay

    var body: some View {
        Button(action: action) {
            DSIcon(
                icon,
                width: iconSize.width,
                height: iconSize.height
            )
            .foregroundColor(tintAsset.swiftUIColor)
        }
        .buttonStyle(
            DSIconButtonStyle(
                iconAsset: icon,
                iconSize: iconSize,
                pressedOverlay: pressedOverlay
            )
        )
    }
}
