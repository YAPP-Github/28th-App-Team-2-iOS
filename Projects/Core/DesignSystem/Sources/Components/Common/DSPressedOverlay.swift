import SwiftUI

public struct DSPressedOverlay: Sendable {
    public let asset: DesignSystemColors
    public let opacity: CGFloat

    static let standard = DSPressedOverlay(
        asset: DesignSystemAsset.Colors.gray975,
        opacity: 0.16
    )

    private init(asset: DesignSystemColors, opacity: CGFloat) {
        self.asset = asset
        self.opacity = opacity
    }
}

extension View {
    func dsPressedOverlay(
        isPressed: Bool,
        shape: DSComponentShape,
        specification: DSPressedOverlay?
    ) -> some View {
        overlay {
            if isPressed,
               let specification {
                shape.swiftUIShape
                    .fill(specification.asset.swiftUIColor)
                    .opacity(specification.opacity)
            }
        }
    }
}

struct DSIconButtonStyle: ButtonStyle {
    let iconAsset: DSIconAsset
    let iconSize: CGSize
    let pressedOverlay: DSPressedOverlay?

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                if configuration.isPressed,
                   let pressedOverlay {
                    DSIcon(
                        iconAsset,
                        width: iconSize.width,
                        height: iconSize.height
                    )
                    .foregroundColor(pressedOverlay.asset.swiftUIColor)
                    .opacity(pressedOverlay.opacity)
                }
            }
    }
}
