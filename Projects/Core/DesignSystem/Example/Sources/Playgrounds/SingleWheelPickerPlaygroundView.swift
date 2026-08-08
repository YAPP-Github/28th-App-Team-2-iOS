import SwiftUI
import DesignSystem

struct SingleWheelPickerPlaygroundView: View {
    @State private var selection = 2
    @State private var isDarkBackground = false

    private let items = WheelPickerExampleData.fortuneTimeItems

    private var specification: DSSingleWheelPicker.Specification {
        DSSingleWheelPicker.specification()
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSSingleWheelPicker.self),
                height: 260,
                isDarkBackground: $isDarkBackground
            ) {
                DSSingleWheelPicker(
                    items: items,
                    selection: $selection,
                    accessibilityLabel: "태어난 시각"
                )
            }

            Form {
                Section(header: Text("Content & State")) {
                    Picker("Selected Item", selection: $selection) {
                        ForEach(items) { item in
                            Text(item.title)
                                .tag(item.value)
                        }
                    }
                }

                Section(header: Text("Figma Specification Check")) {
                    DSSpecificationRow(
                        title: "Container",
                        value: [
                            specification.containerWidth.ptDescription,
                            specification.viewportHeight.ptDescription
                        ].joined(separator: " × ")
                    )
                    DSSpecificationRow(
                        title: "Row Height",
                        value: specification.rowHeight.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Selection Height",
                        value: specification.selectionHeight.ptDescription
                    )
                    DSSpecificationRow(title: "Shape", value: specification.shape.specName)
                    DSSpecificationRow(
                        title: "Selected Typography",
                        value: specification.selectedFontStyle.specName
                    )
                    DSSpecificationRow(
                        title: "Adjacent Typography",
                        value: specification.adjacentFontStyle.specName
                    )
                    DSSpecificationRow(
                        title: "Outer Typography",
                        value: specification.outerFontStyle.specName
                    )
                    DSSpecificationRow(
                        title: "Selection Background",
                        value: specification.selectionBackgroundAsset.specDescription
                    )
                }
            }
        }
        .navigationTitle("DSSingleWheelPicker")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SingleWheelPickerPlaygroundView()
    }
}
