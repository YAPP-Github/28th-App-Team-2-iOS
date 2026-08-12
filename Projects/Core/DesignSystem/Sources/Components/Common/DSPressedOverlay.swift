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

    func dsPressedContentOverlay(
        isPressed: Bool,
        specification: DSPressedOverlay?
    ) -> some View {
        overlay {
            if isPressed,
               let specification {
                specification.asset.swiftUIColor
                    .opacity(specification.opacity)
                    .mask(self)
            }
        }
    }
}

public extension Button {
    /// Applies the shared pressed overlay to a custom button's visible surface.
    ///
    /// Keep additional hit-area expansion outside the button label so the
    /// overlay follows only the supplied visual shape.
    func dsSurfaceButtonStyle(shape: DSComponentShape) -> some View {
        buttonStyle(DSSurfaceButtonStyle(shape: shape))
    }

    /// Applies the shared pressed overlay to the icon pixels of an icon-only button.
    func dsIconButtonStyle(
        _ iconAsset: DSIconAsset,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        buttonStyle(
            DSIconButtonStyle(
                iconAsset: iconAsset,
                iconSize: CGSize(width: width, height: height),
                pressedOverlay: .standard
            )
        )
    }
}

private struct DSSurfaceButtonStyle: ButtonStyle {
    let shape: DSComponentShape

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .dsPressedOverlay(
                isPressed: configuration.isPressed,
                shape: shape,
                specification: isEnabled ? .standard : nil
            )
    }
}

enum DSIconButtonPressedOverlayTarget {
    case icon
    case button
}

struct DSIconButtonStyle: ButtonStyle {
    let iconAsset: DSIconAsset
    let iconSize: CGSize
    let pressedOverlay: DSPressedOverlay?
    let pressedOverlayTarget: DSIconButtonPressedOverlayTarget

    @Environment(\.isEnabled) private var isEnabled

    init(
        iconAsset: DSIconAsset,
        iconSize: CGSize,
        pressedOverlay: DSPressedOverlay?,
        pressedOverlayTarget: DSIconButtonPressedOverlayTarget = .icon
    ) {
        self.iconAsset = iconAsset
        self.iconSize = iconSize
        self.pressedOverlay = pressedOverlay
        self.pressedOverlayTarget = pressedOverlayTarget
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                if isEnabled,
                   configuration.isPressed,
                   let pressedOverlay {
                    switch pressedOverlayTarget {
                    case .icon:
                        DSIcon(
                            iconAsset,
                            width: iconSize.width,
                            height: iconSize.height
                        )
                        .foregroundColor(pressedOverlay.asset.swiftUIColor)
                        .opacity(pressedOverlay.opacity)
                    case .button:
                        Circle()
                            .fill(pressedOverlay.asset.swiftUIColor)
                            .opacity(pressedOverlay.opacity)
                    }
                }
            }
    }
}
