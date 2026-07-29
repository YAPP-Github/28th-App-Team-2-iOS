import SwiftUI

public struct DSTab: View {
    public struct Specification: Sendable {
        public let shape: DSComponentShape
        public let padding: EdgeInsets

        public let backgroundAsset: DesignSystemColors
        public let textFont: FontStyle
        public let textColor: DesignSystemColors
        public let pressedOverlay: DSPressedOverlay
    }

    public static func specification(isOn: Bool) -> Specification {
        Specification(
            shape: .capsule,
            padding: EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16),
            backgroundAsset: isOn ? DesignSystemAsset.Colors.gray975 : DesignSystemAsset.Colors.coolGray100,
            textFont: isOn ? .body2Medium : .body2Regular,
            textColor: isOn ? DesignSystemAsset.Colors.white : DesignSystemAsset.Colors.coolGray500,
            pressedOverlay: .standard
        )
    }

    private let title: String
    private let isOn: Bool
    private let action: () -> Void

    public init(_ title: String, isOn: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isOn = isOn
        self.action = action
    }

    public var body: some View {
        let spec = Self.specification(isOn: isOn)

        Button(action: action) {
            Text(title)
                .dsFont(spec.textFont)
                .lineLimit(1)
                .foregroundColor(spec.textColor.swiftUIColor)
                .padding(spec.padding)
                .background(
                    spec.shape.swiftUIShape
                        .fill(spec.backgroundAsset.swiftUIColor)
                )
        }
        .buttonStyle(DSTabButtonStyle(specification: spec))
        .dsDebugGeometry("DSTab")
    }
}
