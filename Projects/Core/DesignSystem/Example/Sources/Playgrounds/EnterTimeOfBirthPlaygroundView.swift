import SwiftUI
import DesignSystem
import Model

struct EnterTimeOfBirthPlaygroundView: View {
    @State private var selection: BirthTimePeriod?
    @State private var isTimeUnknown = false
    @State private var isSheetPresented = false
    @State private var isDarkBackground = false
    @State private var timeSelection = BirthTimePeriod.inTime.rawValue

    private let timeItems = WheelPickerExampleData.fortuneTimeItems

    private var specification: DSEnterTimeOfBirth.Specification {
        DSEnterTimeOfBirth.specification()
    }

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSEnterTimeOfBirth.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSEnterTimeOfBirth(
                    selection: $selection,
                    isFocused: isSheetPresented,
                    isTimeUnknown: $isTimeUnknown
                ) {
                    isSheetPresented = true
                }
            }

            Form {
                Section(header: Text("Content & State")) {
                    DSSpecificationRow(
                        title: "Selection",
                        value: DSEnterTimeOfBirth.displayTitle(for: selection) ?? "None"
                    )
                    Toggle("Time Unknown", isOn: $isTimeUnknown)
                    Button("Open Fortune Time WheelPicker") {
                        isSheetPresented = true
                    }
                    Button("Clear Selection") {
                        selection = nil
                    }
                }

                Section(header: Text("Figma Specification Check")) {
                    let unknownTimeOption = specification.unknownTimeOption

                    DSSpecificationRow(
                        title: "Content Spacing",
                        value: specification.contentSpacing.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Field Spacing",
                        value: specification.fieldSpacing.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Label Typography",
                        value: specification.labelFontStyle.specName
                    )
                    DSSpecificationRow(
                        title: "Label Color",
                        value: specification.labelForegroundAsset.specDescription
                    )
                    DSSpecificationRow(
                        title: "Unknown Time Option Shape",
                        value: unknownTimeOption.shape.specName
                    )
                    DSSpecificationRow(
                        title: "Unknown Time Option Background",
                        value: unknownTimeOption.backgroundAsset.specDescription
                    )
                    DSSpecificationRow(
                        title: "Unknown Time Option Padding",
                        value: [
                            "H \(unknownTimeOption.horizontalPadding.ptDescription)",
                            "V \(unknownTimeOption.verticalPadding.ptDescription)"
                        ].joined(separator: " · ")
                    )
                    DSSpecificationRow(
                        title: "Unknown Time Option Label Spacing",
                        value: unknownTimeOption.labelSpacing.ptDescription
                    )
                    DSSpecificationRow(
                        title: "Unknown Time Option Typography",
                        value: unknownTimeOption.labelFontStyle.specName
                    )
                    DSSpecificationRow(
                        title: "Unknown Time Option Label Color",
                        value: unknownTimeOption.labelForegroundAsset.specDescription
                    )
                }
            }
        }
        .dsWheelPickerSheet(
            isPresented: $isSheetPresented,
            layout: .single,
            title: "태어난 시각 선택",
            onSave: saveSelection
        ) {
            DSSingleWheelPicker(
                items: timeItems,
                selection: $timeSelection,
                accessibilityLabel: "태어난 시각"
            )
        }
        .navigationTitle("DSEnterTimeOfBirth")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveSelection() {
        selection = BirthTimePeriod(rawValue: timeSelection)
        isSheetPresented = false
    }
}

#Preview {
    NavigationStack {
        EnterTimeOfBirthPlaygroundView()
    }
}
