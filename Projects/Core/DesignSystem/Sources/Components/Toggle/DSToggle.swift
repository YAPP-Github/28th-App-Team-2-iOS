import SwiftUI

// MARK: - Core Toggle Component
public struct DSToggle: View {
    public struct Specification: Sendable {
        public let size: CGSize
        public let shape: DSComponentShape
        public let backgroundAsset: DesignSystemColors
        
        public let padding: EdgeInsets
        public let handleSize: CGFloat
        public let handleShape: DSComponentShape
        public let handleAsset: DesignSystemColors
    }

    public static func specification(isOn: Bool) -> Specification {
        Specification(
            size: CGSize(width: 53, height: 30),
            shape: .capsule,
            backgroundAsset: isOn
                ? DesignSystemAsset.Colors.primary700
                : DesignSystemAsset.Colors.gray200,
            padding: EdgeInsets(top: 3, leading: 4, bottom: 3, trailing: 4),
            handleSize: 24,
            handleShape: .capsule,
            handleAsset: DesignSystemAsset.Colors.white
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
        .toggleStyle(DSToggleStyle())
        .dsDebugGeometry("DSToggle")
    }
}
