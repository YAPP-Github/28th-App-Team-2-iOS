import SwiftUI

public struct DSMultiWheelPicker: View {
    public struct Specification: Sendable {
        public let containerWidth: CGFloat
        public let viewportHeight: CGFloat
        public let rowHeight: CGFloat
        public let selectionHeight: CGFloat
        public let columnWidths: [CGFloat]
        public let columnGap: CGFloat
        public let shape: DSComponentShape
        public let selectedFontStyle: FontStyle
        public let adjacentFontStyle: FontStyle
        public let outerFontStyle: FontStyle
        public let selectionBackgroundAsset: DesignSystemColors
        public let selectedForegroundAsset: DesignSystemColors
        public let adjacentForegroundAsset: DesignSystemColors
        public let outerForegroundAsset: DesignSystemColors
    }

    public static func specification(
        layout: DSMultiWheelPickerLayout
    ) -> Specification {
        let viewportHeight: CGFloat
        let columnWidths: [CGFloat]
        let columnGap: CGFloat

        switch layout {
        case .time:
            viewportHeight = 165
            columnWidths = [40, 40]
            columnGap = 64
        case .date:
            viewportHeight = 178
            columnWidths = [60, 40, 40]
            columnGap = 40
        }

        return Specification(
            containerWidth: 292,
            viewportHeight: viewportHeight,
            rowHeight: 34,
            selectionHeight: 50,
            columnWidths: columnWidths,
            columnGap: columnGap,
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

    private let layout: DSMultiWheelPickerLayout
    private let columns: [DSWheelPickerColumn]
    @State private var activeInputColumnIndex: Int?

    public init(
        layout: DSMultiWheelPickerLayout,
        columns: [DSWheelPickerColumn]
    ) {
        let expectedColumnCount = Self.specification(layout: layout).columnWidths.count
        precondition(
            columns.count == expectedColumnCount,
            "DSMultiWheelPicker \(layout) layout requires \(expectedColumnCount) columns."
        )

        self.layout = layout
        self.columns = columns
    }

    public var body: some View {
        let specification = Self.specification(layout: layout)
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
                .dsDebugDetailGeometry("DSMultiWheelPicker.Selection")

            HStack(spacing: specification.columnGap) {
                ForEach(Array(columns.enumerated()), id: \.offset) { index, column in
                    DSWheelPickerColumnView(
                        items: column.items,
                        selection: column.selection,
                        accessibilityLabel: column.accessibilityLabel,
                        rendering: rendering,
                        directInput: directInputConfiguration(for: index),
                        isCircular: column.isCircular
                    )
                    .frame(width: specification.columnWidths[index])
                    .id("\(String(describing: layout)).\(column.accessibilityLabel)")
                }
            }
        }
        .frame(
            width: specification.containerWidth,
            height: specification.viewportHeight
        )
        .clipped()
        .dsDebugGeometry("DSMultiWheelPicker.\(String(describing: layout))")
    }

    private func directInputConfiguration(
        for columnIndex: Int
    ) -> DSWheelPickerDirectInputConfiguration? {
        guard let maximumDigits = DSWheelPickerDirectInputPolicy.maximumDigits(
            for: layout,
            columnIndex: columnIndex
        ) else {
            return nil
        }

        return DSWheelPickerDirectInputConfiguration(
            maximumDigits: maximumDigits,
            columnIndex: columnIndex,
            nextColumnIndex: DSWheelPickerDirectInputPolicy.nextColumnIndex(
                for: layout,
                columnIndex: columnIndex,
                columnCount: columns.count
            ),
            activeColumnIndex: $activeInputColumnIndex
        )
    }
}
