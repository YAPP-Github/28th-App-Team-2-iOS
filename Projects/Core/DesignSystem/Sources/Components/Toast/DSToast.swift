import SwiftUI

// MARK: - Core Toast Component
public struct DSToast: View {
    public enum Background: Sendable {
        case color(DesignSystemColors)
        case horizontalGradient(
            assets: [DesignSystemColors],
            locations: [CGFloat]
        )
    }

    public struct CloseButtonSpecification: Sendable {
        public let buttonSize: CGFloat
        public let iconFrameSize: CGFloat
        public let iconSize: CGFloat
        public let iconAsset: DSIconAsset
        public let iconColorAsset: DesignSystemColors
        public let pressedOverlay: DSPressedOverlay
    }

    public struct IntrinsicShadowSpecification: Sendable {
        public let colorHex: UInt
        public let opacity: CGFloat
        public let radius: CGFloat
        public let offsetX: CGFloat
        public let offsetY: CGFloat
    }

    public struct Specification: Sendable {
        public let minimumHeight: CGFloat
        public let contentSpacing: CGFloat
        public let leadingPadding: CGFloat
        public let trailingPadding: CGFloat
        public let verticalPadding: CGFloat
        public let fillsAvailableWidth: Bool
        public let shape: DSComponentShape
        public let fontStyle: FontStyle
        public let background: Background
        public let foregroundAsset: DesignSystemColors
        public let closeButton: CloseButtonSpecification?
        public let intrinsicShadow: IntrinsicShadowSpecification?
    }

    public static func specification(variant: DSToastVariant) -> Specification {
        switch variant {
        case .standard:
            Specification(
                minimumHeight: 36,
                contentSpacing: 8,
                leadingPadding: 8,
                trailingPadding: 8,
                verticalPadding: 8,
                fillsAvailableWidth: false,
                shape: .roundedRectangle(cornerRadius: 8),
                fontStyle: .body3Regular,
                background: .color(DesignSystemAsset.Colors.opacity80),
                foregroundAsset: DesignSystemAsset.Colors.gray50,
                closeButton: CloseButtonSpecification(
                    buttonSize: 20,
                    iconFrameSize: 16,
                    iconSize: 13.3333,
                    iconAsset: .closeLine,
                    iconColorAsset: DesignSystemAsset.Colors.gray50,
                    pressedOverlay: .standard
                ),
                intrinsicShadow: nil
            )
        case .compact:
            Specification(
                minimumHeight: 36,
                contentSpacing: 0,
                leadingPadding: 8,
                trailingPadding: 8,
                verticalPadding: 8,
                fillsAvailableWidth: false,
                shape: .roundedRectangle(cornerRadius: 8),
                fontStyle: .body3Regular,
                background: .color(DesignSystemAsset.Colors.opacity80),
                foregroundAsset: DesignSystemAsset.Colors.gray50,
                closeButton: nil,
                intrinsicShadow: nil
            )
        case .luckyAction:
            Specification(
                minimumHeight: 44,
                contentSpacing: 8,
                leadingPadding: 18,
                trailingPadding: 16,
                verticalPadding: 12,
                fillsAvailableWidth: true,
                shape: .roundedRectangle(cornerRadius: 8),
                fontStyle: .body3Regular,
                background: .horizontalGradient(
                    assets: [
                        DesignSystemAsset.Colors.primary600,
                        DesignSystemAsset.Colors.primary800,
                        DesignSystemAsset.Colors.sky600
                    ],
                    locations: [0, 0.5, 1]
                ),
                foregroundAsset: DesignSystemAsset.Colors.gray50,
                closeButton: CloseButtonSpecification(
                    buttonSize: 20,
                    iconFrameSize: 16,
                    iconSize: 13.3333,
                    iconAsset: .closeLine,
                    iconColorAsset: DesignSystemAsset.Colors.whiteOpacity60,
                    pressedOverlay: .standard
                ),
                intrinsicShadow: IntrinsicShadowSpecification(
                    colorHex: 0x9C8AF6,
                    opacity: 0.5,
                    radius: 20,
                    offsetX: 0,
                    offsetY: 0
                )
            )
        }
    }

    private let message: String
    private let variant: DSToastVariant
    private let onClose: (() -> Void)?

    public init(
        _ message: String,
        onClose: @escaping () -> Void
    ) {
        self.message = message
        self.variant = .standard
        self.onClose = onClose
    }

    public init(compact message: String) {
        self.message = message
        self.variant = .compact
        self.onClose = nil
    }

    public init(
        luckyAction message: String,
        onClose: @escaping () -> Void
    ) {
        self.message = message
        self.variant = .luckyAction
        self.onClose = onClose
    }

    private var debugName: String {
        switch variant {
        case .standard:
            "DSToast.Standard"
        case .compact:
            "DSToast.Compact"
        case .luckyAction:
            "DSToast.LuckyAction"
        }
    }

    public var body: some View {
        let specification = Self.specification(variant: variant)

        let toast = HStack(spacing: specification.contentSpacing) {
            Text(message)
                .dsFont(specification.fontStyle)
                .multilineTextAlignment(.leading)
                .foregroundStyle(specification.foregroundAsset.swiftUIColor)
                .frame(
                    maxWidth: specification.fillsAvailableWidth ? .infinity : nil,
                    alignment: .leading
                )
                .layoutPriority(1)

            if let closeButton = specification.closeButton,
               let onClose {
                Button(action: onClose) {
                    DSIcon(
                        closeButton.iconAsset,
                        width: closeButton.iconSize,
                        height: closeButton.iconSize
                    )
                    .foregroundStyle(closeButton.iconColorAsset.swiftUIColor)
                    .frame(
                        width: closeButton.iconFrameSize,
                        height: closeButton.iconFrameSize
                    )
                    .frame(
                        width: closeButton.buttonSize,
                        height: closeButton.buttonSize
                    )
                    .dsDebugDetailGeometry("\(debugName).CloseButton")
                }
                .buttonStyle(
                    DSIconButtonStyle(
                        iconAsset: closeButton.iconAsset,
                        iconSize: CGSize(
                            width: closeButton.iconSize,
                            height: closeButton.iconSize
                        ),
                        pressedOverlay: closeButton.pressedOverlay
                    )
                )
                .accessibilityLabel("닫기")
            }
        }
        .padding(.leading, specification.leadingPadding)
        .padding(.trailing, specification.trailingPadding)
        .padding(.vertical, specification.verticalPadding)
        .frame(
            maxWidth: specification.fillsAvailableWidth ? .infinity : nil,
            minHeight: specification.minimumHeight
        )
        .background {
            background(for: specification)
        }
        .clipShape(specification.shape.swiftUIShape)
        .dsDebugDetailGeometry("\(debugName).Content")

        Group {
            if let intrinsicShadow = specification.intrinsicShadow {
                toast.shadow(
                    color: Color(hex: intrinsicShadow.colorHex).opacity(intrinsicShadow.opacity),
                    radius: intrinsicShadow.radius,
                    x: intrinsicShadow.offsetX,
                    y: intrinsicShadow.offsetY
                )
            } else {
                toast
            }
        }
        .dsDebugGeometry(debugName)
    }

    @ViewBuilder
    private func background(for specification: Specification) -> some View {
        switch specification.background {
        case let .color(asset):
            asset.swiftUIColor
        case let .horizontalGradient(assets, locations):
            LinearGradient(
                stops: zip(
                    assets,
                    locations
                )
                .map { asset, location in
                    Gradient.Stop(color: asset.swiftUIColor, location: location)
                },
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

private extension Color {
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255
        )
    }
}
