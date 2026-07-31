import SwiftUI

public struct DSSingleWheelPicker: View {
    public struct Specification: Sendable {
        public let containerWidth: CGFloat
        public let viewportHeight: CGFloat
        public let rowHeight: CGFloat
        public let selectionHeight: CGFloat
        public let shape: DSComponentShape
        public let selectedFontStyle: FontStyle
        public let adjacentFontStyle: FontStyle
        public let outerFontStyle: FontStyle
        public let selectionBackgroundAsset: DesignSystemColors
        public let selectedForegroundAsset: DesignSystemColors
        public let adjacentForegroundAsset: DesignSystemColors
        public let outerForegroundAsset: DesignSystemColors
    }

    public static func specification() -> Specification {
        Specification(
            containerWidth: 292,
            viewportHeight: 175,
            rowHeight: 34,
            selectionHeight: 47,
            shape: .roundedRectangle(cornerRadius: 8),
            selectedFontStyle: .body1Medium,
            adjacentFontStyle: .body2Regular,
            outerFontStyle: .body3Regular,
            selectionBackgroundAsset: DesignSystemAsset.Colors.primary50,
            selectedForegroundAsset: DesignSystemAsset.Colors.black,
            adjacentForegroundAsset: DesignSystemAsset.Colors.gray700,
            outerForegroundAsset: DesignSystemAsset.Colors.gray400
        )
    }

    private let items: [DSWheelPickerItem]
    @Binding private var selection: Int
    private let accessibilityLabel: String

    public init(
        items: [DSWheelPickerItem],
        selection: Binding<Int>,
        accessibilityLabel: String
    ) {
        precondition(
            Set(items.map(\.value)).count == items.count,
            "DSSingleWheelPicker item values must be unique."
        )

        self.items = items
        self._selection = selection
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        let specification = Self.specification()
        let rendering = DSWheelPickerRenderingConfiguration(
            viewportHeight: specification.viewportHeight,
            rowHeight: specification.rowHeight,
            selectedFontStyle: specification.selectedFontStyle,
            adjacentFontStyle: specification.adjacentFontStyle,
            outerFontStyle: specification.outerFontStyle,
            selectedForegroundAsset: specification.selectedForegroundAsset,
            adjacentForegroundAsset: specification.adjacentForegroundAsset,
            outerForegroundAsset: specification.outerForegroundAsset
        )

        ZStack {
            specification.shape.swiftUIShape
                .fill(specification.selectionBackgroundAsset.swiftUIColor)
                .frame(height: specification.selectionHeight)
                .dsDebugDetailGeometry("DSSingleWheelPicker.Selection")

            DSWheelPickerColumnView(
                items: items,
                selection: $selection,
                accessibilityLabel: accessibilityLabel,
                rendering: rendering,
                directInput: nil,
                isCircular: false
            )
        }
        .frame(
            width: specification.containerWidth,
            height: specification.viewportHeight
        )
        .clipped()
        .dsDebugGeometry("DSSingleWheelPicker")
    }
}
