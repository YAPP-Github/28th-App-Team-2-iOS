import SwiftUI
import DesignSystem

struct SingleWheelPickerPlaygroundView: View {
    @State private var selection = 2
    @State private var isDarkBackground = false

    private let items = [
        DSWheelPickerItem(value: 0, title: "자시 (子時): 23:30 ~ 01:29"),
        DSWheelPickerItem(value: 1, title: "축시 (丑時): 01:30 ~ 03:29"),
        DSWheelPickerItem(value: 2, title: "인시 (寅時): 03:30 ~ 05:29"),
        DSWheelPickerItem(value: 3, title: "묘시 (卯時): 05:30 ~ 07:29"),
        DSWheelPickerItem(value: 4, title: "진시 (辰時): 07:30 ~ 09:29"),
        DSWheelPickerItem(value: 5, title: "사시 (巳時): 09:30 ~ 11:29"),
        DSWheelPickerItem(value: 6, title: "오시 (午時): 11:30 ~ 13:29"),
        DSWheelPickerItem(value: 7, title: "미시 (未時): 13:30 ~ 15:29"),
        DSWheelPickerItem(value: 8, title: "신시 (申時): 15:30 ~ 17:29"),
        DSWheelPickerItem(value: 9, title: "유시 (酉時): 17:30 ~ 19:29"),
        DSWheelPickerItem(value: 10, title: "술시 (戌時): 19:30 ~ 21:29"),
        DSWheelPickerItem(value: 11, title: "해시 (亥時): 21:30 ~ 23:29")
    ]

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
