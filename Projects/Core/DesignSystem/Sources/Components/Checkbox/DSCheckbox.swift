import SwiftUI

// MARK: - Core Checkbox Component
public struct DSCheckbox: View {
    public struct Specification: Sendable {
        public let size: CGFloat
        public let borderWidth: CGFloat?
        public let iconSize: CGFloat?
        public let shape: DSComponentShape
        public let backgroundAsset: DesignSystemColors
        public let borderAsset: DesignSystemColors?
        public let iconAsset: DesignSystemImages?
        public let iconTintAsset: DesignSystemColors?
    }

    public static func specification(isOn: Bool) -> Specification {
        Specification(
            size: 20,
            borderWidth: isOn ? nil : 1,
            iconSize: isOn ? 16 : nil,
            shape: .roundedRectangle(cornerRadius: 6),
            backgroundAsset: isOn
                ? DesignSystemAsset.Colors.primary600
                : DesignSystemAsset.Colors.white,
            borderAsset: isOn ? nil : DesignSystemAsset.Colors.coolGray300,
            iconAsset: isOn ? DesignSystemAsset.Icons.checkLine : nil,
            iconTintAsset: isOn ? DesignSystemAsset.Colors.white : nil
        )
    }

    @Binding private var isOn: Bool

    public init(isOn: Binding<Bool>) {
        self._isOn = isOn
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            EmptyView()
        }
        .toggleStyle(DSCheckboxStyle())
        .dsDebugGeometry("DSCheckbox")
    }
}
