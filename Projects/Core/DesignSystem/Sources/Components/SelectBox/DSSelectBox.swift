import SwiftUI

// MARK: - Core SelectBox Component
public struct DSSelectBox: View {
    public struct Specification: Sendable {
        public let height: CGFloat
        public let horizontalPadding: CGFloat
        public let borderWidth: CGFloat
        public let shape: DSComponentShape
        public let fontStyle: FontStyle
        public let backgroundAsset: DesignSystemColors
        public let borderAsset: DesignSystemColors
        public let foregroundAsset: DesignSystemColors
    }

    public static func specification(isSelected: Bool) -> Specification {
        Specification(
            height: 48,
            horizontalPadding: 16,
            borderWidth: 1,
            shape: .roundedRectangle(cornerRadius: 12),
            fontStyle: .body1Medium,
            backgroundAsset: isSelected
                ? DesignSystemAsset.Colors.primary50
                : DesignSystemAsset.Colors.white,
            borderAsset: isSelected
                ? DesignSystemAsset.Colors.primary600
                : DesignSystemAsset.Colors.coolGray300,
            foregroundAsset: isSelected
                ? DesignSystemAsset.Colors.primary700
                : DesignSystemAsset.Colors.coolGray800
        )
    }

    private let title: String
    @Binding private var isSelected: Bool

    public init(
        _ title: String,
        isSelected: Binding<Bool>
    ) {
        self.title = title
        self._isSelected = isSelected
    }

    public var body: some View {
        Toggle(isOn: $isSelected) {
            Text(title)
        }
        .toggleStyle(DSSelectBoxStyle())
        .dsDebugGeometry("DSSelectBox")
    }
}
